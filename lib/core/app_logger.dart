import 'package:logger/logger.dart';

/// Logger global da aplicação.
/// Use `log.d()`, `log.i()`, `log.w()`, `log.e()` ao invés de `print()`.
final log = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
  ),
  level: Level.debug,
);
