import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia_tdd/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:number_trivia_tdd/features/number_trivia/domain/usecases/get_concreate_number_trivia.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  late GetConcreteNumberTrivia usecase;
  late MockNumberTriviaRepository mockNumberTriviaRepository;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetConcreteNumberTrivia(mockNumberTriviaRepository);
  });

  final tNumber = 1;
  final tNumberTrivia = const NumberTrivia(text: "test", number: 1);

  test("should get trivia for the number from the repository", () async {
    //arrange
    when(() => mockNumberTriviaRepository.getConcreteNumber(tNumber))
        .thenAnswer((_) async => Right(tNumberTrivia));

    //act
    final result = await usecase(Params(number: tNumber));

    //assett
    expect(result, Right(tNumberTrivia));
    verify(() => mockNumberTriviaRepository.getConcreteNumber(tNumber))
        .called(1);
  });
}
