A very flexible file logger which utilizes "logging" package.

## Features

This package provides a simple way to log messages to a file in a
concurrent-safe manner. It uses the existing "logging" package, but with
added functionalities for file handling, such as splitting logs to multiple
files if bigger than a specified size, creating a new file for each day and
deleting log files if they are older than a certain number of days.

Besides writing log to a file, it also provides an options to write log to
console.

## Getting started

This package is dependent on the "logging" package, so make sure to include it
in your `pubspec.yaml` file:

## Usage

Creating logger:
```dart
void main() {
    final logger = FileLogger(
        logFilePath: 'path/to/log/file.log',
        maxFileSize: 1024 * 1024, // 1 MB
        logToConsole: true,
        logLevel: Level.ALL
    );
}
```

Simple log output:
```dart
void main() {
  logger.info('This is an info message');
}
```

Logging an error:
```dart
void main() {
  try {
    throw Exception('This is a test exception');
  } catch (e, stackTrace) {
    logger.severe('This is a severe message', e, stackTrace);
  }
}
```

Clearing old log files:
```dart
void main() async {
  await logger.deleteOldLogs(7); // Deletes log files older than 7 days
  await logger.clearLogs();
}
```

Custom format for log messages:
```dart
void main() {
    logger.logFormatter =  (LogRecord record, int sequenceNumber) =>
      '${record.time} [${record.level.name}] ($sequenceNumber): ${record.message}\n';
}
```

Custom format for file names:
```dart
void main() {
    logger.fileNameGenerator = (String loggerName, DateTime date) =>
      '${loggerName.isNotEmpty ? '${loggerName}_' : ''}${DateFormat('yyyy-MM-dd').format(date)}';
}
```

Custom record handler:
```dart
void main() {
  logger.recordHandler = (LogRecord record, void Function(LogRecord record) defaultProcessor) {
    defaultProcessor(record);
    print("Perform additional tasks");
  };
}
```

## Additional information

You can find more information about this package on GitHub:
https://github.com/elvedin-hamzagic/file-logs
