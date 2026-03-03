import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
import 'screens/monthlystatsscreen.dart';
import 'screens/add_workout_screen.dart';
import 'screens/SignupCompleteScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // 🔥 追加
  await initializeDateFormatting('ja_JP', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ヘルスケアアプリ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthGate(), // 🔥 変更
    );
  }
}

/// 🔥 Firebaseログイン状態を監視するゲート
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ローディング中
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ログイン済み
        if (snapshot.hasData) {
          return StepCounterApp(
            onLogout: () async {
              await FirebaseAuth.instance.signOut();
            },
          );
        }

        // 未ログイン
        return const AuthScreen();
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool signupCompleted = false;
  String signedUpUserName = "";

  /// 🔥 Firebaseログイン処理
  Future<void> _login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'ログインに失敗しました')),
      );
    }
  }

  void _signup(String name, String email, String password) {
    setState(() {
      signedUpUserName = name;
      signupCompleted = true;
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
      _stepStream!.listen((event) {
        setState(() {
          _steps = event.steps;
        });
        _saveSteps(); // 🔥 歩数更新時に保存
      });
    }
  }

  int get calories => (_steps * 0.04).floor();
  int get activeMinutes => (_steps / 100).floor();

  Future<void> _saveSteps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('today_steps', _steps);
  }

  Future<void> _loadSteps() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _steps = prefs.getInt('today_steps') ?? 0;
    });
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
        body = HomeScreen(
          steps: _steps,
          onNavigate: _openDetail,
        );
        break;
      case 'activity':
        body = ActivityScreen();
        break;
      case 'calendar':
        body = CalendarScreen(
          onNavigateToAddWorkout: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddWorkoutScreen(
                  onBack: () => Navigator.pop(context),
                  onSave: (_) {},
                ),
              ),
            ).then((_) {
              setState(() {});
            });
          },
        );
        break;
      case 'health':
        body = HealthScreen();
        break;
      case 'monthly':
        body = MonthlyStatsScreen(
          onBack: () => setState(() => _currentScreen = 'home'),
        );
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
        onNavigate: (screen) {
          setState(() {
            _currentScreen = screen;
          });
        },
      ),
    );
  }
}