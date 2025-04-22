import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otakuplanner/screens/entryScreens/loginPage.dart';
import 'package:otakuplanner/widgets/customButton.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool checkedValue = false;
   void next() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 30.0,
            left: 40,
            right: 40,
            bottom: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/otaku.jpg",
                height: MediaQuery.of(context).size.height / 2 - 150,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.contain,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              Text(
                "SIGN UP",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Text(
                "Join the Otaku Community today!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  fontFamily: "AbhayaLibre",
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1.0),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Fullname or Username",
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    filled: false,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(1.0),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(252, 242, 232, 1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(1.0),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(252, 242, 232, 1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(1.0),
                      borderSide: BorderSide(
                        color: Color(0xFF1E293B),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1.0),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Email Address",
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    filled: false,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(1.0),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(252, 242, 232, 1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(1.0),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(252, 242, 232, 1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(1.0),
                      borderSide: BorderSide(
                        color: Color(0xFF1E293B),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              Container(
                width: MediaQuery.of(context).size.width,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1.0),
                ),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(left: 15, right: 10),
                      child: FaIcon(
                        FontAwesomeIcons.eye,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                    suffixIconConstraints: BoxConstraints(
                      minHeight: 25,
                      minWidth: 50,
                    ),
                    filled: false,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(1.0),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(252, 242, 232, 1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(1.0),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(252, 242, 232, 1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(1.0),
                      borderSide: BorderSide(
                        color: Color(0xFF1E293B),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1.0),
                ),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Confirm Password",
                    filled: false,
                    fillColor: Colors.white12,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(1.0),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(252, 242, 232, 1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(1.0),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(252, 242, 232, 1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(1.0),
                      borderSide: BorderSide(
                        color: Color(0xFF1E293B),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: [
                  Checkbox(
                    value: checkedValue,
                    // checkColor: Color(0xFF1E293B),
                    focusColor: Color(0xFF1E293B),
                    onChanged: (newValue) {
                      setState(() {
                        checkedValue = newValue!;
                      });
                    },
                  ),
                  Text("I agree to the "),
                  Text(
                    "Terms & Conditions",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              CustomButton(
                ontap: () {},
                data: "CREATE ACCOUNT",
                textcolor: Colors.white,
                backgroundcolor: Color(0xFF1E293B),
                width: MediaQuery.of(context).size.width,
                height: 50,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              GestureDetector(
                onTap: next,
                child: Text(
                      "Already have an account? Log in",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
