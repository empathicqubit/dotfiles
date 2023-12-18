import 'dart:io';

import 'package:json5/json5.dart';

Future<List<String>> loadVsCodeTargets(String path) async {
  final contents = await File(path).readAsString();
  final data = JSON5.parse(contents);
  final cfgs = data['configurations'] as List<dynamic>;
  final cwds = <String>[];
  for (final cfg in cfgs) {
    final type = cfg['type'] as String;
    if (type != 'dart') {
      continue;
    }

    String? cwd = cfg['cwd'] as String?;
    if (cwd == null) {
      continue;
    }

    cwds.add(cwd);
  }

  return cwds;
}
