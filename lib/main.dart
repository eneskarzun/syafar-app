import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syafarapp/common/dependency_injection.dart' as di;
import 'package:syafarapp/common/routers.dart';
import 'package:syafarapp/presentation/bloc/search/search_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => di.locator<SearchBloc>())],
      child: MaterialApp.router(
        routerConfig: routers,
        title: 'Syafar Tour',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
      ),
    );
  }
}
