part of 'data_bloc.dart';

// ----- Abstraction

abstract class DataS<Data> {
  const DataS();
}

// ----- Interfaces

abstract class Progress<Data> extends DataS<Data> {}

abstract class ProgressFinished<Data> extends DataS<Data> {}

abstract class ProgressError<Data> extends ProgressFinished<Data> {
  abstract final DataException error;
}
