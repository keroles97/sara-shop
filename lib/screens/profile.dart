import 'package:app/utils/snack_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/http_exception_model.dart';
import '../providers/auth_provider.dart';
import '../providers/database_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/info_alert_dialog.dart';
import '../widgets/form_submit_button.dart';
import '../widgets/vertical_space.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _nameFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  String _name = "";
  String _email = "";
  String _password = "";
  bool _isPasswordVisible = false;
  bool _nameUpdating = false;
  bool _emailUpdating = false;
  bool _passwordUpdating = false;

  Future<void> _nameSubmit(
      AuthProvider auth, DatabaseProvider db, LanguageProvider lang) async {
    FocusScope.of(context).unfocus();
    if (_nameFormKey.currentState!.validate()) {
      _nameFormKey.currentState!.save();
      setState(() {
        _nameUpdating = true;
      });
      try {
        await db.put("users/:uid/name",
            _name.replaceFirst(_name[0], _name[0].toUpperCase()));
        snackBar(context, lang, "update_success");
      } on HttpException catch (error) {
        if (kDebugMode) {
          print('profile_name_submit: ' + error.toString());
        }
        showInfoAlertDialog(
            context, lang, auth.handleAuthenticationError(error), true);
      } catch (error) {
        if (kDebugMode) {
          print('profile_name_submit: ' + error.toString());
        }
        showInfoAlertDialog(context, lang, 'unknown_error', true);
      } finally {
        setState(() {
          _nameUpdating = false;
        });
      }
    }
  }

  Future<void> _authEmailSubmit(
      AuthProvider auth, DatabaseProvider db, LanguageProvider lang) async {
    FocusScope.of(context).unfocus();
    if (_emailFormKey.currentState!.validate()) {
      _emailFormKey.currentState!.save();
      setState(() {
        _emailUpdating = true;
      });
      try {
        await auth.updateEmail(_email);
        await _dbEmailSubmit(auth, db, lang);
        snackBar(context, lang, "update_success");
      } on HttpException catch (error) {
        if (kDebugMode) {
          print('profile_email_submit: ' + error.toString());
        }
        showInfoAlertDialog(
            context, lang, auth.handleAuthenticationError(error), true);
      } catch (error) {
        if (kDebugMode) {
          print('profile_email_submit: ' + error.toString());
        }
        showInfoAlertDialog(context, lang, 'unknown_error', true);
      } finally {
        setState(() {
          _emailUpdating = false;
        });
      }
    }
  }

  Future<void> _dbEmailSubmit(
      AuthProvider auth, DatabaseProvider db, LanguageProvider lang) async {
    try {
      await db.put("users/:uid/email", _email);
    } on HttpException catch (error) {
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> _passwordSubmit(AuthProvider auth, LanguageProvider lang) async {
    FocusScope.of(context).unfocus();
    if (_passwordFormKey.currentState!.validate()) {
      _passwordFormKey.currentState!.save();
      setState(() {
        _passwordUpdating = true;
      });
      try {
        await auth.updatePassword(_password);
        snackBar(context, lang, "update_success");
      } on HttpException catch (error) {
        if (kDebugMode) {
          print('profile_password_submit: ' + error.toString());
        }
        showInfoAlertDialog(
            context, lang, auth.handleAuthenticationError(error), true);
      } catch (error) {
        if (kDebugMode) {
          print('profile_password_submit: ' + error.toString());
        }
        showInfoAlertDialog(context, lang, 'unknown_error', true);
      } finally {
        setState(() {
          _passwordUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    final theme = Provider.of<ThemeProvider>(context, listen: true);
    final auth = Provider.of<AuthProvider>(context, listen: true);
    final db = Provider.of<DatabaseProvider>(context, listen: true);
    return SingleChildScrollView(
      child: Container(
        width: size.width,
        height: size.height - (size.height * .15),
        padding: EdgeInsets.only(
          bottom: size.height * .01,
          right: size.width * .03,
          left: size.width * .03,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(
              key: _nameFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IntrinsicHeight(
                    child: TextFormField(
                      textAlign: TextAlign.justify,
                      initialValue: db.user.name,
                      style: TextStyle(
                          color: theme.swapBackground(),
                          fontSize: size.width * 0.04),
                      maxLines: 1,
                      decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.fromLTRB(
                            size.height * .02,
                            size.height * .02,
                            size.height * .01,
                            size.height * .02,
                          ),
                          prefixIcon: Icon(
                            theme.isIOS()
                                ? CupertinoIcons.person_fill
                                : Icons.person,
                            size: size.width * 0.04,
                            color: Colors.grey,
                          ),
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
                          labelText: lang.get('form_name')),
                      keyboardType: TextInputType.name,
                      onSaved: (value) {
                        setState(() {
                          _name = value!.trim();
                        });
                      },
                      validator: (value) {
                        if (value != null &&
                            value.replaceAll(" ", "").length < 3) {
                          return lang.get("form_name_validate");
                        }
                        return null;
                      },
                    ),
                  ),
                  VerticalSpace(size: size, percentage: 0.02),
                  _nameUpdating
                      ? const CircularProgressIndicator.adaptive()
                      : FormSubmitButton(
                          size: size,
                          lang: lang,
                          theme: theme,
                          textKey: "update_name",
                          fun: () => _nameSubmit(
                                auth,
                                db,
                                lang,
                              ))
                ],
              ),
            ),
            Form(
              key: _emailFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IntrinsicHeight(
                    child: TextFormField(
                      textAlign: TextAlign.left,
                      textDirection: TextDirection.ltr,
                      initialValue: db.user.email,
                      style: TextStyle(
                          color: theme.swapBackground(),
                          fontSize: size.width * 0.04),
                      maxLines: 1,
                      decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.fromLTRB(
                            size.height * .02,
                            size.height * .02,
                            size.height * .01,
                            size.height * .02,
                          ),
                          prefixIcon: Icon(
                            theme.isIOS()
                                ? CupertinoIcons.mail_solid
                                : Icons.email,
                            size: size.width * 0.04,
                            color: Colors.grey,
                          ),
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
                          labelText: lang.get('form_email')),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (value) {
                        setState(() {
                          _email = value!.trim();
                        });
                      },
                      validator: (value) {
                        if (value != null &&
                            (!value.contains("@") ||
                                value.replaceAll(" ", "").length < 5)) {
                          return lang.get("form_email_validate");
                        }
                        return null;
                      },
                    ),
                  ),
                  VerticalSpace(size: size, percentage: 0.02),
                  _emailUpdating
                      ? const CircularProgressIndicator.adaptive()
                      : FormSubmitButton(
                          size: size,
                          lang: lang,
                          theme: theme,
                          textKey: "update_name",
                          fun: () => _authEmailSubmit(
                                auth,
                                db,
                                lang,
                              ))
                ],
              ),
            ),
            Form(
              key: _passwordFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IntrinsicHeight(
                    child: TextFormField(
                      obscureText: !_isPasswordVisible,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: size.width * 0.04),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(
                            size.height * .02,
                            size.height * .02,
                            size.height * .01,
                            size.height * .02,
                          ),
                          isDense: true,
                          prefixIcon: Icon(
                            theme.isIOS()
                                ? CupertinoIcons.lock_fill
                                : Icons.lock,
                            size: size.width * 0.04,
                            color: Colors.grey,
                          ),
                          suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            child: Icon(
                              _isPasswordVisible
                                  ? theme.isIOS()
                                      ? CupertinoIcons.eye_slash_fill
                                      : Icons.visibility_off
                                  : theme.isIOS()
                                      ? CupertinoIcons.eye_fill
                                      : Icons.visibility,
                              size: size.width * 0.04,
                              color: Colors.grey,
                            ),
                          ),
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
                          labelText: lang.get("form_password")),
                      keyboardType: TextInputType.text,
                      onSaved: (value) {
                        setState(() {
                          _password = value!;
                        });
                      },
                      validator: (value) {
                        if ((value!.isEmpty || value.length < 8)) {
                          return lang.get("form_password_validate");
                        }
                        return null;
                      },
                    ),
                  ),
                  VerticalSpace(size: size, percentage: 0.02),
                  _passwordUpdating
                      ? const CircularProgressIndicator.adaptive()
                      : FormSubmitButton(
                          size: size,
                          lang: lang,
                          theme: theme,
                          textKey: "update_password",
                          fun: () => _passwordSubmit(auth, lang))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
