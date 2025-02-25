part of 'submit_bloc.dart';

@immutable
abstract class SubmitS<Request> {}

@immutable
class SubmitReadyS<Request> extends SubmitS<Request> {}

@immutable
abstract class _SubmitRequestS<Request> extends SubmitS<Request> {
  _SubmitRequestS(this.request);

  final Request request;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SubmitRequestS &&
          runtimeType == other.runtimeType &&
          request == other.request;

  @override
  int get hashCode => request.hashCode;
}

@immutable
class SubmittingS<Request> extends _SubmitRequestS<Request> {
  SubmittingS(Request request) : super(request);
}

@immutable
class SubmittedS<Request, Response> extends _SubmitRequestS<Request> {
  SubmittedS({
    required Request request,
    required this.response,
  }) : super(request);

  final Response response;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is SubmittedS &&
          runtimeType == other.runtimeType &&
          response == other.response;

  @override
  int get hashCode => super.hashCode ^ response.hashCode;
}

@immutable
class SubmitErrorS<Request> extends _SubmitRequestS<Request> {
  SubmitErrorS({
    required this.error,
    required Request request,
  }) : super(request);

  final DataException error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is SubmitErrorS &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => super.hashCode ^ error.hashCode;
}
