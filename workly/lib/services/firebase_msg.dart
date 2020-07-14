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
    'Authorization': "key=AAAAe_6bg90:APA91bFJLXATG_94pE0k5ECMt7ApY5hvOv3NxQaeom4M_H7E_4Ozkz4tmkZZWn20gsoNX3NBh_uqgDdDrR1LsqYDO2JzyLqE1HeCKfGYFx8Yc673gaZBt1ofKdf-VeYItnsZFg7Wh2rG"
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