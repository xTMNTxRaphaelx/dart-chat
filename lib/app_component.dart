// Copyright (c) 2017, f1sh. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

import './app_header/app_header.dart';
import 'firebase_service.dart';

@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [AppHeader],
  providers: const [materialProviders, FirebaseService],
)
class AppComponent {
  final FirebaseService fbService;
  String groupName = "";

  AppComponent(FirebaseService this.fbService) {}

  void addGroup() {
    String name = groupName.trim();

    if(name.isNotEmpty) {
      fbService.addGroup(name);
      groupName = "";
    }
  }
}
