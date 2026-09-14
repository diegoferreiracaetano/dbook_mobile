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

  test('given an ADMIN role JSON when mapped then role decodes to admin', () {
    final user = UserResponseDto.fromJson({
      'id': 1,
      'email': 'admin@dbook.com',
      'name': 'Admin',
      'role': 'ADMIN',
    }).toDomain();

    expect(user.role, Role.admin);
  });
}
