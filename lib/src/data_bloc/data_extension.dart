part of 'data_bloc.dart';

extension DataSExtension<Data> on DataS<Data> {
  bool get isIdle => this is IdleS<Data>;

  bool get isLoading => this is LoadingS<Data>;

  bool get isError => this is ErrorS<Data>;
}
