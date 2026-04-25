import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';

class TranslaterController extends GetxController {
  TextEditingController textt = TextEditingController();

  var isListerning = 0.obs;
  List charList = [].obs;
  List showsigns = [].obs;
  var text = "".obs;
  static const List<Map<String, String>> handsignsMap = [
    {'A': 'assets/signlanguage/A.jpg'},
    {'B': 'assets/signlanguage/B.jpg'},
    {'C': 'assets/signlanguage/C.jpg'},
    {'D': 'assets/signlanguage/D.jpg'},
    {'E': 'assets/signlanguage/E.jpg'},
    {'F': 'assets/signlanguage/F.jpg'},
    {'G': 'assets/signlanguage/G.jpg'},
    {'H': 'assets/signlanguage/H.jpg'},
    {'I': 'assets/signlanguage/I.jpg'},
    {'J': 'assets/signlanguage/J.jpg'},
    {'K': 'assets/signlanguage/K.jpg'},
    {'L': 'assets/signlanguage/L.jpg'},
    {'M': 'assets/signlanguage/M.jpg'},
    {'N': 'assets/signlanguage/N.jpg'},
    {'O': 'assets/signlanguage/O.jpg'},
    {'P': 'assets/signlanguage/P.jpg'},
    {'Q': 'assets/signlanguage/Q.jpg'},
    {'R': 'assets/signlanguage/R.jpg'},
    {'S': 'assets/signlanguage/S.jpg'},
    {'T': 'assets/signlanguage/T.jpg'},
    {'U': 'assets/signlanguage/U.jpg'},
    {'V': 'assets/signlanguage/V.jpg'},
    {'W': 'assets/signlanguage/W.jpg'},
    {'X': 'assets/signlanguage/X.jpg'},
    {'Y': 'assets/signlanguage/Y.jpg'},
    {'Z': 'assets/signlanguage/Z.jpg'},
    {' ': 'assets/signlanguage/space.jpg'},
    {'0': 'assets/signlanguage/numbers/0.jpg'},
    {'1': 'assets/signlanguage/numbers/1.jpg'},
    {'2': 'assets/signlanguage/numbers/2.jpg'},
    {'3': 'assets/signlanguage/numbers/3.jpg'},
    {'4': 'assets/signlanguage/numbers/4.jpg'},
    {'5': 'assets/signlanguage/numbers/5.jpg'},
    {'6': 'assets/signlanguage/numbers/6.jpg'},
    {'7': 'assets/signlanguage/numbers/7.jpg'},
    {'8': 'assets/signlanguage/numbers/8.jpg'},
    {'9': 'assets/signlanguage/numbers/9.jpg'},
  ];

  SpeechToText speechToText = SpeechToText();

  void TranslateToSign() {
    charList = text.split('').toList(); // [H, e, l, l, o,  , W, o, r, l, d]
    showsigns = List.filled(charList.length, null);
    for (int i = 0; i < charList.length; i++) {
      showsigns[i] = handsignsMap
          .where((element) =>
              element.containsKey(charList[i].toString().toUpperCase()))
          .first;
    }
    print(showsigns.length);
    update();
  }

  WrittenMessage() {
    if (textt.text.isEmpty) {
      Get.snackbar("Alert", "Please Enter a Message");
    }
    text.value = textt.text;
    TranslateToSign();
  }

  ListernToUser() async {
    if (isListerning.value == 0) {
      var avalable = await speechToText.initialize();
      if (avalable) {
        isListerning.value = 1;
        speechToText.listen(
          onResult: (result) {
            textt.text = result.recognizedWords;
            text.value = result.recognizedWords;
          },
        );
      }
    }
  }

  stopListerning() {
    isListerning.value = 0;
    speechToText.stop();
    if (text.value == "") {
      Get.snackbar("Alert", "Could not hear you, Please Try Again");
    }
    TranslateToSign();
  }
}
