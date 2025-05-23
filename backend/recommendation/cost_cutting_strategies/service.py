import pandas as pd
import pickle
import os

from .utils import translations
basemodel_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "../..", "model")
basemodel_path = os.path.abspath(basemodel_path)  # Ensure the path is absolute

def make_prediction(input_data: dict, language: str = "en"):
    recommendation_model_path = basemodel_path + '/recommendation_model.pkl'
    encoders = basemodel_path + '/encoders.pkl'

    # Load model and encoders
    with open(recommendation_model_path, 'rb') as f:
        model = pickle.load(f)

    with open(encoders, 'rb') as f:
        encoders = pickle.load(f) 

    # Create a DataFrame for prediction
    input_df = pd.DataFrame([input_data])
    input_df['crop_type'] = input_df['crop_type']
    input_df['season'] = input_df['season']

    # Handle unseen labels
    if input_df['crop_type'].iloc[0] not in encoders['crop_type'].classes_:
        raise ValueError(
    f"Sorry, the crop type '{input_df['crop_type'].iloc[0]}' is not recognized. "
    "Please choose one of the supported crop types: teff, wheat, maize, sorghum, barley, coffee, sesame, or haricot beans."
)

    if input_df['season'].iloc[0] not in encoders['season'].classes_:
        raise ValueError(
            f"Sorry, the season '{input_df['season'].iloc[0]}' is not recognized. "
            "Please select one of the supported seasons: belg, bega, kiremt, or tsedey."
        ) 

    # Preprocess the input data
    input_df['crop_type'] = encoders['crop_type'].transform(input_df['crop_type'].str.lower())
    input_df['season'] = encoders['season'].transform(input_df['season'].str.lower())

    # Make prediction  
    predicted_class = model.predict(input_df)[0]
    recommendation = encoders['recommendation'].inverse_transform([predicted_class])[0]

    # For different languages, use the translations dictionary
    if language != "en":
        recommendation = translations.get(recommendation, {}).get(language, recommendation)

    return {"recommendation": recommendation}