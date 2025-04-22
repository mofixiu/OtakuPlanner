import 'package:flutter/material.dart';
import 'package:otakuplanner/screens/entryScreens/SetUpPage2.dart';
import 'package:otakuplanner/screens/dashboard.dart';

class SetupPage1 extends StatefulWidget {
  const SetupPage1({super.key});

  @override
  State<SetupPage1> createState() => _SetupPage1State();
}

class _SetupPage1State extends State<SetupPage1> {
  void animenext() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Setuppage2()),
    );
  }
    void normalnext() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Dashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 120.0,
            left: 30,
            right: 30,
            bottom: 120,
          ),
          child: Column(
            children: [
              Center(
                child: Text(
                  "Step 1 of 2",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Text(
                "Choose Your ",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                "Planner Mode",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Text(
                "Customize your experience to fit your lifestyle!",
                style: TextStyle(
                  fontSize: 17,
                  fontFamily: "AbhayaLibre",
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                ),
              ),

              GestureDetector(
                onTap: animenext,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          "assets/images/anime.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 20,
                      child: Text(
                        "Immerse yourself in an anime-inspired experience.",

                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 40,
                      child: Text(
                        "Anime Mode",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: ClipRRect(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              GestureDetector(
                onTap: normalnext,

                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        height: 50,
                        color: Color.fromRGBO(252, 242, 232, 1),
                        child: Image.asset(
                          "assets/images/normal.jpg",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 20,
                      child: Text(
                        "A simple minimalistic planner experience",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 40,
                      child: Text(
                        "Normal Mode",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(15),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



           