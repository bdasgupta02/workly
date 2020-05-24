import 'package:workly/index.dart';

void main() {
  runApp(Workly());
}

class Workly extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workly',
      theme: ThemeData(
        primarySwatch: Colors.deepPurpleAccent[300], //[Action needed] Update colour
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LandingPage(
        auth: Auth(),
      ),
    );
  }
}
