import os

os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"

import warnings

warnings.filterwarnings("ignore", message="Skipping variable loading for optimizer")

import io

import numpy as np
import tensorflow as tf
from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from keras.models import load_model  # type: ignore
from PIL import Image
from tensorflow.keras.applications.efficientnet_v2 import (
    preprocess_input,  # type: ignore
)
from tensorflow.keras.preprocessing import image

app = FastAPI(title="Garbage Classification API")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load the saved model (HDF5 or SavedModel)
model_path = os.path.join(os.path.dirname(__file__), "garbage_classifier.keras")
model = load_model(model_path)

class_names = [
    "Battery",
    "Biological",
    "Brown-glass",
    "Cardboard",
    "Clothes",
    "Green-glass",
    "Metal",
    "Paper",
    "Plastic",
    "Shoes",
    "Trash",
    "White-glass",
]

# Mapping class -> German bin
class_to_bin = {
    "Battery": "Battery collection (Sondermüll)",
    "Biological": "Brown bin / Bioabfall",
    "Brown-glass": "Glass (brown)",
    "Green-glass": "Glass (green)",
    "White-glass": "Glass (white)",
    "Cardboard": "Paper / Cardboard bin",
    "Paper": "Paper bin",
    "Clothes": "Textiles collection",
    "Metal": "Recycling / Metal bin",
    "Plastic": "Yellow bin / Verpackung",
    "Shoes": "Textiles collection",
    "Trash": "Residual waste (Restmüll)",
}


# Function to preprocess image
def preprocess_image(image_bytes):
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    img = img.resize((224, 224))
    img_array = preprocess_input(np.array(img))
    img_array = np.expand_dims(img_array, axis=0)
    return img_array


@app.get("/")
async def root():
    return {"message": "Welcome to the Garbage Classification API"}


@app.get("/health")
async def health_check():
    return {"status": "ok"}


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    try:
        image_bytes = await file.read()
        image_array = preprocess_image(image_bytes)
        preds = model.predict(image_array)
        predicted_class = class_names[np.argmax(preds)]
        confidence = float(np.max(preds))
        bin_name = class_to_bin.get(predicted_class, "Unknown bin")
        return JSONResponse(
            {"class": predicted_class, "confidence": confidence, "bin": bin_name}
        )
    except Exception as e:
        return JSONResponse({"error": str(e)})
