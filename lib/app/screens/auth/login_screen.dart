import 'package:area_de_risco/app/screens/auth/model/social_signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SocialSignInModel {
  var isLoading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Container(
            color: Colors.red,
            alignment: Alignment.topCenter,
            child: Container(
                alignment: Alignment.center,
                height: size.height * 0.25,
                child: Image.asset(
                  "assets/logo.png",
                  width: 100,
                )),
          ),
          Column(children: [
            SizedBox(
              height: size.height * 0.25,
            ),
            Expanded(
              child: Card(
                color: Color(0xFFEDF2F4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(size.width * 0.3))),
                margin: EdgeInsets.zero,
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.all(36),
                    child: Form(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 30),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Card(
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              controller: emailController,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  label: Text("Email"),
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Card(
                            elevation: 1,
                            child: TextFormField(
                              controller: passController,
                              obscureText: true,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  label: Text("Senha"),
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none),
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            width: size.width,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.red)),
                              child: Text("Entrar"),
                              onPressed: () async {
                                if (emailController.text.isNotEmpty &&
                                    passController.text.isNotEmpty) {
                                  var result = await signin(
                                      emailController.text,
                                      passController.text);
                                  if (result)
                                    Navigator.of(context)
                                        .pushReplacementNamed("main");
                                  else
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Email ou senha incorretos")));
                                }
                              },
                            ),
                          ),
                          GestureDetector(
                            child: Container(
                              margin: EdgeInsets.all(8),
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Não tenho uma conta",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).pushNamed("register");
                            },
                          ),
                          Divider(
                            thickness: 2,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  child: SignInButton(
                                Buttons.Google,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                text: "Entrar com Google",
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  if (await googleSignIns()) {
                                    Navigator.of(context)
                                        .pushReplacementNamed("main");
                                  } else
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Não foi possível consluír o login")));
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                              )),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
          Visibility(
            visible: isLoading,
            child: IgnorePointer(
              ignoring: true,
              child: Center(
                child: CircularProgressIndicator(
                  value: null,
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
