import 'package:number_trivia_tdd/features/number_trivia/data/models/number_trivia_model.dart';

abstract class NumberTriviaRemoteDataSource {
  ///Calls the http://numbersapi.com/{number} endpoint
  ///
  ///Throws a [ServerException] for all error codes
  Future<NumberTriviaModel> getConcreteNumber(int number);

  ///Calls the http://numbersapi.com/random endpoint
  ///
  ///Throws a [ServerException] for all error codes
  Future<NumberTriviaModel> getRandomNumber();
}