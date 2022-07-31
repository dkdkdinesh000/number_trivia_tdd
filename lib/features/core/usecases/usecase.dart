import 'package:dartz/dartz.dart';
import 'package:number_trivia_tdd/features/core/error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
