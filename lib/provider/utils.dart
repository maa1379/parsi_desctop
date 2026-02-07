

/// تابعی برای تبدیل اعداد فارسی و عربی به انگلیسی
String replaceFarsiToEnglishNumber(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  for (int i = 0; i < farsi.length; i++) {
    input = input.replaceAll(farsi[i], english[i]);
  }

  for (int i = 0; i < arabic.length; i++) {
    input = input.replaceAll(arabic[i], english[i]);
  }
  // رفع مشکل کاراکتر '٫'
  input = input.replaceAll("٫", ".");
  return input;
}

/// تابعی یکپارچه برای محاسبه بایت مصرفی از رشته‌های V2Ray
/// مثال ورودی: "1.23 MB" یا "100 KB" یا "12345678" (بایت)
int parseTrafficUsage(String data) {
  final String englishData =
      replaceFarsiToEnglishNumber(data).toLowerCase().trim();
  double value = 0;

  if (englishData.contains("gb")) {
    value =
        (double.tryParse(englishData.replaceAll("gb", "").trim()) ?? 0) *
        1024 *
        1024 *
        1024;
  } else if (englishData.contains("mb")) {
    value =
        (double.tryParse(englishData.replaceAll("mb", "").trim()) ?? 0) *
        1024 * 1024 *
        1024;
  } else if (englishData.contains("kb")) {
    value =
        (double.tryParse(englishData.replaceAll("kb", "").trim()) ?? 0) * 1024;
  } else if (englishData.contains("b")) {
    // شامل " B" یا "B"
    value = double.tryParse(englishData.replaceAll("b", "").trim()) ?? 0;
  } else {
    // --- <<< این راه حل مشکل است >>> ---
    // اگر هیچ واحدی پیدا نشد، فرض می‌کنیم رشته ورودی، عدد بایت است
    value = double.tryParse(englishData) ?? 0;
    // ---
  }

  return value.toInt();
}

/// تابع ترکیبی برای دانلود و آپلود
int getCombinedTraffic(String downloadStr, String uploadStr) {
  final int download = parseTrafficUsage(downloadStr);
  final int upload = parseTrafficUsage(uploadStr);
  return download + upload;
}
