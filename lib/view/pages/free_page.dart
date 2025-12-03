part of 'pages.dart';

class FreePage extends StatefulWidget {
  const FreePage({super.key});

  @override
  State<FreePage> createState() => _FreePageState();
}

class _FreePageState extends State<FreePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Free Page',
        style: TextStyle(fontSize: 24, color: Colors.blue[800]),
      ),
    );
  }
}
