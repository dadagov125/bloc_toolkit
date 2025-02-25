import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_toolkit/bloc_toolkit.dart';
import 'package:meta/meta.dart';

part 'submit_event.dart';

part 'submit_state.dart';

typedef OnSubmitError<Request> = void Function(
  DataException error,
  SubmitE<Request> event,
  Emitter<SubmitS<Request>> emit,
);

void _$onSubmitError<Request>(
  DataException error,
  SubmitE<Request> event,
  Emitter<SubmitS<Request>> emit,
) {
  emit(SubmitErrorS<Request>(error: error, request: event.request));
  emit(SubmitReadyS<Request>());
}

abstract class SubmitBloc<Request, Response>
    extends Bloc<SubmitE<Request>, SubmitS<Request>> {
  SubmitBloc({
    OnSubmitError<Request>? overridedOnSubmitError,
    EventTransformer<SubmitE<Request>>? transformer,
  })  : _onSubmitError = overridedOnSubmitError ?? _$onSubmitError,
        super(SubmitReadyS()) {
    on<SubmitE<Request>>(
      _handleEvent,
      transformer: transformer,
    );
  }

  final OnSubmitError<Request> _onSubmitError;

  FutureOr<void> _handleEvent(
    SubmitE<Request> event,
    Emitter<SubmitS<Request>> emit,
  ) async {
    try {
      emit(SubmittingS(event.request));
      final response = await submit(event);
      emit(SubmittedS(request: event.request, response: response));
    } on DataException catch (error) {
      _onSubmitError(
        error,
        event,
        emit,
      );
    } on Object catch (error, stackTrace) {
      _onSubmitError(
        UnhandledDataException(error: error, stackTrace: stackTrace),
        event,
        emit,
      );
    }
  }

  Future<Response> submit(SubmitE<Request> event);
}
