from datetime import datetime

# Validation function for goods (non-empty)
def validate_cropTypes(v: str) -> str:
    if not v.strip():
        raise ValueError('Crop type name must not be empty')
    return v

# Validation function for positive values
def validate_positive(v: float, field_name: str) -> float:
    if v <= 0:
        raise ValueError(f'{field_name} must be greater than zero')
    return v

# Validation function for non-negative values
def validate_non_negative(v: float, field_name: str) -> float:
    if v < 0:
        raise ValueError(f'{field_name} must be non-negative')
    return v
