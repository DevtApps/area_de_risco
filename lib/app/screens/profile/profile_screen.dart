import 'package:area_de_risco/app/controllers/area_controller.dart';
import 'package:area_de_risco/app/controllers/user_controller.dart';
import 'package:area_de_risco/app/utils/risks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.of(context).padding;
    Size size = MediaQuery.of(context).size;
    return Consumer<UserController>(builder: (context, userController, child) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: padding.top + 30,
              ),
              Container(
                  height: size.height * 0.4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          alignment: Alignment.center,
                          width: 100,
                          height: 100,
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(200),
                          ),
                          child: Image.asset("assets/logo.png"),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Center(
                        child: Text(userController.auth.currentUser!.email!),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red)),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.of(context).pushReplacementNamed("auth");
                          },
                          child: Text(
                            "SAIR",
                            style: TextStyle(color: Colors.white),
                          ))
                    ],
                  )),
              SizedBox(
                height: 28,
              ),
              Center(
                child: Text(
                  "Minhas áreas",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Container(
                width: 200,
                height: 3,
                color: Colors.red,
              ),
              SizedBox(
                height: 16,
              ),
              userController.myAreas.length > 0
                  ? Column(
                      children:
                          List.generate(userController.myAreas.length, (index) {
                        return ListTile(
                          title: Text(userController.myAreas[index].address),
                          subtitle: Text(
                              risks[userController.myAreas[index].risk]['name']
                                  .toString()),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              await Provider.of<AreaController>(context,
                                      listen: false)
                                  .removeArea(userController.myAreas[index].id);
                              userController.notifyListeners();
                            },
                          ),
                        );
                      }),
                    )
                  : Center(
                      child: Text("Você não cadastrou nenhuma área"),
                    )
            ],
          ),
        ),
      );
    });
  }
}
