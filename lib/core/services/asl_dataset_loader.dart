import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service to interact with Hugging Face ASL Dataset
/// The dataset contains 108,618 ASL videos for 2,208 words
class ASLDatasetLoader {
  static const String datasetName = 'akasheroor/American-Sign-Language-Dataset';
  static const String huggingFaceBase = 'https://huggingface.co/api/datasets/$datasetName';
  
  /// Fetch dataset metadata from Hugging Face
  static Future<Map<String, dynamic>> getDatasetInfo() async {
    try {
      final response = await http.get(Uri.parse(huggingFaceBase));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to fetch dataset info: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching dataset: $e');
    }
  }
  
  /// Get the CSV file mapping words to video paths
  /// URL: https://huggingface.co/datasets/akasheroor/American-Sign-Language-Dataset/raw/main/dataset.csv
  static Future<List<ASLWordEntry>> fetchDatasetCSV() async {
    try {
      const csvUrl = 'https://huggingface.co/datasets/akasheroor/American-Sign-Language-Dataset/raw/main/dataset.csv';
      final response = await http.get(Uri.parse(csvUrl));
      
      if (response.statusCode == 200) {
        return _parseCSV(response.body);
      }
      throw Exception('Failed to fetch CSV: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching dataset CSV: $e');
    }
  }
  
  /// Parse CSV data into ASLWordEntry objects
  static List<ASLWordEntry> _parseCSV(String csvContent) {
    final lines = csvContent.split('\n');
    final entries = <ASLWordEntry>[];
    
    // Skip header
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      final parts = line.split(',');
      if (parts.length >= 2) {
        entries.add(ASLWordEntry(
          word: parts[0].trim(),
          videoPath: parts[1].trim(),
        ));
      }
    }
    
    return entries;
  }
  
  /// Get video URL for a specific word from Hugging Face
  /// Returns: https://huggingface.co/datasets/.../resolve/main/{videoPath}
  static String getVideoUrl(String videoPath) {
    return 'https://huggingface.co/datasets/$datasetName/resolve/main/$videoPath';
  }
  
  /// Filter words by category or search term
  static List<ASLWordEntry> filterEntries(
    List<ASLWordEntry> entries,
    String query,
  ) {
    final lowercaseQuery = query.toLowerCase();
    return entries
        .where((entry) => entry.word.toLowerCase().contains(lowercaseQuery))
        .toList();
  }
  
  /// Get unique words in the dataset
  static Set<String> getUniqueWords(List<ASLWordEntry> entries) {
    return entries.map((e) => e.word).toSet();
  }
  
  /// Get word frequency statistics
  static Map<String, int> getWordFrequency(List<ASLWordEntry> entries) {
    final freq = <String, int>{};
    for (final entry in entries) {
      freq[entry.word] = (freq[entry.word] ?? 0) + 1;
    }
    return freq;
  }
}

/// Represents an entry in the ASL dataset CSV
class ASLWordEntry {
  final String word;
  final String videoPath;
  
  ASLWordEntry({
    required this.word,
    required this.videoPath,
  });
  
  /// Get the full video URL
  String getFullUrl() => ASLDatasetLoader.getVideoUrl(videoPath);
  
  @override
  String toString() => 'ASLWordEntry(word: $word, path: $videoPath)';
}
