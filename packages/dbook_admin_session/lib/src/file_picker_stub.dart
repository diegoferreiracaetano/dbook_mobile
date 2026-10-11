/// Um arquivo de texto escolhido pela pessoa.
class PickedTextFile {
  const PickedTextFile({required this.name, required this.content});

  final String name;
  final String content;
}

/// Fora do navegador não há seletor: devolve `null`.
Future<PickedTextFile?> pickTextFile({String accept = '.csv,text/csv'}) async =>
    null;
