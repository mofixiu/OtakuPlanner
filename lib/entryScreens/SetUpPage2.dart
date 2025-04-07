import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:otakuplanner/screens/dashboard.dart';
import 'package:otakuplanner/widgets/customButton.dart';

class Setuppage2 extends StatefulWidget {
  const Setuppage2({super.key});

  @override
  State<Setuppage2> createState() => _Setuppage2State();
}

class _Setuppage2State extends State<Setuppage2> {
    void next() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Dashboard()),
    );
  }
  List<Map<String, dynamic>> characters = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCharacters();
  }

  Future<void> fetchCharacters() async {
    setState(() => isLoading = true);

    final url = Uri.parse('https://api.jikan.moe/v4/characters');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> allCharacters = data['data'];

        if (allCharacters.isNotEmpty) {
          final random = Random();
          // Randomly pick 12 characters
          characters = List.generate(
            12,
            (index) => allCharacters[random.nextInt(allCharacters.length)],
          );
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch data: $e');
    }

    setState(() => isLoading = false);
  }
  Future<void> searchCharacters(String query) async {
    if (query.isEmpty) {
      fetchCharacters(); 
      return;
    }

    final url = Uri.parse('https://api.jikan.moe/v4/characters?q=$query&limit=20');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          characters = List<Map<String, dynamic>>.from(data['data']);
        });
      } else {
        print('Search error: ${response.statusCode}');
      }
    } catch (e) {
      print('Search failed: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
      FocusScope.of(context).unfocus(); 
    },
      child: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 30, right: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Step 2 of 2",
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
                    "Select Your Favorite",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
                GestureDetector(
                  
                  child: Container(
                    
                    width: MediaQuery.of(context).size.width,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: TextField(
                      controller: searchController,
                    onChanged: searchCharacters,
                      obscureText: false,
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
                          borderRadius: BorderRadius.circular(6.0),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(252, 242, 232, 1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(252, 242, 232, 1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          borderSide: BorderSide(
                            color: Color(0xFF1E293B),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1,
                      ),
                    itemCount: characters.length,
                    itemBuilder: (context, index) {
                      final character = characters[index];
                      return GestureDetector(
                        onTap: next,
                        child: Container(
                        decoration: BoxDecoration(
                              color: Color.fromRGBO(252, 242, 232, 1),
                              border: Border.all(
                                color: Colors.grey.shade900,
                                width: 0.2,
                        
                              ),),
                          padding: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundImage: character['images']['jpg']['image_url'] != null
                                    ? NetworkImage(character['images']['jpg']['image_url'])
                                    : null,
                              ),
                              SizedBox(height: 8),
                              Text(
                                character['name'] ?? "Unknown",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                
               SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                Center(
                  child: CustomButton(
                    ontap: () {},
                    data: "<- Back",
                    textcolor: Colors.white,
                    backgroundcolor: Color(0xFF1E293B),
                    width: 100,
                    height: 50,
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
