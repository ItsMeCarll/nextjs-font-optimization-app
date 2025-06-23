import os
import zipfile

def zip_current_directory():
    # Ruta absoluta al directorio donde está este script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    zip_filename = os.path.basename(script_dir) + ".zip"
    zip_path = os.path.join(script_dir, zip_filename)

    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for foldername, subfolders, filenames in os.walk(script_dir):
            for filename in filenames:
                if filename == zip_filename:
                    continue  # Evita incluir el propio .zip
                file_path = os.path.join(foldername, filename)
                arcname = os.path.relpath(file_path, script_dir)  # Relativo al script_dir
                zipf.write(file_path, arcname)

    print(f"Carpeta comprimida como: {zip_path}")

if __name__ == "__main__":
    zip_current_directory()
