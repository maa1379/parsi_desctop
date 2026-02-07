import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parsi/core/network/ApiHelper.dart';

import '../core/PrefHelper/PrefHelpers.dart';
import '../models/configs_model.dart';

class TrainingProvider with ChangeNotifier {
  List<TrainingModel> _trainings = [];
  bool _isLoading = false;
  TrainingModel? _currentTraining;

  List<TrainingModel> get trainings => _trainings;
  bool get isLoading => _isLoading;
  TrainingModel? get currentTraining => _currentTraining;

  // آدرس بیس سرور خود را اینجا وارد کنید

  Future<void> fetchTrainings() async {
    _isLoading = true;
    notifyListeners();
    print('${ApiHelper.baseUrl}configs/trainings');
      final response = await http.get(Uri.parse('${ApiHelper.baseUrl}configs/trainings'),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            "authorization": "bearer ${await PrefHelpers.getToken()}",
      });
      if (response.statusCode == 200) {
        print(response.body);
        final List<dynamic> data = json.decode(response.body);
        _trainings = data.map((e) => TrainingModel.fromJson(e)).toList();
        if (_trainings.isNotEmpty) {
          _currentTraining = _trainings.first;
        }
      } else {
        print("Error fetching data: ${response.statusCode}");
      }
    try {
    } catch (e) {
      print("Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // متد برای تغییر ویدیو وقتی روی تایتل کلیک می‌شود
  void playTraining(TrainingModel training) {
    _currentTraining = training;
    notifyListeners();
  }

  List<FAQModel> _faqs = [];

  List<FAQModel> get faqs => _faqs;
  Future<void> fetchFAQs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('${ApiHelper.baseUrl}configs/faqs'),  headers: {
        'Content-type': 'application/json',
        "authorization": "bearer ${await PrefHelpers.getToken()}",
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _faqs = data.map((e) => FAQModel.fromJson(e)).toList();
      } else {
        print("Error fetching FAQs: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}