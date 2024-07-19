part of 'data_bloc.dart';

abstract class DataE {
  const DataE();
}

class LoadDataE extends DataE {
  const LoadDataE();
}

@immutable
class ReloadDataE extends LoadDataE {
  const ReloadDataE({this.isNextLoading = true});

  final bool isNextLoading;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReloadDataE &&
          runtimeType == other.runtimeType &&
          isNextLoading == other.isNextLoading;

  @override
  int get hashCode => isNextLoading.hashCode;
}

class UpdateDataE<Data> extends DataE {
  const UpdateDataE(this.update);

  final Data Function(Data old) update;
}

@immutable
class InitializeDataE<Data> extends DataE {
  const InitializeDataE(this.data);

  final Data data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InitializeDataE &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}
