import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Setuppage2 extends StatefulWidget {
  const Setuppage2({super.key});

  @override
  State<Setuppage2> createState() => _Setuppage2State();
}

class _Setuppage2State extends State<Setuppage2> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body:SingleChildScrollView(
        child: Padding(
 padding: const EdgeInsets.only(
            top: 50.0,
            left: 30,
            right: 30,
           
          ),          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Center(
              child: Text(
                    "Step 2 of 4",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Center(
                child: Text(
                  "Select Your Favourite",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Center(
                child: Text(
                  " Character",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Center(
                child: Text(
                  "Unleash your inner anime hero!",
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: "AbhayaLibre",
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                    hintText: "Search character by name",
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 15, right: 10),
                      child: FaIcon(
                        FontAwesomeIcons.magnifyingGlass,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Container(
                  
                decoration: BoxDecoration(
                  color: Color.fromRGBO(252, 242, 232, 1),
                      border: Border.all(color: Colors.grey.shade900, width: 0.5),
                ),
                height:120,width: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  CircleAvatar(radius: 40,),
                  Text("Placeholder")
                ],),
              ),
               Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(252, 242, 232, 1),
                      border: Border.all(color: Colors.grey.shade900, width: 0.5),
                ),
                height:120,width: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  CircleAvatar(radius: 40,),
                  Text("Place holder")
                ],),
              )
              ],),
             
              
          ],),
        ),
      )
    );
  }
}