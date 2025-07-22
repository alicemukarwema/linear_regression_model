# API/prediction.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, confloat, conint
from typing import Literal
import joblib
from pathlib import Path
import numpy as np
import pandas as pd
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Crop Yield Prediction API")

# Get the absolute path to the model file
current_dir = Path(__file__).parent
model_path = current_dir.parent / "linear_regression" / "models" / "best_model.pkl"

# Load the model
model_data = joblib.load(model_path)
model = model_data['model']
numeric_features = model_data['numeric_features']
categorical_features = model_data['categorical_features']

# Define allowed values for categorical features
allowed_soil_types = ['Sandy', 'Clay', 'Loam', 'Silt']
allowed_regions = ['North', 'South', 'East', 'West']
allowed_crops = ['Cotton', 'Rice', 'Barley', 'Soybean', 'Wheat']
allowed_weather = ['Sunny', 'Cloudy', 'Rainy']

# Define input data model
class CropYieldInput(BaseModel):
    Region: Literal[tuple(allowed_regions)]
    Soil_Type: Literal[tuple(allowed_soil_types)]
    Crop: Literal[tuple(allowed_crops)]
    Rainfall_mm: confloat(ge=0, le=2000)
    Temperature_Celsius: confloat(ge=-20, le=50)
    Fertilizer_Used: bool
    Irrigation_Used: bool
    Weather_Condition: Literal[tuple(allowed_weather)]
    Days_to_Harvest: conint(ge=1, le=365)

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Crop Yield Prediction API"}

@app.post("/predict")
def predict_yield(input_data: CropYieldInput):
    try:
        # Convert input to DataFrame
        input_dict = input_data.dict()
        input_df = pd.DataFrame([input_dict])
        
        # Make prediction
        prediction = model.predict(input_df)
        
        return {
            "predicted_yield": float(prediction[0]),
            "units": "tons_per_hectare"
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)