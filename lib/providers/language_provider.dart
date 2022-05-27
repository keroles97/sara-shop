import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  String? language;
  bool loaded = false;

  Map<String, String> eng = {
    "app_name": "Sara Shop",
    "theme_mode": "Theme mode",
    "theme_color": "Theme color",
    "language": "Language",
    "contact_us": "Contact us",
    "contact_us_copied": "Copied to clipboard",
    "contact_us_message": "Contact us through Email and WhatsApp.",
    "light": "Light",
    "dark": "Dark",
    "tab_home": "Home",
    "tab_favorites": "Favorites",
    "tab_account": "Account",
    "tab_settings": "Settings",
    "color_picker": "Pick a color",
    "login_header": "Login",
    "register_header": "Register",
    "login_sub_header": "To start in publishing your services.",
    "form_email": "Email Address",
    "form_password": "Password",
    "form_name": "Name",
    "form_email_validate": "Please enter a valid email address",
    "form_password_validate":
        "Password must be at least 8 characters without spaces",
    "form_name_validate": "Name must be at least 3 characters",
    "login": "Login",
    "register": "Register",
    "logout": "Logout",
    "forget_password": "Forget my password",
    "not_member": "Not a member?",
    "already_member": "Already a member?",
    "check_internet": "Check internet connection",
    "wrong_password": "Password is incorrect",
    "already_signed_up": "That email is already has an account",
    "user_not_found": "Unregistered email",
    "requires-recent-login":
        "Logout, Login again then try the update operation",
    "reset_password_email_sent":
        "Password reset link has been sent to your email",
    "email_verification_sent": "Check your email to confirm it then Login ",
    "services_chat_support": "Services Chat Support",
    "my_services": "My Services",
    "add_service": "Add Service",
    "my_profile": "My Profile",
    "account_status": "Account Status",
    "update_name": "Update name",
    "update_email": "Update email",
    "update_password": "Update password",
    "update_success": "Successful update",
    "update_failed": "Failure update",
    "wrong": "Something wrong",
    "pick_image": "Pick service images\nat least 5 images",
    "service_edit_pick_images":
        "if you want to keep old images, just do not pick any images.",
    "pick_image_validate": "Service images must be from 5 to 10 images",
    "pick_image_one_line": "Pick service images at least 5 images |",
    "english_service_title": "Service title in english",
    "arabic_service_title": "Service title in arabic",
    "form_service_title_validate": "Title must be at least 50 character",
    "form_service_description_validate":
        "Description must be at least 200 character without spaces",
    "english_service_description": "Service Description In English",
    "arabic_service_description": "Service Description In Arabic",
    "service_phone": "Phone Number",
    "english_service_key_words": "Key Words in English With Separator (*)",
    "arabic_service_key_words": "Key Words in Arabic With Separator (*)",
    "form_service_phone_validate": "Invalid phone number",
    "service_whatsapp": "WhatsApp Number",
    "form_service_whatsapp_validate": "Invalid whatsapp number",
    "service_email": "Email",
    "form_service_email_validate": "Invalid email",
    "service_price": "Service Price",
    "form_service_price_validate": "Invalid service Price",
    "form_service_key_word_validate": "Key words must be at least 3 words",
    "sar": "SAR",
    "publish": "Publish",
    "account_status_inactive":
        "Your account is inactive, Your services will not showing for users, Contact us.",
    "account_status_active": "Your account is active.",
    "enable": "Enable",
    "disable": "Disable",
    "edit": "Edit",
    "delete": "Delete",
    "delete_service_dialog_title": "You sure about delete that service",
    "ok": "Ok",
    "copy": "Copied to clipboard",
    "cancel": "Cancel",
    "update": "Update",
    "search": "Search by keyword like hair, style, etc",
    "message_hint": "Message...",
    "empty_message": "Empty Message",
    "no_services": "No services yet",
    "no_chats": "No chats yet",
    "rate": "Rate service",
    "seller": "Seller",
    "done": "Done",
    "clipboard": "Copied to clipboard",
    "no_favorites_services": "You have no favorite services yet",
    "already_rated": "You have already rated this service",
    "succeed": "Successful Operation.",
    "error_occurred": "An Error Occurred!",
    "unknown_error": "An error occurred, Try again later.",
    "no_connection": "No Internet Connection",
    "exit": "Exit",
    "privacy_policy": "Privacy Policy",
    "privacy_policy_body": "You have already rated this service",
  };

  Map<String, String> ara = {
    "app_name": "متجر سارة",
    "theme_mode": "نسق التطبيق",
    "theme_color": "اللون المفضل",
    "language": "اللغة",
    "contact_us": "تواصل معنا",
    "contact_us_copied": "تم النسخ",
    "contact_us_message": "يمكنك التواصل معنا عن طريق الايميل و الواتساب",
    "light": "مضيئ",
    "dark": "مظلم",
    "tab_home": "الرئيسية",
    "tab_favorites": "المفضلة",
    "tab_account": "الحساب",
    "tab_settings": "الاعدادات",
    "color_picker": "اختر لونك المفضل",
    "login_header": "سجل دخولك",
    "register_header": "انشئ حساب",
    "login_sub_header": "لتبدا في عرض خدماتك.",
    "form_email": "البريد الالكتروني",
    "form_password": "كلمة المرور",
    "form_name": "الاسم",
    "form_email_validate": "يرجي ادخال عنوان بريد الكتروني صالح",
    "form_password_validate":
        "كلمة المرور يجب ان تكون ثمانية احرف علي الاقل بدون فراغ",
    "form_name_validate": "الاسم يجب ان يكون ثلاث احرف علي الاقل",
    "login": "تسجيل دخول",
    "register": "انشاء حساب",
    "logout": "تسجيل خروح",
    "forget_password": "نسيت كلمة المرور",
    "not_member": "ليس لديك حساب؟",
    "already_member": "لديك حساب بالفعل؟",
    "check_internet": "تاكد من اتصالك ب الانترنت",
    "wrong_password": "كلمة المرور غير صحيحة",
    "user_not_found": "لا يوجد حساب مرتبط بهذا البريد الالكتروني",
    "already_signed_up": "بالفعل هناك حساب متصل بذلك البريد الالكتروني",
    "requires-recent-login":
        "قم بعمل تسجيل خروج ثم اعد تسجيل الدخول مرة اخري ثم حاول التحديث",
    "reset_password_email_sent":
        "تم ارسال رابط اعادة تعيين كلمة المرور الي بريدك الالكتروني",
    "email_verification_sent":
        "راجع بريدك الالكتروني لتاكيد الحساب ثم قم بتسجيل الدحول",
    "services_chat_support": "الدعم الفني لخدماتي",
    "my_services": "خدماتي",
    "add_service": "اضافة خدمة",
    "my_profile": "بياناتي",
    "enable": "تفعيل",
    "disable": "تعطيل",
    "account_status": "حالة حسابك",
    "update_name": "تحديث الاسم",
    "update_email": "تحديث البريد الالكتروني",
    "update_password": "تحديث كلمة المرور",
    "update_success": "تم التحديث",
    "update_failed": "فشل التحديث",
    "wrong": "حدث خطا",
    "pick_image": "اختر صور خدمتك\nخمسة صور علي الاقل",
    "service_edit_pick_images":
        "اذا تريد الابقاء علي الصور القديمة, فقط لا تختار صور جديدة.",
    "pick_image_validate": "صور الخدمة يجب ان تكون من 5 الي 10 صور",
    "pick_image_one_line": "اختر صور خدمتك خمسة صور علي الاقل |",
    "arabic_service_title": "عنوان الخدمة بالعربية",
    "english_service_title": "عنوان الخدمة بالانجليزية",
    "form_service_title_validate": "عنوان الخدمة يجب ان يكون 50 حرف علي الاقل",
    "form_service_description_validate":
        "وصف الخدمة يجب ان يكون 200 حرف علي الاقل بدون المسافات",
    "english_service_description": "وصف الخدمة بالانجليزية",
    "arabic_service_description": "وصف الخدمة بالعربية",
    "service_phone": "رقم الهاتف",
    "english_service_key_words": "الكلمات الدلالية بالانجليزية مفصولة ب (*)",
    "arabic_service_key_words": "الكلمات الدلالية بالعربي مفصولة ب (*)",
    "form_service_phone_validate": "رقم هاتف غير صالح",
    "service_whatsapp": "رقم الواتساب",
    "form_service_whatsapp_validate": "رقم غير صالح",
    "service_email": "البريد الالكتروني",
    "form_service_email_validate": "بريد الكتروني غير صالح",
    "service_price": "تكلفة الخدمة",
    "form_service_price_validate": "ادخل التكلفة بشكل صحيح",
    "form_service_key_word_validate":
        "الكلمات الدلالية يجب ان تكون علي الاقل 3 كلمات",
    "sar": "ريال سعودي",
    "publish": "نشر",
    "account_status_inactive":
        "حسابك غير نشط, خدماتك لن تظهر للمستخدمين, راسلنا.",
    "account_status_active": "حسابك نشط.",
    "active": "تفعيل",
    "edit": "تعديل",
    "delete": "حذف",
    "delete_service_dialog_title": "هل انت متاكد انك تريد حذف تلك الخدمة",
    "ok": "نعم",
    "cancel": "الغاء",
    "update": "تحديث",
    "search": "ابحث ب كلمة دلالية مثل شعر, ستايل, قص ...",
    "message_hint": "رسالة...",
    "empty_message": "رسالة فارغة",
    "no_services": "لا تتوفر خدمات حتي الان",
    "no_chats": "لا تتوفر محادثات حتي الان",
    "rate": "تقييم الخدمة",
    "seller": "البائع",
    "done": "تم",
    "clipboard": "تم النسخ",
    "copy": "تم النسخ",
    "no_favorites_services": "ليس لديك خدمات مفضلة حتي الان",
    "already_rated": "لقد قمت بالفعل بتقييم هذه الخدمة من قبل",
    "succeed": "Successful Operation.",
    "error_occurred": "حدث خطا!",
    "unknown_error": "حدث خطا. حاول مرة اخري",
    "exit": "خروج",
    "no_connection": "تاكد من الاتصال بالانترنت",
    "privacy_policy": "سياسة الخصوصية",
    "privacy_policy_body": "لقد قمت بالفعل بتقييم هذه الخدمة من قبل",
  };

  loadLanguagePrefs() async {
    loaded = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    language = prefs.getString("language");
    loaded = true;
    notifyListeners();
  }

  TextDirection getDirection() {
    switch (language) {
      case "english":
        return TextDirection.ltr;
      case "arabic":
        return TextDirection.rtl;
      default:
        return TextDirection.ltr;
    }
  }

  bool isLanguageSet() {
    if (language == null) return false;
    return true;
  }

  bool isEng() {
    if (language == 'english') return true;
    return false;
  }

  setLanguage(String language) async {
    this.language = language;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("language", this.language!);
  }

  String get(String key) {
    switch (language) {
      case "english":
        return eng[key]!;
      case "arabic":
        return ara[key]!;
      default:
        return eng[key]!;
    }
  }
}
