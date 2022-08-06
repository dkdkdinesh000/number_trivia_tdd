import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:number_trivia_tdd/features/core/platform/network_info.dart';
import 'package:number_trivia_tdd/features/core/util/input_converter.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia_tdd/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:number_trivia_tdd/features/number_trivia/domain/usecases/get_concreate_number_trivia.dart';
import 'package:number_trivia_tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia_tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final sl = GetIt.instance;

Future<void> init() async {
  // ! Features - Number Trivia
  sl.registerFactory(() =>
      NumberTriviaBloc(concrete: sl(), random: sl(), inputConverter: sl()));

  // ! Use cases
  sl.registerSingleton(() => GetConcreteNumberTrivia(sl()));
  sl.registerSingleton(() => GetRandomNumberTrivia(sl()));

  // ! Repository
  sl.registerLazySingleton<NumberTriviaRepository>(
    () => NumberTriviaRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // ! Data sources
  sl.registerLazySingleton<NumberTriviaLocalDataSource>(
    () => NumberTriviaLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<NumberTriviaRemoteDataSource>(
      () => NumberTriviaRemoteDataSourceImpl(client: sl()));

  // ! Core
  sl.registerLazySingleton(() => InputConverter());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // ! Externals
  final sharedPreference = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreference);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}
