A very flexible file logger which utilizes "logging" package.

## Features

This package provides a simple and concurrent-safe way to log messages to a file.
It builds on the existing logging package, adding file-handling features such as:

- Splitting logs into multiple files when they exceed a specified size
- Creating a new file for each day
- Automatically deleting old log files after a specified retention period

In addition to file logging, the package supports:
- Writing logs to the console
- Defining custom record handlers for extensibility

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
