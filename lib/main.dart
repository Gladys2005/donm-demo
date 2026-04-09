import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/config/app_config.dart';
import 'core/di/injection_container.dart';
import 'core/theme/donm_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';

import 'donm_theme.dart';
import 'donm_logo_widget.dart';
import 'enums.dart';
import 'models.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize dependencies
  await initializeDependencies();
  
  // Initialize notifications
  await NotificationService.initialize();
  
  // Initialize storage
  await StorageService.initialize();
  
  runApp(const DonMApp());
}

class DonMApp extends StatefulWidget {
  const DonMApp({super.key});

  @override
  State<DonMApp> createState() => _DonMAppState();
}

class _DonMAppState extends State<DonMApp> {
  late GoRouter _router;
  
  @override
  void initState() {
    super.initState();
    _router = AppRouter.router;
    _setupFirebaseMessaging();
  }
  
  void _setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificationService.showForegroundNotification(message);
    });
    
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });
    
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationTap(message);
      }
    });
  }
  
  void _handleNotificationTap(RemoteMessage message) {
    // Handle notification tap
    final data = message.data;
    if (data != null) {
      final route = data['route'];
      if (route != null) {
        _router.push(route);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<NotificationBloc>()),
      ],
      child: MaterialApp.router(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: AppConfig.isDebugMode,
        theme: DonMTheme.lightTheme,
        darkTheme: DonMTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _router,
        scaffoldMessengerKey: scaffoldMessengerKey,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0, // Prevent text scaling
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
