import 'package:flutter/material.dart';
import '../../core/services/asl_dataset_loader.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Screen to browse and learn from the Hugging Face ASL Dataset
class ASLDatasetBrowserScreen extends StatefulWidget {
  const ASLDatasetBrowserScreen({super.key});

  @override
  State<ASLDatasetBrowserScreen> createState() => _ASLDatasetBrowserScreenState();
}

class _ASLDatasetBrowserScreenState extends State<ASLDatasetBrowserScreen> {
  List<ASLWordEntry> _allEntries = [];
  List<ASLWordEntry> _filteredEntries = [];
  bool _loading = true;
  String _searchQuery = '';
  Map<String, int> _wordFrequency = {};

  @override
  void initState() {
    super.initState();
    _loadDataset();
  }

  Future<void> _loadDataset() async {
    try {
      setState(() => _loading = true);
      
      // Fetch dataset CSV from Hugging Face
      _allEntries = await ASLDatasetLoader.fetchDatasetCSV();
      _filteredEntries = List.from(_allEntries);
      _wordFrequency = ASLDatasetLoader.getWordFrequency(_allEntries);
      
      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dataset: $e')),
        );
      }
    }
  }

  void _filterEntries(String query) {
    setState(() {
      _searchQuery = query;
      _filteredEntries = ASLDatasetLoader.filterEntries(_allEntries, query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ASL Dataset Browser'),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: _filterEntries,
                    decoration: InputDecoration(
                      hintText: 'Search words (${_allEntries.length} total)',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                // Stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _StatCard(
                        label: 'Total Words',
                        value: _wordFrequency.length.toString(),
                        isLight: isLight,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Total Videos',
                        value: _allEntries.length.toString(),
                        isLight: isLight,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Avg Videos/Word',
                        value: _wordFrequency.isEmpty
                            ? '0'
                            : (_allEntries.length ~/ _wordFrequency.length)
                                .toString(),
                        isLight: isLight,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // List
                Expanded(
                  child: _filteredEntries.isEmpty
                      ? Center(
                          child: Text(
                            'No results for "$_searchQuery"',
                            style: AppTextStyles.body(),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredEntries.length,
                          itemBuilder: (_, i) {
                            final entry = _filteredEntries[i];
                            final count =
                                _wordFrequency[entry.word] ?? 0;
                            return _DatasetEntryCard(
                              entry: entry,
                              videoCount: count,
                              isLight: isLight,
                            );
                          },
                        ),
                )
              ],
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isLight;

  const _StatCard({
    required this.label,
    required this.value,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isLight ? Colors.blue.shade50 : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.cyan.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.heading(size: 16),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatasetEntryCard extends StatelessWidget {
  final ASLWordEntry entry;
  final int videoCount;
  final bool isLight;

  const _DatasetEntryCard({
    required this.entry,
    required this.videoCount,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLight
            ? Colors.white
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLight
              ? Colors.grey.shade200
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.word,
                  style: AppTextStyles.bodyMedium(
                    color: isLight
                        ? Colors.black87
                        : AppColors.text1,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$videoCount videos',
                  style: AppTextStyles.caption(
                    color: AppColors.cyan,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.videoPath,
            style: AppTextStyles.caption(
              color: isLight
                  ? Colors.grey.shade600
                  : AppColors.text3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              // Copy video URL to clipboard or open in browser
              final url = entry.getFullUrl();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('URL: ${url.substring(0, 50)}...')),
              );
            },
            icon: const Icon(Icons.open_in_browser, size: 16),
            label: const Text('View on HuggingFace'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cyan,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
