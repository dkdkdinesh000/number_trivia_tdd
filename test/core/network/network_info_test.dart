import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_tdd/features/core/platform/network_info.dart';

class MockDataConnectionChecker extends Mock
    implements InternetConnectionChecker {}

void main() {
  late NetworkInfoImpl networkInfo;
  late MockDataConnectionChecker mockDataConnectionChecker;

  setUp(() {
    mockDataConnectionChecker = MockDataConnectionChecker();
    networkInfo = NetworkInfoImpl(mockDataConnectionChecker);
  });

  group('isConnected', () {
    test('should forward the call to DataConnectionChecker.hasConnection',
        () async {
      //arrange
      when(() => mockDataConnectionChecker.hasConnection)
          .thenAnswer((_) async => true);

      //act
      final result = await networkInfo.isConnected;

      //assert
      verify(() => mockDataConnectionChecker.hasConnection).called(1);
      expect(result, true);
    });
  });
}
