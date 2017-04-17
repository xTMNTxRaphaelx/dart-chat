import 'dart:html';
import 'dart:async';

import 'package:angular2/core.dart';
import 'package:firebase/firebase.dart' as fb;

import './groups.dart';

@Injectable()
class FirebaseService {
  fb.User user;
  fb.Auth _fbAuth;
  fb.GoogleAuthProvider _fbGoogleAuthProvider;
  fb.Database _fbDatabase;
  fb.Storage _fbStorage;
  fb.DatabaseReference _fbRefRooms;
  fb.DatabaseReference _fbRefMessages;

  List<Group> groups;

  FirebaseService() {
    fb.initializeApp(
        apiKey: "AIzaSyBXeMnmGkReiO22PSqZhb8nStocThgjmDw",
        authDomain: "chat-work-2.firebaseapp.com",
        databaseURL: "https://chat-work-2.firebaseio.com",
        storageBucket: "chat-work-2.appspot.com"
    );

    void _authChanged(fb.AuthEvent event) {
      user = event.user;
    }

    _fbGoogleAuthProvider= new fb.GoogleAuthProvider();
    _fbAuth = fb.auth();
    _fbAuth.onAuthStateChanged.listen(_authChanged);

    _fbDatabase= fb.database();
    _fbRefRooms = _fbDatabase.ref('rooms');

    void _newGroup(fb.QueryEvent event) {
      print(event.snapshot.val());
      Group group = new Group.fromMap(event.snapshot.val());
      groups.add(group);
    }

    if(user != null) {
      groups= [];
      _fbRefRooms.limitToLast(12).onChildAdded.listen(_newGroup);
    }
  }

  Future signIn() async {
    try {
      await _fbAuth.signInWithPopup(_fbGoogleAuthProvider);
    }
    catch (error) {
      print("$runtimeType:: login() -- $error");
    }
  }

  void signOut() {
    _fbAuth.signOut();
  }

  Future addGroup(String name) async {
    try {
      Group group= new Group(name, user.displayName, [user.displayName]);
      await _fbRefRooms.push(group.toMap());
    }
    catch (err) {
      print ("$runtimeType:: addGroup() -- $err");
    }
  }
}