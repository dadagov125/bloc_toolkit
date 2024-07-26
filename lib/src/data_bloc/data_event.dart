part of 'data_bloc.dart';

@immutable
abstract class DataE<Params> {
  const DataE({this.params});

  final Params? params;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataE &&
          runtimeType == other.runtimeType &&
          params == other.params;

  @override
  int get hashCode => params.hashCode;
}

@immutable
class LoadDataE<Params> extends DataE<Params> {
  const LoadDataE({Params? params}) : super(params: params);
}

@immutable
class ReloadDataE<Params> extends LoadDataE<Params> {
  const ReloadDataE({this.isNextLoading = false, Params? params})
      : super(params: params);

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

@immutable
class UpdateDataE<Data, Params> extends DataE<Params> {
  const UpdateDataE(this.update, {Params? params}) : super(params: params);

  final Data Function(Data oldData) update;
}

@immutable
class InitializeDataE<Data, Params> extends DataE<Params> {
  const InitializeDataE(this.data, {Params? params}) : super(params: params);

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
