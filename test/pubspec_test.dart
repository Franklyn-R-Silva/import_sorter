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
      // Cleans up the test file after each execution
      if (testFile.existsSync()) {
        testFile.deleteSync();
      }
    });

    test('Sorts dependencies alphabetically', () {
      // 1. Create a messy yaml file
      const content = '''
name: testing
dependencies:
  yaml: ^3.1.0
  args: ^2.0.0
  tint: ^2.0.0
''';
      testFile.writeAsStringSync(content);

      // 2. Run your function on the test file
      final changed = sortPubspec(path: testFilePath);

      // 3. Check if there was a change and if it is sorted
      expect(changed, isTrue);

      final sortedContent = testFile.readAsStringSync();
      // args comes before tint, which comes before yaml
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
      // lints should come before test
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

      // Run the function
      final changed = sortPubspec(path: testFilePath);

      // Should not have changed anything
      expect(changed, isFalse);
    });
  });
}
