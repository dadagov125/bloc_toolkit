part of 'data_bloc.dart';

//----- Data
R? dataMapOrNull<R, Data>(
  DataS<Data> state, {
  R Function(IdleS<Data>)? idle,
  R Function(LoadingS<Data>)? loading,
  R Function(ErrorS<Data>)? error,
}) {
  if (state.isIdle) {
    return idle?.call(state as IdleS<Data>);
  } else if (state.isLoading) {
    return loading?.call(state as LoadingS<Data>);
  } else if (state.isError) {
    return error?.call(state as ErrorS<Data>);
  } else {
    return null;
  }
}

R dataMaybeMap<R, Data>({
  required DataS<Data> state,
  required R Function(IdleS<Data>) idle,
  required R Function(LoadingS<Data>) loading,
  required R Function(ErrorS<Data>) error,
  required R Function() orElse,
}) {
  if (state.isIdle) {
    return idle(state as IdleS<Data>);
  } else if (state.isLoading) {
    return loading(state as LoadingS<Data>);
  } else if (state.isError) {
    return error(state as ErrorS<Data>);
  } else {
    return orElse();
  }
}

R dataMap<R, Data>({
  required DataS<Data> state,
  required R Function(IdleS<Data>) idle,
  required R Function(LoadingS<Data>) loading,
  required R Function(ErrorS<Data>) error,
}) {
  if (state.isIdle) {
    return idle(state as IdleS<Data>);
  } else if (state.isLoading) {
    return loading(state as LoadingS<Data>);
  } else if (state.isError) {
    return error(state as ErrorS<Data>);
  } else {
    throw Exception('Unknown type');
  }
}

//----- Idle

R? idleMapOrNull<R, Data, Params>(
  IdleS<Data> state, {
  R Function(LoadedDataS<Data, Params>)? loaded,
  R Function(UnloadedDataS<Data>)? unloaded,
}) {
  if (state is LoadedDataS) {
    return loaded?.call(state as LoadedDataS<Data, Params>);
  } else if (state is UnloadedDataS) {
    return unloaded?.call(state as UnloadedDataS<Data>);
  } else {
    return null;
  }
}

R idleMaybeMap<R, Data, Params>({
  required IdleS<Data> state,
  required R Function(LoadedDataS<Data, Params>) loaded,
  required R Function(UnloadedDataS<Data>) unloaded,
  required R Function() orElse,
}) {
  if (state is LoadedDataS) {
    return loaded(state as LoadedDataS<Data, Params>);
  } else if (state is UnloadedDataS) {
    return unloaded(state as UnloadedDataS<Data>);
  } else {
    return orElse();
  }
}

R idleMap<R, Data, Params>({
  required IdleS<Data> state,
  required R Function(LoadedDataS<Data, Params>) loaded,
  required R Function(UnloadedDataS<Data>) unloaded,
}) {
  if (state is LoadedDataS) {
    return loaded(state as LoadedDataS<Data, Params>);
  } else if (state is UnloadedDataS) {
    return unloaded(state as UnloadedDataS<Data>);
  } else {
    throw Exception('Unknown type');
  }
}

//----- Loading

R? loadingMapOrNull<R, Data, Params>(
  LoadingS<Data> state, {
  R Function(ReloadingDataS<Data, Params>)? reloading,
  R Function(LoadingDataS<Data>)? loading,
}) {
  if (state is ReloadingDataS) {
    return reloading?.call(state as ReloadingDataS<Data, Params>);
  } else if (state is LoadingDataS) {
    return loading?.call(state as LoadingDataS<Data>);
  } else {
    return null;
  }
}

R loadingMaybeMap<R, Data, Params>({
  required LoadingS<Data> state,
  required R Function(ReloadingDataS<Data, Params>) reloading,
  required R Function(LoadingDataS<Data>) loading,
  required R Function() orElse,
}) {
  if (state is ReloadingDataS) {
    return reloading(state as ReloadingDataS<Data, Params>);
  } else if (state is LoadingDataS) {
    return loading(state as LoadingDataS<Data>);
  } else {
    return orElse();
  }
}

R loadingMap<R, Data, Params>({
  required LoadingS<Data> state,
  required R Function(ReloadingDataS<Data, Params>) reloading,
  required R Function(LoadingDataS<Data>) loading,
}) {
  if (state is ReloadingDataS) {
    return reloading(state as ReloadingDataS<Data, Params>);
  } else if (state is LoadingDataS) {
    return loading(state as LoadingDataS<Data>);
  } else {
    throw Exception('Unknown type');
  }
}

//----- Error

R? errorMapOrNull<R, Data, Params>(
  ErrorS<Data> state, {
  R Function(ReloadingDataErrorS<Data, Params>)? reloadingError,
  R Function(LoadingDataErrorS<Data, Params>)? loadingError,
}) {
  if (state is ReloadingDataErrorS) {
    return reloadingError?.call(state as ReloadingDataErrorS<Data, Params>);
  } else if (state is LoadingDataErrorS) {
    return loadingError?.call(state as LoadingDataErrorS<Data, Params>);
  } else {
    return null;
  }
}

R errorMaybeMap<R, Data, Params>({
  required ErrorS<Data> state,
  required R Function(ReloadingDataErrorS<Data, Params>) reloadingError,
  required R Function(LoadingDataErrorS<Data, Params>) loadingError,
  required R Function() orElse,
}) {
  if (state is ReloadingDataErrorS) {
    return reloadingError(state as ReloadingDataErrorS<Data, Params>);
  } else if (state is LoadingDataErrorS) {
    return loadingError(state as LoadingDataErrorS<Data, Params>);
  } else {
    return orElse();
  }
}

R errorMap<R, Data, Params>({
  required ErrorS<Data> state,
  required R Function(ReloadingDataErrorS<Data, Params>) reloadingError,
  required R Function(LoadingDataErrorS<Data, Params>) loadingError,
}) {
  if (state is ReloadingDataErrorS) {
    return reloadingError(state as ReloadingDataErrorS<Data, Params>);
  } else if (state is LoadingDataErrorS) {
    return loadingError(state as LoadingDataErrorS<Data, Params>);
  } else {
    throw Exception('Unknown type');
  }
}
