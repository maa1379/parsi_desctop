import '../PrefHelper/PrefHelpers.dart';
import 'ApiHelper.dart';

class ApiService {
  Future<ApiResult> getAllConfig() async {
    final response = await ApiHelper.makeGetRequest(
      path: "configs/getAllConfigs/",
      header: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        "authorization": "bearer ${await PrefHelpers.getToken()}",
      },
    );
    return response;
  }

  Future<ApiResult> getSetting() async {
    final response = await ApiHelper.makeGetRequest(
      path: "settings/getSetting/",
      header: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return response;
  }


  Future<ApiResult> disconnectOtherUsers(String subCode,String userId) async {
    final response = await ApiHelper.makePostRequest(
      path: "accounts/disconnectOtherUsers/",
      body: {
        "subCode": subCode,
        "userId": userId,
      },
      header: {
        "authorization": "bearer ${await PrefHelpers.getToken()}",
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return response;
  }




  Future<ApiResult> setUserDeviceInfo(
      String deviceInfo, String fcm_token) async {
    final response =
        await ApiHelper.makePostRequest(path: "users/setUserInfo/", header: {
      // "authorization": "bearer ${await PrefHelpers.getToken()}",
      'Content-type': 'application/json',
      'Accept': 'application/json',
    }, body: {
      "device": deviceInfo,
      "fcm_token": fcm_token,
    });

    print("------------------------");
    print(response.statusCode);
    print(response.data);
    print(response.message);
    print("------------------------");

    return response;
  }

  Future<ApiResult> getUserInfo(String id) async {
    final response = await ApiHelper.makeGetRequest(
      path: "users/getUserInfo/$id/",
      header: {
        "authorization": "bearer ${await PrefHelpers.getToken()}",
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return response;
  }

  Future<ApiResult> getAllSubPeriod() async {
    final response = await ApiHelper.makeGetRequest(
      path: "accounts/getAllSubPeriod/",
      header: {
        "authorization": "bearer ${await PrefHelpers.getToken()}",
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return response;
  }

  Future<ApiResult> getAllNotification(String id) async {
    final response = await ApiHelper.makeGetRequest(
      path: "notifications/getAllNotificationForUser/$id",
      header: {
        "authorization": "bearer ${await PrefHelpers.getToken()}",
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
    );
    print(response.statusCode);
    print(response.data);
    return response;
  }

  Future<ApiResult> getLastPopUp() async {
    final response = await ApiHelper.makeGetRequest(
      path: "notifications/getLastPopUp/",
      header: {
        "authorization": "bearer ${await PrefHelpers.getToken()}",
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
    );
    print(response.data);
    print(response.data);
    print(response.data);
    print(response.data);
    print(response.data);
    print(response.data);
    print(response.statusCode);
    print(response.statusCode);
    print(response.statusCode);
    print(response.statusCode);
    return response;
  }

  Future<ApiResult> getAccountInfo(String id) async {
    final response = await ApiHelper.makeGetRequest(
      path: "accounts/getAccountInfo/$id/",
      header: {
        "authorization": "bearer ${await PrefHelpers.getToken()}",
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return response;
  }

  Future<ApiResult> getPayInfo() async {
    final response = await ApiHelper.makeGetRequest(
      path: "accounts/getPayInfo/",
      header: {
        "authorization": "bearer ${await PrefHelpers.getToken()}",
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return response;
  }

  Future<ApiResult> createAccountSub(
    String periodId,
    String userId,
    String phoneNumber,
    String note,
    bool forOthers,
    String offerCode,
  ) async {
    final response = await ApiHelper.makePostRequest(
      path: "accounts/createAccountSub/",
      header: {
        "authorization": "bearer ${await PrefHelpers.getToken()}",
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
      body: {
        "periodId": periodId,
        "userId": userId,
        "phone_number": phoneNumber,
        "note": note,
        "for_others": forOthers,
        "offer_code": offerCode,
      },
    );
    return response;
  }

  Future<ApiResult> accountRenewal(String subCode) async {
    final response = await ApiHelper.makePostRequest(
      path: "accounts/accountRenewal/",
      header: {
        "authorization": "bearer ${await PrefHelpers.getToken()}",
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
      body: {
        "subCode": subCode,
      },
    );
    return response;
  }


  Future<ApiResult> accountRenewalWithWallet(String subCode,String offerCode,String periodId) async {
    final response = await ApiHelper.makePostRequest(
      path: "accounts/accountRenewalWithWallet/",
      header: {
        "authorization": "bearer ${await PrefHelpers.getToken()}",
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
      body: {
        "subCode": subCode,
        "offer_code": offerCode,
        "periodId": periodId,
        "userId": await PrefHelpers.getUserId(),
      },
    );

    return response;
  }

  Future<ApiResult> checkSubNumber(String subCode, String userId) async {
    final response = await ApiHelper.makePostRequest(
      path: "accounts/checkSubNumber/",
      header: {
        "authorization": "bearer ${await PrefHelpers.getToken()}",
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
      body: {
        "subCode": subCode,
        "userId": userId,
      },
    );
    return response;
  }

  Future<ApiResult> getActiveAccount(String subCode, String deviceId) async {
    final response = await ApiHelper.makeGetRequest(
      path: "accounts/getActiveAccount/$deviceId/$subCode/",
      header: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        "authorization": "bearer ${await PrefHelpers.getToken()}",
      },
    );
    print(response.data);
    return response;
  }

  Future<ApiResult> updateTrafficAccount(String id, int traffic) async {
    print(traffic);
    print(traffic);
    print(traffic);
    final response = await ApiHelper.makePutRequest(
      path: "accounts/updateTrafficAccount/$id",
      header: {
        "authorization": "bearer ${await PrefHelpers.getToken()}",
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
      body: {
        "traffic": traffic,
      },
    );
    return response;
  }

  Future<ApiResult> removeDevice(String subCode) async {
    final response = await ApiHelper.makePostRequest(
      path: "accounts/removeDevice/",
      header: {
        "authorization": "bearer ${await PrefHelpers.getToken()}",
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
      body: {
        "subCode": subCode,
        "is_default_sub": true,
      },
    );
    return response;
  }

  Future<ApiResult> checkOfferCode(String code) async {
    final response = await ApiHelper.makePostRequest(
      path: "accounts/checkOfferCode/",
      header: {
        "authorization": "bearer ${await PrefHelpers.getToken()}",
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
      body: {
        "code": code,
      },
    );
    print(response.data);
    return response;
  }

  Future<ApiResult> getWallet(String id) async {
    final response = await ApiHelper.makeGetRequest(
      path: "wallets/getWallet/$id",
      header: {
        "authorization": "bearer ${await PrefHelpers.getToken()}",
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return response;
  }

  Future<ApiResult> chargeWallet(
      bool status, String amount, String walletId) async {
    final response = await ApiHelper.makePostRequest(
      path: "wallets/chargeWallet/",
      header: {
        "authorization": "bearer ${await PrefHelpers.getToken()}",
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
      body: {
        "status": status,
        "amount": amount,
        "walletId": walletId,
      },
    );
    return response;
  }

  Future<ApiResult> createAccountWithWallet(
    String periodId,
    String userId,
    String phoneNumber,
    String note,
    bool forOthers,
    String offerCode,
  ) async {
    final response = await ApiHelper.makePostRequest(
      path: "accounts/createAccountWithWallet/",
      header: {
        "authorization": "bearer ${await PrefHelpers.getToken()}",
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
      body: {
        "periodId": periodId,
        "userId": userId,
        "phone_number": phoneNumber,
        "note": note,
        "for_others": forOthers,
        "offer_code": offerCode,
      },
    );
    return response;
  }
}
