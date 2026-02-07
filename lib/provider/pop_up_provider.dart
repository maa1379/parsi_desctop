import 'package:flutter/material.dart';

import '../core/network/api_service.dart';
import '../models/pop_up_model.dart';
import 'check_internet_connection.dart';

class PopUpProvider extends ChangeNotifier {
  late PopUpModel popUpModel;
  final ApiService api = ApiService();

// ورودی کانتکست را اضافه کنید تا بتوانیم وضعیت صفحه را چک کنیم
  void getPopUp(Function show) async {

    if (await CheckInternetConnection.checkInternetConnection() == true) {

      final res = await api.getLastPopUp();

      if (res.statusCode == 200 && res.data['data']['last'] != null) {

        popUpModel = PopUpModel.fromJson(res.data['data']);

        final getSavedPopUp = await PopUpModel.getDB();

        if (getSavedPopUp == null ||

            getSavedPopUp.last.id != popUpModel.last.id) {

          show();

          await PopUpModel.saveToDB(popUpModel);

        }

      } else {}

    }

  }

  void showInitDialog(BuildContext context) async {
    Size size = MediaQuery.sizeOf(context);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              alignment: Alignment.center,
              height: size.height * .25,
              width: size.width,
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/back.png"),
                    fit: BoxFit.cover,
                  )),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: Image.network(
                      popUpModel.last.popUpPath,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
