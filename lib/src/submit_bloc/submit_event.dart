part of 'submit_bloc.dart';

@immutable
class SubmitE<Request> {
  const SubmitE(this.request);

  final Request request;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmitE &&
          runtimeType == other.runtimeType &&
          request == other.request;

  @override
  int get hashCode => request.hashCode;
}
