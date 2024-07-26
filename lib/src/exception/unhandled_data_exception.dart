import 'package:bloc_toolkit/src/exception/data_exception.dart';

class UnhandledDataException extends DataException {
  const UnhandledDataException({
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace stackTrace;

  @override
  toString() => 'UnhandledDataException: $error';
}
