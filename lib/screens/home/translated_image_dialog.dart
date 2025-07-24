import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:my_project/utils/gpt_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:my_project/utils/translation_config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TranslatedTextLine {
  final String translated;
  final Rect rect;

  TranslatedTextLine({required this.translated, required this.rect});
}

class TranslatedImageDialog extends StatefulWidget {
  final String imageUrl;

  const TranslatedImageDialog({super.key, required this.imageUrl});

  @override
  State<TranslatedImageDialog> createState() => _TranslatedImageDialogState();
}

class _TranslatedImageDialogState extends State<TranslatedImageDialog> {
  ui.Image? image;
  List<TranslatedTextLine> lines = [];

  @override
  void initState() {
    super.initState();
    processImage();
  }

  Future<void> processImage() async {
    final response = await http.get(Uri.parse(widget.imageUrl));
    final bytes = response.bodyBytes;

    // Load the image using ui.Image
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final imgUi = frame.image;

    // Navigate and pass bytes instead of translating here
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => FullScreenTranslatedImage(
            image: imgUi,
            imageBytes: bytes,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _TranslatedOverlayPainter extends CustomPainter {
  final ui.Image image;
  final List<TranslatedTextLine> lines;

  _TranslatedOverlayPainter(this.image, this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());

    for (final line in lines) {
      const minHeight = 30.0;
      const padding = 4.0;

      final originalRect = line.rect;
      final adjustedHeight =
          originalRect.height < minHeight ? minHeight : originalRect.height;

      final rect = Rect.fromLTWH(
        originalRect.left,
        originalRect.top,
        originalRect.width,
        adjustedHeight,
      );

      final backgroundPaint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      canvas.drawRect(rect, backgroundPaint);

      final boxPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.blue
        ..strokeWidth = 2;
      canvas.drawRect(rect, boxPaint);

      const maxFontSize = 24.0;
      const minFontSize = 8.0;
      final maxWidth = rect.width - padding * 2;
      final maxHeight = rect.height - padding * 2;

      TextPainter textPainter = TextPainter(
        text: const TextSpan(text: ''),
        textDirection: TextDirection.ltr,
      );

      double fontSize = maxFontSize;

      while (fontSize >= minFontSize) {
        textPainter = TextPainter(
          text: TextSpan(
            text: line.translated,
            style: TextStyle(color: Colors.black, fontSize: fontSize),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 3,
          ellipsis: '...',
        );

        textPainter.layout(maxWidth: maxWidth);

        if (textPainter.height <= maxHeight && textPainter.width <= maxWidth) {
          break;
        }

        fontSize -= 1;
      }

      final offsetX = rect.left + (rect.width - textPainter.width) / 2;
      final offsetY = rect.top + (rect.height - textPainter.height) / 2;
      textPainter.paint(canvas, Offset(offsetX, offsetY));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class FullScreenTranslatedImage extends StatefulWidget {
  final ui.Image image;
  final Uint8List imageBytes;

  const FullScreenTranslatedImage({
    super.key,
    required this.image,
    required this.imageBytes,
  });

  @override
  State<FullScreenTranslatedImage> createState() =>
      _FullScreenTranslatedImageState();
}

class _FullScreenTranslatedImageState extends State<FullScreenTranslatedImage> {
  String selectedLanguage = selectedTranslationLanguage;
  List<TranslatedTextLine> lines = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _translateText();
  }

  Future<void> _translateText() async {
    setState(() => isLoading = true);

    if (selectedTranslationLanguage.isEmpty) {
      setState(() {
        lines = [];
        isLoading = false;
      });
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_image.jpg');
    await tempFile.writeAsBytes(widget.imageBytes);

    final inputImage = InputImage.fromFile(tempFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);

    List<TranslatedTextLine> translated = [];

    for (TextBlock block in recognizedText.blocks) {
      final translation = await translateWithGPT(
        block.text,
        targetLanguage: selectedTranslationLanguage,
      );
      translated.add(TranslatedTextLine(
        translated: translation,
        rect: block.boundingBox,
      ));
    }

    setState(() {
      lines = translated;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(AppLocalizations.of(context)!.translatedImg),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Dropdown bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.black,
              child: DropdownButtonFormField<String>(
                value: selectedLanguage,
                dropdownColor: Colors.grey[900],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: AppLocalizations.of(context)!.translatedTo,
                  labelStyle: TextStyle(color: Color(0xFF00E676)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00E676)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00E676), width: 2),
                  ),
                ),
                iconEnabledColor: Color(0xFF00E676),
                style: const TextStyle(color: Colors.black),
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Text(
                        AppLocalizations.of(context)!.defaultNoLangSelected,
                        style: TextStyle(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: 'English',
                    child: Text(AppLocalizations.of(context)!.english,
                        style: TextStyle(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: 'Chinese',
                    child: Text(AppLocalizations.of(context)!.chinese,
                        style: TextStyle(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: 'Tagalog',
                    child: Text(AppLocalizations.of(context)!.tagalog,
                        style: TextStyle(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: 'Indonesian',
                    child: Text(AppLocalizations.of(context)!.indonesian,
                        style: TextStyle(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: 'Burmese',
                    child: Text(AppLocalizations.of(context)!.burmese,
                        style: TextStyle(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: 'Tamil',
                    child: Text(AppLocalizations.of(context)!.tamil,
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
                selectedItemBuilder: (BuildContext context) {
                  return [
                    AppLocalizations.of(context)!.defaultNoLangSelected,
                    AppLocalizations.of(context)!.english,
                    AppLocalizations.of(context)!.chinese,
                    AppLocalizations.of(context)!.tagalog,
                    AppLocalizations.of(context)!.indonesian,
                    AppLocalizations.of(context)!.burmese,
                    AppLocalizations.of(context)!.tamil,
                  ].map((value) {
                    return Text(
                      value,
                      style: const TextStyle(color: Colors.black),
                    );
                  }).toList();
                },
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedLanguage = value;
                      selectedTranslationLanguage = value;
                    });

                    if (value.isNotEmpty) {
                      _translateText(); // only translate if a language is selected
                    } else {
                      setState(() {
                        lines.clear(); // show plain image if Default selected
                      });
                    }
                  }
                },
              ),
            ),

            // Image with translated text
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 0.5,
                        maxScale: 5.0,
                        boundaryMargin: const EdgeInsets.all(100),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: widget.image.width.toDouble(),
                            height: widget.image.height.toDouble(),
                            child: CustomPaint(
                              painter: _TranslatedOverlayPainter(
                                  widget.image, lines),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
