import 'package:dbook_feature_admin_auth/src/password_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given a password shorter than twelve when checking then it is '
      'rejected and weak', () {
    expect(PasswordRules.longEnough('short-pass'), isFalse);
    expect(PasswordRules.strength('short-pass'), PasswordStrength.weak);
  });

  test('given a password equal to the e-mail when checking then it does not '
      'differ', () {
    expect(
      PasswordRules.differsFromEmail('Ana@Exemplo.com', 'ana@exemplo.com'),
      isFalse,
    );
    expect(
      PasswordRules.acceptable('ana@exemplo.com', 'ana@exemplo.com'),
      isFalse,
    );
  });

  test('given more than 72 bytes when checking then it is too long', () {
    expect(PasswordRules.notTooLong('a' * 72), isTrue);
    expect(PasswordRules.notTooLong('a' * 73), isFalse);
  });

  test('given long mixed passwords when measuring then grades medium and '
      'strong', () {
    expect(PasswordRules.strength('abcdefgh1234ABCD'), PasswordStrength.strong);
    expect(PasswordRules.strength('abcdEFGH1234'), PasswordStrength.medium);
    expect(PasswordRules.strength('abcdefghijklmnop'), PasswordStrength.weak);
  });
}
