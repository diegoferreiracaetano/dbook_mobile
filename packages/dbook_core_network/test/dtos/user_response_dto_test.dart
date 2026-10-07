import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:test/test.dart';

void main() {
  test('given a CLIENT role JSON when mapped then role decodes to client', () {
    final user = UserResponseDto.fromJson({
      'id': 1,
      'email': 'diego@dbook.com',
      'name': 'Diego Ferreira',
      'role': 'CLIENT',
    }).toDomain();

    expect(user.role, Role.client);
    expect(user.email, 'diego@dbook.com');
    expect(user.name, 'Diego Ferreira');
  });

  test('given a SUPER_ADMIN role JSON when mapped then role decodes', () {
    final user = UserResponseDto.fromJson({
      'id': 1,
      'email': 'admin@dbook.com',
      'name': 'Admin',
      'role': 'SUPER_ADMIN',
    }).toDomain();

    expect(user.role, Role.superAdmin);
  });

  test('given a role the app does not know when mapped then it is unknown', () {
    final user = UserResponseDto.fromJson({
      'id': 1,
      'email': 'new@dbook.com',
      'name': 'New',
      'role': 'AUDITOR',
    }).toDomain();

    expect(user.role, Role.unknown);
  });
}
