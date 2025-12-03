import 'package:depd_mvvm_2025/viewmodel/international_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:depd_mvvm_2025/shared/style.dart';
import 'package:depd_mvvm_2025/view/pages/pages.dart';
import 'package:depd_mvvm_2025/viewmodel/home_viewmodel.dart';

Future<void> main() async {
  // Memastikan binding Flutter sudah diinisialisasi sebelum menjalankan aplikasi
  WidgetsFlutterBinding.ensureInitialized();
  // Memuat file .env sebelum diakses widget
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => InternationalViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter x RajaOngkir API',
        theme: ThemeData(
          primaryColor: Style.blue800,
          scaffoldBackgroundColor: Style.grey50,
          textTheme: Theme.of(
            context,
          ).textTheme.apply(bodyColor: Style.black, displayColor: Style.black),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Style.blue800),
              foregroundColor: WidgetStateProperty.all<Color>(Style.white),
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.all(16),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Style.blue800),
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Style.grey500),
            floatingLabelStyle: TextStyle(color: Style.blue800),
            hintStyle: TextStyle(color: Style.grey500),
            iconColor: Style.grey500,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Style.grey500),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Style.blue800, width: 2),
            ),
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {'/': (context) => const MainPage()},
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(), // Accessible because we imported pages.dart
    const InternationalPage(),
    const FreePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Style.blue800,
        unselectedItemColor: Style.grey500,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Domestic',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'International',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.catching_pokemon),
            label: 'Free',
          ),
        ],
      ),
    );
  }
}
