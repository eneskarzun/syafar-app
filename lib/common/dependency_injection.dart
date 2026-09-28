import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:syafarapp/data/datasources/remote_data_sources.dart';
import 'package:syafarapp/data/repositories/hotel_repository_impl.dart';
import 'package:syafarapp/domain/hotel/hotel_repository.dart';
import 'package:syafarapp/domain/hotel/hotel_usecase.dart';
import 'package:syafarapp/presentation/bloc/search/search_bloc.dart';

final locator = GetIt.instance;

void init() {
  // BLoC
  locator.registerFactory(() => SearchBloc(hotelUsecase: locator()));

  // Use cases
  locator.registerLazySingleton(() => HotelUsecase(locator()));

  // Repository
  locator.registerLazySingleton<HotelRepository>(
    () => HotelRepositoryImpl(remoteDataSource: locator()),
  );

  // Data sources
  locator.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(client: locator()),
  );

  // External
  locator.registerLazySingleton(() => http.Client());
}
