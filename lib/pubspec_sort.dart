// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Sorts the dependencies (dependencies, dev_dependencies, dependency_overrides)
/// in pubspec.yaml alphabetically.
///
/// Returns true if changes were made to the file, and false otherwise
/// (if the file doesn't exist or is already sorted).
bool sortPubspec({String path = 'pubspec.yaml'}) {
  final file = File(path);

  // 1. Check if the file exists.
  if (!file.existsSync()) {
    return false;
  }

  final content = file.readAsStringSync();
  final editor = YamlEditor(content);
  final yaml = loadYaml(content);

  // 2. Define the sections that should be sorted.
  final sectionsToCheck = [
    'dependencies',
    'dev_dependencies',
    'dependency_overrides'
  ];

  var changed = false;

  // 3. Iterate over sections and apply sorting logic.
  for (final section in sectionsToCheck) {
    if (yaml is Map && yaml.containsKey(section)) {
      final sectionMap = yaml[section];

      // Skip if the section is not a Map or is empty
      if (sectionMap is! Map || sectionMap.isEmpty) continue;

      // Get the keys (package names)
      final keys = sectionMap.keys.map((e) => e.toString()).toList();

      // Create a list of sorted keys
      final sortedKeys = List<String>.from(keys)..sort();

      // If the current order is different from the sorted order, apply the change
      if (keys.toString() != sortedKeys.toString()) {
        // Recreate the map with the new order
        final sortedMap = {for (var key in sortedKeys) key: sectionMap[key]};

        // Update the file virtually (using yaml_edit to preserve comments and structure)
        editor.update([section], sortedMap);
        changed = true;
      }
    }
  }

  // 4. If any change was made, write the new content to the file.
  if (changed) {
    file.writeAsStringSync(editor.toString());
  }

  return changed;
}
