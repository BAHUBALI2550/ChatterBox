import 'dart:convert';
import 'dart:developer';

import 'package:chatter_box/sk.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final List<Map<String,String>> messages = [];
  Future<Object?> isArtPromptAPI(String prompt) async {
    try{
      final res = await http.post(Uri.parse('https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$openAIAPIKey'),
        headers: {
          'Content-Type' : 'application/json',
        },
        body: jsonEncode({
          "contents" : [{
            "parts":[{"text": "Does this message want to generate an AI picture, image, art or anything similar? : $prompt . Simply answer with a yes or no."}]
          }],
        }),
      );

      if(res.statusCode == 200){
        String content = jsonDecode(res.body)['candidates'][0]['content']['parts'][0]['text'];
        content = content.trim();
        print(content);

        switch(content) {
          case 'Yes' :
          case 'yes' :
          case 'Yes.' :
          case 'yes.' :
            final res = await generateImage(prompt);
            return res;
          default :
            final res = await chatGPTAPI(prompt);
            return res;
        }
      }
      return 'An internal error occurred';
    }catch(e){
      return e.toString();
    }
  }
  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role' : 'user',
      'content' : prompt,
    });
    try{
      final res = await http.post(Uri.parse('https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$openAIAPIKey'),
        headers: {
          'Content-Type' : 'application/json',
        },
        body: jsonEncode({
          "contents" : [{
            "parts":[{"text": prompt}]
          }],
        }),
      );
      if(res.statusCode == 200){
        String content = jsonDecode(res.body)['candidates'][0]['content']['parts'][0]['text'];
        content = content.trim();

        messages.add({
          'role' : 'assistant',
          'content' : content,
        });
        return content;
      }
      return 'An internal error occurred';

    }catch(e){
      return e.toString();
    }
  }
  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role' : 'user',
      'content' : prompt,
    });
    try{
      final res = await http.post(Uri.parse('https://api.vyro.ai/v1/imagine/api/generations'),
        headers: {
          'Authorization' : 'Bearer $imageAPIKey'
        },
        body: jsonEncode({
          'prompt': prompt,
          'style_id': '122',
          'aspect_ratio': '1:1',
          'cfg': '5',
          'seed': '1',
          'high_res_results': '1'
        }),
      );
      print(res.body);
      if(res.statusCode == 200){
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        messages.add({
          'role' : 'assistant',
          'content' : imageUrl,
        });
        return imageUrl;
      }
      return 'An internal error occured';
      return 'AI';
    }catch(e){
      return e.toString();
    }
  }

  Future<Uint8List?> generateImage(String prompt) async {
    try {
      String url = 'https://api.vyro.ai/v1/imagine/api/generations';
      Map<String, dynamic> headers = {
        'Authorization': 'Bearer $imageAPIKey'
      };

      Map<String, dynamic> payload = {
        'prompt': prompt,
        'style_id': '122',
        'aspect_ratio': '1:1',
        'cfg': '5',
        'seed': '1',
        'high_res_results': '1'
      };

      FormData formData = FormData.fromMap(payload);

      Dio dio = Dio();
      dio.options =
          BaseOptions(headers: headers, responseType: ResponseType.bytes);

      final response = await dio.post(url, data: formData);
      if (response.statusCode == 200) {
        log(response.data.runtimeType.toString());
        log(response.data.toString());
        Uint8List uint8List = Uint8List.fromList(response.data);
        return uint8List;
      } else {
        return null;
      }
    } catch (e) {
      log(e.toString());
    }
  }
}