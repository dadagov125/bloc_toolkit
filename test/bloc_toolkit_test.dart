//ignore_for_file: lines_longer_than_80_chars, one_member_abstracts
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_toolkit/bloc_toolkit.dart';
import 'package:bloc_toolkit/src/data_bloc/data_bloc.dart';
import 'package:bloc_toolkit/src/list_bloc/list_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

abstract class DataRepository {
  Future<int> loadData(String params);
}

class TestInternalDataBloc extends InternalDataBloc<int, String> {
  TestInternalDataBloc(this.repository) : super();
  final DataRepository repository;

  @override
  FutureOr<int> loadData(DataS<int> oldState, LoadDataE<String> event) {
    return repository.loadData(event.params!);
  }
}

class MockDataException extends Mock implements DataException {}

class MockDataRepository extends Mock implements DataRepository {}

class MockDataS extends Mock implements DataS<int> {}

class MockIdleS extends Mock implements IdleS<int> {}

class MockLoadingS extends Mock implements LoadingS<int> {}

class MockErrorS extends Mock implements ErrorS<int> {}

abstract class ListRepository {
  Future<List<int>> loadData();
}

class MockListRepository extends Mock implements ListRepository {}

class TestListBloc extends ListBloc<int> {
  TestListBloc({
    List<int>? initialList,
    ListParams<int>? initialParams,
    required this.repository,
  }) : super(
          initialList: initialList,
          initialParams: initialParams,
        );

  final ListRepository repository;

  @override
  FutureOr<List<int>> loadData(
    DataS<List<int>> oldState,
    LoadDataE<ListParams<int>> event,
  ) {
    return repository.loadData();
  }
}

class IntComparator extends Comparator<int> {
  @override
  int compare(int a, int b) {
    return a.compareTo(b);
  }
}

class IntFilterPredicate extends FilterPredicate<int> {
  IntFilterPredicate(this.filterList);

  final List<int> filterList;

  @override
  bool test(int e) {
    return filterList.contains(e);
  }
}

