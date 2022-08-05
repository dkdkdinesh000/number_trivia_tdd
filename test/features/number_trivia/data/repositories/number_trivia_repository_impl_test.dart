import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_tdd/features/core/error/exception.dart';
import 'package:number_trivia_tdd/features/core/error/failures.dart';
import 'package:number_trivia_tdd/features/core/platform/network_info.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia_tdd/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel(text: 'test trivia', number: tNumber);

    final NumberTrivia tNumberTrivia = tNumberTriviaModel;
    test('should check if the device is online', () async {
      //arrage
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getConcreteNumber(tNumber)).thenAnswer(
        (invocation) async => tNumberTriviaModel,
      );
      when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
          .thenAnswer((_) async => Future.value());
      //act
      repository.getConcreteNumber(1);
      //assert
      verify(() => mockNetworkInfo.isConnected).called(1);
    });

    runTestsOnline(() {
      test(
          'should return remote data when the call to remote data source is success',
          () async {
        //arrange
        when(() => mockRemoteDataSource.getConcreteNumber(tNumber))
            .thenAnswer((_) async => tNumberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((_) async => Future.value());
        //act
        final result = await repository.getConcreteNumber(tNumber);
        //assert
        verify(() => mockRemoteDataSource.getConcreteNumber(tNumber)).called(1);
        expect(result, Right(tNumberTriviaModel));
      });

      test(
          'should cache the data locally when the call to remote data source is successful.',
          () async {
        //arrange
        when(() => mockRemoteDataSource.getConcreteNumber(tNumber))
            .thenAnswer((_) async => tNumberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((_) async => Future.value());
        //act
        final result = await repository.getConcreteNumber(tNumber);
        //assert
        verify(() => mockRemoteDataSource.getConcreteNumber(tNumber)).called(1);
        verify(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .called(1);
        expect(result, Right(tNumberTriviaModel));
      });

      test(
          'should return server failure when the call to remote data source is unsuccessful.',
          () async {
        //arrange
        when(() => mockRemoteDataSource.getConcreteNumber(tNumber))
            .thenThrow(ServerException());

        //act
        final result = await repository.getConcreteNumber(tNumber);
        //assert
        verify(() => mockRemoteDataSource.getConcreteNumber(tNumber)).called(1);
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      test(
          'should return last locally cached data when the cached data is present',
          () async {
        //arrange
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((invocation) async => tNumberTriviaModel);

        //act
        final result = await repository.getConcreteNumber(tNumber);

        //assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastNumberTrivia()).called(1);
        expect(result, Right(tNumberTrivia));
      });

      test('should return CacheFailure when there is no cached data is present',
          () async {
        //arrange
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());

        //act
        final result = await repository.getConcreteNumber(tNumber);

        //assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastNumberTrivia()).called(1);
        expect(result, Left(CacheFailure()));
      });
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel(text: 'test trivia', number: 123);

    final NumberTrivia tNumberTrivia = tNumberTriviaModel;
    test('should check if the device is online', () async {
      //arrage
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getRandomNumber()).thenAnswer(
        (invocation) async => tNumberTriviaModel,
      );
      when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
          .thenAnswer((_) async => Future.value());
      //act
      repository.getRandomNumber();
      //assert
      verify(() => mockNetworkInfo.isConnected).called(1);
    });

    runTestsOnline(() {
      test(
          'should return remote data when the call to remote data source is success',
          () async {
        //arrange
        when(() => mockRemoteDataSource.getRandomNumber())
            .thenAnswer((_) async => tNumberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((_) async => Future.value());
        //act
        final result = await repository.getRandomNumber();
        //assert
        verify(() => mockRemoteDataSource.getRandomNumber()).called(1);
        expect(result, Right(tNumberTriviaModel));
      });

      test(
          'should cache the data locally when the call to remote data source is successful.',
          () async {
        //arrange
        when(() => mockRemoteDataSource.getRandomNumber())
            .thenAnswer((_) async => tNumberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((_) async => Future.value());
        //act
        final result = await repository.getRandomNumber();
        //assert
        verify(() => mockRemoteDataSource.getRandomNumber()).called(1);
        verify(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .called(1);
        expect(result, Right(tNumberTriviaModel));
      });

      test(
          'should return server failure when the call to remote data source is unsuccessful.',
          () async {
        //arrange
        when(() => mockRemoteDataSource.getRandomNumber())
            .thenThrow(ServerException());

        //act
        final result = await repository.getRandomNumber();
        //assert
        verify(() => mockRemoteDataSource.getRandomNumber()).called(1);
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      test(
          'should return last locally cached data when the cached data is present',
          () async {
        //arrange
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((invocation) async => tNumberTriviaModel);

        //act
        final result = await repository.getRandomNumber();

        //assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastNumberTrivia()).called(1);
        expect(result, Right(tNumberTrivia));
      });

      test('should return CacheFailure when there is no cached data is present',
          () async {
        //arrange
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());

        //act
        final result = await repository.getRandomNumber();

        //assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastNumberTrivia()).called(1);
        expect(result, Left(CacheFailure()));
      });
    });
  });
}
