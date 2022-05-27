import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/http_exception_model.dart';
import '../models/service_model.dart';
import '../providers/app_view_controller_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/database_provider.dart';
import '../providers/language_provider.dart';
import '../providers/storage_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/info_alert_dialog.dart';
import '../utils/snack_bar.dart';
import '../widgets/horizontal_space.dart';
import '../widgets/vertical_space.dart';

class EditService extends StatefulWidget {
  const EditService({Key? key, required this.service}) : super(key: key);
  final ServiceModel? service;

  @override
  _EditServiceState createState() => _EditServiceState();
}

class _EditServiceState extends State<EditService> {
  late ServiceModel? _serviceData;
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final List<XFile> _serviceImagesFiles = [];
  List<dynamic> _serviceImagersUrls = [];
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

  Future<void> _submit(
      AppViewControllerProvider appViewController,
      AuthProvider auth,
      DatabaseProvider db,
      StorageProvider storage,
      LanguageProvider lang) async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _updating = true;
      });
      try {
        _serviceImagersUrls = _serviceData!.images!;

        if (_serviceImagesFiles.isNotEmpty) {
          await deleteServiceImages(storage, db.user.uId!, _serviceData!.id!);
          _serviceImagersUrls = await uploadServiceImages(
              storage, db.user.uId!, _serviceData!.id!);
        }

        ServiceModel service = ServiceModel(
          sellerUid: _serviceData!.sellerUid,
          id: _serviceData!.id,
          active: _serviceData!.active,
          englishTitle: _englishTitle,
          arabicTitle: _arabicTitle,
          englishDescription: _englishDescription,
          arabicDescription: _arabicDescription,
          phone: _phone,
          whatsapp: _whatsapp,
          email: _email,
          price: _price,
          ratersCount: _serviceData!.ratersCount,
          rate: _serviceData!.rate,
          englishKeyWords: _englishServiceKeyWords,
          arabicKeyWords: _arabicServiceKeyWords,
          images: _serviceImagersUrls,
        );

        await db.put("services/${_serviceData!.id}", service.toMap());
        snackBar(context, lang, "update_success");
        appViewController.setShowingEditScreen(false);
      } on HttpException catch (error) {
        if (kDebugMode) {
          print('service_edit_submit: ' + error.toString());
        }
        showInfoAlertDialog(
            context, lang, auth.handleAuthenticationError(error), true);
      } catch (error) {
        if (kDebugMode) {
          print('service_edit_submit: ' + error.toString());
        }
        showInfoAlertDialog(context, lang, 'unknown_error', true);
      } finally {
        setState(() {
          _updating = false;
        });
      }
    }
  }

  Future<void> deleteServiceImages(
      StorageProvider storage, String uid, String serviceId) async {
    try {
      for (int i = 0; i < _serviceData!.images!.length; i++) {
        await storage.delete('users/$uid/servicesImages/$serviceId/image$i');
      }
    } on HttpException catch (error) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> uploadServiceImages(
      StorageProvider storage, String uid, String serviceId) async {
    try {
      List<dynamic> list = [];
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

  void _cancelEdit(AppViewControllerProvider appViewController) {
    appViewController.setShowingEditScreen(false);
  }

  @override
  void initState() {
    _serviceData = widget.service;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final appViewController =
        Provider.of<AppViewControllerProvider>(context, listen: true);
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    final theme = Provider.of<ThemeProvider>(context, listen: true);
    final auth = Provider.of<AuthProvider>(context, listen: true);
    final db = Provider.of<DatabaseProvider>(context, listen: true);
    final storage = Provider.of<StorageProvider>(context, listen: true);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * .05),
        child: Container(
            height: size.height * .05,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: size.width * .04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                InkWell(
                    onTap: () {
                      appViewController.setShowingEditScreen(false);
                    },
                    child: Icon(
                      theme.isIOS() ? CupertinoIcons.back : Icons.arrow_back,
                      color: theme.themeAccent,
                      size: size.height * .03,
                    ))
              ],
            )),
      ),
      body: Container(
        width: size.width,
        height: size.height - (size.height * .15),
        padding: EdgeInsets.symmetric(
            vertical: size.height * .01, horizontal: size.width * .03),
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
                        child: Column(
                          children: [
                            Text(
                              lang.get("service_edit_pick_images"),
                              textAlign: TextAlign.center,
                            ),
                            VerticalSpace(size: size, percentage: .01),
                          ],
                        ),
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
                      style: TextStyle(fontSize: size.width * .04),
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
                    _serviceData!.englishTitle!,
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
                    _serviceData!.arabicTitle!,
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
                    _serviceData!.englishDescription!,
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
                    _serviceData!.arabicDescription!,
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
                    _serviceData!.phone!,
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
                    _serviceData!.whatsapp!,
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
                    _serviceData!.email!,
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
                    _serviceData!.englishKeyWords!,
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
                    _serviceData!.arabicKeyWords!,
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
                          _serviceData!.price!,
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: size.width / 4,
                            margin: EdgeInsets.symmetric(
                                horizontal: size.width * .05, vertical: 0),
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.symmetric(
                                            vertical: size.height * .01)),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.green)),
                                onPressed: () => _submit(
                                    appViewController, auth, db, storage, lang),
                                child: Text(
                                  lang.get('edit'),
                                  style: TextStyle(
                                      fontSize: size.width * .04,
                                      color: Colors.white),
                                )),
                          ),
                          Container(
                            width: size.width / 4,
                            margin: EdgeInsets.symmetric(
                                horizontal: size.width * .05, vertical: 0),
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.symmetric(
                                            vertical: size.height * .01)),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.red)),
                                onPressed: () => _cancelEdit(appViewController),
                                child: Text(
                                  lang.get('cancel'),
                                  style: TextStyle(
                                      fontSize: size.width * .04,
                                      color: Colors.white),
                                )),
                          ),
                        ],
                      ),
              ],
            ),
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
    String initialValue,
    String title,
    String key,
    int? textLength,
  ) {
    return TextFormField(
        initialValue: initialValue,
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
        keyboardType: TextInputType.multiline,
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
