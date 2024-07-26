//ignore_for_file: lines_longer_than_80_chars, one_member_abstracts
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_toolkit/bloc_toolkit.dart';
import 'package:bloc_toolkit/src/data_bloc/data_bloc.dart';
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
              .having((s) => s.params, 'params', 'test'),
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
              .having((s) => s.params, 'params', 'test1'),
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
              .having((s) => s.params, 'params', 'test1'),
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
  });
}
