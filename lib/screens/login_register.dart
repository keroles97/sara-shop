import 'package:app/models/http_exception_model.dart';
import 'package:app/models/user_model.dart';
import 'package:app/providers/database_provider.dart';
import 'package:app/utils/info_alert_dialog.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({Key? key}) : super(key: key);

  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _name = "";
  String _email = "";
  String _password = "";
  bool _passwordVisibility = false;
  bool _loading = false;
  bool _resetPassword = false;
  bool _login = true;

  void _submit(LanguageProvider lang) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _resetPassword = false;
    });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _loading = true;
        });
        _formKey.currentState!.save();
        if (_login) {
          await auth.login(context, lang, _email, _password);
        } else {
          List<String> data = await auth.register(_email, _password);
          db.getUserAuthData(data[0], data[1], false);
          await _createUser(auth, db, lang);
          setState(() {
            _login = true;
          });
        }
      } on HttpException catch (error) {
        if (kDebugMode) {
          print('login_register_submit_http: ' + error.toString());
        }
        showInfoAlertDialog(
            context, lang, auth.handleAuthenticationError(error), true);
      } catch (error) {
        if (kDebugMode) {
          print('login_register_submit: ' + error.toString());
        }
        showInfoAlertDialog(context, lang, 'unknown_error', true);
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _createUser(
      AuthProvider auth, DatabaseProvider db, LanguageProvider lang) async {
    final user = UserModel(
      name: _name,
      email: _email,
      uId: db.user.uId,
      token: db.user.token,
    );
    try {
      await db.put('users/:uid', user.toMap());
      await auth.sendEmailVerification(db.user.token!);
      db.resetUser();
      showInfoAlertDialog(context, lang, 'email_verification_sent', false);
    } on HttpException {
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  void _resetPass(LanguageProvider lang) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _resetPassword = true;
    });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _loading = true;
        });
        _formKey.currentState!.save();
        await auth.sendResetPasswordEmail(_email);
        showInfoAlertDialog(context, lang, 'reset_password_email_sent', false);
      } on HttpException catch (error) {
        if (kDebugMode) {
          print('resetPass: ' + error.toString());
        }
        showInfoAlertDialog(
            context, lang, auth.handleAuthenticationError(error), true);
      } catch (error) {
        if (kDebugMode) {
          print('resetPass: ' + error.toString());
        }
        showInfoAlertDialog(context, lang, 'unknown_error', true);
      }
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    final theme = Provider.of<ThemeProvider>(context, listen: true);
    return SingleChildScrollView(
      child: SizedBox(
        width: size.width,
        height: size.height - (size.height * .05),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * .03),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    lang.get(_login ? "login" : "register"),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.themeAccent,
                        fontSize: size.width * 0.08),
                  ),
                  VerticalSpace(size: size, percentage: 0.01),
                  Text(
                    lang.get("login_sub_header"),
                    style: TextStyle(fontSize: size.width * 0.03),
                  ),
                ],
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!_login)
                        IntrinsicHeight(
                          child: TextFormField(
                            minLines: 1,
                            style: TextStyle(fontSize: size.width * 0.04),
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
                                labelText: lang.get("form_name")),
                            keyboardType: TextInputType.name,
                            onSaved: (value) {
                              setState(() {
                                _name = value!.trim().replaceFirst(
                                    value.trim()[0],
                                    value.trim()[0].toUpperCase());
                              });
                            },
                            validator: (value) {
                              if (!_login &&
                                  (value!.trim().isEmpty ||
                                      value.trim().length < 3)) {
                                return lang.get("form_name_validate");
                              }
                              return null;
                            },
                          ),
                        ),
                      VerticalSpace(size: size, percentage: 0.02),
                      IntrinsicHeight(
                        child: TextFormField(
                          controller: _emailController,
                          maxLines: 1,
                          style: TextStyle(fontSize: size.width * 0.04),
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
                              labelText: lang.get("form_email")),
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (value) {
                            setState(() {
                              _email = value!.trim();
                            });
                          },
                          validator: (value) {
                            if (value!.trim().isEmpty ||
                                !value.contains("@") ||
                                value.trim().length < 5) {
                              return lang.get("form_email_validate");
                            }
                            return null;
                          },
                        ),
                      ),
                      VerticalSpace(size: size, percentage: 0.02),
                      IntrinsicHeight(
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: !_passwordVisibility,
                          maxLines: 1,
                          style: TextStyle(fontSize: size.width * 0.04),
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
                                    ? CupertinoIcons.lock_fill
                                    : Icons.lock,
                                size: size.width * 0.04,
                                color: Colors.grey,
                              ),
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    _passwordVisibility = !_passwordVisibility;
                                  });
                                },
                                child: Icon(
                                  _passwordVisibility
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
                              _password = value!.trim();
                            });
                          },
                          validator: (value) {
                            if (!_resetPassword &&
                                (value!.contains(' ') ||
                                    value.trim().isEmpty ||
                                    value.trim().length < value.length)) {
                              return lang.get("form_password_validate");
                            }
                            return null;
                          },
                        ),
                      ),
                      VerticalSpace(size: size, percentage: 0.04),
                      _loading
                          ? const CircularProgressIndicator.adaptive()
                          : Container(
                              width: size.width,
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
                                  ),
                                  onPressed: () => _submit(lang),
                                  child: Text(
                                    lang.get(_login ? "login" : "register"),
                                    style: TextStyle(
                                        fontSize: size.width * .05,
                                        color: Colors.white),
                                  )),
                            ),
                      VerticalSpace(size: size, percentage: 0.04),
                      if (_login)
                        TextButton(
                            onPressed: () => _resetPass(lang),
                            child: Text(
                              lang.get("forget_password"),
                              style: TextStyle(fontSize: size.width * 0.05),
                            )),
                    ],
                  )),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    lang.get(_login ? "not_member" : "already_member"),
                    style: TextStyle(fontSize: size.width * 0.03),
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        lang.get(_login ? "register" : "login"),
                        style: TextStyle(
                            color: theme.themeAccent,
                            fontSize: size.width * 0.05),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _login = !_login;
                      });
                    },
                  )
                ],
              ),
              // InkWell(
              //   child: Text(
              //     lang.get("privacy_policy"),
              //     style: TextStyle(
              //         decoration: TextDecoration.underline,
              //         color: theme.themeAccent,
              //         fontSize: size.width * 0.04),
              //   ),
              //   onTap: () {
              //     showDialog(
              //         context: context,
              //         builder: (BuildContext ctx) {
              //           return PrivacyPolicyDialog(
              //             size: size,
              //             lang: lang,
              //             theme: theme,
              //           );
              //         });
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
