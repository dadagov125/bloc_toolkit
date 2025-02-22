import 'package:bloc_toolkit/bloc_toolkit.dart';

extension DataStateExtention<Data> on DataS<Data> {
  bool get isUnloaded => this is UnloadedS;

  bool get isLoading => this is LoadingS;

  bool get isSubmitting => this is SubmittingDataS;

  bool get isLoaded => this is LoadedS;

  bool get isError => this is ErrorS;
}
