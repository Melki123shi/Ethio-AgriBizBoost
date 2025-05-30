import 'package:app/services/api/auth_service.dart';
import 'package:app/services/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';

// Generate mocks for these classes
@GenerateMocks([
  AuthService,
  Dio,
  FlutterSecureStorage,
  HttpClientAdapter,
], customMocks: [
  MockSpec<TokenStorage>(as: #MockTokenStorage),
])
void main() {}
