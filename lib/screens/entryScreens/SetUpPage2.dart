// import 'dart:async';
// // import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:http/http.dart' as http;
// import 'package:otakuplanner/screens/dashboard.dart';
// import 'package:otakuplanner/widgets/customButton.dart';
// import 'package:otakuplanner/shared/jikan_service.dart';

// class Setuppage2 extends StatefulWidget {
//   const Setuppage2({super.key});

//   @override
//   State<Setuppage2> createState() => _Setuppage2State();
// }

// class _Setuppage2State extends State<Setuppage2> {

//     void next() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const Dashboard()),
//     );
//   }
//     final JikanService jikanService = JikanService(); // ✅ Use your service

//   List<Map<String, dynamic>> characters = [];
//   bool isLoading = true;
//   TextEditingController searchController = TextEditingController();
// Timer? _debounce;

//   @override
//   void initState() {
//     super.initState();
//     fetchCharacters();
//   }

//   // Future<void> fetchCharacters() async {
//   //   setState(() => isLoading = true);

//   //   try {
//   //     // Add delay between requests
//   //     await Future.delayed(Duration(milliseconds: 500));
//   //     final url = Uri.parse('https://api.jikan.moe/v4/characters');
//   //     final response = await http.get(url);

//   //     // Check for rate limiting response
//   //     if (response.statusCode == 429) {
//   //       print('Rate limited - wait before trying again');
//   //       // Handle rate limiting
//   //       setState(() {
//   //         isLoading = false;
//   //         // Show rate limit error to user
//   //       });
//   //       return;
//   //     }

//   //     if (response.statusCode == 200) {
//   //       final data = json.decode(response.body);
//   //       List<dynamic> allCharacters = data['data'];

//   //       if (allCharacters.isNotEmpty) {
//   //         final random = Random();
//   //         // Randomly pick 12 characters
//   //         characters = List.generate(
//   //           12,
//   //           (index) => allCharacters[random.nextInt(allCharacters.length)],
//   //         );
//   //       }
//   //     } else {
//   //       print('Error: ${response.statusCode}');
//   //     }
//   //   } catch (e) {
//   //     print('Failed to fetch data: $e');
//   //   }

//   //   setState(() => isLoading = false);
//   // }
//   Future<void> fetchCharacters() async {
//     setState(() => isLoading = true);

//     final fetchedCharacters = await jikanService.fetchCharacters();
//     if (fetchedCharacters.isNotEmpty) {
//       final random = Random();
//       characters = List.generate(
//         12,
//         (index) => fetchedCharacters[random.nextInt(fetchedCharacters.length)],
//       );
//     }

//     setState(() => isLoading = false);
//   }
//   // Future<void> searchCharacters(String query) async {
//   //   if (query.isEmpty) {
//   //     fetchCharacters();
//   //     return;
//   //   }

//   //   final url = Uri.parse('https://api.jikan.moe/v4/characters?q=$query&limit=20');
//   //   try {
//   //     final response = await http.get(url);
//   //     if (response.statusCode == 200) {
//   //       final data = json.decode(response.body);
//   //       setState(() {
//   //         characters = List<Map<String, dynamic>>.from(data['data']);
//   //       });
//   //     } else {
//   //       print('Search error: ${response.statusCode}');
//   //     }
//   //   } catch (e) {
//   //     print('Search failed: $e');
//   //   }
//   // }
//    Future<void> searchCharacters(String query) async {
//     if (query.isEmpty) {
//       fetchCharacters();
//       return;
//     }

//     setState(() => isLoading = true);
//     final results = await jikanService.searchCharacters(query);
//     setState(() {
//       characters = results;
//       isLoading = false;
//     });

// }
//   void onSearchChanged(String query) {
//   if (_debounce?.isActive ?? false) _debounce!.cancel();

