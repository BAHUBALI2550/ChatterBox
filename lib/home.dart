
import 'dart:typed_data';

import 'package:animate_do/animate_do.dart';
import 'package:chatter_box/openai_service.dart';
import 'package:chatter_box/resuable_box.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final speechToText = SpeechToText();
  final OpenAIService openAIService = OpenAIService();
  final flutterTts = FlutterTts();
  String lastWords = '';
  String? generatedContent;
  // String? generatedImageUrl;
  int start = 200;
  int delay = 200;
  TextEditingController _textFieldController = TextEditingController();
  Uint8List? generatedImageUrl;
  bool isMute = false;
  bool isListening = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {
      isListening = true;
    });
    print('Started listening...');
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {
      isListening = false;
    });
    print('Stopped listening.');
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // floatingActionButton: ZoomIn(
        //   delay: Duration(milliseconds: start+ 3*delay),
        //   child: FloatingActionButton(
        //     backgroundColor: const Color.fromRGBO(165, 231, 244, 1),
        //     onPressed: () async{
        //         if(await speechToText.hasPermission && speechToText.isNotListening){
        //           await startListening();
        //         } else if (speechToText.isListening){
        //             final speech = await openAIService.isArtPromptAPI(lastWords);
        //             if(speech is Uint8List){
        //               generatedContent = null;
        //               generatedImageUrl = speech;
        //               setState(() {
        //
        //               });
        //             } else{
        //               generatedContent = speech as String?;
        //               generatedImageUrl = null;
        //               setState(() {
        //
        //               });
        //               if(isMute == false) {
        //                 await systemSpeak(speech!);
        //               }
        //             }
        //             await stopListening();
        //         }else{
        //           initSpeechToText();
        //         }
        //     },
        //     child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
        //   ),
        // ),
        appBar: AppBar(
          title: BounceInDown(child: const Text('ChatterBox')),
          centerTitle: true,
          leading: const Icon(Icons.menu),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children:[
                        ZoomIn(
                        child: Stack(
                          children: [
                            Center(
                              child: Container(
                                height: 120,
                                width: 120,
                                margin: const EdgeInsets.only(top: 4),
                                decoration: const BoxDecoration(
                                  color: Color(0xffc4f59d),
                                  shape: BoxShape.circle
                                ),
                              ),
                            ),
                            Container(
                              height: 150,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage('assets/pictures/assist.png')
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                        Positioned(
                            right: 30,
                            top: 10,
                            child: InkWell(
                              onTap: (){
                                setState(() {
                                  isMute = !isMute;
                                  if(isMute){
                                    flutterTts.stop();
                                  }else{
                                    flutterTts.speak(generatedContent!);
                                  }
                                });
                              },
                              child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xffe8fc49),
                                    shape: BoxShape.circle,

                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Icon(isMute ? Icons.volume_off : Icons.volume_up),
                                  )),
                            )
                        ),
                      ],
                    ),
                    FadeInRight(
                      child: Visibility(
                        visible: generatedImageUrl == null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(top: 30),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1.5,
                              color: const Color.fromRGBO(200, 200, 200, 1),
                            ),

                            borderRadius: BorderRadius.circular(20).copyWith(topLeft: Radius.zero,bottomRight: Radius.zero),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              generatedContent == null ? 'Good Morning, what task can I do for you?' : generatedContent!,
                                style: TextStyle(
                                  fontSize: generatedContent == null ? 25:18,
                                  color: const Color.fromRGBO(19, 61, 95, 1),
                                  fontFamily: 'Cera Pro',
                                ),),
                          ),
                        ),
                      ),
                    ),
                    if(generatedImageUrl != null) Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.memory(generatedImageUrl!,),
                      ),
                    ),
                    SlideInLeft(
                      child: Visibility(
                        visible: generatedContent == null && generatedImageUrl == null,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(top: 10,left: 20),
                            alignment: Alignment.centerLeft,
                            child: const Text('Here are a few features',
                            style: TextStyle(
                              fontFamily: 'Cera Pro',
                              fontSize: 20,
                              color: Color.fromRGBO(19, 61, 95, 1),
                              fontWeight: FontWeight.bold
                            ),)),
                      ),
                    ),
                    Visibility(
                      visible: generatedContent == null && generatedImageUrl == null,
                      child: Column(
                        children: [
                          SlideInLeft(
                              delay: Duration(milliseconds: start),
                              child: const ReusableBox(color: Color(0xffbcf58e),heading: 'ChatterBox',description: 'A smarter way to stay organised and informed with Gemini',)),
                          SlideInLeft(
                              delay: Duration(milliseconds: start+delay),
                              child: const ReusableBox(color: Color(0xffd9f02b),heading: 'Vyro-AI',description: 'Get inspired and stay creative with your personal assistant powered by Vyro-AI',)),
                          SlideInLeft(
                              delay: Duration(milliseconds: start+delay+delay),
                              child: const ReusableBox(color: Color(0xffbcf58e),heading: 'Smart Voice Assistant',description: 'Get the best of both worlds with a voice assistant powered by Vyro-AI and Gemini',)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 15,top:6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textFieldController,
                      cursorColor: Colors.purple,
                      decoration: InputDecoration(
                        border:OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.purple,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (String value) async{
                        if(value.isNotEmpty) {

                            lastWords = value;
                            final speech = await openAIService.isArtPromptAPI(lastWords);
                            if(speech is Uint8List){
                              generatedContent = null;
                              generatedImageUrl = speech;
                              setState(() {

                              });
                            } else{
                              generatedContent = speech as String?;
                              generatedImageUrl = null;
                              setState(() {

                              });
                              if(isMute == false) {
                                await systemSpeak(speech!);
                              }
                            }
                            _textFieldController.clear();
                          setState(()  {

                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ZoomIn(
                    delay: Duration(milliseconds: start + 3*delay),
                    child: GestureDetector(
                      onTap: () async{
                                  if(await speechToText.hasPermission && !isListening){
                                    await startListening();
                                  } else if (isListening){
                                    if (kDebugMode) {
                                      print(lastWords);
                                    }
                                      final speech = await openAIService.isArtPromptAPI(lastWords);
                                      if(speech is Uint8List){
                                        generatedContent = null;
                                        generatedImageUrl = speech;
                                        setState(() {

                                        });
                                      } else{
                                        generatedContent = speech as String?;
                                        generatedImageUrl = null;
                                        setState(() {

                                        });
                                        if(isMute == false) {
                                          await systemSpeak(speech!);
                                        }
                                      }
                                      await stopListening();
                                  }else{
                                    initSpeechToText();
                                  }
                                  setState(() {

                                  });
                              },
                      child: Container(
                        height: 62,
                        width: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xffe8fc49),
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: Icon(isListening ? Icons.stop : Icons.mic),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
