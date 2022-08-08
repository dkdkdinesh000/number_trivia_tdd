import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_tdd/features/core/error/failures.dart';
import 'package:number_trivia_tdd/features/core/util/input_converter.dart';
import 'package:number_trivia_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia_tdd/features/number_trivia/domain/usecases/get_concreate_number_trivia.dart';
import 'package:number_trivia_tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia_tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('initialState should be empty', () {
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    const tNumberString = '1';
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    void setUpMockInputConverterSuccess() =>
        when(() => mockInputConverter.stringToUnsignedInteger(tNumberString))
            .thenReturn(const Right(tNumberParsed));

    void setUpMockInputConverterFailure() =>
        when(() => mockInputConverter.stringToUnsignedInteger(tNumberString))
            .thenReturn(Left(InvalidInputFailure()));

    test(
        'should call the InputConverter to validate and convert the string to an unsigned integer',
        () async {
      //arrange
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      //act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));

      await untilCalled(
          () => mockInputConverter.stringToUnsignedInteger(any()));

      //assert

      verify(() => mockInputConverter.stringToUnsignedInteger(tNumberString))
          .called(1);
    });

    test('should emit [Error] when the input is invalid', () async {
      setUpMockInputConverterFailure();

      final expected = [
        const Error(message: INVALID_INPUT_FAILURE_MESSAGE),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));

      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test('should get data from the concrete use case', () async {
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      bloc.add(const GetTriviaForConcreteNumber(tNumberString));

      await untilCalled(
          () => mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));

      verify(
        () => mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)),
      );
    });

    test('should emit[Loading,Loaded] when data is gotten successfully',
        () async {
      //arrange
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)))
          .thenAnswer((invocation) async => const Right(tNumberTrivia));
      //assert later
      final expected = [
        Loading(),
        const Loaded(trivia: tNumberTrivia),
      ];
      expect(bloc.stream, emitsInOrder(expected));

      //act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test(
        'should emit[Loading,Error] with proper message for the error when server fails',
        () async {
      //arrange
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)))
          .thenAnswer((invocation) async => Left(ServerFailure()));
      //assert later
      final expected = [
        Loading(),
        const Error(message: SERVER_FAILURE_MESSAGE)
      ];
      expect(bloc.stream, emitsInOrder(expected));

      //act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test(
        'should emit[Loading,Error] with proper message for the error when getting cache data fails',
        () async {
      //arrange
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)))
          .thenAnswer((invocation) async => Left(CacheFailure()));
      //assert later
      final expected = [Loading(), const Error(message: CACHE_FAILURE_MESSAGE)];
      expect(bloc.stream, emitsInOrder(expected));

      //act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });
  });

  group('GetTriviaForRandomNumber', () {
    const tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    test('should get data from the concrete use case', () async {
      when(() => mockGetRandomNumberTrivia(NoParams()))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      bloc.add(GetTriviaForRandomNumber());

      await untilCalled(() => mockGetRandomNumberTrivia(NoParams()));

      verify(
        () => mockGetRandomNumberTrivia(NoParams()),
      );
    });

    test('should emit[Loading,Loaded] when data is gotten successfully',
        () async {
      //arrange
      when(() => mockGetRandomNumberTrivia(NoParams()))
          .thenAnswer((invocation) async => const Right(tNumberTrivia));
      //assert later
      final expected = [
        Loading(),
        const Loaded(trivia: tNumberTrivia),
      ];
      expect(bloc.stream, emitsInOrder(expected));

      //act
      bloc.add(GetTriviaForRandomNumber());
    });

    test(
        'should emit[Loading,Error] with proper message for the error when server fails',
        () async {
      //arrange
      when(() => mockGetRandomNumberTrivia(NoParams()))
          .thenAnswer((invocation) async => Left(ServerFailure()));
      //assert later
      final expected = [
        Loading(),
        const Error(message: SERVER_FAILURE_MESSAGE)
      ];
      expect(bloc.stream, emitsInOrder(expected));

      //act
      bloc.add(GetTriviaForRandomNumber());
    });

    test(
        'should emit[Loading,Error] with proper message for the error when getting cache data fails',
        () async {
      //arrange
      when(() => mockGetRandomNumberTrivia(NoParams()))
          .thenAnswer((invocation) async => Left(CacheFailure()));
      //assert later
      final expected = [Loading(), const Error(message: CACHE_FAILURE_MESSAGE)];
      expect(bloc.stream, emitsInOrder(expected));

      //act
      bloc.add(GetTriviaForRandomNumber());
    });
  });
}
