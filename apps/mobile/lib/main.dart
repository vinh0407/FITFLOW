import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/workout/presentation/pages/programs_page.dart';
import 'features/workout/presentation/pages/active_workout_page.dart';
import 'features/nutrition/presentation/pages/nutrition_page.dart';
import 'features/progress/presentation/pages/progress_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/fitness_repository.dart';
import 'widgets/ai_workout_bottom_sheet.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization: $e');
  }
  await fitnessRepository.load();
  runApp(const VinceCoreApp());
}

class VinceCoreApp extends StatelessWidget {
  const VinceCoreApp({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: fitnessRepository,
        builder: (context, _) => MaterialApp(
          title: 'FITFLOW',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: fitnessRepository.themeMode,
          home: const AppEntryGate(),
        ),
      );
}

class AppEntryGate extends StatelessWidget {
  const AppEntryGate({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: fitnessRepository,
        builder: (context, _) {
          if (!fitnessRepository.authComplete) {
            return const AuthPage();
          }
          if (!fitnessRepository.onboardingComplete) {
            return const OnboardingPage();
          }
          return const MainScreen();
        },
      );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _recoveryWarningDismissed = false;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(
        onStartWorkout: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ActiveWorkoutPage(
                title: 'PULL DAY · Lưng & Tay trước',
              ),
            ),
          );
        },
        onNavigateTab: (index) {
          setState(() => _currentIndex = index);
        },
      ),
      const ProgressPage(),
      const ProgramsPage(),
      const NutritionPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? AppColors.lightSurface : AppColors.darkSurface;

    return Scaffold(
      body: Column(children: [
        if (!_recoveryWarningDismissed &&
            fitnessRepository.storageWarnings.isNotEmpty)
          SafeArea(
            bottom: false,
            child: MaterialBanner(
              leading: const Icon(Icons.info_outline),
              forceActionsBelow: true,
              content: const Text(
                  'Một số dữ liệu lưu trên máy bị lỗi. Phần hợp lệ đã được tải; bản gốc được giữ để kiểm tra.'),
              actions: [
                TextButton(
                  onPressed: () =>
                      setState(() => _recoveryWarningDismissed = true),
                  child: const Text('Đã hiểu'),
                )
              ],
            ),
          ),
        Expanded(child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            final isExpanded = constraints.maxWidth >= 860;
            return Row(
              children: [
                SafeArea(
                  right: false,
                  child: NavigationRail(
                    extended: isExpanded,
                    minExtendedWidth: 184,
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (index) =>
                        setState(() => _currentIndex = index),
                    labelType: isExpanded
                        ? NavigationRailLabelType.none
                        : NavigationRailLabelType.all,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home_rounded),
                        label: Text('HOME'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.insights_outlined),
                        selectedIcon: Icon(Icons.insights_rounded),
                        label: Text('PROGRESS'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.explore_outlined),
                        selectedIcon: Icon(Icons.explore_rounded),
                        label: Text('PROGRAMS'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.restaurant_outlined),
                        selectedIcon: Icon(Icons.restaurant_rounded),
                        label: Text('NUTRITION'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person_outline_rounded),
                        selectedIcon: Icon(Icons.person_rounded),
                        label: Text('PROFILE'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 840),
                      child: _pages[_currentIndex],
                    ),
                  ),
                ),
              ],
            );
          }

          return Scaffold(
            backgroundColor: bgColor,
            body: _pages[_currentIndex],
            bottomNavigationBar: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) =>
                  setState(() => _currentIndex = index),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Home'),
                NavigationDestination(
                    icon: Icon(Icons.insights_outlined),
                    selectedIcon: Icon(Icons.insights_rounded),
                    label: 'Phân tích'),
                NavigationDestination(
                    icon: Icon(Icons.explore_outlined),
                    selectedIcon: Icon(Icons.explore_rounded),
                    label: 'Programs'),
                NavigationDestination(
                    icon: Icon(Icons.restaurant_outlined),
                    selectedIcon: Icon(Icons.restaurant_rounded),
                    label: 'Dinh dưỡng'),
                NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Hồ sơ'),
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: _aiNavItem(),
            ),
          );
        })),
      ]),
    );
  }

  Widget _aiNavItem() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Tooltip(
      message: 'Mở AI Coach',
      child: Semantics(
        button: true,
        label: 'AI Coach',
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            AiWorkoutBottomSheet.show(context);
          },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 64,
            height: 56,
            decoration: BoxDecoration(
              color:
                  isLight ? AppColors.primaryBlue : AppColors.primaryBlueLight,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.24),
                    blurRadius: 14,
                    offset: const Offset(0, 5))
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 23),
                SizedBox(height: 3),
                Text('AI',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
