//ignore_for_file: lines_longer_than_80_chars, one_member_abstracts
// ignore_for_file: unreachable_from_main, discarded_futures

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_toolkit/bloc_toolkit.dart';
import 'package:bloc_toolkit/src/data_bloc/data_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

abstract class DataRepository {
  Future<int?> loadData(String params);

  Future<int?> submitData(String params);
}

class TestInternalDataBloc extends InternalDataBloc<int, String> {
  TestInternalDataBloc(this.repository) : super();
  final DataRepository repository;

  @override
  FutureOr<int?> loadData(DataS<int> oldState, LoadDataE<String> event) =>
      repository.loadData(event.params!);

  @override
  FutureOr<int?> submitData(
    LoadedS<int, String> oldState,
    SubmitDataE<int, String> event,
  ) =>
      repository.submitData(event.params!);
}

class MockDataException extends Mock implements DataException {}

class MockDataRepository extends Mock implements DataRepository {}

class MockDataS extends Mock implements DataS<int> {}

class MockIdleS extends Mock implements IdleS<int> {}

class MockLoadingS extends Mock implements LoadingS<int> {}

// ignore: avoid_implementing_value_types
class MockErrorS extends Mock implements ErrorS<int> {}

abstract class ListRepository {
  Future<List<int>> loadData();
}

class MockListRepository extends Mock implements ListRepository {}

class TestListBloc extends ListBloc<int> {
  TestListBloc({
    required this.repository,
    List<int>? initialList,
    ListParams<int>? initialParams,
  }) : super(
          initialList: initialList,
          initialParams: initialParams,
        );

  final ListRepository repository;

  @override
  FutureOr<List<int>> loadData(
    DataS<List<int>> oldState,
    LoadDataE<ListParams<int>> event,
  ) =>
      repository.loadData();
}

class IntComparator extends Comparator<int> {
  @override
  int compare(int a, int b) => a.compareTo(b);
}

class IntFilterPredicate extends FilterPredicate<int> {
  IntFilterPredicate(this.filterList);

  final List<int> filterList;

  @override
  bool test(int e) => filterList.contains(e);
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
        'emits [LoadingDataS, UnloadedDataS] on LoadDataE when loadData return null',
        build: () => bloc,
        setUp: () {
          when(() => repository.loadData(any())).thenAnswer((_) async => null);
        },
        act: (bloc) => bloc.add(const LoadDataE(params: 'test')),
        expect: () => [
          isA<LoadingDataS<int>>(),
          isA<UnloadedDataS<int>>(),
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
        'emits [ReloadingDataS, LoadedDataSuccessS(with update data)] on ReloadDataE when loadData return data',
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
        'emits [ReloadingDataS, LoadedDataSuccessS(without update data)] on ReloadDataE when loadData return null',
        build: () => bloc,
        seed: () => const LoadedDataS<int, String>(0, params: 'test'),
        setUp: () {
          when(() => repository.loadData(any())).thenAnswer((_) async => null);
        },
        act: (bloc) => bloc.add(
          const ReloadDataE(params: 'test2', isNextLoading: true),
        ),
        expect: () => [
          isA<ReloadingDataS<int, String>>()
              .having((s) => s.isNextLoading, 'isNextLoading', true)
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test2'),
          isA<LoadedDataS<int, String>>()
              .having((s) => s.data, 'data', 0)
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
              .having((s) => s.error, 'error', isA<UnhandledDataException>()),
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

    group('SubmitDataE', () {
      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'nothing emits when state is not LoadedDataS on SubmitDataE',
        build: () => bloc,
        seed: () => const UnloadedDataS<int>(),
        act: (bloc) => bloc.add(const SubmitDataE(1, params: 'test2')),
        expect: () => <DataS<int>>[],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [SubmittingDataS, LoadedDataSuccessS(with update data)] on SubmitDataE when submitData return data',
        build: () => bloc,
        setUp: () {
          when(() => repository.submitData(any()))
              .thenAnswer((_) => Future.value(123));
        },
        seed: () => const LoadedDataS<int, String>(0, params: 'test'),
        act: (bloc) => bloc.add(const SubmitDataE(1, params: 'test2')),
        expect: () => [
          isA<SubmittingDataS<int, String>>()
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test2'),
          isA<LoadedDataS<int, String>>()
              .having((s) => s.data, 'data', 123)
              .having((s) => s.params, 'params', 'test2'),
        ],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [SubmittingDataS, LoadedDataSuccessS(without update data)] on SubmitDataE when submitData return null',
        build: () => bloc,
        setUp: () {
          when(() => repository.submitData(any()))
              .thenAnswer((_) => Future.value());
        },
        seed: () => const LoadedDataS<int, String>(0, params: 'test'),
        act: (bloc) => bloc.add(const SubmitDataE(1, params: 'test2')),
        expect: () => [
          isA<SubmittingDataS<int, String>>()
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test2'),
          isA<LoadedDataS<int, String>>()
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test2'),
        ],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [SubmittingDataS, SubmittingDataErrorS] on SubmitDataE with DataException',
        build: () => bloc,
        setUp: () {
          when(() => repository.submitData(any()))
              .thenThrow(MockDataException());
        },
        seed: () => const LoadedDataS<int, String>(0, params: 'test'),
        act: (bloc) => bloc.add(const SubmitDataE(1, params: 'test2')),
        expect: () => [
          isA<SubmittingDataS<int, String>>()
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test2'),
          isA<SubmittingDataErrorS<int, String>>()
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test2')
              .having((s) => s.error, 'error', isA<DataException>()),
          isA<LoadedDataS<int, String>>()
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test'),
        ],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [SubmittingDataS, SubmittingDataErrorS with UnhandledDataException] on SubmitDataE with unhandled exception',
        build: () => bloc,
        setUp: () {
          when(() => repository.submitData(any())).thenThrow(Exception());
        },
        seed: () => const LoadedDataS<int, String>(0, params: 'test'),
        act: (bloc) => bloc.add(const SubmitDataE(1, params: 'test2')),
        expect: () => [
          isA<SubmittingDataS<int, String>>()
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test2'),
          isA<SubmittingDataErrorS<int, String>>()
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test2')
              .having((s) => s.error, 'error', isA<UnhandledDataException>()),
          isA<LoadedDataS<int, String>>()
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test'),
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
  });

  group('ListBloc', () {
    late TestListBloc bloc;
    late MockListRepository repository;

    final unsortedList = <int>[3, 1, 2, 9, 0, 4, 5, 8, 7, 6];
    final sortedList = <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

    var params = const ListParams<int>();

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
        bloc.add(const SelectE(1));
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
      seed: () => const SelectedS<int>(items: [1, 2, 3], selected: 1),
      act: (bloc) {
        bloc.add(const SelectE(null));
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
      seed: () => const SelectedS<int>(items: [1, 2, 3], selected: 1),
      build: () => bloc,
      act: (bloc) {
        bloc.add(const SelectE(2));
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
