import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_hands/base/res/global/global_variables.dart';

class ImagePredictionService {
  static Future<Map<String, dynamic>> sendImageToAPI(File imageFile) async {
    String apiUrl = 'http://${GlobalVariables.server}/api/predict/';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        
        // Ensure the expected fields exist, with defaults if they don't
        // This maintains backward compatibility if your API doesn't immediately return these fields
        if (!responseData.containsKey('is_valid_digit')) {
          // For backward compatibility: consider predictions 0-9 as valid digits
          int prediction = responseData['prediction'] ?? -1;
          responseData['is_valid_digit'] = (0 <= prediction && prediction <= 9);
        }
        
        if (!responseData.containsKey('gesture_type')) {
          // For backward compatibility: determine gesture type based on prediction
          int prediction = responseData['prediction'] ?? -1;
          responseData['gesture_type'] = (0 <= prediction && prediction <= 9) ? 'digit' : 'special';
        }
        
        return responseData;
      } else {
        throw Exception('Failed to predict: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}