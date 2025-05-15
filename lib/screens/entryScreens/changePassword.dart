import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otakuplanner/widgets/customAppBar.dart';
import 'package:otakuplanner/widgets/customButtonSmallerTextSize.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Back to Settings"),
      body: Padding(
        padding: const EdgeInsets.only(left:15.0,right:15.0,bottom:15,top:90),
        child: Container(
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 249, 233, 1),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF1E293B),
                      child: Icon(Icons.lock, size: 30, color: Colors.white),
                    ),
                    SizedBox(width: 20),
                    Text(
                      "Change Password",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  "Current Password",
                  style: TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
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
                      hintText: "Enter your current password",
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  "New Password",
                  style: TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
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
                      hintText: "Enter your new password",
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.circleInfo,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Password must be at least 8 characters",
                      style: TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  "Confirm New Password",
                  style: TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
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
                      hintText: "Confirm your new password",
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
                SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                CustomButton(ontap: (){}, data: "Update Password", textcolor: Colors.white, backgroundcolor: Color(0xFF1E293B), width: MediaQuery.of(context).size.width, height: 50)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
