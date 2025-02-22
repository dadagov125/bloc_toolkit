import 'dart:async';
import 'dart:math';

import 'package:bloc_toolkit/bloc_toolkit.dart';

class AnimalRepository {
  final animals = [
    'Dog',
    'Cat',
    'Cow',
    'Horse',
    'Elephant',
    'Lion',
    'Tiger',
  ];

  FutureOr<String> getAnimal(int index) async {
    await _checkError();
    return animals[index];
  }

  FutureOr<String> saveAnimal(int index, String animal) async {
    await _checkError();
    animals[index] = animal;
    return animals[index];
  }

  Future<void> _checkError() async {
    await Future.delayed(const Duration(seconds: 1));
    final i = Random().nextInt(3);
    if (i == 1) {
      throw ApiException();
    }
    if (i == 2) {
      throw Exception();
    }
  }
}

class ApiException implements DataException {
  @override
  String toString() => 'ApiException';
}