//   _debounce = Timer(Duration(milliseconds: 500), () {
//     searchCharacters(query);
//   });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//       FocusScope.of(context).unfocus();
//     },
//       child: Scaffold(
//         body: SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: Padding(
//             padding: const EdgeInsets.only(top: 50.0, left: 30, right: 30),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Text(
//                     "Step 2 of 2",
//                     style: TextStyle(
//                       fontSize: 23,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1E293B),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//                 Center(
//                   child: Text(
//                     "Select Your Favorite",
//                     style: TextStyle(
//                       fontSize: 25,
//                       fontWeight: FontWeight.w900,
//                       color: Color(0xFF1E293B),
//                     ),
//                   ),
//                 ),
//                 Center(
//                   child: Text(
//                     " Character",
//                     style: TextStyle(
//                       fontSize: 25,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1E293B),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//                 Center(
//                   child: Text(
//                     "Unleash your inner anime hero!",
//                     style: TextStyle(
//                       fontSize: 17,
//                       fontFamily: "AbhayaLibre",
//                       color: Color(0xFF1E293B),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: MediaQuery.of(context).size.height * 0.03),
//                 GestureDetector(

//                   child: Container(

//                     width: MediaQuery.of(context).size.width,
//                     height: 45,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(6.0),
//                     ),
//                     child: TextField(
//                       controller: searchController,
//                     onChanged: onSearchChanged,
//                       obscureText: false,
//                       decoration: InputDecoration(
//                         hintText: "Search character by name",
//                         prefixIcon: Padding(
//                           padding: EdgeInsets.only(left: 15, right: 10),
//                           child: FaIcon(
//                             FontAwesomeIcons.magnifyingGlass,
//                             color: Colors.grey.shade600,
//                             size: 20,
//                           ),
//                         ),
//                         prefixIconConstraints: BoxConstraints(
//                           minHeight: 25,
//                           minWidth: 50,
//                         ),

//                         filled: false,
//                         fillColor: Colors.white12,

//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(6.0),
//                           borderSide: BorderSide(
//                             color: Color.fromRGBO(252, 242, 232, 1),
//                           ),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(6.0),
//                           borderSide: BorderSide(
//                             color: Color.fromRGBO(252, 242, 232, 1),
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(6.0),
//                           borderSide: BorderSide(
//                             color: Color(0xFF1E293B),
//                             width: 1.5,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 if (isLoading)
//                   Center(child: CircularProgressIndicator())
//                 else
//                   GridView.builder(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         crossAxisSpacing: 15,
//                         mainAxisSpacing: 15,
//                         childAspectRatio: 1,
//                       ),
//                     itemCount: characters.length,
//                     itemBuilder: (context, index) {
//                       final character = characters[index];
//                       return GestureDetector(
//                         onTap: next,
//                         child: Container(
//                         decoration: BoxDecoration(
//                               color: Color.fromRGBO(252, 242, 232, 1),
//                               border: Border.all(
//                                 color: Colors.grey.shade900,
//                                 width: 0.2,

//                               ),),
//                           padding: EdgeInsets.all(8),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               CircleAvatar(
//                                 radius: 35,
//                                 backgroundImage: character['images']['jpg']['image_url'] != null
//                                     ? NetworkImage(character['images']['jpg']['image_url'])
//                                     : null,
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 character['name'] ?? "Unknown",
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),

//                SizedBox(height: MediaQuery.of(context).size.height*0.02,),
//                 Center(
//                   child: CustomButton(
//                     ontap: () {},
//                     data: "<- Back",
//                     textcolor: Colors.white,
//                     backgroundcolor: Color(0xFF1E293B),
//                     width: 100,
//                     height: 50,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:otakuplanner/screens/dashboard.dart';
// import 'package:otakuplanner/widgets/customButton.dart';
// import 'package:otakuplanner/shared/anilist_service.dart';

// class Setuppage2 extends StatefulWidget {
//   const Setuppage2({super.key});

//   @override
//   State<Setuppage2> createState() => _Setuppage2State();
// }

// class _Setuppage2State extends State<Setuppage2> {
//   final AniListService aniListService = AniListService();

//   List<Map<String, dynamic>> characters = [];
//   bool isLoading = true;
//   TextEditingController searchController = TextEditingController();
//   Timer? _debounce;

//   @override
//   void initState() {
//     super.initState();
//     fetchCharacters();
//   }

//   void next() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const Dashboard()),
//     );
//   }

//   Future<void> fetchCharacters() async {
//     setState(() => isLoading = true);
//     final results = await aniListService.searchCharacters("Naruto");
//     setState(() {
//       characters = results;
//       isLoading = false;
//     });
//   }

