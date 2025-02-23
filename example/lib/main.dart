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

class AnimalBloc extends DataBloc<String, int> {
  AnimalBloc({required AnimalRepository animalRepository})
      : _animalRepository = animalRepository;
  final AnimalRepository _animalRepository;

  @override
  FutureOr<String> loadData(DataS<String> oldState, LoadDataE<int> event) =>
      _animalRepository.getAnimal(event.params!);

  @override
  FutureOr<String?> submitData(
          LoadedDataS<String, int> oldState, SubmitDataE<String, int> event) =>
      _animalRepository.saveAnimal(event.params!, event.data);
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

  void _showEditDialog(BuildContext context, LoadedS<String, int> state) {
    final controller = TextEditingController(text: state.data);
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Edit'),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context
                      .read<AnimalBloc>()
                      .add(SubmitDataE(controller.text, params: state.params!));
                  Navigator.of(context).pop();
                },
                child: const Text('Submit'),
              ),
            ],
            content: TextField(controller: controller),
          );
        });
  }

  void _showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(text),
      duration: const Duration(milliseconds: 2000),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: BlocProvider(
              create: (_) => AnimalBloc(animalRepository: AnimalRepository()),
              child: BlocConsumer<AnimalBloc, DataS<String>>(
                listener: (context, state) {
                  if (state is ReloadingDataErrorS<String, int>) {
                    _showSnackBar(context, 'Reloading error: ${state.error}');
                  } else if (state is LoadingDataErrorS<String, int>) {
                    _showSnackBar(context, 'Loading error: ${state.error}');
                  } else if (state is SubmittingDataErrorS<String, int>) {
                    _showSnackBar(context, 'Submitting error: ${state.error}');
                  }
                },
                builder: (context, state) {
                  if (state is UnloadedDataS) {
                    return ElevatedButton(
                      onPressed: () => context
                          .read<AnimalBloc>()
                          .add(const LoadDataE(params: 0)),
                      child: const Text('Load'),
                    );
                  }
                  if (state is LoadingDataS) {
                    return const Text('Loading...');
                  }
                  if (state is LoadedS<String, int>) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state is ReloadingDataS) Text('Next loading...'),
                        if (state is SubmittingDataS) Text('Submitting...'),
                        Text(state.data),
                        ElevatedButton(
                          onPressed: () => context
                              .read<AnimalBloc>()
                              .add(ReloadDataE(params: state.params! + 1)),
                          child: const Text('Load next'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showEditDialog(context, state);
                          },
                          child: const Text('Edit'),
                        )
                      ],
                    );
                  }

                  return const SizedBox();
                },
              ))),
    );
  }
}
