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

  bool isGroupActive;

//  Logged User
  String newGroupName = "";
  String activeGroup = "";
  String chatMessage = "";
  String userToInvite = "";


  AppComponent(FirebaseService this.fbService) {
    this.isGroupActive = false;
  }

  /**
   * Function is called when user is trying to add new group.
   */
  void addGroup() {
    String groupName = newGroupName.trim();
    if (groupName.isNotEmpty) {
      fbService.addGroup(groupName);
      newGroupName = "";
    }
  }

  /**
   * Function triggered when user selectes a group.
   */
  void selectGroup(group) {
    isGroupActive = true;
    activeGroup = group.name;
    fbService.selectGroup(activeGroup);
  }

  /**
   * Function triggered when user sends a message.
   */
  void sendMessage() {
    String chatMsg = chatMessage.trim();
    if (chatMsg.isNotEmpty) {
      fbService.sendMessage(text: chatMsg, groupName: activeGroup);
      chatMessage = "";
    }
  }


  /**
   * Fcuntion triggered to add a new member to active group
   */
  void addMember() {
    String newMemb = userToInvite.trim();
    if (newMemb.isNotEmpty) {
      fbService.addMember(newMemb, activeGroup);
      userToInvite = "";
    }
  }

  /**
   * Function triggered to remove a member from active group.
   */
  void removeMember(memberName) {
    fbService.removeMember(memberName, activeGroup);
  }

  isYou(email) {
    if (fbService.user.displayName != email) {
      return true;
    } else {
      return false;
    }
  }

  isMe(email) {
    if (fbService.user.displayName == email) {
      return true;
    } else {
      return false;
    }
  }

  void sendImageMessage(FileList files) {
    if (files.isNotEmpty) {
      fbService.sendImage(files.first, activeGroup);
    }
  }
}