//   void onSearchChanged(String query) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       searchCharacters(query);
//     });
//   }

//   Future<void> searchCharacters(String query) async {
//     if (query.isEmpty) {
//       fetchCharacters();
//       return;
//     }
//     setState(() => isLoading = true);
//     final results = await aniListService.searchCharacters(query);
//     setState(() {
//       characters = results;
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         body: SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: Padding(
//             padding: const EdgeInsets.only(top: 50.0, left: 30, right: 30),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Text("Step 2 of 2",
//                     style: TextStyle(
//                       fontSize: 23,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1E293B),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//                 Center(
//                   child: Text("Select Your Favorite",
//                     style: TextStyle(
//                       fontSize: 25,
//                       fontWeight: FontWeight.w900,
//                       color: Color(0xFF1E293B),
//                     ),
//                   ),
//                 ),
//                 Center(
//                   child: Text(" Character",
//                     style: TextStyle(
//                       fontSize: 25,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1E293B),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//                 Center(
//                   child: Text("Unleash your inner anime hero!",
//                     style: TextStyle(
//                       fontSize: 17,
//                       fontFamily: "AbhayaLibre",
//                       color: Color(0xFF1E293B),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: MediaQuery.of(context).size.height * 0.03),
//                 Container(
//                   width: MediaQuery.of(context).size.width,
//                   height: 45,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(6.0),
//                   ),
//                   child: TextField(
//                     controller: searchController,
//                     onChanged: onSearchChanged,
//                     decoration: InputDecoration(
//                       hintText: "Search character by name",
//                       prefixIcon: Padding(
//                         padding: EdgeInsets.only(left: 15, right: 10),
//                         child: FaIcon(
//                           FontAwesomeIcons.magnifyingGlass,
//                           color: Colors.grey.shade600,
//                           size: 20,
//                         ),
//                       ),
//                       prefixIconConstraints: BoxConstraints(minHeight: 25, minWidth: 50),
//                       filled: false,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(6.0),
//                         borderSide: BorderSide(color: Color.fromRGBO(252, 242, 232, 1)),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(6.0),
//                         borderSide: BorderSide(color: Color.fromRGBO(252, 242, 232, 1)),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(6.0),
//                         borderSide: BorderSide(color: Color(0xFF1E293B), width: 1.5),
//                       ),
//                     ),
//                   ),
//                 ),
//                 if (isLoading)
//                   Center(child: CircularProgressIndicator())
//                 else
//                   GridView.builder(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 15,
//                       mainAxisSpacing: 15,
//                       childAspectRatio: 1,
//                     ),
//                     itemCount: characters.length,
//                     itemBuilder: (context, index) {
//                       final character = characters[index];
//                       return GestureDetector(
//                         onTap: next,
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Color.fromRGBO(252, 242, 232, 1),
//                             border: Border.all(color: Colors.grey.shade900, width: 0.2),
//                           ),
//                           padding: EdgeInsets.all(8),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               CircleAvatar(
//                                 radius: 35,
//                                 backgroundImage: character['image_url'] != null
//                                     ? NetworkImage(character['image_url'])
//                                     : null,
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 character['name'] ?? "Unknown",
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//                 Center(
//                   child: CustomButton(
//                     ontap: () {},
//                     data: "<- Back",
//                     textcolor: Colors.white,
//                     backgroundcolor: Color(0xFF1E293B),
//                     width: 100,
//                     height: 50,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otakuplanner/screens/normalMode/dashboard.dart';
import 'package:otakuplanner/themes/theme.dart';
import 'package:otakuplanner/widgets/customButton.dart';
import 'package:otakuplanner/shared/jikan_service.dart';

class Setuppage2 extends StatefulWidget {
  const Setuppage2({super.key});

  @override
  State<Setuppage2> createState() => _Setuppage2State();
}

class _Setuppage2State extends State<Setuppage2> {
  final JikanService jikanService = JikanService();

  List<Map<String, dynamic>> characters = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchCharacters();
  }

  void next() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Dashboard()),
    );
  }

  Future<void> fetchCharacters() async {
    setState(() => isLoading = true);

    try {
      // Fetch characters using Jikan service
      final fetchedCharacters = await jikanService.fetchCharacters();
      setState(() {
        characters = fetchedCharacters;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching characters: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchCharacters(query);
    });
  }

  Future<void> searchCharacters(String query) async {
    if (query.isEmpty) {
      fetchCharacters();
      return;
    }

    setState(() => isLoading = true);
    try {
      final results = await jikanService.searchCharacters(query);
      setState(() {
        characters = results;
        isLoading = false;
      });
    } catch (e) {
      print('Error searching characters: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Theme(
        data: OtakuPlannerTheme.lightTheme,

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
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
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
                  Transform.translate(offset: Offset(0, -2),
               child: isLoading
                    ? Center(child: CircularProgressIndicator())
                  : characters.isEmpty
                    ? Center(child: Text("No characters found"))
                  : 
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85, // Adjusted for taller cards
                      ),
                      itemCount: characters.length,
                      itemBuilder: (context, index) {
                        final character = characters[index];
                        // Get favorites count from the API response
                        final favorites = character['favorites'] ?? 0;

                        return GestureDetector(
                          onTap: next,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Character Image - takes most of the card space
                                  Expanded(
                                    flex: 4,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // Character image
                                        character['images'] != null &&
                                                character['images']['jpg'] !=
                                                    null &&
                                                character['images']['jpg']['image_url'] !=
                                                    null
                                            ? Image.network(
                                              character['images']['jpg']['image_url'],
                                              fit: BoxFit.cover,
                                            )
                                            : Container(
                                              color: Colors.grey[300],
                                              child: Icon(
                                                Icons.person,
                                                size: 50,
                                              ),
                                            ),

                                        // Heart count overlay at the bottom left
                                        Positioned(
                                          left: 8,
                                          bottom: 8,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.favorite,
                                                  color: Colors.purple[300],
                                                  size: 16,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  favorites.toString(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Character name
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    alignment: Alignment.center,
                                    child: Text(
                                      character['name'] ?? "Unknown",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),),
                  // else
                  //   GridView.builder(
                  //     shrinkWrap: true,
                  //     physics: NeverScrollableScrollPhysics(),
                  //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  //       crossAxisCount: 2,
                  //       crossAxisSpacing: 15,
                  //       mainAxisSpacing: 15,
                  //       childAspectRatio: 1,
                  //     ),
                  //     itemCount: characters.length,
                  //     itemBuilder: (context, index) {
                  //       final character = characters[index];
                  //       return GestureDetector(
                  //         onTap: next,
                  //         child: Container(
                  //           decoration: BoxDecoration(
                  //             color: Color.fromRGBO(252, 242, 232, 1),
                  //             border: Border.all(
                  //               color: Colors.grey.shade900,
                  //               width: 0.2,
                  //             ),
                  //           ),
                  //           padding: EdgeInsets.all(8),
                  //           child: Column(
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             children: [
                  //               CircleAvatar(
                  //                 radius: 35,
                  //                 backgroundImage:
                  //                     character['images'] != null &&
                  //                             character['images']['jpg'] !=
                  //                                 null &&
                  //                             character['images']['jpg']['image_url'] !=
                  //                                 null
                  //                         ? NetworkImage(
                  //                           character['images']['jpg']['image_url'],
                  //                         )
                  //                         : null,
                  //                 child:
                  //                     character['images'] == null
                  //                         ? Icon(Icons.person)
                  //                         : null,
                  //               ),
                  //               SizedBox(height: 8),
                  //               Text(
                  //                 character['name'] ?? "Unknown",
                  //                 textAlign: TextAlign.center,
                  //                 style: TextStyle(
                  //                   fontSize: 16,
                  //                   fontWeight: FontWeight.bold,
                  //                 ),
                  //                 maxLines: 2,
                  //                 overflow: TextOverflow.ellipsis,
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Center(
                    child: CustomButton(
                      ontap: () {
                        Navigator.pop(context);
                      },
                      data: "<- Back",
                      textcolor: Colors.white,
                      backgroundcolor: Color(0xFF1E293B),
                      width: 100,
                      height: 50,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
