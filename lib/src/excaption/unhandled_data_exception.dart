import 'package:bloc_toolkit/src/excaption/data_exception.dart';

class UnhandledDataException extends DataException {
  const UnhandledDataException({
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace stackTrace;
}
