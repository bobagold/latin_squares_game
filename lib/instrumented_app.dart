import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'main.dart';

void main() {
  var requests = StreamController<String>.broadcast();
  var responses = StreamController<String>.broadcast();

  enableFlutterDriverExtension(handler: (message) async {
    requests.sink.add(message.toUpperCase());
    var response = Completer<String>();
    var subscription;
    subscription = responses.stream.listen((event) {
      response.complete(event);
      subscription?.cancel();
    });
    return response.future;
  });

  runApp(MyApp(requests: requests, responses: responses));
}
