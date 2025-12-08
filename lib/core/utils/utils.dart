import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';

class Utils {
  static void showToast(String message, {Toast? length, Color? color}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: length ?? Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 3,
      backgroundColor: color ?? Pallet.tertiaryColor,
      textColor: Colors.white,
      fontSize: 16,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
