import 'package:gif/gif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hands/base/widgets/okay_button.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/widgets/image_carousel.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';

class Instructions extends StatefulWidget {
  const Instructions({
    super.key,
    required this.onGotIt,
    required this.instructionContent,
    required this.bottomInstruction,
    required this.images,
    required this.gifInstruction,
  });

  final VoidCallback onGotIt;
  final String instructionContent;
  final String bottomInstruction;
  final List<String> images;
  final String gifInstruction;

  @override
  State<Instructions> createState() => _InstructionsState();
}

class _InstructionsState extends State<Instructions>
    with TickerProviderStateMixin {
  bool isExiting = false;
  late final GifController _teacherController;

  @override
  void initState() {
    super.initState();
    _teacherController = GifController(vsync: this);
  }

  @override
  void dispose() {
    _teacherController.dispose();
    super.dispose();
  }

  void handleExit() async {
    setState(() {
      isExiting = true;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    widget.onGotIt();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double teacherSize = MediaQuery.of(context).size.width * 1;
    return ValueListenableBuilder(
        valueListenable: ThemeManager().isDarkModeNotifier,
        builder: (context, isDarkMode, child) {
          return Material(
            color: AppStyles.getTextColor(isDarkMode),
            child: Stack(children: [
              Container(
                decoration: BoxDecoration(
                    color: AppStyles.getBackgroundColor(isDarkMode)),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppStyles.getMyBlue(isDarkMode),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Instructions',
                            style: AppStyles.getHeadLineStyle2(isDarkMode)
                                .copyWith(
                                    color:
                                        const Color.fromARGB(255, 141, 61, 0))),
                        const SizedBox(height: 16),
                        Text(widget.instructionContent,
                            style: AppStyles.getParagraph1(isDarkMode)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: screenHeight * 0.35,
                          child: ImageCarousel(images: widget.images),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.bottomInstruction,
                          style: AppStyles.getParagraph1(isDarkMode),
                        ),
                        const SizedBox(height: 24),
                        OkayButton(onProceed: handleExit)
                      ],
                    ),
                  )
                      .animate()
                      .slideY(
                          begin: -1,
                          end: 0,
                          duration: 500.ms,
                          curve: Curves.easeOutBack)
                      .animate(target: isExiting ? 1 : 0)
                      .slideY(
                        begin: 0,
                        end: -1,
                        duration: 500.ms,
                        curve: Curves.easeInBack,
                      ),
                ),
              ),
              Positioned(
                      right: -120,
                      bottom: -40,
                      child: SizedBox(
                        width: teacherSize * 0.7,
                        height: teacherSize * 0.7,
                        child: Gif(
                          image: AssetImage(widget.gifInstruction),
                          autostart: Autostart.once,
                          controller: _teacherController,
                          fit: BoxFit.cover,
                        ),
                      ))
                  .animate(target: isExiting ? 1 : 0)
                  .slideX(
                      begin: 0,
                      end: 1,
                      duration: 500.ms,
                      curve: Curves.easeInBack)
            ]),
          );
        });
  }
}
