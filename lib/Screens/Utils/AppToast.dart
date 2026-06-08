import 'package:fluttertoast/fluttertoast.dart';

class AppToast {
  const AppToast._();

  static Future<bool?> show({
    String? title,
    required String message,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast toastLength = Toast.LENGTH_SHORT,
  }) {
    final trimmedMessage = message.trim();
    final trimmedTitle = title?.trim();

    final msg =
        (trimmedTitle == null || trimmedTitle.isEmpty)
            ? trimmedMessage
            : '$trimmedMessage';

    if (msg.isEmpty) {
      return Future.value(false);
    }

    return Fluttertoast.showToast(
      msg: msg,
      gravity: gravity,
      toastLength: toastLength,
    );
  }

  static Future<bool?> success(String message) {
    return show(title: 'Success', message: message);
  }

  static Future<bool?> error(String message) {
    return show(title: 'Error', message: message);
  }
}
