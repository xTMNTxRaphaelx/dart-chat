import 'package:angular2/angular2.dart';

import '../firebase_service.dart';

@Component(
  selector: 'app-header',
  templateUrl: 'app_header.html',
  styleUrls: const ['app_header.css']
)
class AppHeader {
  final FirebaseService fbService;

  AppHeader(FirebaseService this.fbService);
}