void main() {
  group('DataBloc', () {
    late TestInternalDataBloc bloc;
    late MockDataRepository repository;

    setUp(() {
      repository = MockDataRepository();
      bloc = TestInternalDataBloc(repository);
      when(() => repository.loadData(any())).thenAnswer((_) async => 1);
    });

    test('initialState is UnloadedDataS', () {
      expect(bloc.state, isA<UnloadedDataS<int>>());
    });

    group('LoadDataE', () {
      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'nothing emits when state is not UnloadedDataS on LoadDataE',
        build: () => bloc,
        seed: () => const LoadedDataS<int, String>(1, params: 'test'),
        act: (bloc) => bloc.add(const LoadDataE(params: 'test')),
        expect: () => <DataS<int>>[],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [LoadingDataS, LoadedDataSuccessS] on LoadDataE',
        build: () => bloc,
        act: (bloc) => bloc.add(const LoadDataE(params: 'test')),
        expect: () => [
          isA<LoadingDataS<int>>(),
          isA<LoadedDataS<int, String>>()
              .having((s) => s.data, 'data', 1)
              .having((s) => s.params, 'params', 'test'),
        ],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [LoadingDataS, LoadingDataErrorS, UnloadedDataS] on LoadDataE with DataException',
        build: () => bloc,
        setUp: () {
          when(() => repository.loadData(any())).thenThrow(MockDataException());
        },
        act: (bloc) => bloc.add(const LoadDataE(params: 'test')),
        expect: () => [
          isA<LoadingDataS<int>>(),
          isA<LoadingDataErrorS<int, String>>()
              .having((s) => s.error, 'error', isA<DataException>())
              .having((s) => s.params, 'params', 'test'),
          isA<UnloadedDataS<int>>(),
        ],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [LoadingDataS, LoadingDataErrorS with UnhandledDataException, UnloadedDataS] on LoadDataE with unhandled exception',
        build: () => bloc,
        setUp: () {
          when(() => repository.loadData(any())).thenThrow(Exception());
        },
        act: (bloc) => bloc.add(const LoadDataE(params: 'test')),
        expect: () => [
          isA<LoadingDataS<int>>(),
          isA<LoadingDataErrorS<int, String>>()
              .having((s) => s.error, 'error', isA<UnhandledDataException>())
              .having((s) => s.params, 'params', 'test'),
          isA<UnloadedDataS<int>>(),
        ],
      );
    });

    group('ReloadDataE', () {
      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'nothing emits when state is not LoadedDataS on ReloadDataE',
        build: () => bloc,
        seed: () => const UnloadedDataS(),
        act: (bloc) => bloc.add(const ReloadDataE(params: 'test2')),
        expect: () => <DataS<int>>[],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [ReloadingDataS, LoadedDataSuccessS] on ReloadDataE',
        build: () => bloc,
        seed: () => const LoadedDataS<int, String>(0, params: 'test'),
        act: (bloc) => bloc.add(
          const ReloadDataE(params: 'test2', isNextLoading: true),
        ),
        expect: () => [
          isA<ReloadingDataS<int, String>>()
              .having((s) => s.isNextLoading, 'isNextLoading', true)
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test2'),
          isA<LoadedDataS<int, String>>()
              .having((s) => s.data, 'data', 1)
              .having((s) => s.params, 'params', 'test2'),
        ],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [ReloadingDataS, ReloadingDataErrorS] on ReloadDataE with DataException',
        build: () => bloc,
        setUp: () {
          when(() => repository.loadData(any())).thenThrow(MockDataException());
        },
        seed: () => const LoadedDataS<int, String>(0, params: 'test1'),
        act: (bloc) => bloc.add(
          const ReloadDataE(params: 'test2', isNextLoading: true),
        ),
        expect: () => [
          isA<ReloadingDataS<int, String>>()
              .having((s) => s.isNextLoading, 'isNextLoading', true)
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test2'),
          isA<ReloadingDataErrorS<int, String>>()
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test2')
              .having((s) => s.error, 'error', isA<DataException>()),
          isA<LoadedDataS<int, String>>()
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test1'),
        ],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [ReloadingDataS, ReloadingDataErrorS with UnhandledDataException, LoadedDataS ] on LoadDataE with unhandled exception',
        build: () => bloc,
        seed: () => const LoadedDataS<int, String>(0, params: 'test1'),
        setUp: () {
          when(() => repository.loadData(any())).thenThrow(Exception());
        },
        act: (bloc) => bloc.add(
          const ReloadDataE(params: 'test2', isNextLoading: true),
        ),
        expect: () => [
          isA<ReloadingDataS<int, String>>()
              .having((s) => s.isNextLoading, 'isNextLoading', true)
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test2'),
          isA<ReloadingDataErrorS<int, String>>()
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test2')
              .having((s) => s.error, 'error', isA<DataException>()),
          isA<LoadedDataS<int, String>>()
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test1'),
        ],
      );
    });

    group('UpdateDataE', () {
      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'nothing emits when state is not LoadedDataS on UnloadedDataS',
        build: () => bloc,
        seed: () => const UnloadedDataS(),
        act: (bloc) => bloc.add(const ReloadDataE(params: 'test2')),
        expect: () => <DataS<int>>[],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [LoadedDataS] on UpdateDataE',
        build: () => bloc,
        seed: () => const LoadedDataS<int, String>(0, params: 'test1'),
        act: (bloc) => bloc.add(UpdateDataE((data) => 1, params: 'test2')),
        expect: () => [
          isA<LoadedDataS<int, String>>()
              .having((s) => s.data, 'data', 1)
              .having((s) => s.params, 'params', 'test2'),
        ],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [ ReloadingDataErrorS with UnhandledDataException, LoadedDataS ] on UpdateDataE with unhandled exception',
        build: () => bloc,
        seed: () => const LoadedDataS<int, String>(0, params: 'test1'),
        act: (bloc) => bloc.add(
          UpdateDataE(
            (data) {
              throw Exception();
            },
            params: 'test2',
          ),
        ),
        expect: () => [
          isA<ReloadingDataErrorS<int, String>>()
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test2')
              .having((s) => s.error, 'error', isA<DataException>()),
          isA<LoadedDataS<int, String>>()
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test1'),
        ],
      );
    });

    group('InitializeDataE', () {
      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'nothing emits when state is not UnloadedDataS on InitializeDataE',
        build: () => bloc,
        seed: () => const LoadedDataS<int, String>(0, params: 'test1'),
        act: (bloc) => bloc.add(const InitializeDataE(1, params: 'test2')),
        expect: () => <DataS<int>>[],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [LoadedDataS] on InitializeDataE',
        build: () => bloc,
        act: (bloc) => bloc.add(const InitializeDataE(1, params: 'test1')),
        expect: () => [
          isA<LoadedDataS<int, String>>()
              .having((s) => s.data, 'data', 1)
              .having((s) => s.params, 'params', 'test1'),
        ],
      );
    });

    //-----data
    group('union -> dataMap', () {
      DataS<int> getStateFromDataMap(DataS<int> state) {
        return dataMap<DataS<int>, int>(
          state,
          idle: (s) => s,
          loading: (s) => s,
          error: (s) => s,
        );
      }

      test('[LoadedDataS]  is [IdleS] on dataMap ', () {
        final state = getStateFromDataMap(LoadedDataS(0, params: null));
        expect(state, isA<IdleS<int>>());
      });

      test('[UnloadedDataS] is [IdleS] on dataMap ', () {
        final state = getStateFromDataMap(UnloadedDataS());
        expect(state, isA<IdleS<int>>());
      });

      test('[LoadingDataS]  is [LoadingS] on dataMap ', () {
        final state = getStateFromDataMap(LoadingDataS());
        expect(state, isA<LoadingS<int>>());
      });

      test('[ReloadingDataS] is [LoadingS] on dataMap ', () {
        final state = getStateFromDataMap(
          ReloadingDataS(LoadedDataS(0), isNextLoading: true),
        );
        expect(state, isA<LoadingS<int>>());
      });

      test('[LoadingDataErrorS]  is [ErrorS] on dataMap ', () {
        final state =
            getStateFromDataMap(LoadingDataErrorS(MockDataException()));
        expect(state, isA<ErrorS<int>>());
      });

      test('[ReloadingDataErrorS] is [ErrorS] on dataMap ', () {
        final state = getStateFromDataMap(
          ReloadingDataErrorS(LoadedDataS(0), MockDataException()),
        );
        expect(state, isA<ErrorS<int>>());
      });
    });

    group('union -> dataMaybeMap', () {
      DataS<int> getStateFromDataMaybeMap(DataS<int> state) {
        return dataMaybeMap<DataS<int>, int>(
          state,
          idle: (s) => s,
          loading: (s) => s,
          error: (s) => s,
          orElse: () => throw Exception('Unknown type'),
        );
      }

      test('[LoadedDataS]  is [IdleS] on dataMaybeMap ', () {
        final state = getStateFromDataMaybeMap(LoadedDataS(0, params: null));
        expect(state, isA<IdleS<int>>());
      });

      test('[UnloadedDataS] is [IdleS] on dataMaybeMap ', () {
        final state = getStateFromDataMaybeMap(UnloadedDataS());
        expect(state, isA<IdleS<int>>());
      });

      test('[LoadingDataS]  is [LoadingS] on dataMaybeMap ', () {
        final state = getStateFromDataMaybeMap(LoadingDataS());
        expect(state, isA<LoadingS<int>>());
      });

      test('[ReloadingDataS] is [LoadingS] on dataMaybeMap ', () {
        final state = getStateFromDataMaybeMap(
          ReloadingDataS(LoadedDataS(0), isNextLoading: true),
        );
        expect(state, isA<LoadingS<int>>());
      });

      test('[LoadingDataErrorS]  is [ErrorS] on dataMaybeMap ', () {
        final state =
            getStateFromDataMaybeMap(LoadingDataErrorS(MockDataException()));
        expect(state, isA<ErrorS<int>>());
      });

      test('[ReloadingDataErrorS] is [ErrorS] on dataMaybeMap ', () {
        final state = getStateFromDataMaybeMap(
          ReloadingDataErrorS(LoadedDataS(0), MockDataException()),
        );
        expect(state, isA<ErrorS<int>>());
      });

      test('throws exception on unknown type', () {
        expect(
          () => getStateFromDataMaybeMap(MockDataS()),
          throwsException,
        );
      });
    });

    group('union -> dataMapOrNull', () {
      DataS<int>? getStateFromDataMapOrNull(DataS<int> state) {
        return dataMapOrNull<DataS<int>, int>(
          state,
          idle: (s) => s,
          loading: (s) => s,
          error: (s) => s,
        );
      }

      test('[LoadedDataS]  is [IdleS] on dataMapOrNull ', () {
        final state = getStateFromDataMapOrNull(LoadedDataS(0, params: null));
        expect(state, isA<IdleS<int>>());
      });

      test('[UnloadedDataS] is [IdleS] on dataMapOrNull ', () {
        final state = getStateFromDataMapOrNull(UnloadedDataS());
        expect(state, isA<IdleS<int>>());
      });

      test('[LoadingDataS]  is [LoadingS] on dataMapOrNull ', () {
        final state = getStateFromDataMapOrNull(LoadingDataS());
        expect(state, isA<LoadingS<int>>());
      });

      test('[ReloadingDataS] is [LoadingS] on dataMapOrNull ', () {
        final state = getStateFromDataMapOrNull(
          ReloadingDataS(LoadedDataS(0), isNextLoading: true),
        );
        expect(state, isA<LoadingS<int>>());
      });

      test('[LoadingDataErrorS]  is [ErrorS] on dataMapOrNull ', () {
        final state =
            getStateFromDataMapOrNull(LoadingDataErrorS(MockDataException()));
        expect(state, isA<ErrorS<int>>());
      });

      test('[ReloadingDataErrorS] is [ErrorS] on dataMapOrNull ', () {
        final state = getStateFromDataMapOrNull(
          ReloadingDataErrorS(LoadedDataS(0), MockDataException()),
        );
        expect(state, isA<ErrorS<int>>());
      });

      test('returns null on unknown type', () {
        final state = getStateFromDataMapOrNull(MockDataS());
        expect(state, isNull);
      });
    });

    //----- Idle
    group('union -> idleMap', () {
      IdleS<int> getStateFromIdleMap(IdleS<int> state) {
        return idleMap<IdleS<int>, int, void>(
          state,
          loaded: (s) => s,
          unloaded: (s) => s,
        );
      }

      test('[LoadedDataS]  is [LoadedDataS] on idleMap ', () {
        final state = getStateFromIdleMap(LoadedDataS(0, params: null));
        expect(state, isA<LoadedDataS<int, void>>());
      });

      test('[UnloadedDataS] is [UnloadedDataS] on idleMap ', () {
        final state = getStateFromIdleMap(UnloadedDataS());
        expect(state, isA<UnloadedDataS<int>>());
      });

      test('throws exception on unknown type', () {
        expect(
          () => getStateFromIdleMap(MockIdleS()),
          throwsException,
        );
      });
    });

    group('union -> idleMaybeMap', () {
      IdleS<int> getStateFromIdleMaybeMap(IdleS<int> state) {
        return idleMaybeMap<IdleS<int>, int, void>(
          state,
          loaded: (s) => s,
          unloaded: (s) => s,
          orElse: () => throw Exception('Unknown type'),
        );
      }

      test('[LoadedDataS]  is [LoadedDataS] on idleMaybeMap ', () {
        final state = getStateFromIdleMaybeMap(LoadedDataS(0, params: null));
        expect(state, isA<LoadedDataS<int, void>>());
      });

      test('[UnloadedDataS] is [UnloadedDataS] on idleMaybeMap ', () {
        final state = getStateFromIdleMaybeMap(UnloadedDataS());
        expect(state, isA<UnloadedDataS<int>>());
      });

      test('throws exception on unknown type', () {
        expect(
          () => getStateFromIdleMaybeMap(MockIdleS()),
          throwsException,
        );
      });
    });

    group('union -> idleMapOrNull', () {
      IdleS<int>? getStateFromIdleMapOrNull(IdleS<int> state) {
        return idleMapOrNull<IdleS<int>, int, void>(
          state,
          loaded: (s) => s,
          unloaded: (s) => s,
        );
      }

      test('[LoadedDataS]  is [LoadedDataS] on idleMapOrNull ', () {
        final state = getStateFromIdleMapOrNull(LoadedDataS(0, params: null));
        expect(state, isA<LoadedDataS<int, void>>());
      });

      test('[UnloadedDataS] is [UnloadedDataS] on idleMapOrNull ', () {
        final state = getStateFromIdleMapOrNull(UnloadedDataS());
        expect(state, isA<UnloadedDataS<int>>());
      });

      test('returns null on unknown type', () {
        final state = getStateFromIdleMapOrNull(MockIdleS());
        expect(state, isNull);
      });
    });

    //------- Loading

    group('union -> loadingMap', () {
      LoadingS<int> getStateFromLoadingMap(LoadingS<int> state) {
        return loadingMap<LoadingS<int>, int, void>(
          state,
          reloading: (s) => s,
          loading: (s) => s,
        );
      }

      test('[ReloadingDataS]  is [ReloadingDataS] on loadingMap ', () {
        final state = getStateFromLoadingMap(
          ReloadingDataS(LoadedDataS(0), isNextLoading: true),
        );
        expect(state, isA<ReloadingDataS<int, void>>());
      });

      test('[LoadingDataS] is [LoadingDataS] on loadingMap ', () {
        final state = getStateFromLoadingMap(LoadingDataS());
        expect(state, isA<LoadingDataS<int>>());
      });

      test('throws exception on unknown type', () {
        expect(
          () => getStateFromLoadingMap(MockLoadingS()),
          throwsException,
        );
      });
    });

    group('union -> loadingMaybeMap', () {
      LoadingS<int> getStateFromLoadingMaybeMap(LoadingS<int> state) {
        return loadingMaybeMap<LoadingS<int>, int, void>(
          state,
          reloading: (s) => s,
          loading: (s) => s,
          orElse: () => throw Exception('Unknown type'),
        );
      }

      test('[ReloadingDataS]  is [ReloadingDataS] on loadingMaybeMap ', () {
        final state = getStateFromLoadingMaybeMap(
          ReloadingDataS(LoadedDataS(0), isNextLoading: true),
        );
        expect(state, isA<ReloadingDataS<int, void>>());
      });

      test('[LoadingDataS] is [LoadingDataS] on loadingMaybeMap ', () {
        final state = getStateFromLoadingMaybeMap(LoadingDataS());
        expect(state, isA<LoadingDataS<int>>());
      });

      test('throws exception on unknown type', () {
        expect(
          () => getStateFromLoadingMaybeMap(MockLoadingS()),
          throwsException,
        );
      });
    });

    group('union -> loadingMapOrNull', () {
      LoadingS<int>? getStateFromLoadingMapOrNull(LoadingS<int> state) {
        return loadingMapOrNull<LoadingS<int>, int, void>(
          state,
          reloading: (s) => s,
          loading: (s) => s,
        );
      }

      test('[ReloadingDataS]  is [ReloadingDataS] on loadingMapOrNull ', () {
        final state = getStateFromLoadingMapOrNull(
          ReloadingDataS(LoadedDataS(0), isNextLoading: true),
        );
        expect(state, isA<ReloadingDataS<int, void>>());
      });

      test('[LoadingDataS] is [LoadingDataS] on loadingMapOrNull ', () {
        final state = getStateFromLoadingMapOrNull(LoadingDataS());
        expect(state, isA<LoadingDataS<int>>());
      });

      test('returns null on unknown type', () {
        final state = getStateFromLoadingMapOrNull(MockLoadingS());
        expect(state, isNull);
      });
    });

    //----- Error
    group('union -> errorMap', () {
      ErrorS<int> getStateFromErrorMap(ErrorS<int> state) {
        return errorMap<ErrorS<int>, int, void>(
          state,
          loadingError: (s) => s,
          reloadingError: (s) => s,
        );
      }

      test('[LoadingDataErrorS]  is [LoadingDataErrorS] on errorMap ', () {
        final state =
            getStateFromErrorMap(LoadingDataErrorS(MockDataException()));
        expect(state, isA<LoadingDataErrorS<int, void>>());
      });

      test('[ReloadingDataErrorS] is [ReloadingDataErrorS] on errorMap ', () {
        final state = getStateFromErrorMap(
          ReloadingDataErrorS(LoadedDataS(0), MockDataException()),
        );
        expect(state, isA<ReloadingDataErrorS<int, void>>());
      });

      test('throws exception on unknown type', () {
        expect(
          () => getStateFromErrorMap(MockErrorS()),
          throwsException,
        );
      });
    });
  });

  group('ListBloc', () {
    late TestListBloc bloc;
    late MockListRepository repository;

    final List<int> unsortedList = [3, 1, 2, 9, 0, 4, 5, 8, 7, 6];
    final List<int> sortedList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

    ListParams<int> params = ListParams();

    setUp(() {
      repository = MockListRepository();
      // bloc = TestListBloc(repository: repository);
      when(() => repository.loadData()).thenAnswer((_) async => unsortedList);
    });

    test(
        'initialState is [LoadedDataS] without [ListParams] and [initialList] is [not modified] when passed without [ListParams]',
        () {
      bloc = TestListBloc(
        repository: repository,
        initialList: unsortedList,
      );
      expect(
        bloc.state,
        isA<LoadedDataS<List<int>, ListParams<int>>>()
            .having((s) => s.data, 'data', unsortedList)
            .having((s) => s.params, 'params', null),
      );
    });

    test(
        'initialState is [LoadedDataS] with [ListParams] and [initialList] is [sorted] when passed with [ListParams(IntComparator)]',
        () {
      params = ListParams(comparator: IntComparator());
      bloc = TestListBloc(
        repository: repository,
        initialList: unsortedList,
        initialParams: params,
      );
      expect(
        bloc.state,
        isA<LoadedDataS<List<int>, ListParams<int>>>()
            .having((s) => s.data, 'data', sortedList)
            .having((s) => s.params, 'params', params),
      );
    });

    test(
        'initialState is [LoadedDataS] with [ListParams] and [initialList] is [filtered] when passed with [ListParams(IntFilterPredicate)]',
        () {
      params = ListParams<int>(
        filters: [
          IntFilterPredicate([1]),
        ],
      );
      bloc = TestListBloc(
        repository: repository,
        initialList: unsortedList,
        initialParams: params,
      );
      expect(
        bloc.state,
        isA<LoadedDataS<List<int>, ListParams<int>>>()
            .having((s) => s.data.length, 'data.length', 1)
            .having((s) => s.data, 'data', [1]).having(
          (s) => s.params,
          'params',
          params,
        ),
      );
    });

    test(
        'initialState is [LoadedDataS] with [ListParams] and [initialList] is [sorted, filtered] when passed with [ListParams(IntComparator, IntFilterPredicate)]',
        () {
      params = ListParams<int>(
        filters: [
          IntFilterPredicate([1, 2, 3, 4, 5]),
        ],
        comparator: IntComparator(),
      );
      bloc = TestListBloc(
        repository: repository,
        initialList: unsortedList,
        initialParams: params,
      );
      expect(
        bloc.state,
        isA<LoadedDataS<List<int>, ListParams<int>>>()
            .having((s) => s.data.length, 'data.length', 5)
            .having((s) => s.data, 'data', [1, 2, 3, 4, 5]).having(
          (s) => s.params,
          'params',
          params,
        ),
      );
    });

    blocTest<TestListBloc, DataS<List<int>>>(
      'emits [LoadedDataS] on [InitializeDataE] and [data]  is [sorted, filtered] with [ListParams(IntComparator, IntFilterPredicate)]',
      setUp: () {
        params = ListParams<int>(
          filters: [
            IntFilterPredicate([1, 2, 3, 4, 5]),
          ],
          comparator: IntComparator(),
        );
        bloc = TestListBloc(repository: repository);
      },
      build: () => bloc,
      act: (bloc) {
        bloc.add(InitializeDataE(unsortedList, params: params));
      },
      expect: () => [
        isA<LoadedDataS<List<int>, ListParams<int>>>()
            .having((s) => s.data.length, 'data.length', 5)
            .having((s) => s.data, 'data', [1, 2, 3, 4, 5]).having(
          (s) => s.params,
          'params',
          params,
        ),
      ],
    );

    blocTest<TestListBloc, DataS<List<int>>>(
      'emits [LoadedDataS, LoadedDataS] on [InitializeDataE, ApplyParamsE(UpdateDataE)] and data  is [sorted, filtered] with [ListParams(IntComparator, IntFilterPredicate)]',
      setUp: () {
        params = ListParams<int>(
          filters: [
            IntFilterPredicate([1, 2, 3, 4, 5]),
          ],
          comparator: IntComparator(),
        );
        bloc = TestListBloc(repository: repository);
      },
      build: () => bloc,
      act: (bloc) async {
        bloc.add(
          InitializeDataE(
            unsortedList,
          ),
        );
        bloc.add(ApplyParamsE(params));
      },
      expect: () => [
        isA<LoadedDataS<List<int>, ListParams<int>>>()
            .having((s) => s.data, 'data', unsortedList)
            .having((s) => s.params, 'params', null),
        isA<LoadedDataS<List<int>, ListParams<int>>>()
            .having((s) => s.data.length, 'data.length', 5)
            .having((s) => s.data, 'data', [1, 2, 3, 4, 5]).having(
          (s) => s.params,
          'params',
          params,
        ),
      ],
    );
  });

  group(SelectBloc, () {
    late SelectBloc<int> bloc;

    test(
        ' when initialize with [selected] state is [SelectedS] with [selected]',
        () {
      bloc = SelectBloc<int>(items: [1, 2, 3], selected: 1);
      expect(
        bloc.state,
        isA<SelectedS<int>>()
            .having((s) => s.items, 'items', [1, 2, 3])
            .having((s) => s.selected, 'selected', 1)
            .having(
              (s) => s.items.contains(s.selected),
              'items contains selected',
              true,
            ),
      );
    });

    test(' when initialize without [selected] state is [SelectS]', () {
      bloc = SelectBloc<int>(
        items: [1, 2, 3],
      );
      expect(
        bloc.state,
        isA<SelectS<int>>().having((s) => s.items, 'items', [1, 2, 3]),
      );
    });

    blocTest<SelectBloc<int>, SelectS<int>>(
      'emits [SelectedS] on [SelectE] with [selected]',
      setUp: () {
        bloc = SelectBloc<int>(
          items: [1, 2, 3],
        );
      },
      build: () => bloc,
      act: (bloc) {
        bloc.add(SelectE(1));
      },
      expect: () => [
        isA<SelectedS<int>>()
            .having((s) => s.items, 'items', [1, 2, 3])
            .having((s) => s.selected, 'selected', 1)
            .having(
              (s) => s.items.contains(s.selected),
              'items contains selected',
              true,
            ),
      ],
    );

    blocTest<SelectBloc<int>, SelectS<int>>(
      'emits [SelectE] on [SelectE] without [selected]',
      setUp: () {
        bloc = SelectBloc<int>(
          items: [1, 2, 3],
        );
      },
      build: () => bloc,
      seed: () => SelectedS<int>(items: [1, 2, 3], selected: 1),
      act: (bloc) {
        bloc.add(SelectE(null));
      },
      expect: () => [
        isA<SelectS<int>>().having((s) => s.items, 'items', [1, 2, 3]),
      ],
    );

    blocTest<SelectBloc<int>, SelectS<int>>(
      'emits [SelectedS] when state is [SelectedS] on [SelectE] with [selected]',
      setUp: () {
        bloc = SelectBloc<int>(
          items: [1, 2, 3],
        );
      },
      seed: () => SelectedS<int>(items: [1, 2, 3], selected: 1),
      build: () => bloc,
      act: (bloc) {
        bloc.add(SelectE(2));
      },
      expect: () => [
        isA<SelectedS<int>>()
            .having((s) => s.items, 'items', [1, 2, 3])
            .having((s) => s.selected, 'selected', 2)
            .having(
              (s) => s.items.contains(s.selected),
              'items contains selected',
              true,
            ),
      ],
    );
  });
}
