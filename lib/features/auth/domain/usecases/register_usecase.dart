import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String role;

  RegisterParams({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
  });
}

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call(RegisterParams params) async {
    return await _repository.register(
      name: params.name,
      email: params.email,
      phone: params.phone,
      password: params.password,
      role: params.role,
    );
  }
}
