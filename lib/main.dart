import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

// screens
import 'screens/login_screen.dart';
import 'screens/signupscreen.dart';
import 'screens/home.dart';
import 'screens/activity_screen.dart';
import 'screens/health_screen.dart';
import 'screens/navigation_bar.dart';
import 'screens/calories_detail_screen.dart';
import 'screens/active_time_detail_screen.dart';
import 'screens/ProfileScreen.dart';
import 'screens/CalendarScreen.dart';
import 'screens/DayDetailScreen.dart';
import 'screens/monthlystatsscreen.dart';
import 'screens/add_workout_screen.dart';
import 'screens/SignupCompleteScreen.dart';

// models
import 'models/workout_record.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP', null);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;

  void _handleLoginSuccess() => setState(() => isLoggedIn = true);
  void _handleLogout() => setState(() => isLoggedIn = false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ヘルスケアアプリ',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: isLoggedIn
          ? StepCounterApp(onLogout: _handleLogout)
          : AuthScreen(onLoginSuccess: _handleLoginSuccess),
    );
  }
}

class AuthScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const AuthScreen({super.key, required this.onLoginSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool signupCompleted = false; // ✅ 追加

  String signedUpUserName = ""; // サインアップ完了時の名前

  void _login(String email, String password) => widget.onLoginSuccess();

  void _signup(String name, String email, String password) {
    // サインアップ処理の後に
    setState(() {
      signedUpUserName = name;
      signupCompleted = true; // 完了画面に切り替え
    });
  }

  void _backToLoginFromSignupComplete() {
    setState(() {
      signupCompleted = false;
      isLogin = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (signupCompleted) {
      // サインアップ完了画面
      return SignupCompleteScreen(
        userName: signedUpUserName,
        onBackToLogin: _backToLoginFromSignupComplete,
      );
    }

    return isLogin
        ? LoginScreen(
            onLogin: _login,
            onNavigateToSignup: () => setState(() => isLogin = false),
            onNavigateToForgotPassword: () {},
          )
        : SignupScreen(
            onSignup: _signup,
            onBackToLogin: () => setState(() => isLogin = true),
          );
  }
}

class StepCounterApp extends StatefulWidget {
  final VoidCallback onLogout;
  const StepCounterApp({super.key, required this.onLogout});

  @override
  State<StepCounterApp> createState() => _StepCounterAppState();
}

class _StepCounterAppState extends State<StepCounterApp> {
  Stream<StepCount>? _stepStream;
  int _steps = 0;
  String _currentScreen = 'home';
  final List<WorkoutRecord> _workoutRecords = [];

  @override
  void initState() {
    super.initState();
    _loadSteps();
    _initPedometer();
  }

  Future<void> _initPedometer() async {
    if (await Permission.activityRecognition.request().isGranted ||
        !Theme.of(context).platform.toString().contains('android')) {
      _stepStream = Pedometer.stepCountStream;
      _stepStream!.listen((event) => setState(() => _steps = event.steps));
    }
  }

  int get calories => (_steps * 0.04).floor();
  int get activeMinutes => (_steps / 100).floor();

  Future<void> _saveSteps() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('today_steps', _steps);
  }

  Future<void> _loadSteps() async {
    final prefs = await SharedPreferences.getInstance();
    _steps = prefs.getInt('today_steps') ?? 0;
    setState(() {});
  }

  void _openDetail(String type) {
    if (type == 'calories') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CaloriesDetailScreen(
            onBack: () => Navigator.pop(context),
            todayCalories: calories,
            weeklyAvg: calories,
            monthlyTotal: calories * 30,
            goalCalories: 400,
            weeklyData: const [],
            monthlyData: const [],
            breakdownData: const [],
          ),
        ),
      );
    }

    if (type == 'active') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveTimeDetailScreen(
            onBack: () => Navigator.pop(context),
            todayMinutes: activeMinutes,
            weeklyTotal: activeMinutes * 7,
            monthlyTotal: activeMinutes * 30,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (_currentScreen) {
      case 'home':
        body = HomeScreen(steps: _steps, onNavigate: _openDetail);
        break;
      case 'activity':
        body = ActivityScreen();
        break;
      case 'calendar':
        body = CalendarScreen(
          workoutRecords: _workoutRecords,
          onNavigateToDayDetail: (date) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DayDetailScreen(
                  selectedDate: date,
                  workoutRecords: _workoutRecords,
                  onBack: () => Navigator.pop(context),
                ),
              ),
            );
          },
          onNavigateToAddWorkout: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddWorkoutScreen(
                  onBack: () => Navigator.pop(context),
                  onSave: (workout) {
                    setState(() {
                      _workoutRecords.add(
                        WorkoutRecord(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                          date: workout.date,
                          type: workout.type,
                          startTime: workout.startTime,
                          duration: workout.duration.toInt(),
                          calories: workout.calories,
                          distance: workout.distance,
                          heartRate: workout.heartRate?.toInt(),
                          notes: workout.notes,
                        ),
                      );
                    });
                  },
                ),
              ),
            );
          },
        );
        break;
      case 'health':
        body = HealthScreen();
        break;
      case 'monthly':
        body =
            MonthlyStatsScreen(onBack: () => setState(() => _currentScreen = 'home'));
        break;
      case 'profile':
        body = ProfileScreen(onLogout: widget.onLogout);
        break;
      default:
        body = const SizedBox();
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBarWidget(
        currentScreen: _currentScreen,
        onNavigate: (screen) => setState(() => _currentScreen = screen),
      ),
    );
  }
}
