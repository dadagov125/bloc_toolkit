import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_toolkit/bloc_toolkit.dart';
import 'package:meta/meta.dart';

part 'submit_event.dart';

part 'submit_state.dart';

typedef onSubmitted<Request, Response> = void Function(
  SubmitE<Request> event,
  Response response,
  Emitter<SubmitS<Request>> emit,
);

void _$onSubmitted<Request, Response>(
  SubmitE<Request> event,
  Response response,
  Emitter<SubmitS<Request>> emit,
) {
  emit(SubmittedS(request: event.request, response: response));
  emit(SubmitReadyS<Request>());
}

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
    onSubmitted<Request, Response>? overridedOnSubmitted,
    EventTransformer<SubmitE<Request>>? transformer,
  })  : _onSubmitError = overridedOnSubmitError ?? _$onSubmitError,
        _onSubmitted = overridedOnSubmitted ?? _$onSubmitted,
        super(SubmitReadyS()) {
    on<SubmitE<Request>>(
      _handleEvent,
      transformer: transformer,
    );
  }

  final OnSubmitError<Request> _onSubmitError;
  final onSubmitted<Request, Response> _onSubmitted;

  FutureOr<void> _handleEvent(
    SubmitE<Request> event,
    Emitter<SubmitS<Request>> emit,
  ) async {
    try {
      emit(SubmittingS(event.request));
      final response = await submit(event);
      _onSubmitted(event, response, emit);
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
