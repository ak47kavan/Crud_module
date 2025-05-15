import 'package:crud_module/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'bloc/task_bloc.dart';
import 'services/firestore_service.dart';
import 'services/local_db_helper.dart';
import 'screens/login_screen.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalDbHelper.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return BlocProvider(
            create: (_) => TaskBloc(firestoreService: _firestoreService),
            child: MaterialApp(
              title: 'CRUD Module',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              home: LoginScreen(),
            ),
          );
        },
      ),
    );
  }
}
