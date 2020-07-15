import 'dart:convert';

import 'package:http/http.dart' as http;

Future<void> sendNoti(String userToken) async {

  final postUrl = 'https://fcm.googleapis.com/fcm/send';
  final data = {
    // "registration_ids" : [userToken],
    "to": userToken,
    // "collapse_key" : "type_a",
    "notification" : {
      "title": '1NewTextTitle',
      "body" : '1NewTextBody',
    }
  };

  final headers = {
    'content-type': 'application/json',
    'Authorization': "",
  };
  final response = await http.post(postUrl,
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
      headers: headers);
  
  if (response.statusCode == 200) {
    print('test ok push CFM');
  } else {
    print(response.statusCode);
    print(' CFM error');
  }
}