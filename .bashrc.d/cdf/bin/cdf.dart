import 'package:cdf/cdf.dart' as cdf;

Future<void> main(List<String> arguments) async {
  final cwds = await cdf.loadVsCodeTargets(arguments[0]);
  for (final cwd in cwds) {
    print(cwd);
  }
}
