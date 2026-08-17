import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'data/datasources/contact_remote_data_source.dart';
import 'data/datasources/favorites_local_data_source.dart';
import 'data/repositories/contact_repository_impl.dart';
import 'domain/repositories/contact_repository.dart';
import 'presentation/contacts/contacts_page.dart';
import 'presentation/contacts/cubit/contacts_cubit.dart';
import 'presentation/favorites/cubit/favorites_cubit.dart';

class ContactsApp extends StatefulWidget {
  const ContactsApp({super.key, required this.preferences});

  final SharedPreferences preferences;

  @override
  State<ContactsApp> createState() => _ContactsAppState();
}

class _ContactsAppState extends State<ContactsApp> {
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = ThemeController(widget.preferences);
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ContactRepository>(
      create: (_) => ContactRepositoryImpl(
        ContactRemoteDataSource(ApiClient()),
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                ContactsCubit(context.read<ContactRepository>())..loadInitial(),
          ),
          BlocProvider(
            create: (_) =>
                FavoritesCubit(FavoritesLocalDataSource(widget.preferences)),
          ),
        ],
        child: ThemeScope(
          controller: _themeController,
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: _themeController,
            builder: (context, themeMode, _) => MaterialApp(
              title: 'Contacts',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeMode,
              home: const ContactsPage(),
            ),
          ),
        ),
      ),
    );
  }
}
