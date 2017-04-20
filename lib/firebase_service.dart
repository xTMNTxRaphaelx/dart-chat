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
  fb.DatabaseReference _fbRefGroups;
  fb.DatabaseReference _fbRefMessages;

  List<Group> myGroups;
  List<Group> invitedGroups;
  var selectedGroup;
  List<Message> messages;
  List<Message> groupMessages;

  FirebaseService() {
    fb.initializeApp(
        apiKey: "AIzaSyBXeMnmGkReiO22PSqZhb8nStocThgjmDw",
        authDomain: "chat-work-2.firebaseapp.com",
        databaseURL: "https://chat-work-2.firebaseio.com",
        storageBucket: "chat-work-2.appspot.com");

    _fbDatabase = fb.database();
    _fbRefGroups = _fbDatabase.ref('rooms');
    _fbRefMessages = _fbDatabase.ref('messages');

    _fbStorage = fb.storage();

    _fbGoogleAuthProvider = new fb.GoogleAuthProvider();

    _fbAuth = fb.auth();
    _fbAuth.onAuthStateChanged.listen((fb.AuthEvent event) {
      user = event.user;
      if (user != null) {
        myGroups = [];
        invitedGroups = [];
        messages = [];
        _fbRefGroups.onChildAdded.listen(this.groupAdded);
        _fbRefGroups.onChildChanged.listen(this.groupChanged);

        _fbRefMessages.onChildAdded.listen(this.messageAdded);
      }
    });
  }

  /**
   * Firebase event triggered when group is added in fbRef. Sort groups based on my groups or invited group
   */
  void groupAdded(e) {
    Group group = new Group.fromMap(e.snapshot.val());
    if (group.members.indexOf(user.displayName) != -1) {
      if (group.leader == user.displayName) {
        myGroups.add(group);
      } else {
        invitedGroups.add(group);
      }
    }
  }

  /**
   * Firebase event triggered when group is editted in fbRef[mostly when someone is added or removed].
   */
  void groupChanged(e) {
    Group group = new Group.fromMap(e.snapshot.val());
    //if change is done by group leader, show/remove invited user in right list
    if (group.leader == user.displayName) {
      myGroups.forEach((igroup) {
        if (igroup.name == group.name) {
          igroup.members = group.members;
        }
      });
    } else {
      bool wasAdded = false;
      invitedGroups.forEach((igroup) {
        if (igroup.name == group.name) {
          wasAdded = true;
          // some other user was added
          if (igroup.members.indexOf(user.displayName) != -1 && group.members.indexOf(user.displayName) == -1) {
            igroup.name = '';
          } else {
            igroup.members = group.members;
          }
        }
      });
      if (!wasAdded) {
        invitedGroups.add(group);
      }
    }
  }

  /**
   * Firebase future async function to add new group.
   */
  Future addGroup(String groupName) async {
    try {
      Group group = new Group(groupName, user.displayName, [user.displayName]);
      await _fbRefGroups.push(group.toMap());
    } catch (err) {
      print("$runtimeType:: addGroup() -- $err");
    }
  }

  void selectGroup(String groupName) {
    bool wasMyGroup= false;
    myGroups.forEach((group) {
      if(group.name == groupName) {
        selectedGroup= group;
        wasMyGroup= true;
      }
    });

    if(!wasMyGroup) {
      invitedGroups.forEach((group) {
        if(group.name == groupName) {
          selectedGroup= group;
        }
      });
    }

    this.refreshRoomMessages(selectedGroup.name);
  }

  /**
   * Firebase event triggered when message is added in fbRef.
   */
  void messageAdded(e) {
    Message msg = new Message.fromMap(e.snapshot.val());
    messages.add(msg);
    this.refreshRoomMessages(msg.roomName);
  }

  /**
   * Event triggered to refresh messages shown inside room.
   */
  void refreshRoomMessages(String groupName) {
    groupMessages = [];
    messages.forEach((message) {
      if (message.roomName == groupName) {
        groupMessages.add(message);
      }
    });
  }

  /**
   * Event triggered when user is sending a new message. Add message to firebase ref.
   */
  Future sendMessage({String text, String groupName, String imageURL}) async {
    try {
      Message msg = new Message(
          user.displayName, groupName, text, user.photoURL, imageURL);
      await _fbRefMessages.push(msg.toMap());
    } catch (err) {
      print("$runtimeType:: sendMessage() -- $err");
    }
  }

  /**
   * Event triggered when member is added to a group.
   */
  addMember(String memberName, String roomName) {
    _fbRefGroups.orderByChild('name').equalTo(roomName).once("value").then((e) {
      e.snapshot.forEach((data) {
        var snapshot = e.snapshot.val();
        var key = data.key;
        List membersList = snapshot[key]['members'];
        membersList.add(memberName);
        _fbRefGroups.child(key).update({"members": membersList});
      });
    });
  }

  /**
   * Event triggered when member is removed from a group.
   */
  removeMember(String memberName, String roomName) {
    _fbRefGroups.orderByChild('name').equalTo(roomName).once("value").then((e) {
      e.snapshot.forEach((data) {
        var snapshot = e.snapshot.val();
        var key = data.key;
        List membersList = snapshot[key]['members'];
        List tempList = [];
        membersList.asMap().forEach((i, value) {
          if (value != memberName) {
            tempList.add(value);
          }
        });
        _fbRefGroups.child(key).update({"members": tempList});
      });
    });
  }

  Future signIn() async {
    try {
      await _fbAuth.signInWithPopup(_fbGoogleAuthProvider);
    } catch (error) {
      print("$runtimeType:: login() -- $error");
    }
  }

  void signOut() {
    _fbAuth.signOut();
  }


  Future sendImage(File file, String roomName) async {
    fb.StorageReference fbRefImage =
        _fbStorage.ref("${user.uid}/${new DateTime.now()}/${file.name}");

    fb.UploadTask task =
        fbRefImage.put(file, new fb.UploadMetadata(contentType: file.type));

    StreamSubscription sub;

    sub = task.onStateChanged.listen((fb.UploadTaskSnapshot snapshot) {
      print(
          "uploading image -- transfered ${snapshot.bytesTransferred}/${snapshot.totalBytes}...");
      if (snapshot.bytesTransferred == snapshot.totalBytes) {
        sub.cancel();
      }
    }, onError: (fb.FirebaseError error) {
      print(error.message);
    });

    try {
      fb.UploadTaskSnapshot snapshot = await task.future;

      if (snapshot.state == fb.TaskState.SUCCESS) {
        sendMessage(
            text: '',
            imageURL: snapshot.downloadURL.toString(),
            groupName: roomName);
      }
    } catch (err) {
      print(err);
    }
  }
}
