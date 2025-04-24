import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otakuplanner/screens/entryScreens/SetUpPage1.dart';
import 'package:otakuplanner/screens/entryScreens/forgotPassword.dart';
import 'package:otakuplanner/screens/entryScreens/signup.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/themes/theme.dart';
import 'package:otakuplanner/widgets/customButton.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  void login1() {
 String username = _usernameController.text.trim();
  if (username.isNotEmpty) {
    // sav>e the username in the provider
    Provider.of<UserProvider>(context, listen: false).setUsername(username);

    // navigate to setup page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SetupPage1()),
    );
  }  
}

    void forgot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPassword()),
    );}
      void create() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUp()),
    );}
    void login() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SetupPage1()),
    );}
    final TextEditingController _usernameController = TextEditingController();

    
  @override
  Widget build(BuildContext context) {
    return Theme(
            data:OtakuPlannerTheme.lightTheme,

      child: Scaffold(
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
                  height: MediaQuery.of(context).size.height / 2 - 130,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  "LOG IN",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Text(
                  "Plan like a true otaku!🎌",
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
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: TextField(
                      controller: _usernameController,
      
                    decoration: InputDecoration(
                      hintText: "Email Address or Username",
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      filled: false,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
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
                        borderRadius: BorderRadius.circular(5.0),
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
                    borderRadius: BorderRadius.circular(5.0),
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
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(252, 242, 232, 1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
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
                CustomButton(
                  ontap: login1,
                  data: "LOG IN",
                  textcolor: Colors.white,
                  backgroundcolor: Color(0xFF1E293B),
                  width: MediaQuery.of(context).size.width,
                  height: 45,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Text(
                  "Or login with",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 3 - 33,
                      height: 40,
                      // margin: EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(252, 242, 232, 1),
                        border: Border.all(color: Colors.grey.shade600, width: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "assets/images/google.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Container(
                      width: MediaQuery.of(context).size.width / 3 - 33,
                      height: 40,
                      // margin: EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(252, 242, 232, 1),
                        border: Border.all(color: Colors.grey.shade600, width: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "assets/images/twitter.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Container(
                      width: MediaQuery.of(context).size.width / 3 - 33,
                      height: 40,
                      // margin: EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(252, 242, 232, 1),
                        border: Border.all(color: Colors.grey.shade600, width: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "assets/images/apple.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                GestureDetector(
                  onTap:forgot,
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    GestureDetector(
                      onTap: create,
                      child: Text(
                        "Sign Up ",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
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
}
