import 'dart:io';

import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:synchronized/synchronized.dart';

typedef LogFormatter = String Function(LogRecord record, int sequenceNumber);
typedef FileNameGenerator = String Function(String loggerName, DateTime date);
typedef RecordHandler = void Function(LogRecord record, void Function(LogRecord record) defaultProcessor);

class FileLogger
{
  static final String _defaultLogPath = p.join(Platform.environment['HOME'] ?? '', 'logs');

  FileLogger({String name = '', Level level = Level.ALL, this.logToConsole = true,
    this.logToFile = true, this.maxFileSize = 0, String? logPath}) : _logger = Logger(name)
  {
    if (logPath != null) {
      _logPath = logPath;
    }
    _createLogPath();

    hierarchicalLoggingEnabled = true;
    _logger.level = level;
    _logger.onRecord.listen((LogRecord record) => _recordHandler(record, _recordProcessor));
  }

  bool logToConsole;
  bool logToFile;
  int maxFileSize;

  late final Logger _logger;
  final Lock _writeLock = Lock();
  final Lock _deleteLock = Lock();
  String? _currentFileName;
  int _fileNumber = 0;
  int _sequenceNumber = 0;
  String _logPath = _defaultLogPath;

  LogFormatter _logFormatter = (LogRecord record, int sequenceNumber) =>
      '[${DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(record.time)}] '
      '[${record.loggerName.isNotEmpty ? '${record.loggerName}#' : ''}$sequenceNumber] '
      '[${record.level.name}] '
      '${record.message} '
      '${record.error == null ? '' : '(${record.error})'} '
      '${record.stackTrace == null ? '' : '\n${record.stackTrace}'}'
      '\n';

  FileNameGenerator _fileNameGenerator = (String loggerName, DateTime date) =>
      '${loggerName.isNotEmpty ? '${loggerName}_' : ''}${DateFormat('yyyyMMdd').format(date)}';

  RecordHandler _recordHandler = (LogRecord record, void Function(LogRecord record) defaultProcessor) =>
      defaultProcessor(record);

  String get name => _logger.name;
  Level get level => _logger.level;
  String get logPath => _logPath;

  set level(Level level) => _logger.level = level;
  set logFormatter(LogFormatter formatter) => _logFormatter = formatter;
  set fileNameGenerator(FileNameGenerator generator) => _fileNameGenerator = generator;
  set recordHandler(RecordHandler handler) => _recordHandler = handler;

  void finest(String message, [Object? error, StackTrace? stackTrace]) => _logger.finest(message, error, stackTrace);
  void finer(String message, [Object? error, StackTrace? stackTrace]) => _logger.finer(message, error, stackTrace);
  void fine(String message, [Object? error, StackTrace? stackTrace]) => _logger.fine(message, error, stackTrace);
  void config(String message, [Object? error, StackTrace? stackTrace]) => _logger.config(message, error, stackTrace);
  void info(String message, [Object? error, StackTrace? stackTrace]) => _logger.info(message, error, stackTrace);
  void warning(String message, [Object? error, StackTrace? stackTrace]) => _logger.warning(message, error, stackTrace);
  void severe(String message, [Object? error, StackTrace? stackTrace]) => _logger.severe(message, error, stackTrace);
  void shout(String message, [Object? error, StackTrace? stackTrace]) => _logger.shout(message, error, stackTrace);

  Future<void> clearLogs() async => await deleteOldLogs(0);

  Future<void> deleteOldLogs(int daysOld) async
  {
    DateTime thresholdDate = DateTime.now().subtract(Duration(days: daysOld));
    var directory = Directory(_logPath);

    await _deleteLock.synchronized(() async {
      if (!await directory.exists()) {
        return;
      }

      deleteFunction() => _deleteOldLogFiles(directory, thresholdDate);
      if (daysOld <= 0) {
        await _writeLock.synchronized(() async {
          await deleteFunction();
        });
      } else {
        await deleteFunction();
      }
    });
  }

  String _formatLogEntry(LogRecord record) => _logFormatter(record, ++_sequenceNumber);
  String _getFileName(DateTime date) => _fileNameGenerator(name, date);

  Future<void> _recordProcessor(LogRecord record) async
  {
    String entry = _formatLogEntry(record);

    await _writeLock.synchronized(() async {
      if (logToConsole) {
        _writeToConsole(entry);
      }
      if (logToFile) {
        await _writeToFile(record.time, entry);
      }
    });
  }

  Future<void> _createLogPath() async
  {
    try {
      if (!await Directory(_logPath).exists()) {
        await Directory(_logPath).create(recursive: true);
      }
    } catch (e) {
      _writeToConsole('Failed to create directory for logs: $e');
    }
  }

  void _writeToConsole(String entry) => print(entry);

  Future<void> _writeToFile(DateTime date, String entry) async
  {
    try {
      var file = await _getLogFile(date);
      await file.writeAsString(entry, mode: FileMode.writeOnlyAppend); }
    catch (e) {
      _writeToConsole('Error writing to file: $e');
    }
  }

  Future<File> _getLogFile(DateTime date) async
  {
    String fileName = _getFileName(date);
    File file = File(p.join(_logPath, fileName));

    if (_currentFileName != null && _currentFileName != fileName) {
      _currentFileName = fileName;
      _fileNumber = 0;
      return file;
    }

    return _backupBigLogFile(file, fileName);
  }

  Future<File> _backupBigLogFile(File file, String fileName) async
  {
    if (maxFileSize > 0 && await file.exists() && await file.length() > maxFileSize) {
      String filePath = p.join(_logPath, fileName);
      bool backedUp = false;

      while (!backedUp) {
        _fileNumber++;
        String backupFileName = '$filePath${_fileNumber == 0 ? '' : '_$_fileNumber'}';
        var backupFile = File(backupFileName);

        if (!await backupFile.exists()) {
          await file.rename(backupFileName);
          backedUp = true;
        }
      }

      file = File(filePath);
    }

    return file;
  }

  Future<void> _deleteOldLogFiles(Directory directory, DateTime thresholdDate) async {
    await for (var item in directory.list(recursive: false)) {
      if (item is! File) {
        continue;
      }

      var stat = await item.stat();
      DateFormat dateFormat = DateFormat('yyyyMMdd');
      if (dateFormat.format(stat.modified).compareTo(dateFormat.format(thresholdDate)) > 0) {
        continue;
      }

      _writeToConsole('Deleting old log file: ${item.path}');
      await item.delete();
    }
  }
}
