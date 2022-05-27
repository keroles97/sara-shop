import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/http_exception_model.dart';
import '../models/service_model.dart';
import '../providers/auth_provider.dart';
import '../providers/database_provider.dart';
import '../providers/language_provider.dart';
import '../providers/storage_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/info_alert_dialog.dart';
import '../utils/snack_bar.dart';
import '../widgets/form_submit_button.dart';
import '../widgets/horizontal_space.dart';
import '../widgets/vertical_space.dart';

class AddNewService extends StatefulWidget {
  const AddNewService({
    Key? key,
  }) : super(key: key);

  @override
  _AddNewServiceState createState() => _AddNewServiceState();
}

class _AddNewServiceState extends State<AddNewService> {
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final List<XFile> _serviceImagesFiles = [];
  List<String> _serviceImagersUrls = [];
  String _englishServiceKeyWords = '';
  String _arabicServiceKeyWords = '';
  String _englishTitle = "";
  String _englishDescription = "";
  String _arabicTitle = "";
  String _arabicDescription = "";
  String _price = "";
  String _phone = "";
  String _whatsapp = "";
  String _email = "";
  bool _updating = false;

  Future<void> _submit(AuthProvider auth, DatabaseProvider db,
      StorageProvider storage, LanguageProvider lang) async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate() &&
        _serviceImagesFiles.length > 4 &&
        _serviceImagesFiles.length < 11) {
      _formKey.currentState!.save();
      setState(() {
        _updating = true;
      });
      try {
        ServiceModel service = ServiceModel(
          sellerUid: 'dummy',
        );

        final res = await db.post("services", service.toMap());

        String serviceId = res['name'].toString();

        _serviceImagersUrls =
            await uploadServiceImages(storage, db.user.uId!, serviceId);

        service = ServiceModel(
          sellerUid: db.user.uId,
          id: serviceId,
          active: true,
          englishTitle: _englishTitle,
          arabicTitle: _arabicTitle,
          englishDescription: _englishDescription,
          arabicDescription: _arabicDescription,
          phone: _phone,
          whatsapp: _whatsapp,
          email: _email,
          price: _price,
          englishKeyWords: _englishServiceKeyWords,
          arabicKeyWords: _arabicServiceKeyWords,
          images: _serviceImagersUrls,
          rate: 0.0,
          ratersCount: 0,
        );

        await db.put("services/$serviceId", service.toMap());

        snackBar(context, lang, "update_success");
      } on HttpException catch (error) {
        if (kDebugMode) {
          print('service_add_submit: ' + error.toString());
        }
        showInfoAlertDialog(
            context, lang, auth.handleAuthenticationError(error), true);
      } catch (error) {
        if (kDebugMode) {
          print('service_add_submit: ' + error.toString());
        }
        showInfoAlertDialog(context, lang, 'unknown_error', true);
      } finally {
        setState(() {
          _updating = false;
        });
      }
    }
  }

  Future<List<String>> uploadServiceImages(
      StorageProvider storage, String uid, String serviceId) async {
    try {
      List<String> list = [];
      for (int i = 0; i < _serviceImagesFiles.length; i++) {
        String downloadUrl = await storage.post(
            'users/$uid/servicesImages/$serviceId/image$i',
            await _serviceImagesFiles[i].readAsBytes());
        list.add(downloadUrl);
      }
      return list;
    } on HttpException catch (error) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getServiceImagesFromGallery(LanguageProvider lang) async {
    List<XFile>? picked = await _picker.pickMultiImage(imageQuality: 60);
    if (picked == null) {
      snackBar(context, lang, "wrong");
      return;
    }
    setState(() {
      _serviceImagesFiles.addAll(picked);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    final theme = Provider.of<ThemeProvider>(context, listen: true);
    final auth = Provider.of<AuthProvider>(context, listen: true);
    final db = Provider.of<DatabaseProvider>(context, listen: true);
    final storage = Provider.of<StorageProvider>(context, listen: true);
    return Container(
      width: size.width,
      height: size.height - (size.height * .15),
      padding: EdgeInsets.only(
        bottom: size.height * .01,
        right: size.width * .03,
        left: size.width * .03,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _serviceImagesFiles.isEmpty
                  ? Center(
                      child: InkWell(
                          onTap: () => getServiceImagesFromGallery(lang),
                          child: Text(
                            lang.get("pick_image"),
                            style: TextStyle(color: theme.themeAccent),
                            textAlign: TextAlign.center,
                          )),
                    )
                  : SizedBox(
                      height: size.height * .3,
                      child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: _serviceImagesFiles.length,
                          itemBuilder: (BuildContext ctx, int i) {
                            return Container(
                              width: size.height * .2,
                              margin: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: size.width * .01),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _serviceImagesFiles.removeAt(i);
                                      });
                                    },
                                    icon: const Icon(Icons.delete_forever),
                                    color: theme.swapBackground(),
                                  ),
                                  VerticalSpace(size: size, percentage: .01),
                                  Image.file(
                                    File(_serviceImagesFiles[i].path),
                                    height: size.height * .2,
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
              if (_serviceImagesFiles.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: () => getServiceImagesFromGallery(lang),
                        child: Text(
                          lang.get("pick_image_one_line"),
                          style: TextStyle(
                              fontSize: size.width * .03,
                              color: theme.themeAccent),
                        )),
                    Text(
                      " ${_serviceImagesFiles.length}/10",
                      style: TextStyle(fontSize: size.width * .03),
                    )
                  ],
                ),
              VerticalSpace(size: size, percentage: .01),
              if (_serviceImagesFiles.length < 5 ||
                  _serviceImagesFiles.length > 10)
                Text(
                  lang.get("pick_image_validate"),
                  style: const TextStyle(color: Colors.red),
                ),
              VerticalSpace(size: size, percentage: .04),
              textForm(
                  validator,
                  theme,
                  lang,
                  size,
                  TextAlign.left,
                  TextDirection.ltr,
                  TextInputType.multiline,
                  "english_service_title",
                  "title",
                  80),
              VerticalSpace(size: size, percentage: .02),
              textForm(
                  validator,
                  theme,
                  lang,
                  size,
                  TextAlign.right,
                  TextDirection.rtl,
                  TextInputType.multiline,
                  "arabic_service_title",
                  "title",
                  80),
              VerticalSpace(size: size, percentage: .04),
              textForm(
                  validator,
                  theme,
                  lang,
                  size,
                  TextAlign.left,
                  TextDirection.ltr,
                  TextInputType.multiline,
                  "english_service_description",
                  "description",
                  500),
              VerticalSpace(size: size, percentage: .02),
              textForm(
                  validator,
                  theme,
                  lang,
                  size,
                  TextAlign.right,
                  TextDirection.rtl,
                  TextInputType.multiline,
                  "arabic_service_description",
                  "description",
                  500),
              VerticalSpace(size: size, percentage: .04),
              textForm(
                  validator,
                  theme,
                  lang,
                  size,
                  TextAlign.left,
                  TextDirection.ltr,
                  TextInputType.phone,
                  "service_phone",
                  "phone",
                  null),
              VerticalSpace(size: size, percentage: .02),
              textForm(
                  validator,
                  theme,
                  lang,
                  size,
                  TextAlign.left,
                  TextDirection.ltr,
                  TextInputType.phone,
                  "service_whatsapp",
                  "whatsapp",
                  null),
              VerticalSpace(size: size, percentage: .02),
              textForm(
                  validator,
                  theme,
                  lang,
                  size,
                  TextAlign.left,
                  TextDirection.ltr,
                  TextInputType.emailAddress,
                  "service_email",
                  "email",
                  null),
              VerticalSpace(size: size, percentage: .04),
              textForm(
                  validator,
                  theme,
                  lang,
                  size,
                  TextAlign.left,
                  TextDirection.ltr,
                  TextInputType.multiline,
                  "english_service_key_words",
                  "keyWord",
                  null),
              VerticalSpace(size: size, percentage: .02),
              textForm(
                  validator,
                  theme,
                  lang,
                  size,
                  TextAlign.right,
                  TextDirection.rtl,
                  TextInputType.multiline,
                  "arabic_service_key_words",
                  "keyWord",
                  null),
              VerticalSpace(size: size, percentage: .04),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: size.width * .4,
                    child: textForm(
                        validator,
                        theme,
                        lang,
                        size,
                        TextAlign.left,
                        TextDirection.ltr,
                        TextInputType.number,
                        "service_price",
                        "price",
                        null),
                  ),
                  HorizontalSpace(size: size, percentage: .03),
                  Text(lang.get("sar")),
                ],
              ),
              VerticalSpace(size: size, percentage: .04),
              _updating
                  ? const CircularProgressIndicator.adaptive()
                  : FormSubmitButton(
                      size: size,
                      lang: lang,
                      theme: theme,
                      textKey: "publish",
                      fun: () => _submit(auth, db, storage, lang)),
            ],
          ),
        ),
      ),
    );
  }

  String? validator(String key, String value, LanguageProvider lang) {
    if (key == "title" && value.length < 50) {
      return lang.get("form_service_title_validate");
    } else if (key == "description" && value.length < 200) {
      return lang.get("form_service_description_validate");
    } else if (key == "phone" &&
        (value.replaceAll(" ", "").isEmpty || !value.contains('+'))) {
      return lang.get("form_service_phone_validate");
    } else if (key == "whatsapp" &&
        (value.replaceAll(" ", "").isEmpty || !value.contains('+'))) {
      return lang.get("form_service_whatsapp_validate");
    } else if (key == "price" &&
        (value.replaceAll(" ", "").isEmpty || double.parse(value) == 0.0)) {
      return lang.get("form_service_price_validate");
    } else if (key == "email" &&
        (!value.contains("@") || value.replaceAll(" ", "").length < 5)) {
      return lang.get("form_service_email_validate");
    } else if (key == "keyWord" &&
        (value.split("*").length < 3 || value.split("*").length < 3)) {
      return lang.get("form_service_key_word_validate");
    }
    return null;
  }

  Widget textForm(
    Function fun,
    ThemeProvider theme,
    LanguageProvider lang,
    Size size,
    TextAlign textAlign,
    TextDirection textDirection,
    TextInputType textInputType,
    String title,
    String key,
    int? textLength,
  ) {
    return TextFormField(
        minLines: null,
        maxLines: null,
        maxLength: textLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        style: TextStyle(fontSize: size.width * 0.04),
        textAlign: textAlign,
        textDirection: textDirection,
        decoration: InputDecoration(
            isDense: true,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.grey,
                )),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: theme.themeAccent,
                )),
            labelText: lang.get(title)),
        keyboardType: textInputType,
        onSaved: (value) {
          setState(() {
            if (title == "english_service_title") {
              _englishTitle = value!.trim();
            } else if (title == "arabic_service_title") {
              _arabicTitle = value!.trim();
            } else if (title == "english_service_description") {
              _englishDescription = value!.trim();
            } else if (title == "arabic_service_description") {
              _arabicDescription = value!.trim();
            } else if (title == "service_phone") {
              _phone = value!.replaceAll(" ", "");
            } else if (title == "service_email") {
              _email = value!.replaceAll(" ", "");
            } else if (title == "service_whatsapp") {
              _whatsapp = value!.replaceAll(" ", "");
            } else if (title == "english_service_key_words") {
              _englishServiceKeyWords = value!.trim();
            } else if (title == "arabic_service_key_words") {
              _arabicServiceKeyWords = value!.trim();
            } else if (title == "service_price") {
              if (!value!.contains(".")) {
                _price = value.replaceAll(" ", "") + ".0";
                return;
              }
              _price = value.replaceAll(" ", "");
            }
          });
        },
        validator: (value) {
          return fun(key, value, lang);
        });
  }
}
