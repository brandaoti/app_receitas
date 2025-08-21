import 'package:dart_either/dart_either.dart';

import 'exceptions/base_exception.dart';

typedef Output<T> = Either<BaseException, T>;

class Unit {
  static const Unit _unit = Unit._instance();
  const Unit._instance();

  @override
  String toString() => '()';
}

const unit = Unit._unit;
