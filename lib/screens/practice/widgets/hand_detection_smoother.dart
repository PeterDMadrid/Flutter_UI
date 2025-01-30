class HandDetectionSmoother {
  final int windowSize;
  final List<bool> _detectionHistory = [];

  HandDetectionSmoother({this.windowSize = 5});

  bool smoothDetection(bool currentDetection) {
    _detectionHistory.add(currentDetection);
    if (_detectionHistory.length > windowSize) {
      _detectionHistory.removeAt(0);
    }

    // Use majority voting to smooth the detection
    final trueCount = _detectionHistory.where((detection) => detection).length;
    return trueCount > windowSize / 2;
  }
}