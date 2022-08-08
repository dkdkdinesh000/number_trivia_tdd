import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:number_trivia_tdd/features/core/error/exception.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(() => mockHttpClient.get(
          Uri.parse('http://numbersapi.com/1'),
          headers: {
            'Content-Type': 'application/json',
          },
        )).thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientSuccessRandom200() {
    when(() => mockHttpClient.get(
          Uri.parse('http://numbersapi.com/random'),
          headers: {
            'Content-Type': 'application/json',
          },
        )).thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure404() {
    when(() => mockHttpClient.get(
          Uri.parse('http://numbersapi.com/1'),
          headers: {
            'Content-Type': 'application/json',
          },
        )).thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  void setUpMockHttpClientFailureRandom404() {
    when(() => mockHttpClient.get(
          Uri.parse('http://numbersapi.com/random'),
          headers: {
            'Content-Type': 'application/json',
          },
        )).thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''should perform a GET request on a URL with number
       being the endpoint and with application/json header''',
      () async {
        // arrange
        setUpMockHttpClientSuccess200();
        // act
        dataSource.getConcreteNumber(tNumber);
        // assert
        verify(() => mockHttpClient.get(
              Uri.parse('http://numbersapi.com/$tNumber'),
              headers: {
                'Content-Type': 'application/json',
              },
            )).called(1);
      },
    );

    test(
      'should return NumberTrivia when the response code is 200 (success)',
      () async {
        // arrange
        setUpMockHttpClientSuccess200();
        // act
        final result = await dataSource.getConcreteNumber(tNumber);
        // assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async {
        // arrange
        setUpMockHttpClientFailure404();
        // act
        final call = dataSource.getConcreteNumber;
        // assert
        expect(() => call(tNumber), throwsA(const TypeMatcher<ServerException>()));
      },
    );
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''should perform a GET request on a URL with number
       being the endpoint and with application/json header''',
      () async {
        // arrange
        setUpMockHttpClientSuccessRandom200();
        // act
        dataSource.getRandomNumber();
        // assert
        verify(() => mockHttpClient.get(
              Uri.parse('http://numbersapi.com/random'),
              headers: {
                'Content-Type': 'application/json',
              },
            )).called(1);
      },
    );

    test(
      'should return NumberTrivia when the response code is 200 (success)',
      () async {
        // arrange
        setUpMockHttpClientSuccessRandom200();
        // act
        final result = await dataSource.getRandomNumber();
        // assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async {
        // arrange
        setUpMockHttpClientFailureRandom404();
        // act
        final call = dataSource.getRandomNumber;
        // assert
        expect(() => call(), throwsA(const TypeMatcher<ServerException>()));
      },
    );
  });
}
