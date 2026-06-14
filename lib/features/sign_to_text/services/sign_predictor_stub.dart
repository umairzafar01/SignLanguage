class SignPredictor {
  String? get lastError => null;

  Future<void> initialize() async {}

  Future<String> predict(List<double> landmarks) async {
    return 'Unknown';
  }

  void dispose() {}
}