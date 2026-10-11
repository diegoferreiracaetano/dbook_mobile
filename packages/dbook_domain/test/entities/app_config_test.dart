import 'package:dbook_domain/dbook_domain.dart';
import 'package:test/test.dart';

const _release = AppRelease(
  minSupportedVersion: '1.2.0',
  latestVersion: '1.5.0',
  storeUrl: 'https://store.example/dbook',
);

void main() {
  test('given versions with different lengths and build suffix when comparing '
      'then compares by numbers', () {
    expect(compareVersions('1.2', '1.2.0'), 0);
    expect(compareVersions('1.2.0+17', '1.2.0'), 0);
    expect(compareVersions('1.10.0', '1.9.9'), greaterThan(0));
    expect(compareVersions('1.0.9', '1.1.0'), lessThan(0));
  });

  test('given a non numeric piece when comparing then treats it as zero '
      'instead of throwing', () {
    expect(compareVersions('1.x.0', '1.0.0'), 0);
  });

  test('given a version below the minimum when assessing then the update is '
      'required', () {
    expect(
      assessUpdate(currentVersion: '1.1.9', release: _release),
      UpdateStatus.required,
    );
  });

  test('given a version between minimum and latest when assessing then an '
      'update is only available', () {
    expect(
      assessUpdate(currentVersion: '1.3.0', release: _release),
      UpdateStatus.available,
    );
  });

  test('given the latest version when assessing then it is up to date', () {
    expect(
      assessUpdate(currentVersion: '1.5.0', release: _release),
      UpdateStatus.upToDate,
    );
  });

  test('given no release or an unknown version when assessing then never '
      'blocks', () {
    expect(
      assessUpdate(currentVersion: '0.0.1', release: null),
      UpdateStatus.upToDate,
    );
    expect(
      assessUpdate(currentVersion: 'unknown', release: _release),
      UpdateStatus.upToDate,
    );
  });

  test('given a web platform when asking its release then there is none', () {
    const config = AppConfig(android: _release);

    expect(config.forPlatform('android'), _release);
    expect(config.forPlatform('web'), isNull);
  });
}
