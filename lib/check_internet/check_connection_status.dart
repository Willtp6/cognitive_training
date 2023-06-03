import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CheckConnectionStatus {
  ValueNotifier connectionStatus =
      ValueNotifier(Connectivity().checkConnectivity());
  CheckConnectionStatus() {
    Connectivity().onConnectivityChanged.listen((event) {
      Logger().i(event);
      connectionStatus.value = event;
    });
  }
}
