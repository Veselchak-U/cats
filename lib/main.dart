import 'package:cats/import.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp(
    databaseRepository: DatabaseRepository(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({this.databaseRepository});

  final DatabaseRepository databaseRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: databaseRepository,
        ),
      ],
      child: MaterialApp(
        title: 'Cats & Pets',
        theme: theme,
        debugShowCheckedModeBanner: false,
        home: BlocProvider(
          create: (BuildContext context) => HomeCubit(
              repo:
                  RepositoryProvider.of<DatabaseRepository>(context))
            ..load(),
          child: HomeScreen(),
        ),
      ),
    );
  }
}
