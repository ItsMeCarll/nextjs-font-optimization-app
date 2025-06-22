# Video Downloader Backend

This is the FastAPI backend for the Video Downloader app.

## Features
- APIs for downloading videos from multiple platforms
- Video and audio processing with FFmpeg
- Integration with Firebase for authentication and Firestore database
- Cloudinary for media storage
- OpenAI Whisper for transcription services

## Setup
1. Create a virtual environment and install dependencies:
   ```
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```
2. Configure Firebase, Cloudinary, and OpenAI credentials in environment variables or config files.
3. Run the server:
   ```
   uvicorn main:app --reload
   ```

## Project Structure
- main.py: FastAPI app entry point
- services/: video download and processing logic
- auth/: Firebase authentication handlers
- utils/: helper functions

## Deployment
- Recommended platforms: Render, Railway
