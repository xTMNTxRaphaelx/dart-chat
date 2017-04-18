// Copyright (c) 2017, f1sh. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:html";
import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

import './app_header/app_header.dart';
import 'firebase_service.dart';

import 'scroll_down.dart';

@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [AppHeader, VuScrollDown],
  providers: const [materialProviders, FirebaseService],
)
class AppComponent {
  final FirebaseService fbService;
  String groupName = "";
  String chatMessage = "";
  String newMember = "";
  List chatRoomMessage = [];
  var activeRoom= "";
  List activeMembers = [];
  List myGroups = [];
  List invitedGroups = [];

  var isRoomActive = false;

  AppComponent(FirebaseService this.fbService) {}


  void addGroup() {
    String name = groupName.trim();
//    print(name);
    if(name.isNotEmpty) {
      fbService.addGroup(name);
      groupName = "";
    }
  }

  void loadMessages(room) {
    activeRoom= room.name;
    activeMembers= room.members;
    isRoomActive= true;
    fbService.updateRoomMessages(activeRoom);
  }

  void sendMessage() {
    if(chatMessage.isNotEmpty) {
      fbService.sendMessage(text: chatMessage, roomName: activeRoom);
      chatMessage = "";
    }
  }

  void addMember() {
    if(newMember.isNotEmpty) {
      fbService.addMember(newMember, activeRoom);
      activeMembers.add(newMember);
    }
  }

  void removeMember(memberName) {
    fbService.removeMember(memberName, activeRoom);
    List tempList= [];
    activeMembers.asMap().forEach((i, value) {
      if(value != memberName) {
        tempList.add(value);
      }
    });
    activeMembers = tempList;
  }

  isYou(email) {
    if(fbService.user.displayName != email) {
      return true;
    } else {
      return false;
    }
  }

  isMe(email) {
    if(fbService.user.displayName == email) {
      return true;
    } else {
      return false;
    }
  }

  void sendImageMessage(FileList files) {
    if(files.isNotEmpty) {
      fbService.sendImage(files.first, activeRoom);
    }
  }
}
