// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:test/test.dart';

// 🌎 Project imports:
import 'package:import_sorter/pubspec_sort.dart';

void main() {
  group('Pubspec Sorting', () {
    final testFilePath = 'pubspec_test_temp.yaml';
    late File testFile;

    setUp(() {
      testFile = File(testFilePath);
    });

    tearDown(() {
      // Limpa o arquivo de teste após cada execução
      if (testFile.existsSync()) {
        testFile.deleteSync();
      }
    });

    test('Sorts dependencies alphabetically', () {
      // 1. Cria um arquivo yaml bagunçado
      const content = '''
name: testing
dependencies:
  yaml: ^3.1.0
  args: ^2.0.0
  tint: ^2.0.0
''';
      testFile.writeAsStringSync(content);

      // 2. Roda sua função no arquivo de teste
      final changed = sortPubspec(path: testFilePath);

      // 3. Verifica se houve mudança e se está ordenado
      expect(changed, isTrue);

      final sortedContent = testFile.readAsStringSync();
      // args vem antes de tint, que vem antes de yaml
      expect(sortedContent, contains('args: ^2.0.0'));
      expect(sortedContent.indexOf('args:'),
          lessThan(sortedContent.indexOf('tint:')));
      expect(sortedContent.indexOf('tint:'),
          lessThan(sortedContent.indexOf('yaml:')));
    });

    test('Sorts dev_dependencies alphabetically', () {
      const content = '''
name: testing
dev_dependencies:
  test: ^1.0.0
  lints: ^2.0.0
''';
      testFile.writeAsStringSync(content);

      sortPubspec(path: testFilePath);

      final sortedContent = testFile.readAsStringSync();
      // lints deve vir antes de test
      expect(sortedContent.indexOf('lints:'),
          lessThan(sortedContent.indexOf('test:')));
    });

    test('Does nothing if already sorted', () {
      const content = '''
name: testing
dependencies:
  args: ^2.0.0
  yaml: ^3.1.0
''';
      testFile.writeAsStringSync(content);

      // Roda a função
      final changed = sortPubspec(path: testFilePath);

      // Não deve ter alterado nada
      expect(changed, isFalse);
    });
  });
}
