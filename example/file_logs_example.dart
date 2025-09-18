import 'package:file_logs/file_logs.dart';

Future<void> main() async {
  final logger = FileLogger(maxFileSize: 512, logPath: 'file_logs');
  await logger.clearLogs();
  logger.finest('This is a finest message');
  logger.finer('This is a finer message');
  logger.fine('This is a fine message');
  logger.info('This is an info message');
  logger.config('This is a config message');

  try {
    throw Exception('This is a test exception');
  } catch (e, stackTrace) {
    logger.warning('This is a warning message', e, stackTrace);
    logger.severe('This is a severe message', e, stackTrace);
    logger.shout('This is a shout message', e, stackTrace);
  }
}
