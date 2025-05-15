import 'package:flutter/material.dart';
import 'package:otakuplanner/screens/entryScreens/loginPage.dart';
import 'package:otakuplanner/themes/theme.dart';
import 'package:otakuplanner/widgets/customButton.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
   void next() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );}
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
                  height: MediaQuery.of(context).size.height / 2 - 60,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Text(
                  "FORGOT PASSWORD",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      
                Center(
                  child: Text(
                    "Enter your email address below and\n we'll send you a link to reset your \npassword",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
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
      
                CustomButton(
                  ontap: () {},
                  data: "SEND RESET LINK",
                  textcolor: Colors.white,
                  backgroundcolor: Color(0xFF1E293B),
                  width: MediaQuery.of(context).size.width,
                  height: 45,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      
                GestureDetector(
                  onTap:next,
                  child: Text(
                    "Back To Login",
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
      ),
    );
  }
}
