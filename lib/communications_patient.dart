import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

// enum translateLanguage {
//   /// Afrikaans   /// Albanian
//   afrikaans, albanian,
  
//  /// Arabic   /// Belarusian
//   arabic,   belarusian,

//   /// Bengali     /// Bulgarian
//   bengali,    bulgarian,

//   /// Catalan    /// Chinese
//   catalan,   chinese,

//   /// Croatian    /// Czech
//   croatian,    czech,

//   /// Danish   /// Dutch
//   danish,    dutch,

//   /// English    /// Esperanto
//   english,    esperanto,

//   /// Estonian     /// Finnish
//   estonian,     finnish,

//   /// French    /// Galician
//   french,     galician,

//   /// Georgian    /// German
//   georgian,    german,

//   /// Greek    /// Gujarati
//   greek,     gujarati,

//   /// Haitian    /// Hebrew
//   haitian,     hebrew,
 
//   /// Hindi     /// Hungarian
//   hindi,    hungarian,

//   /// Icelandic     /// Indonesian
//   icelandic,     indonesian,

//   /// Irish     /// Italian
//   irish,    italian,

//   /// Japanese   /// Kannada
//   japanese,     kannada,

//   /// Korean    /// Latvian
//   korean,    latvian,

//   /// Lithuanian    /// Macedonian
//   lithuanian,        macedonian,

//   /// Malay     /// Maltese
//   malay,      maltese,

//   /// Marathi     /// Norwegian
//   marathi,       norwegian,

//   /// Persian    /// Polish
//   persian,         polish,

//   /// Portuguese   /// Romanian
//   portuguese,     romanian,

//   /// Russian     /// Slovak
//   russian,       slovak,

//   /// Slovenian     /// Spanish
//   slovenian,     spanish,

//   /// Swahili     /// Swedish
//   swahili,     swedish,

//   /// Tagalog     /// Tamil
//   tagalog,     tamil,

//   /// Telugu     /// Thai
//   telugu,       thai,

//   /// Turkish  /// Ukrainian
//   turkish,     ukrainian,

//   /// Urdu    /// Vietnamese
//   urdu,     vietnamese,

//   /// Welsh
//   welsh,
// }

class _communcationsScreemState extends State<communcationsScreem> {

  String? _translatedText;
  final _controller = TextEditingController();
  // final _modelManager = OnDeviceTranslatorModelManager();
  // String? selectedValue;
  Object? valueSelect;
  final _sourceLanguage = TranslateLanguage.english;
  // final _sourceLanguage = TranslateLanguage.values.firstWhere((element) => element.bcpCode == valueSelect!);
  final _targetLanguage = TranslateLanguage.spanish;

    late final _onDeviceTranslator = OnDeviceTranslator(
      sourceLanguage: _sourceLanguage, targetLanguage: _targetLanguage);

TextEditingController translatedTextfield1 = TextEditingController();
TextEditingController translatedTextfield2 = TextEditingController();

// final textTranslation = await _onDeviceTranslator

 Future<void> translateTextFunction() async {
    // FocusScope.of(context).unfocus();
    final result = await _onDeviceTranslator.translateText(_controller.text);
    setState(() {
      _translatedText = result;
    });
  }

