import 'dart:async';

import 'package:bloc_toolkit/bloc_toolkit.dart';
import 'package:example/animal_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

void main() {
  final logger = Logger();
  Bloc.observer = SimpleBlocObserver(logger);
  runApp(const MyApp());
}

class AnimalBloc extends DataBloc<String, void> {
  AnimalBloc({required AnimalRepository animalRepository})
      : _animalRepository = animalRepository;

  final AnimalRepository _animalRepository;

  @override
  FutureOr<String> loadData(DataS<String> oldState, LoadDataE<void> event) {
    return _animalRepository.getAnimal();
  }
}

class SimpleBlocObserver extends BlocObserver {
  SimpleBlocObserver(this._logger);

  final Logger _logger;

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    final nextState = change.nextState;
    if (nextState is ErrorS) {
      final error = nextState.error;
      if (error is UnhandledDataException) {
        _logger.f('UnhandledDataException',
            error: error.error, stackTrace: error.stackTrace);
        //TODO: send to analytics
      }
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  void _showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(text),
      duration: const Duration(milliseconds: 1000),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: BlocProvider(
              create: (_) => AnimalBloc(animalRepository: AnimalRepository()),
              child: BlocConsumer<AnimalBloc, DataS<String>>(
                listener: (context, state) => dataMapOrNull(
                  state,
                  error: (state) => errorMap(
                    state,
                    reloadingError: (state) {
                      _showSnackBar(
                          context, 'Reloading animal error: ${state.error}');
                    },
                    loadingError: (state) {
                      _showSnackBar(
                          context, 'Loading animal error: ${state.error}');
                    },
                  ),
                ),
                builder: (context, state) => dataMaybeMap(
                  state,
                  idle: (state) => idleMap(
                    state,
                    unloaded: (state) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Animal not loaded'),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<AnimalBloc>()
                                .add(const LoadDataE<void>());
                          },
                          child: const Text('Load Animal'),
                        ),
                      ],
                    ),
                    loaded: (state) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.data),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<AnimalBloc>()
                                .add(const ReloadDataE<void>());
                          },
                          child: const Text('Reload Animal'),
                        ),
                      ],
                    ),
                  ),
                  loading: (state) => loadingMap(state,
                      loading: (state) => const Text('Loading animal...'),
                      reloading: (state) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(state.data),
                              const Text('Reloading animal...'),
                            ],
                          )),
                  orElse: () => const SizedBox(),
                ),
              ))),
    );
  }
}
