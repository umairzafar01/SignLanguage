import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/progress_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../text_to_sign/text_to_sign_screen.dart';

class _Sign {
  final String word, category, langs, signInput;
  final IconData icon;
  final Color color;
  bool favorite;
  _Sign(this.word, this.category, this.langs, this.signInput, this.icon, this.color,
      {this.favorite = false});
}

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});
  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final _searchCtrl = TextEditingController();
  int _filterIndex = 0;
  final _filters = ['All', 'Greetings', 'Emotions', 'Numbers', 'Family', 'Everyday'];

  final _signs = [
    _Sign('Hello', 'Greetings', 'ASL, BSL', 'HELLO', Icons.waving_hand_rounded, AppColors.cyan, favorite: true),
    _Sign('Love', 'Emotions', 'ASL', 'LOVE', Icons.favorite_rounded, AppColors.rose),
    _Sign('Thank You', 'Greetings', 'ASL, PSL', 'THANK YOU', Icons.star_rounded, AppColors.amber, favorite: true),
    _Sign('Peace', 'Emotions', 'ASL', 'PEACE', Icons.sentiment_satisfied_rounded, AppColors.violet),
    _Sign('Goodbye', 'Greetings', 'ASL, BSL', 'GOODBYE', Icons.back_hand_rounded, AppColors.emerald),
    _Sign('Help', 'Everyday', 'ASL', 'HELP', Icons.support_rounded, AppColors.cyan),
    _Sign('Yes', 'Everyday', 'ASL, BSL, PSL', 'YES', Icons.check_circle_rounded, AppColors.emerald),
    _Sign('No', 'Everyday', 'ASL, BSL, PSL', 'NO', Icons.cancel_rounded, AppColors.rose),
    _Sign('Mother', 'Family', 'ASL', 'MOTHER', Icons.person_rounded, AppColors.amber),
    _Sign('Father', 'Family', 'ASL', 'FATHER', Icons.person_2_rounded, AppColors.violet),
    _Sign('One', 'Numbers', 'ASL, BSL', '1', Icons.looks_one_rounded, AppColors.cyan),
    _Sign('Two', 'Numbers', 'ASL, BSL', '2', Icons.looks_two_rounded, AppColors.cyan),
    _Sign('Three', 'Numbers', 'ASL, BSL', '3', Icons.looks_3_rounded, AppColors.cyan),
    _Sign('Seven', 'Numbers', 'ASL, BSL', '7', Icons.filter_7_rounded, AppColors.cyan),
    _Sign('Ten', 'Numbers', 'ASL, BSL', '10', Icons.exposure_plus_1_rounded, AppColors.cyan),
  ];

  List<_Sign> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    var list = _signs;
    if (_filterIndex > 0) {
      final cat = _filters[_filterIndex];
      list = list.where((s) => s.category.toLowerCase().contains(cat.toLowerCase())).toList();
    }
    if (q.isNotEmpty) {
      list = list
          .where((s) =>
              s.word.toLowerCase().contains(q) ||
              s.signInput.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('2,400+ signs indexed',
                            style: AppTextStyles.caption()),
                        const SizedBox(height: 3),
                        Text('AI Dictionary',
                            style: AppTextStyles.heading(size: 22)),
                      ],
                    ),
                  ),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cyan.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: AppColors.cyan, size: 18),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        color: AppColors.text3, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        style: AppTextStyles.body(
                                color: AppColors.text1, size: 13),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Search signs, words…',
                          hintStyle: AppTextStyles.body(
                              color: AppColors.text4, size: 13),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text('⌘K',
                          style: AppTextStyles.caption()
                              .copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
              child: Row(
                children: _filters.asMap().entries.map((e) {
                  final on = e.key == _filterIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _filterIndex = e.key),
                    child: Container(
                      margin: const EdgeInsets.only(right: 7),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: on
                            ? const LinearGradient(colors: [
                                AppColors.cyan,
                                AppColors.violet,
                              ])
                            : null,
                        color: on ? null : AppColors.surface,
                        borderRadius: BorderRadius.circular(100),
                        border: on ? null : Border.all(color: AppColors.border),
                      ),
                      child: Text(e.value,
                          style: AppTextStyles.caption(
                                  color: on
                                      ? const Color(0xFF021015)
                                      : AppColors.text3)
                              .copyWith(fontWeight: FontWeight.w700)),
                    ),
                  );
                }).toList(),
              ),
            ),

            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final s = _filtered[i];
                  return _DictEntry(
                    sign: s,
                    isFirst: i == 0,
                    onTap: () {
                      context.read<UserProgressProvider>().recordDictionaryLookup();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TextToSignScreen(initialText: s.signInput),
                        ),
                      );
                    },
                    onFav: () {
                      setState(() => s.favorite = !s.favorite);
                      final saved = _signs.where((entry) => entry.favorite).length;
                      context.read<UserProgressProvider>().setSavedSignsCount(saved);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DictEntry extends StatelessWidget {
  final _Sign sign;
  final bool isFirst;
  final VoidCallback onTap;
  final VoidCallback onFav;

  const _DictEntry({
    required this.sign,
    required this.isFirst,
    required this.onTap,
    required this.onFav,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFirst ? sign.color.withOpacity(0.15) : AppColors.border2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: isFirst
                    ? sign.color.withOpacity(0.08)
                    : AppColors.surface2,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: isFirst
                      ? sign.color.withOpacity(0.2)
                      : AppColors.border,
                ),
              ),
              child: Icon(sign.icon, color: sign.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sign.word,
                      style: AppTextStyles.bodyMedium(color: AppColors.text1)
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${sign.category} · ',
                          style: AppTextStyles.caption(),
                        ),
                        TextSpan(
                          text: sign.langs,
                          style: AppTextStyles.caption(color: AppColors.cyan)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onFav,
              child: Icon(
                sign.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                color: sign.favorite ? AppColors.amber : AppColors.text3,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
