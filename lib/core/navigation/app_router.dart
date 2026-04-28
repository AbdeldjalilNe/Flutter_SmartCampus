import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/pages/admin/admin_dashboard_page.dart';
import '../../presentation/pages/announcements/announcement_detail_page.dart';
import '../../presentation/pages/announcements/announcements_page.dart';
import '../../presentation/pages/events/event_detail_page.dart';
import '../../presentation/pages/events/events_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/login/login_page.dart';
import '../../presentation/pages/map/campus_map_page.dart';
import '../../presentation/pages/profile/edit_profile_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/qr_scanner/qr_scanner_page.dart';
import '../../presentation/pages/register/register_page.dart';
import '../../presentation/pages/safety/safety_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/timetable/timetable_page.dart';
import 'router_refresh_stream.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  // Holds the refresh stream so GoRouter re-evaluates redirects on auth changes.
  static GoRouterRefreshStream? _refreshNotifier;

  /// Call this once from the widget tree (after BlocProvider is available)
  /// to wire up the AuthBloc stream to the router.
  static void setRefreshStream(Stream<dynamic> stream) {
    _refreshNotifier?.dispose();
    _refreshNotifier = GoRouterRefreshStream(stream);
    // Notify the already-built router to refresh.
    _refreshNotifier!.addListener(_router.refresh);
  }

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: '/splash',
    redirect: (context, state) {
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;

      final isAuthenticated = authState is Authenticated;
      final isLoading = authState is AuthLoading || authState is AuthInitial;

      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' || loc == '/register' || loc == '/splash';

      // Still initializing — stay put
      if (isLoading) return null;

      // If not authenticated and NOT already on an auth route → go to login
      if (!isAuthenticated && !isAuthRoute) return '/login';

      // If not authenticated and sitting on splash → send to login
      if (!isAuthenticated && loc == '/splash') return '/login';

      // If authenticated and on an auth/splash route → send to home
      if (isAuthenticated && isAuthRoute) return '/home';

      return null;
    },
    routes: [
      // Splash Route
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Main App Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/announcements',
            name: 'announcements',
            builder: (context, state) => const AnnouncementsPage(),
          ),
          GoRoute(
            path: '/events',
            name: 'events',
            builder: (context, state) => const EventsPage(),
          ),
          GoRoute(
            path: '/timetable',
            name: 'timetable',
            builder: (context, state) => const TimetablePage(),
          ),
          GoRoute(
            path: '/map',
            name: 'map',
            builder: (context, state) => const CampusMapPage(),
          ),
        ],
      ),

      // Detail Routes
      GoRoute(
        path: '/announcement/:id',
        name: 'announcement_detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AnnouncementDetailPage(announcementId: id);
        },
      ),
      GoRoute(
        path: '/event/:id',
        name: 'event_detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return EventDetailPage(eventId: id);
        },
      ),

      // Feature Routes
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'edit_profile',
        builder: (context, state) {
          final authBloc = context.read<AuthBloc>();
          final authState = authBloc.state;
          if (authState is Authenticated) {
            return EditProfilePage(user: authState.user);
          }
          // Fallback if somehow accessed without being authenticated
          return const ProfilePage();
        },
      ),
      GoRoute(
        path: '/qr-scanner',
        name: 'qr_scanner',
        builder: (context, state) => const QrScannerPage(),
      ),
      GoRoute(
        path: '/safety',
        name: 'safety',
        builder: (context, state) => const SafetyPage(),
      ),

      // Admin Routes
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardPage(),
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
}

// Main Shell with Bottom Navigation
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<String> _routes = [
    '/home',
    '/announcements',
    '/events',
    '/timetable',
    '/map',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    // Update current index based on current route
    final location = GoRouterState.of(context).matchedLocation;
    _currentIndex = _routes.indexWhere(location.startsWith);
    if (_currentIndex == -1) _currentIndex = 0;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: 'Announcements',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Timetable',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
      ),
    );
  }
}

// Error Page
class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Page Not Found',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'The requested page could not be found.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
}

// Navigation helper extension
extension NavigationExtension on BuildContext {
  void goToHome() => go('/home');
  void goToLogin() => go('/login');
  void goToAnnouncements() => go('/announcements');
  void goToEvents() => go('/events');
  void goToTimetable() => go('/timetable');
  void goToMap() => go('/map');
  void goToSettings() => go('/settings');
  void goToProfile() => go('/profile');
  void goToEditProfile() => go('/profile/edit');
  void goToQrScanner() => go('/qr-scanner');
  void goToSafety() => go('/safety');
  void goToAdmin() => go('/admin');

  void goToAnnouncementDetail(String id) => go('/announcement/$id');
  void goToEventDetail(String id) => go('/event/$id');
}
