import pandas as pd
from catboost import CatBoostClassifier, CatBoostRegressor
      
# Load models
base_model_path = "/home/melki/Desktop/Ethio-AgriBizBoost/model/"
demand_model = CatBoostClassifier()
demand_model.load_model(f'{base_model_path}demand_model.cbm')

min_model = CatBoostRegressor()
min_model.load_model(f'{base_model_path}max_price_model.cbm')

max_model = CatBoostRegressor()
max_model.load_model(f'{base_model_path}min_price_model.cbm')

def make_predictions(input_data: dict):
    single_value_input = {key: value[0] for key, value in input_data.items()}
    input_df = pd.DataFrame([single_value_input])
    
    demand_pred = demand_model.predict(input_df)[0]
    min_price_pred = min_model.predict(input_df)[0]
    max_price_pred = max_model.predict(input_df)[0]
    
    return {
        "Predicted Demand": str(demand_pred[0]),
        "Predicted Min Price": float(min_price_pred),
        "Predicted Max Price": float(max_price_pred)
    }