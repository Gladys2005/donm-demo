import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, Map<String, dynamic>>> login(String email, String password);
  Future<Either<Failure, Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  });
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, Map<String, dynamic>>> refreshToken();
  Future<Either<Failure, bool>> checkAuthStatus();
}
