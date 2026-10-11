/// A versão mais nova e a mínima aceita de um app numa loja, como o backend
/// as publica em `GET /v1/app-config`.
class AppRelease {
  const AppRelease({
    required this.minSupportedVersion,
    required this.latestVersion,
    required this.storeUrl,
  });

  final String minSupportedVersion;
  final String latestVersion;
  final String storeUrl;
}

/// A configuração de ciclo de vida do app: uma entrada por plataforma. Uma
/// plataforma ausente (web) nunca bloqueia nem avisa.
class AppConfig {
  const AppConfig({this.android, this.ios});

  final AppRelease? android;
  final AppRelease? ios;

  AppRelease? forPlatform(String platform) => switch (platform) {
    'android' => android,
    'ios' => ios,
    _ => null,
  };
}

/// O que fazer com a versão instalada.
enum UpdateStatus {
  /// Em dia (ou sem como saber): segue normal.
  upToDate,

  /// Há versão mais nova, mas a instalada ainda é aceita: aviso dispensável.
  available,

  /// Abaixo da mínima: o app não deve ser usado até atualizar.
  required,
}

/// Compara duas versões `1.4.2` ou `1.4.2+17` pelos números, da esquerda para
/// a direita (a parte depois do `+` é só build e não conta). Negativo se [a]
/// é mais velha que [b], zero se iguais, positivo se mais nova. Um pedaço que
/// não é número vale 0, para um valor estranho nunca travar o app.
int compareVersions(String a, String b) {
  List<int> parts(String v) => [
    for (final p in v.split('+').first.split('.')) int.tryParse(p.trim()) ?? 0,
  ];
  final left = parts(a);
  final right = parts(b);
  final length = left.length > right.length ? left.length : right.length;
  for (var i = 0; i < length; i++) {
    final x = i < left.length ? left[i] : 0;
    final y = i < right.length ? right[i] : 0;
    if (x != y) return x < y ? -1 : 1;
  }
  return 0;
}

/// A regra do ciclo de vida: abaixo da mínima exige atualizar; abaixo da
/// mais nova só avisa. Sem versão conhecida (`unknown`) ou sem configuração
/// da plataforma, **não bloqueia**: errar para o lado de deixar usar.
UpdateStatus assessUpdate({
  required String currentVersion,
  required AppRelease? release,
}) {
  if (release == null ||
      currentVersion == 'unknown' ||
      currentVersion.isEmpty) {
    return UpdateStatus.upToDate;
  }
  if (compareVersions(currentVersion, release.minSupportedVersion) < 0) {
    return UpdateStatus.required;
  }
  if (compareVersions(currentVersion, release.latestVersion) < 0) {
    return UpdateStatus.available;
  }
  return UpdateStatus.upToDate;
}
