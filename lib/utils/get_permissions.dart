import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:solstice/utils/constants.dart';

class GetImagePermission {
  bool granted = false;

  Permission _permission;
  final String subHeading;

  GetImagePermission.gallery(
      {this.subHeading = "Photos permission is needed to select photos"}) {
    if (Platform.isIOS) {
      _permission = Permission.photos;
      _permission = Permission.storage;
    } else {
      _permission = Permission.storage;
    }
  }

  GetImagePermission.camera(
      {this.subHeading = "Camera permission is needed to record video"}) {
    _permission = Permission.camera;
  }

  GetImagePermission.microphone(
      {this.subHeading = "Microphone permission is needed to record video"}) {
    _permission = Permission.microphone;
  }

  Future<void> getPermission(context) async {
    PermissionStatus permissionStatus = await _permission.status;
    print('permissionStatus $permissionStatus => ${_permission.value}');

    if (permissionStatus == PermissionStatus.restricted) {
      permissionStatus = await _permission.status;

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.permanentlyDenied) {
      permissionStatus = await _permission.status;
      print('permissionStatus=> $permissionStatus');

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _permission.request();
      print('Request ${permissionStatus}');

      if (permissionStatus == PermissionStatus.permanentlyDenied) {
        if (_permission.value == 1) {
          Constants().errorToast(
              context, "Please allow camera permission from settings");
        } else {
          Constants().errorToast(
              context, "Please allow storage permission from settings");
        }

        return;
      }
      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.denied) {
      if (Platform.isIOS) {
      } else {
        permissionStatus = await _permission.request();
      }

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.granted) {
      granted = true;
      return;
    }
  }
}
