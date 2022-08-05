import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_tdd/features/core/error/exception.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test(
        'should return NumberTrivia from SharedPreference when there is one in the cache',
        () async {
      //arrange
      when(() => mockSharedPreferences.getString(any()))
          .thenReturn(fixture('trivia.json'));
      //act
      final result = await dataSource.getLastNumberTrivia();

      //assert
      verify(() => mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA))
          .called(1);
      expect(result, equals(tNumberTriviaModel));
    });

    test('should return CacheException when there is not a cached value',
        () async {
      //arrange
      when(() => mockSharedPreferences.getString(any())).thenReturn(null);
      //act
      final call = await dataSource.getLastNumberTrivia;

      //assert

      expect(() => call(), throwsA(const TypeMatcher<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    const tNumberTriviaModel =
        NumberTriviaModel(text: 'Test Trivia', number: 1);

    test('should sharedpreference cache the data', () async {
      //arrage
      final expectedString = json.encode(tNumberTriviaModel.toJson());
      when(() => mockSharedPreferences.setString(
              CACHED_NUMBER_TRIVIA, expectedString))
          .thenAnswer((invocation) async => true);

      //act
      await dataSource.cacheNumberTrivia(tNumberTriviaModel);

      //assert
      verify(() => mockSharedPreferences.setString(
          CACHED_NUMBER_TRIVIA, expectedString)).called(1);
    });
  });
}
