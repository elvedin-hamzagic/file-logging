import 'package:file_logs/file_logs.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  group('Logging 1', () {
    final logger = FileLogger(name: 'TestLogger1', maxFileSize: 1024, logPath: './file_logs_1/');

    setUp(() {});

    test('Delete old logs', () async {
      await logger.deleteOldLogs(0);
    });

    test('Fine Test', () {
      logger.fine('This is a fine message');
    });

    test('Info Test', () {
      logger.info('This is an info message');
    });

    test('Warning Test', () {
      logger.warning('This is a warning message');
    });

    test('Severe Test', () {
      try {
        throw Exception('This is a test exception');
      } catch (e, stackTrace) {
        logger.severe('This is a severe message', e, stackTrace);
      }
    });
  });

  group('Logging 2', () {
    final logger = FileLogger(
      name: 'TestLogger2',
      level: Level.WARNING,
      logToConsole: false,
      maxFileSize: 1024,
      logPath: './file_logs_2/',
    );

    setUp(() {
      logger.logFormatter = (LogRecord record, int sequenceNumber) =>
          '${record.time} [${record.level.name}] ($sequenceNumber): ${record.message}\n';

      logger.fileNameGenerator = (String loggerName, DateTime date) =>
          '${loggerName.isNotEmpty ? '${loggerName}_' : ''}${DateFormat('yyyy-MM-dd').format(date)}';

      logger.recordHandler = (LogRecord record, void Function(LogRecord record) defaultProcessor) {
        defaultProcessor(record);
        print("Perform additional tasks");
      };
    });

    test('Set log formatter', () {});

    test('Set file name generator', () {});

    test('Set file name generator', () {});

    test('Fine Test', () {
      logger.fine('This is a fine message');
    });

    test('Info Test', () {
      logger.info('This is an info message');
    });

    test('Warning Test', () {
      logger.warning('This is a warning message');
    });

    test('Severe Test', () {
      try {
        throw Exception('This is a test exception');
      } catch (e, stackTrace) {
        logger.severe('This is a severe message', e, stackTrace);
      }
    });

    test('Delete old logs', () async {
      await logger.deleteOldLogs(1);
    });
  });
}
