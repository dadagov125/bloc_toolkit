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
        seed: () => const LoadedDataSuccessS<int, String>(1, params: 'test'),
        act: (bloc) => bloc.add(const LoadDataE(params: 'test')),
        expect: () => <DataS<int>>[],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [LoadingDataS, LoadedDataSuccessS] on LoadDataE',
        build: () => bloc,
        act: (bloc) => bloc.add(const LoadDataE(params: 'test')),
        expect: () => [
          isA<LoadingDataS<int>>(),
          isA<LoadedDataSuccessS<int, String>>()
              .having((s) => s.data, 'data', 1)
              .having((s) => s.params, 'params', 'test'),
        ],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [LoadingDataS, LoadingDataErrorS] on LoadDataE with DataException',
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
        ],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [LoadingDataS, LoadingDataErrorS with UnhandledDataException] on LoadDataE with unhandled exception',
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
        seed: () => const LoadedDataSuccessS<int, String>(0, params: 'test'),
        act: (bloc) => bloc.add(
          const ReloadDataE(params: 'test2', isNextLoading: false),
        ),
        expect: () => [
          isA<ReloadingDataS<int, String>>()
              .having((s) => s.isNextLoading, 'isNextLoading', false)
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test'),
          isA<LoadedDataSuccessS<int, String>>()
              .having((s) => s.data, 'data', 1)
              .having((s) => s.params, 'params', 'test2'),
        ],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [ReloadingDataS, ReloadingErrorS] on ReloadDataE with DataException',
        build: () => bloc,
        setUp: () {
          when(() => repository.loadData(any())).thenThrow(MockDataException());
        },
        seed: () => const LoadedDataSuccessS<int, String>(0, params: 'test1'),
        act: (bloc) => bloc.add(
          const ReloadDataE(params: 'test2', isNextLoading: false),
        ),
        expect: () => [
          isA<ReloadingDataS<int, String>>()
              .having((s) => s.isNextLoading, 'isNextLoading', false)
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test1'),
          isA<ReloadingErrorS<int, String>>()
              .having((s) => s.data, 'data', 0)
              //TODO: it might be worth passing parameters from the event to resend the event?
              .having((s) => s.params, 'params', 'test1')
              .having((s) => s.error, 'error', isA<DataException>()),
          isA<LoadedDataSuccessS<int, String>>()
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test1'),
        ],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [ReloadingDataS, ReloadingErrorS with UnhandledDataException, LoadedDataSuccessS ] on LoadDataE with unhandled exception',
        build: () => bloc,
        seed: () => const LoadedDataSuccessS<int, String>(0, params: 'test1'),
        setUp: () {
          when(() => repository.loadData(any())).thenThrow(Exception());
        },
        act: (bloc) => bloc.add(
          const ReloadDataE(params: 'test2', isNextLoading: false),
        ),
        expect: () => [
          isA<ReloadingDataS<int, String>>()
              .having((s) => s.isNextLoading, 'isNextLoading', false)
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test1'),
          isA<ReloadingErrorS<int, String>>()
              .having((s) => s.data, 'data', 0)
              //TODO: it might be worth passing parameters from the event to resend the event?
              .having((s) => s.params, 'params', 'test1')
              .having((s) => s.error, 'error', isA<DataException>()),
          isA<LoadedDataSuccessS<int, String>>()
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
        'emits [LoadedDataSuccessS] on UpdateDataE',
        build: () => bloc,
        seed: () => const LoadedDataSuccessS<int, String>(0, params: 'test1'),
        act: (bloc) => bloc.add(UpdateDataE((data) => 1, params: 'test2')),
        expect: () => [
          isA<LoadedDataSuccessS<int, String>>()
              .having((s) => s.data, 'data', 1)
              .having((s) => s.params, 'params', 'test2'),
        ],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [ ReloadingErrorS with UnhandledDataException, LoadedDataSuccessS ] on UpdateDataE with unhandled exception',
        build: () => bloc,
        seed: () => const LoadedDataSuccessS<int, String>(0, params: 'test1'),
        act: (bloc) => bloc.add(
          UpdateDataE(
            (data) {
              throw Exception();
            },
            params: 'test2',
          ),
        ),

        expect: () => [
          isA<ReloadingErrorS<int, String>>()
              .having((s) => s.data, 'data', 0)
              //TODO: it might be worth passing parameters from the event to resend the event?
              .having((s) => s.params, 'params', 'test1')
              .having((s) => s.error, 'error', isA<DataException>()),
          isA<LoadedDataSuccessS<int, String>>()
              .having((s) => s.data, 'data', 0)
              .having((s) => s.params, 'params', 'test1'),
        ],
      );
    });

    group('InitializeDataE', () {
      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'nothing emits when state is not UnloadedDataS on InitializeDataE',
        build: () => bloc,
        seed: () => const LoadedDataSuccessS<int, String>(0, params: 'test1'),
        act: (bloc) => bloc.add(const InitializeDataE(1, params: 'test2')),
        expect: () => <DataS<int>>[],
      );

      blocTest<InternalDataBloc<int, String>, DataS<int>>(
        'emits [LoadedDataSuccessS] on InitializeDataE',
        build: () => bloc,
        act: (bloc) => bloc.add(const InitializeDataE(1, params: 'test1')),
        expect: () => [
          isA<LoadedDataSuccessS<int, String>>()
              .having((s) => s.data, 'data', 1)
              .having((s) => s.params, 'params', 'test1'),
        ],
      );
    });
  });
}
