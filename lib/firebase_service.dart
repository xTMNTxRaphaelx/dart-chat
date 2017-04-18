import 'dart:html';
import 'dart:async';

import 'package:angular2/core.dart';
import 'package:firebase/firebase.dart' as fb;

import './groups.dart';
import './messages.dart';

@Injectable()
class FirebaseService {

  fb.User user;

  fb.Auth _fbAuth;
  fb.GoogleAuthProvider _fbGoogleAuthProvider;

  fb.Database _fbDatabase;
  fb.Storage _fbStorage;
  fb.DatabaseReference _fbRefRooms;
  fb.DatabaseReference _fbRefMessages;

  List<Group> myGroups;
  List<Group> invitedGroups;
  List<Message> messages;
  List<Message> roomMessages;

  FirebaseService() {
    fb.initializeApp(
        apiKey: "AIzaSyBXeMnmGkReiO22PSqZhb8nStocThgjmDw",
        authDomain: "chat-work-2.firebaseapp.com",
        databaseURL: "https://chat-work-2.firebaseio.com",
        storageBucket: "chat-work-2.appspot.com"
    );

    _fbDatabase= fb.database();
    _fbRefRooms = _fbDatabase.ref('rooms');
    _fbRefMessages = _fbDatabase.ref('messages');

    void listGroups() {
      myGroups = [];
      invitedGroups= [];
      _fbRefRooms.onChildAdded.listen((e) {
        Group group = new Group.fromMap(e.snapshot.val());
        if(group.members.indexOf(user.displayName) != -1) {
          if(group.leader == user.displayName) {
            myGroups.add(group);
          } else {
            invitedGroups.add(group);
          }
        }

      });
    }

    void loadMessages() {
      messages = [];
      _fbRefMessages.onChildAdded.listen((e) {
        Message msg = new Message.fromMap(e.snapshot.val());
        messages.add(msg);
        updateRoomMessages(msg.roomName);
      });
    }

    void _authChanged(fb.AuthEvent event) {
      user = event.user;
      if(user != null) {
        listGroups();
        loadMessages();
      }
    }

    _fbGoogleAuthProvider= new fb.GoogleAuthProvider();
    _fbAuth = fb.auth();
    _fbAuth.onAuthStateChanged.listen(_authChanged);
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

  void updateRoomMessages(String roomname) {
    roomMessages= [];
    messages.forEach((message) {
      if(message.roomName == roomname) {
        roomMessages.add(message);
      }
    });
  }

  Future sendMessage({String text, String roomName, String imageURL}) async {
    try {
      Message msg= new Message(user.displayName, roomName, text, user.photoURL, imageURL);
      await _fbRefMessages.push(msg.toMap());
    }
    catch (err) {
      print ("$runtimeType:: sendMessage() -- $err");
    }
  }

  addMember(String memberName, String roomName) {
    _fbRefRooms.orderByChild('name').equalTo(roomName).once("value").then((e) {
      e.snapshot.forEach((data) {
        var snapshot= e.snapshot.val();
        var key= data.key;
        print(snapshot[key]);
        var membersList= snapshot[key]['members'];
        print(membersList);
        var newMembersList = membersList.add(memberName);
        print(newMembersList);
        _fbRefRooms.child(key).update({"members": newMembersList});
      });
    });
  }
//http://stackoverflow.com/questions/41427859/get-array-of-items-from-firebase-snapshot
}