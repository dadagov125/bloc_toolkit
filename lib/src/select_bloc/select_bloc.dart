import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'select_event.dart';

part 'select_state.dart';

class SelectBloc<T> extends Bloc<SelectE<T>, SelectS<T>> {
  SelectBloc({
    List<T> items = const [],
    T? selected,
  }) : super(
          selected != null && items.contains(selected)
              ? SelectedS(selected: selected, items: items)
              : SelectS(items),
        ) {
    on<SelectE<T>>(_select);
  }

  FutureOr<void> _select(SelectE<T> event, Emitter<SelectS<T>> emit) async {
    final item = event.item;
    if (item != null) {
      if (!state.items.contains(item)) {
        return;
      }
      emit(SelectedS(selected: item, items: state.items));
    } else {
      emit(SelectS(state.items));
    }
  }
}
