import 'package:dartz/dartz.dart';
import 'package:number_trivia_tdd/features/core/error/failures.dart';
import 'package:number_trivia_tdd/features/number_trivia/domain/entities/number_trivia.dart';


abstract class NumberTriviaRepository {
  Future<Either<Failure, NumberTrivia>> getConcreteNumber(int number);
  Future<Either<Failure, NumberTrivia>> getRandomNumber();
}
