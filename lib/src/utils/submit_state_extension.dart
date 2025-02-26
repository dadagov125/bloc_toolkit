import 'package:bloc_toolkit/bloc_toolkit.dart';

extension SubmitStateExtention<T> on SubmitS<T> {
  bool get isReady => this is SubmitReadyS;

  bool get isSubmitting => this is SubmittingS;

  bool get isSubmitted => this is SubmittedS;

  bool get isError => this is SubmitErrorS;
}
