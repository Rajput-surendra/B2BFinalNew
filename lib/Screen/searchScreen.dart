import 'dart:convert';
import 'dart:math';

import 'package:b2b/utils/GetPreference.dart';
import 'package:b2b/widgets/Appbar.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Model/SearchModel.dart';
import '../apiServices/apiConstants.dart';
import '../color.dart';
import '../utils/design_config.dart';
import '../widgets/appButton.dart';
import 'HomeScreen.dart';


class SearchScreen extends StatefulWidget {
   SearchScreen({Key? key,this.con}) : super(key: key);
  String? con;


  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    searchApi();
    super.initState();

  }
  TextEditingController searchC = TextEditingController();
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;

  String lastStatus = '';
  String _currentLocaleId = '';
  String lastWords = '';
  final SpeechToText speech = SpeechToText();
  late StateSetter setStater;
  void resultListener(SpeechRecognitionResult result) {
    setStater(
          () {
        lastWords = result.recognizedWords;
        searchC.text = lastWords;
      },
    );

    if (result.finalResult) {
      Future.delayed(const Duration(seconds: 1)).then((_) async {
        // clearAll();

        searchC.text = lastWords;
        searchC.selection = TextSelection.fromPosition(
            TextPosition(offset: searchC.text.length));

        setState(() {});
        searchApi();
        Navigator.of(context).pop();
      });
    }
  }
  Future<void> initSpeechState() async {
    var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: false,
        finalTimeout: const Duration(milliseconds: 0));
    if (hasSpeech) {
      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? '';
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
    if (hasSpeech) showSpeechDialog();
  }
  void errorListener(SpeechRecognitionError error) {}
  void statusListener(String status) {
    setStater(
          () {
        lastStatus = status;
      },
    );
  }
  void startListening() {
    lastWords = '';
    speech.listen(
        onResult: resultListener,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setStater(() {});
  }
  showSpeechDialog() {
    return DesignConfiguration.dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater1) {
          setStater = setStater1;
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              "Search",
              // getTranslated(context, 'SEarchHint')!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
                fontSize: textFontSize16,
                fontFamily: 'ubuntu',
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          blurRadius: .26,
                          spreadRadius: level * 1.5,
                          color: Colors.black
                              .withOpacity(.05))
                    ],
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(circularBorderRadius50)),
                  ),
                  child: IconButton(
                      icon: const Icon(
                        Icons.mic,
                        color: colors.primary,
                      ),
                      onPressed: () {
                        if (!_hasSpeech) {
                          initSpeechState();
                        } else {
                          !_hasSpeech || speech.isListening
                              ? null
                              : startListening();
                        }
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(lastWords),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  color:
                  Colors.black.withOpacity(0.1),
                  child: Center(
                    child: speech.isListening
                        ? Text(
                      'I\'m listening...',
                      // getTranslated(context, "I'm listening...")!,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(
                          color:
                          Colors.black,
                          fontFamily: 'ubuntu',
                          fontWeight: FontWeight.bold),
                    )
                        : Text(
                      'Not listening',
                      //  getTranslated(context, 'Not listening')!,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(
                        color:
                        Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ubuntu',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);

    setStater(() {
      this.level = level;
    });
  }
  bool currentIndex = true;

  @override
  Widget build(BuildContext context) {
    print('____dgdfgfdgfd______${widget.con}_________');
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          // appBar: customAppBar(context: context, text: "Search", isTrue: false),
          body:Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width:
                  MediaQuery.of(context).size.width / 1.1,
                  height: 50,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: TextField(
                    controller: searchC,
                    decoration: InputDecoration(
                      contentPadding:
                      const EdgeInsets.only(top: 20),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 1,
                            color: Colors.transparent),
                        borderRadius:
                        BorderRadius.circular(7),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 1, color: Colors.white),
                        borderRadius:
                        BorderRadius.circular(7),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 1, color: Colors.white),
                        borderRadius:
                        BorderRadius.circular(7),
                      ),
                      hintText: "Search",
                      filled: true,
                      fillColor: Colors.white,
                      hintStyle: const TextStyle(
                          color: Colors.black54),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 20,
                      ),
                      prefixIconColor: Colors.black,
                      suffixIcon: IconButton(icon: const Icon(Icons.mic),
                        onPressed: (){
                          initSpeechState();
                          // if (!_hasSpeech) {
                          //   initSpeechState();
                          // } else {
                          //   !_hasSpeech || speech.isListening
                          //       ? null
                          //       : startListening();
                          // }
                        },),
                      suffixIconColor: Colors.black,
                    ),
                    onChanged: (value) {
                      searchApi();
                    },
                  ),
                ),
              ),
              getSubcat(),
            ],
          )

      ),
    );
  }

  getSubcat() {
    return Container(
      padding: const EdgeInsets.only(top: 0, left: 12, right: 12),
      child:  Container(
        height: MediaQuery.of(context).size.height / 1.2,
        //  GetSub!.data![i].products!.length >3? 280:140,
        child: isProducts ?
        Center(child: Text('No Products found!'))
            : searchList.isNotEmpty ?
        ListView.builder(
            shrinkWrap: true,

            physics: ScrollPhysics(),
            itemCount: searchList.length,
            //> 6 ? 6 : GetSub!.data![i].products!.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: (){
                  //Navigator.push(context, MaterialPageRoute(builder: (context)=>ProductDetailsHome(pId: searchList!.data![index].productId)));
                },
                child: Container(
                  width:
                  MediaQuery.of(context).size.width / 1.2,
                  margin: const EdgeInsets.all(0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.start,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20),
                          height: MediaQuery.of(context)
                              .size
                              .height /
                              5.6,
                          width: MediaQuery.of(context)
                              .size
                              .width,
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(20),
                            child: Image.network(
                              "${searchList[index].image}" ??
                                  '',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 24, top: 10),
                          child: Text(
                            "${searchList[index].name}" ??
                                '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.only(
                                left: 24, top: 10),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                        backgroundColor:
                                        colors.primary,
                                        radius: 10,
                                        child: Icon(
                                          Icons
                                              .person_rounded,
                                          color: colors.white,
                                          size: 15,
                                        )),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                        "${searchList[index].storeName}" ?? ''),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                        width: 120,
                                        child: Text(
                                          "(${searchList[index].typeOfSeller})" ??
                                              '',
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow
                                              .ellipsis,
                                          style: TextStyle(
                                              color: colors
                                                  .black,
                                              fontWeight:
                                              FontWeight
                                                  .bold),
                                        )),
                                  ],
                                )
                              ],
                            )),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 24, top: 5),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 10,
                                backgroundColor:
                                colors.primary,
                                child: Icon(
                                  Icons.location_pin,
                                  size: 15,
                                  color: colors.white,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                  width: 180,
                                  child: Text(
                                    "${searchList[index].sellerAddress}" ??
                                        "",
                                    overflow:
                                    TextOverflow.ellipsis,
                                    maxLines: 1,
                                  )),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 20, top: 5, right: 20),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                            children: [
                              InkWell(
                                  onTap: () {
                                    launch(
                                        "${searchList[index].video}");
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons
                                            .video_camera_back_outlined,
                                        color: colors.primary,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      InkWell(
                                          child: Text(
                                              "Watch Video"))
                                    ],
                                  )),
                              Row(
                                children: [
                                  CircleAvatar(
                                      radius: 15,
                                      backgroundColor:
                                      Colors.white,
                                      child: Icon(
                                        Icons.image,
                                        color: colors.primary,
                                      )),
                                  InkWell(
                                      onTap: () {
                                        showDialog<String>(
                                          context: context,
                                          builder: (BuildContext
                                          context) =>
                                              AlertDialog(
                                                title: Text(
                                                    'Broucher Image'),
                                                content:searchList[index].broucherImage == null ? Image.asset("Images/no-image-icon.png",height: 120,width:double.infinity,fit: BoxFit.fill,):
                                                Image.network(
                                                    "${searchList[index].broucherImage}"),
                                              ),
                                        );
                                      },
                                      child: Text("Broucher"))
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 20, right: 20),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                height: 25,
                                width: 25,
                                decoration:
                                const BoxDecoration(
                                    borderRadius:
                                    BorderRadius.all(
                                        Radius
                                            .circular(
                                            50)),
                                    color: Colors
                                        .deepPurple),
                                child: Icon(
                                  Icons.add_circle,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                height: 25,
                                width: 25,
                                decoration:
                                const BoxDecoration(
                                    borderRadius:
                                    BorderRadius.all(
                                        Radius
                                            .circular(
                                            5)),
                                    color: Colors
                                        .deepPurple),
                                child: const Padding(
                                  padding: EdgeInsets.only(
                                      left: 5,
                                      right: 5,
                                      top: 3,
                                      bottom: 3),
                                  child: Icon(
                                    Icons.message,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                height: 25,
                                width: 25,
                                decoration:
                                const BoxDecoration(
                                    borderRadius:
                                    BorderRadius.all(
                                        Radius
                                            .circular(
                                            6)),
                                    color:
                                    colors.secondary),
                                child: const Padding(
                                  padding: EdgeInsets.only(
                                      left: 5,
                                      right: 5,
                                      top: 3,
                                      bottom: 3),
                                  child: Icon(
                                    Icons.mail_outline,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                height: 25,
                                width: 25,
                                decoration:
                                const BoxDecoration(
                                    borderRadius:
                                    BorderRadius.all(
                                        Radius
                                            .circular(
                                            50)),
                                    color:
                                    colors.primary),
                                child: const Padding(
                                  padding: EdgeInsets.only(
                                      left: 5,
                                      right: 5,
                                      top: 3,
                                      bottom: 3),
                                  child: Icon(
                                    Icons.location_pin,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                height: MediaQuery.of(context)
                                    .size
                                    .height /
                                    20,
                                width: MediaQuery.of(context)
                                    .size
                                    .width /
                                    3,
                                decoration: BoxDecoration(
                                    borderRadius:
                                    const BorderRadius
                                        .all(
                                        Radius.circular(
                                            6)),
                                    border: Border.all(
                                        width: 2,
                                        color: Colors.grey),
                                    color: colors.white),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceAround,
                                  children: [
                                    Container(
                                      height: 25,
                                      width: 25,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius
                                              .all(Radius
                                              .circular(
                                              50)),
                                          color: searchList[index].taxNumber == ""
                                              ? colors.primary
                                              : colors
                                              .secondary),
                                      child: const Padding(
                                        padding:
                                        EdgeInsets.only(
                                            left: 5,
                                            right: 5,
                                            top: 3,
                                            bottom: 3),
                                        child: Icon(
                                          Icons.description,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 25,
                                      width: 25,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius
                                              .all(Radius
                                              .circular(
                                              50)),
                                          color: searchList[index]
                                              .subscriptionType ==
                                              1
                                              ? colors.primary
                                              : colors
                                              .secondary),
                                      child: const Padding(
                                        padding:
                                        EdgeInsets.only(
                                            left: 5,
                                            right: 5,
                                            top: 3,
                                            bottom: 3),
                                        child: Icon(
                                          Icons
                                              .check_circle_outline,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 25,
                                      width: 25,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius
                                              .all(Radius
                                              .circular(
                                              50)),
                                          color:searchList[index]
                                              .subscriptionType ==
                                              1
                                              ? colors.primary
                                              : colors
                                              .secondary),
                                      child: const Padding(
                                        padding:
                                        EdgeInsets.only(
                                            left: 5,
                                            right: 5,
                                            top: 3,
                                            bottom: 3),
                                        child: Icon(
                                          Icons.verified_user,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Center(
                          child: Btn(
                            height: 40,
                            width: 150,
                            title: "Contact Supplier",
                            onPress: () {
                              print('__________fdfdfgdfgd_________');
                              //showDialogContactSuplier(searchModel!.data![index].id, mobilee);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            })
            : Center(
          child: Container(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(
              color: colors.primary,
            ),
          ),
        ),
      ),
    );
  }
  List<SearchData> searchList = [];
  bool isProducts = false;

  searchApi() async {
    print("sdfghjkl");
    var headers = {'Cookie': 'ci_session=150ah7cca9g5b61a3nbpvaa41ch6lihe'};
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}fetch_product_by_fillters'));
    request.fields.addAll({
      'name': searchC.text.toString(),
      'city': widget.con.toString()
    });
    print('____requery=t______${request.fields}_________');
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      // String responseData = await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(result);
      // var result = await response.stream.bytesToString();
      var finalResult = SearchModel.fromJson(userData);
      print('____search result______${result}_________');
      setState(() {
        isProducts = finalResult.error!;
        searchList = finalResult.data!;
      });
      print('_____search_____${searchList.length}_________');

    } else {
      print(response.reasonPhrase);
    }
  }
}
