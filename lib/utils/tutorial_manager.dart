import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

int currentTutorialStep = 0;

Future<void> setTutorialStep(int step) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('tutorialStep', step);
}

Future<int> getTutorialStep() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('tutorialStep') ?? -1; // -1 = no tutorial in progress
}


class TutorialManager {
  late BuildContext context;
  List<TargetFocus> targets = [];

  GlobalKey? keyLoginButton;
  GlobalKey? keySignUpButton;

  TutorialManager(this.context, {this.keyLoginButton, this.keySignUpButton});

  void showTutorial({VoidCallback? onFinish}) {
    final tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black.withOpacity(0.8),
      textSkip: "SKIP",
      onClickTarget: (_) {},
      onSkip: () => true,
      onFinish: onFinish ?? () => print("Tutorial finished"),
    );

    tutorial.show(context: context);
  }
}
