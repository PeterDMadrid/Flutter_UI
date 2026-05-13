import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class GifDisplay extends StatefulWidget {
  final String gifPath;
  final String staticFramePath;
  final VoidCallback onGifDisplayed;

  const GifDisplay({
    super.key,
    required this.gifPath,
    required this.staticFramePath,
    required this.onGifDisplayed,
  });

  @override
  State<GifDisplay> createState() => _GifDisplayState();
}

class _GifDisplayState extends State<GifDisplay> {
  bool _showGif = true;
  Timer? _timer;
  int _key = 0; // Used to force rebuild

  @override
  void initState() {
    super.initState();
    _startGifTimer();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onGifDisplayed();
    });
  }

  void _startGifTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 5000), () {
      if (mounted) {
        setState(() {
          _showGif = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<Uint8List> _loadGif() async {
    ByteData data = await DefaultAssetBundle.of(context).load(widget.gifPath);
    return data.buffer.asUint8List();
  }

  void _restartGif() {
    setState(() {
      _key++; // Increment key to force rebuild
      _showGif = true;
    });
    _startGifTimer();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Center(
      child: SizedBox(
        height: screenSize.height * 0.4,
        width: screenSize.width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_showGif)
              FutureBuilder<Uint8List>(
                key: ValueKey(_key), // Use key to force rebuild
                future: _loadGif(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      gaplessPlayback: false,
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              )
            else
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    widget.staticFramePath,
                    fit: BoxFit.cover,
                  ),
                  ElevatedButton(
                    onPressed: _restartGif,
                    child: const Text('Retry'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}