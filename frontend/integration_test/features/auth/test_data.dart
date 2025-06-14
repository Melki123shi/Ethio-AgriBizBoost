/// Test data constants for authentication integration tests
/// This file centralizes all test data to maintain consistency across tests

class AuthTestData {
  // Valid test credentials
  static const validPhoneNumberInternational = '+251911234567';
  static const validPhoneNumberLocal = '0911234567';
  static const validPhoneNumberWithSpaces = '091 123 4567';
  static const validPassword = 'SecurePass123!';
  static const validEmail = 'abebe.kebede@test.et';
  static const validName = 'Abebe Kebede';
  static const validNameAmharic = 'አበበ ከበደ ወልደማሪያም';

  // Invalid phone numbers for testing
  static const invalidPhoneNumbers = [
    '123456', // Too short
    '+1234567890', // Wrong country code
    '08123456789', // Wrong prefix
    '+25191234567', // Wrong format
    'abcdefghij', // Non-numeric
    '091234567890', // Too long
    '', // Empty
  ];

  // Valid Ethiopian phone number formats
  static const validEthiopianPhoneFormats = [
    '+251911234567',
    '+251912334455',
    '+251913445566',
    '+251914556677',
    '0911234567',
    '0912334455',
    '0913445566',
    '0914556677',
    '091 123 4567',
    '+251 91 123 4567',
  ];

  // Password test cases
  static const passwordTooShort = '1234567'; // 7 chars
  static const passwordMinimumValid = '12345678'; // 8 chars
  static const passwordWithSpecialChars = 'P@ssw0rd!2023';
  static const passwordWithEthiopianChars = 'Pass123!አበበ';

  // Email test cases
  static const validEmails = [
    'user@example.com',
    'test.user@domain.co.uk',
    'user+tag@example.org',
    'user123@test-domain.com',
    'አበበ@example.et', // Unicode in local part
  ];

  static const invalidEmails = [
    'invalid-email',
    '@domain.com',
    'user@',
    'user.domain.com',
    'user @domain.com',
    'user@domain',
  ];

  // API response messages
  static const signupSuccessMessage = 'Account created. Please log in.';
  static const loginSuccessMessage = 'Login successful';
  static const logoutSuccessMessage = 'Logout successful';

  // Error messages
  static const phoneAlreadyRegistered = 'Phone number already registered';
  static const invalidCredentials = 'Invalid credentials';
  static const internalServerError = 'Internal server error';
  static const tokenExpired = 'Token expired';
  static const invalidRefreshToken = 'Invalid refresh token';

  // Validation error messages
  static const phoneValidationError = 'Enter a valid Ethiopian phone number.';
  static const passwordValidationError =
      'Password must be at least 8 characters.';
  static const emailValidationError = 'Enter a valid email address.';
  static const formValidationError = 'Please correct the highlighted fields.';

  // Token values for testing
  static const mockAccessToken = 'mock-access-token-123';
  static const mockRefreshToken = 'mock-refresh-token-123';
  static const newMockAccessToken = 'new-mock-access-token-456';
  static const newMockRefreshToken = 'new-mock-refresh-token-456';
  static const tokenType = 'Bearer';

  // User profile test data
  static const mockUserId = 'test-user-id-123';
  static const mockUserName = 'Test User';
  static const mockUserEmail = 'test@example.com';
  static const mockUserLocation = 'Addis Ababa, Ethiopia';

  // Timeout durations
  static const apiTimeout = Duration(seconds: 30);
  static const navigationTimeout = Duration(seconds: 5);
  static const loadingStateTimeout = Duration(milliseconds: 500);
}

/// Test scenarios for different user types in Ethiopian agricultural context
class UserScenarios {
  static const farmer = {
    'name': 'Tadesse Bekele',
    'nameAmharic': 'ታደሰ በቀለ',
    'phone': '+251912345678',
    'email': 'tadesse.farmer@test.et',
    'password': 'FarmerTeff2023!',
    'location': 'Amhara Region',
    'crops': ['Teff', 'Wheat', 'Barley'],
  };

  static const cooperative = {
    'name': 'Sidama Coffee Cooperative',
    'nameAmharic': 'ሲዳማ ቡና ህብረት ስራ ማህበር',
    'phone': '+251933567890',
    'email': 'coop@sidamacoffee.et',
    'password': 'CoopCoffee@Sidama',
    'location': 'Sidama Region',
    'members': 250,
  };

  static const advisor = {
    'name': 'Dr. Sara Alemayehu',
    'nameAmharic': 'ዶ/ር ሳራ አለማየሁ',
    'phone': '+251944123789',
    'email': 'sara.advisor@agri.et',
    'password': 'AdvisorOromia123!',
    'location': 'Oromia Region',
    'specialization': 'Crop Protection',
  };

  static const trader = {
    'name': 'Mohammed Ali Trading',
    'nameAmharic': 'መሐመድ አሊ ንግድ',
    'phone': '+251922987654',
    'email': 'info@mohammedtrading.et',
    'password': 'Trader@2023Export',
    'location': 'Dire Dawa',
    'tradingFocus': 'Export',
  };
}

/// Network conditions for testing
class NetworkConditions {
  static const success = {'delay': 100, 'statusCode': 200};
  static const slowNetwork = {'delay': 3000, 'statusCode': 200};
  static const timeout = {'delay': 35000, 'statusCode': 0};
  static const serverError = {'delay': 500, 'statusCode': 500};
  static const unauthorized = {'delay': 200, 'statusCode': 401};
  static const badRequest = {'delay': 200, 'statusCode': 400};
}
