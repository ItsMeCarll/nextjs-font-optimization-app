from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, HttpUrl
from typing import List, Optional, Dict
import yt_dlp
import os
import shutil
import asyncio
import aiohttp
import whisper
import json
from datetime import datetime

app = FastAPI(title="Video Downloader API")

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Modelos
class VideoRequest(BaseModel):
    url: HttpUrl
    format: Optional[str] = "mp4"
    quality: Optional[str] = "720p"
    extract_audio: Optional[bool] = False

class SearchRequest(BaseModel):
    query: str
    platform: Optional[str] = None
    category: Optional[str] = None
    filters: Optional[Dict] = None

# Configuración de yt-dlp
YDL_OPTS = {
    'format': 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best',
    'outtmpl': 'downloads/%(title)s.%(ext)s',
    'quiet': True,
    'no_warnings': True,
    'extract_flat': True,
}

# Almacenamiento en memoria de las descargas activas
active_downloads = {}

# Rutas
@app.get("/")
async def root():
    return {"message": "Video Downloader Backend is running"}

@app.get("/video_info")
async def get_video_info(url: HttpUrl):
    try:
        with yt_dlp.YoutubeDL(YDL_OPTS) as ydl:
            info = ydl.extract_info(str(url), download=False)
            
            formats = []
            for f in info.get('formats', []):
                if f.get('vcodec') != 'none':
                    formats.append({
                        'format_id': f.get('format_id'),
                        'ext': f.get('ext'),
                        'resolution': f.get('resolution'),
                        'filesize': f.get('filesize'),
                        'vcodec': f.get('vcodec'),
                        'acodec': f.get('acodec'),
                        'url': f.get('url'),
                    })

            return {
                'id': info.get('id'),
                'title': info.get('title'),
                'description': info.get('description'),
                'thumbnail': info.get('thumbnail'),
                'duration': info.get('duration'),
                'view_count': info.get('view_count'),
                'uploader': info.get('uploader'),
                'formats': formats,
                'subtitles': info.get('subtitles', {}),
                'automatic_captions': info.get('automatic_captions', {}),
            }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/download")
async def download_video(video: VideoRequest, background_tasks: BackgroundTasks):
    try:
        download_id = datetime.now().strftime('%Y%m%d%H%M%S')
        
        # Configurar opciones de descarga
        opts = YDL_OPTS.copy()
        if video.extract_audio:
            opts.update({
                'format': 'bestaudio/best',
                'postprocessors': [{
                    'key': 'FFmpegExtractAudio',
                    'preferredcodec': 'mp3',
                    'preferredquality': '192',
                }],
            })
        else:
            format_str = f'bestvideo[height<={video.quality[:-1]}]+bestaudio/best[height<={video.quality[:-1]}]'
            opts.update({'format': format_str})

        # Iniciar descarga en segundo plano
        background_tasks.add_task(
            download_in_background,
            str(video.url),
            download_id,
            opts
        )

        return {"download_id": download_id, "status": "started"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/download/{download_id}")
async def get_download_status(download_id: str):
    if download_id not in active_downloads:
        raise HTTPException(status_code=404, detail="Download not found")
    return active_downloads[download_id]

@app.post("/search")
async def search_videos(search: SearchRequest):
    try:
        with yt_dlp.YoutubeDL(YDL_OPTS) as ydl:
            # Construir la URL de búsqueda según la plataforma
            if search.platform == "youtube":
                search_url = f"ytsearch10:{search.query}"
            elif search.platform == "facebook":
                search_url = f"fbsearch10:{search.query}"
            else:
                search_url = f"ytsearch10:{search.query}"

            results = ydl.extract_info(search_url, download=False)
            videos = []

            for entry in results['entries']:
                if entry:
                    videos.append({
                        'id': entry.get('id'),
                        'title': entry.get('title'),
                        'thumbnail': entry.get('thumbnail'),
                        'duration': entry.get('duration'),
                        'uploader': entry.get('uploader'),
                    })

            return {"results": videos}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/transcribe/{video_id}")
async def transcribe_video(video_id: str):
    try:
        # Cargar modelo de Whisper
        model = whisper.load_model("base")
        
        # Obtener el archivo de audio
        audio_path = f"downloads/{video_id}.mp3"
        if not os.path.exists(audio_path):
            raise HTTPException(status_code=404, detail="Audio file not found")

        # Transcribir
        result = model.transcribe(audio_path)
        
        return {"transcription": result["text"]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/subtitles/{video_id}")
async def get_subtitles(video_id: str, language: Optional[str] = None):
    try:
        with yt_dlp.YoutubeDL(YDL_OPTS) as ydl:
            info = ydl.extract_info(f"https://youtube.com/watch?v={video_id}", download=False)
            
            subtitles = info.get('subtitles', {})
            if language:
                return {language: subtitles.get(language, {})}
            return subtitles
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# Función de descarga en segundo plano
async def download_in_background(url: str, download_id: str, opts: dict):
    try:
        active_downloads[download_id] = {"status": "downloading", "progress": 0}
        
        def progress_hook(d):
            if d['status'] == 'downloading':
                total = d.get('total_bytes') or d.get('total_bytes_estimate', 0)
                if total > 0:
                    downloaded = d.get('downloaded_bytes', 0)
                    progress = (downloaded / total) * 100
                    active_downloads[download_id]["progress"] = progress

        opts['progress_hooks'] = [progress_hook]
        
        with yt_dlp.YoutubeDL(opts) as ydl:
            ydl.download([url])
            
        active_downloads[download_id] = {"status": "completed", "progress": 100}
    except Exception as e:
        active_downloads[download_id] = {"status": "failed", "error": str(e)}

# Limpiar descargas completadas periódicamente
@app.on_event("startup")
async def startup_event():
    if not os.path.exists("downloads"):
        os.makedirs("downloads")

@app.on_event("shutdown")
async def shutdown_event():
    if os.path.exists("downloads"):
        shutil.rmtree("downloads")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
