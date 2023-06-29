import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

void main() => runApp(MaterialApp(
      title: "App",
      home: communcationsScreem(),
    ));

class communcationsScreem extends StatefulWidget {
  // LoginScreen
  const communcationsScreem({super.key});

  @override
  State<communcationsScreem> createState() => _communcationsScreemState();
}

enum TranslateLanguage {
  /// Afrikaans   /// Albanian
  afrikaans, albanian,
  
 /// Arabic   /// Belarusian
  arabic,   belarusian,

  /// Bengali     /// Bulgarian
  bengali,    bulgarian,

  /// Catalan    /// Chinese
  catalan,   chinese,

  /// Croatian    /// Czech
  croatian,    czech,

  /// Danish   /// Dutch
  danish,    dutch,

  /// English    /// Esperanto
  english,    esperanto,

  /// Estonian     /// Finnish
  estonian,     finnish,

  /// French    /// Galician
  french,     galician,

  /// Georgian    /// German
  georgian,    german,

  /// Greek    /// Gujarati
  greek,     gujarati,

  /// Haitian    /// Hebrew
  haitian,     hebrew,
 
  /// Hindi     /// Hungarian
  hindi,    hungarian,

  /// Icelandic     /// Indonesian
  icelandic,     indonesian,

  /// Irish     /// Italian
  irish,    italian,

  /// Japanese   /// Kannada
  japanese,     kannada,

  /// Korean    /// Latvian
  korean,    latvian,

  /// Lithuanian    /// Macedonian
  lithuanian,        macedonian,

  /// Malay     /// Maltese
  malay,      maltese,

  /// Marathi     /// Norwegian
  marathi,       norwegian,

  /// Persian    /// Polish
  persian,         polish,

  /// Portuguese   /// Romanian
  portuguese,     romanian,

  /// Russian     /// Slovak
  russian,       slovak,

  /// Slovenian     /// Spanish
  slovenian,     spanish,

  /// Swahili     /// Swedish
  swahili,     swedish,

  /// Tagalog     /// Tamil
  tagalog,     tamil,

  /// Telugu     /// Thai
  telugu,       thai,

  /// Turkish  /// Ukrainian
  turkish,     ukrainian,

  /// Urdu    /// Vietnamese
  urdu,     vietnamese,

  /// Welsh
  welsh,
}

class _communcationsScreemState extends State<communcationsScreem> {

  String? _translatedText;
  final _controller = TextEditingController();
  final _modelManager = OnDeviceTranslatorModelManager();
  
  // final _sourceLanguage = TranslateLanguage.english;
  // final _targetLanguage = TranslateLanguage.spanish;
  // late final _onDeviceTranslator = OnDeviceTranslator(
  //     sourceLanguage: _sourceLanguage, targetLanguage: _targetLanguage);
 

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar:AppBar(
  toolbarHeight: 40,
  elevation: 0,
  automaticallyImplyLeading: false,
  title: Text(
    'Communications',
    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
  ),
  titleTextStyle: TextStyle(
    color: Colors.black,
  ),
  centerTitle: true, // Set centerTitle to false for left alignment
),
      body: Container(
        child: Column(
          children: [
            
            Container(
              color: Color(0xFF9EE8BF),
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 30, 0, 30),
              child: Text('Translate Questions', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold) ,),),
        ]),
      ),
    );
  }
}