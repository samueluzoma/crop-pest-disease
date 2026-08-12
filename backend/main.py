from io import BytesIO
from pathlib import Path

import numpy as np
import tensorflow as tf
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image

MODEL_DIR = Path(__file__).parent / "model"
INPUT_SIZE = 224
MEAN = 127.5
STD = 127.5

app = FastAPI(title="Crop Pest Insect Detection API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

interpreter = tf.lite.Interpreter(model_path=str(MODEL_DIR / "model_unquant.tflite"))
interpreter.allocate_tensors()
_input_details = interpreter.get_input_details()
_output_details = interpreter.get_output_details()

labels = [
    line.strip()
    for line in (MODEL_DIR / "labels.txt").read_text().splitlines()
    if line.strip()
]


@app.get("/health")
def health() -> dict:
    return {"status": "ok", "labels": labels}


@app.post("/predict")
async def predict(file: UploadFile = File(...)) -> dict:
    raw = await file.read()
    try:
        image = Image.open(BytesIO(raw)).convert("RGB")
    except Exception as exc:
        raise HTTPException(status_code=400, detail=f"Invalid image: {exc}")

    resized = image.resize((INPUT_SIZE, INPUT_SIZE))
    array = np.asarray(resized, dtype=np.float32)
    array = (array - MEAN) / STD
    input_tensor = np.expand_dims(array, axis=0)

    interpreter.set_tensor(_input_details[0]["index"], input_tensor)
    interpreter.invoke()
    output = interpreter.get_tensor(_output_details[0]["index"])[0]

    max_index = int(np.argmax(output))
    confidence = float(output[max_index]) * 100

    return {
        "label": labels[max_index] if labels else "Unknown",
        "confidence": confidence,
    }