    final languagePicker = [
      'afrikaans', 'albanian', 'arabic', 'belarusian', 'bengali', 'bulgarian',
      'catalan', 'chinese', 'croatian', 'czech', 'danish', 'dutch', 'english',
      'esperanto', 'estonian', 'finnish', 'french', 'galician', 'georgian',
      'german', 'greek', 'gujarati', 'haitian', 'hebrew', 'hindi', 'hungarian',
      'icelandic', 'indonesian', 'irish', 'italian', 'japanese', 'kannada',
      'korean', 'latvian', 'lithuanian', 'macedonian', 'malay', 'maltese',
      'marathi', 'norwegian', 'persian', 'polish', 'portuguese', 'romanian',
      'russian', 'slovak', 'slovenian', 'spanish', 'swahili', 'swedish',
      'tagalog', 'tamil', 'telugu', 'thai', 'turkish', 'ukrainian', 'urdu',
      'vietnamese', 'welsh',
    ];



//  final languagePicker2 = [
//   (expression) {
//     switch (expression) {
//      case TranslateLanguage.afrikaans:
//         return 'afrikaans';
//       case TranslateLanguage.albanian:
//         return 'sq';
//       case TranslateLanguage.arabic:
//         return 'ar';
//       case TranslateLanguage.belarusian:
//         return 'be';
//       case TranslateLanguage.bengali:
//         return 'bn';
//       case TranslateLanguage.bulgarian:
//         return 'bg';
//       case TranslateLanguage.catalan:
//         return 'ca';
//       case TranslateLanguage.chinese:
//         return 'zh';
//       case TranslateLanguage.croatian:
//         return 'hr';
//       case TranslateLanguage.czech:
//         return 'cs';
//       case TranslateLanguage.danish:
//         return 'da';
//       case TranslateLanguage.dutch:
//         return 'nl';
//       case TranslateLanguage.english:
//         return 'en';
//       case TranslateLanguage.esperanto:
//         return 'eo';
//       case TranslateLanguage.estonian:
//         return 'et';
//       case TranslateLanguage.finnish:
//         return 'fi';
//       case TranslateLanguage.french:
//         return 'fr';
//       case TranslateLanguage.galician:
//         return 'gl';
//       case TranslateLanguage.georgian:
//         return 'ka';
//       case TranslateLanguage.german:
//         return 'de';
//       case TranslateLanguage.greek:
//         return 'el';
//       case TranslateLanguage.gujarati:
//         return 'gu';
//       case TranslateLanguage.haitian:
//         return 'ht';
//       case TranslateLanguage.hebrew:
//         return 'he';
//       case TranslateLanguage.hindi:
//         return 'hi';
//       case TranslateLanguage.hungarian:
//         return 'hu';
//       case TranslateLanguage.icelandic:
//         return 'is';
//       case TranslateLanguage.indonesian:
//         return 'id';
//       case TranslateLanguage.irish:
//         return 'ga';
//       case TranslateLanguage.italian:
//         return 'it';
//       case TranslateLanguage.japanese:
//         return 'ja';
//       case TranslateLanguage.kannada:
//         return 'kn';
//       case TranslateLanguage.korean:
//         return 'ko';
//       case TranslateLanguage.latvian:
//         return 'lv';
//       case TranslateLanguage.lithuanian:
//         return 'lt';
//       case TranslateLanguage.macedonian:
//         return 'mk';
//       case TranslateLanguage.malay:
//         return 'ms';
//       case TranslateLanguage.maltese:
//         return 'mt';
//       case TranslateLanguage.marathi:
//         return 'mr';
//       case TranslateLanguage.norwegian:
//         return 'no';
//       case TranslateLanguage.persian:
//         return 'fa';
//       case TranslateLanguage.polish:
//         return 'pl';
//       case TranslateLanguage.portuguese:
//         return 'pt';
//       case TranslateLanguage.romanian:
//         return 'ro';
//       case TranslateLanguage.russian:
//         return 'ru';
//       case TranslateLanguage.slovak:
//         return 'sk';
//       case TranslateLanguage.slovenian:
//         return 'sl';
//       case TranslateLanguage.spanish:
//         return 'es';
//       case TranslateLanguage.swahili:
//         return 'sw';
//       case TranslateLanguage.swedish:
//         return 'sv';
//       case TranslateLanguage.tagalog:
//         return 'tl';
//       case TranslateLanguage.tamil:
//         return 'ta';
//       case TranslateLanguage.telugu:
//         return 'te';
//       case TranslateLanguage.thai:
//         return 'th';
//       case TranslateLanguage.turkish:
//         return 'tr';
//       case TranslateLanguage.ukrainian:
//         return 'uk';
//       case TranslateLanguage.urdu:
//         return 'ur';
//       case TranslateLanguage.vietnamese:
//         return 'vi';
//       case TranslateLanguage.welsh:
//         return 'cy';
//       // Add more cases for each language pattern

//     }
//   }
// ];





Widget buildCard2(int index) => Container(
padding: EdgeInsets.all(10.0),
  decoration: const BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(22)),
    color: Color(0xFFF6F6F6),
    boxShadow: [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.2),
      offset: Offset(0, 1),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ],
  ),

    child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question $index', style: TextStyle(fontSize: 20),),
      ],),
);

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
        resizeToAvoidBottomInset: true,
      appBar:AppBar(
  toolbarHeight: 30,
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
// resizeToAvoidBottomInset: false,
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Color(0xFF9EE8BF),
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 30, 0, 30),
              child: Text('Translate Questions', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold) ,),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: DropdownButton(
                    hint: Text('English'),
                    value:valueSelect,
                    onChanged: (newValue) {
                      setState(() {
                         valueSelect = newValue;
                      });
                    },
                    items: languagePicker.map((valueItem) {
                      return DropdownMenuItem(
                        value: valueItem,
                        child: Text(valueItem),);
                    }).toList(), ),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: DropdownButton(
                    hint: Text('English'),
                    value:valueSelect,
                    onChanged: (newValue) {
                      setState(() {
                         valueSelect = newValue;
                      });
                    },
                    items: languagePicker.map((valueItem) {
                      return DropdownMenuItem(
                        value: valueItem,
                        child: Text(valueItem),);
                    }).toList(), ),
                ),
              ],
              ),
              Container(
                child: TextFormField(
                  controller: _controller,
                  // onChanged: translateTextFunction(_translatedText()),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: ("Enter text"),
                    ),
                ),
              ),

              Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        border: Border.all(
                      width: 2,
                    )),
                    child: Text(_translatedText ?? 'pease')),
             

              Container(
                 decoration: BoxDecoration(
                        border: Border.all(
                      width:2,
                    )),
                    width: double.infinity,
                padding: EdgeInsets.fromLTRB(15, 20, 0, 20), 
                child: Text('Common / Saved questions for caregivers',  style: TextStyle(fontSize: 20),),
              ),
              Expanded(
               child: ListView.separated(
                 padding:EdgeInsets.all(10.0),
                 itemCount: 4,
                 separatorBuilder: (context,index) {
                  return const SizedBox(height: 15,);
                 },
                 itemBuilder: (context, index) {
                  return buildCard2(index);
                 },
               ),
             ) ,            
            Container(
              width: double.infinity,
padding: EdgeInsets.all(10.0),
  decoration: const BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(22)),
  ),
    child: ElevatedButton(onPressed: (){},  
               child: Text('Add Questions?', 
               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black,),), 
               style: ElevatedButton.styleFrom(
              primary: Color(0xFFF6F6F6),
          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22), // Rounded corner radius
          ),
        ), 
        ),
),
              // ElevatedButton(
              //       onPressed: _translateText, child: Text('Translate'))
              // ]), 
        ]),
      ),
    );
  }
}