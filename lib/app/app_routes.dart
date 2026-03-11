import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const home = '/home';

  static final routes = {
    splash: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
  };
}
