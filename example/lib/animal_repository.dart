import 'dart:async';
import 'dart:math';

import 'package:bloc_toolkit/bloc_toolkit.dart';
import 'package:faker/faker.dart';

class AnimalRepository {
  FutureOr<String> getAnimal() async {
    await Future.delayed(const Duration(seconds: 1));
    final i = Random().nextInt(3);
    if (i ==1) {
      throw ApiException();
    }
    if(i == 2) {
      throw Exception();
    }
    return faker.animal.name();
  }
}

class ApiException implements DataException {
  @override
  String toString() => 'ApiException';
}
