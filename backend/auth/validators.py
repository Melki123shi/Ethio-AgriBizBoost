import re
from typing import Optional

def is_valid_ethiopian_phone(phone_number: str) -> bool:
    """
    Validates an Ethiopian phone number.
    
    Supports the following formats:
    - International format: +251912345678, +251712345678
    - Local format: 0912345678, 0712345678
    - Allows spaces, dashes, or parentheses which are removed during validation
    
    Returns True if valid, False otherwise.
    """
    # Remove spaces, dashes, or parentheses
    clean_phone = re.sub(r'[\s\-\(\)]', '', phone_number)
    
    # Validate +251 format (international)
    if clean_phone.startswith('+251'):
        return bool(re.match(r'^\+251[79]\d{8}$', clean_phone))
    # Validate 0 format (local)
    elif clean_phone.startswith('0'):
        return bool(re.match(r'^0[79]\d{8}$', clean_phone))
    
    return False

def validate_ethiopian_phone(phone_number: str) -> str:
    """
    Validates an Ethiopian phone number and raises ValueError if invalid.
    Returns the cleaned phone number if valid.
    """
    # Remove spaces, dashes, or parentheses
    clean_phone = re.sub(r'[\s\-\(\)]', '', phone_number)
    
    # Validate +251 format (international)
    if clean_phone.startswith('+251'):
        if not re.match(r'^\+251[79]\d{8}$', clean_phone):
            raise ValueError('Invalid Ethiopian phone number format. For international format use: +251 followed by 9 digits')
    # Validate 0 format (local)
    elif clean_phone.startswith('0'):
        if not re.match(r'^0[79]\d{8}$', clean_phone):
            raise ValueError('Invalid Ethiopian phone number format. For local format use: 0 followed by 9 digits')
    else:
        raise ValueError('Ethiopian phone number must start with +251 or 0')
        
    return clean_phone

def normalize_phone_number(phone_number: str) -> str:
    """
    Normalizes an Ethiopian phone number to the international format.
    
    Converts:
    - 0912345678 -> +251912345678
    - Already international formats are kept as is
    - Removes any spaces, dashes, or parentheses
    
    Raises ValueError if the phone number is invalid.
    """
    # First validate the phone number
    clean_phone = validate_ethiopian_phone(phone_number)
    
    # Convert local format to international format if needed
    if clean_phone.startswith('0'):
        clean_phone = '+251' + clean_phone[1:]
        
    return clean_phone

def get_alternative_phone_format(phone_number: str) -> str:
    """
    Returns the alternative format of a phone number.
    - If international (+251...) returns local (0...)
    - If local (0...) returns international (+251...)
    
    Useful for checking both formats in database
    """
    clean_phone = re.sub(r'[\s\-\(\)]', '', phone_number)
    
    if clean_phone.startswith('+251'):
        return '0' + clean_phone[4:]
    elif clean_phone.startswith('0'):
        return '+251' + clean_phone[1:]
    
    return clean_phone

def check_phone_exists(get_user_function, phone_number: str) -> Optional[dict]:
    """
    Checks if a phone number exists in the database in any format.
    
    Args:
        get_user_function: A function that takes a phone number and returns a user or None
        phone_number: The phone number to check
        
    Returns:
        User object if found, None otherwise
    """
    # Try with provided format
    user = get_user_function(phone_number)
    if user:
        return user
    
    # Try with normalized format
    try:
        normalized = normalize_phone_number(phone_number)
        if normalized != phone_number:
            user = get_user_function(normalized)
            if user:
                return user
    except ValueError:
        pass
    
    # Try with alternative format
    try:
        alternative = get_alternative_phone_format(phone_number)
        if alternative != phone_number:
            user = get_user_function(alternative)
            if user:
                return user
    except ValueError:
        pass
    
    return None 