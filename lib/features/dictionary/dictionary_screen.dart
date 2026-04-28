import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../core/providers/progress_provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../translator/translator_hub_screen.dart';
import '../notifications/notifications_screen.dart';

class _Sign {
  final String word, category, langs, signInput;
  final IconData icon;
  final Color color;
  final String? videoPath;
  bool favorite;
  _Sign(this.word, this.category, this.langs, this.signInput, this.icon, this.color, {this.favorite = false, this.videoPath});
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
    _Sign('Hello', 'Greetings', 'ASL, BSL', 'HELLO', Icons.waving_hand_rounded, const Color(0xFF0891B2), favorite: true, videoPath: 'assets/signlanguage/Hello.mp4'),
    _Sign('Love', 'Emotions', 'ASL', 'LOVE', Icons.favorite_rounded, const Color(0xFFEF4444), videoPath: 'assets/signlanguage/LOVE.mp4'),
    // Numbers 0-9 (images available under assets/signlanguage/numbers)
    _Sign('Zero', 'Numbers', 'ASL, BSL', '0', Icons.looks_one_rounded, const Color(0xFF0891B2)),
    _Sign('One', 'Numbers', 'ASL, BSL', '1', Icons.looks_one_rounded, const Color(0xFF0891B2)),
    _Sign('Two', 'Numbers', 'ASL, BSL', '2', Icons.looks_two_rounded, const Color(0xFF0891B2)),
    _Sign('Three', 'Numbers', 'ASL, BSL', '3', Icons.looks_3_rounded, const Color(0xFF0891B2)),
    _Sign('Four', 'Numbers', 'ASL, BSL', '4', Icons.filter_4_rounded, const Color(0xFF0891B2)),
    _Sign('Five', 'Numbers', 'ASL, BSL', '5', Icons.filter_5_rounded, const Color(0xFF0891B2)),
    _Sign('Six', 'Numbers', 'ASL, BSL', '6', Icons.filter_6_rounded, const Color(0xFF0891B2)),
    _Sign('Seven', 'Numbers', 'ASL, BSL', '7', Icons.filter_7_rounded, const Color(0xFF0891B2)),
    _Sign('Eight', 'Numbers', 'ASL, BSL', '8', Icons.filter_8_rounded, const Color(0xFF0891B2)),
    _Sign('Nine', 'Numbers', 'ASL, BSL', '9', Icons.filter_9_rounded, const Color(0xFF0891B2)),
    // Additional video-backed signs found in assets
    _Sign('Dad', 'Family', 'ASL', 'DAD', Icons.person_rounded, const Color(0xFFF59E0B), videoPath: 'assets/signlanguage/DAD.mp4'),
    _Sign('Mom', 'Family', 'ASL', 'MOM', Icons.person_2_rounded, const Color(0xFF7C3AED), videoPath: 'assets/signlanguage/MOM.mp4'),
    _Sign('Home', 'Everyday', 'ASL', 'HOME', Icons.home_rounded, const Color(0xFF0891B2), videoPath: 'assets/signlanguage/home.mp4'),
    _Sign('Goodbye (Wave)', 'Greetings', 'ASL', 'GOODBYE', Icons.back_hand_rounded, const Color(0xFF10B981), videoPath: 'assets/signlanguage/WAVE-goodbye.mp4'),
    _Sign('Thank You', 'Greetings', 'ASL, PSL', 'THANK YOU', Icons.star_rounded, const Color(0xFFF59E0B), favorite: true, videoPath: 'assets/signlanguage/Thank You.mp4'),
    _Sign('No', 'Everyday', 'ASL, BSL, PSL', 'NO', Icons.cancel_rounded, const Color(0xFFEF4444), videoPath: 'assets/signlanguage/NO.mp4'),
    _Sign('Yes', 'Everyday', 'ASL, BSL, PSL', 'YES', Icons.check_circle_rounded, const Color(0xFF10B981), videoPath: 'assets/signlanguage/YES.mp4'),
  ];

  List<_Sign> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    var list = _signs;
    if (_filterIndex > 0) {
      final cat = _filters[_filterIndex];
      list = list.where((s) => s.category.toLowerCase().contains(cat.toLowerCase())).toList();
    }
    if (q.isNotEmpty) {
      list = list.where((s) => s.word.toLowerCase().contains(q) || s.signInput.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _showVideoDialog(BuildContext context, String videoPath) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: _VideoPlayer(videoPath: videoPath),
      ),
    );
  }

  void _showNumberDialog(BuildContext context, String digit) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: _NumberPreview(digit: digit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('2,400+ signs indexed', style: AppTextStyles.captionOf(context)),
                        const SizedBox(height: 3),
                        Text('Learning Hub', style: AppTextStyles.headingOf(context, size: 22)),
                      ],
                    ),
                  ),
                  Consumer<NotificationProvider>(
                    builder: (_, notes, __) {
                      final unread = notes.unreadCount;
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: isLight ? LightColors.primaryLight : AppColors.cyanDim.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(color: isLight ? LightColors.border : AppColors.border),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(Icons.notifications_none_rounded, color: primary, size: 18),
                              if (unread > 0)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                    child: Center(child: Text(unread > 9 ? '9+' : '$unread', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isLight ? LightColors.surface : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isLight ? LightColors.border : AppColors.border),
                  boxShadow: isLight ? const [BoxShadow(color: LightColors.shadow, blurRadius: 10, offset: Offset(0, 2))] : [],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: isLight ? LightColors.text3 : AppColors.text3, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        style: AppTextStyles.body(color: isLight ? LightColors.text1 : AppColors.text1, size: 13),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          border: InputBorder.none, enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true, contentPadding: EdgeInsets.zero,
                          hintText: 'Search signs, words…',
                          hintStyle: AppTextStyles.body(color: isLight ? LightColors.text4 : AppColors.text4, size: 13),
                        ),
                      ),
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
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filterIndex = e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: on ? primary : (isLight ? LightColors.surface : AppColors.surface),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: on ? primary : (isLight ? LightColors.border : AppColors.border)),
                          boxShadow: on ? [BoxShadow(color: primary.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 3))] : [],
                        ),
                        child: Text(e.value,
                            style: AppTextStyles.caption(color: on ? Colors.white : (isLight ? LightColors.text3 : AppColors.text3))
                                .copyWith(fontWeight: FontWeight.w700)),
                      ),
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
                    sign: s, isLight: isLight,
                      onTap: () {
                      if (s.category.toLowerCase() == 'numbers') {
                        context.read<UserProgressProvider>().recordDictionaryLookup();
                        _showNumberDialog(context, s.signInput);
                        return;
                      }

                      if (s.videoPath != null) {
                        context.read<UserProgressProvider>().recordDictionaryLookup();
                        _showVideoDialog(context, s.videoPath!);
                        return;
                      }

                      context.read<UserProgressProvider>().recordDictionaryLookup();
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => TranslatorHubScreen(initialMode: 1, initialText: s.signInput)));
                    },
                    onFav: () {
                      setState(() => s.favorite = !s.favorite);
                      final saved = _signs.where((e) => e.favorite).length;
                      context.read<UserProgressProvider>().setSavedSignsCount(saved);
                    },
                    onVideoPlay: s.videoPath != null ? () => _showVideoDialog(context, s.videoPath!) : null,
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
  final bool isLight;
  final VoidCallback onTap, onFav;
  final VoidCallback? onVideoPlay;
  const _DictEntry({required this.sign, required this.isLight, required this.onTap, required this.onFav, this.onVideoPlay});

  @override
  Widget build(BuildContext context) {
    final amber = isLight ? LightColors.amber : AppColors.amber;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: isLight ? LightColors.surface : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isLight ? LightColors.border : AppColors.border2),
          boxShadow: isLight ? const [BoxShadow(color: LightColors.shadow, blurRadius: 8, offset: Offset(0, 2))] : [],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: sign.color.withOpacity(0.06),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: sign.color.withOpacity(0.12)),
              ),
              child: sign.category.toLowerCase() == 'numbers'
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/signlanguage/${sign.signInput}.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(sign.icon, color: sign.color, size: 22),
                      ),
                    )
                  : Icon(sign.icon, color: sign.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sign.word,
                      style: AppTextStyles.bodyMedium(color: isLight ? LightColors.text1 : AppColors.text1)
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(text: '${sign.category} · ', style: AppTextStyles.captionOf(context)),
                      TextSpan(text: sign.langs,
                          style: AppTextStyles.caption(color: isLight ? LightColors.cyan : AppColors.cyan)
                              .copyWith(fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onFav,
              child: Icon(
                sign.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                color: sign.favorite ? amber : (isLight ? LightColors.text3 : AppColors.text3),
                size: 20,
              ),
            ),
            if (onVideoPlay != null) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onVideoPlay,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.play_circle_filled_rounded, color: AppColors.cyan, size: 18),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VideoPlayer extends StatefulWidget {
  final String videoPath;
  const _VideoPlayer({required this.videoPath});

  @override
  State<_VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<_VideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
            // Video player
            if (_controller.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            else
              const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator(color: AppColors.cyan)),
              ),
            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _controller.value.isPlaying ? _controller.pause() : _controller.play();
                      });
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.cyan,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _controller.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: AppColors.cyan,
                          backgroundColor: Colors.white24,
                          bufferedColor: Colors.white12,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(_controller.value.duration),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _NumberPreview extends StatefulWidget {
  final String digit;
  const _NumberPreview({required this.digit});

  @override
  State<_NumberPreview> createState() => _NumberPreviewState();
}

class _NumberPreviewState extends State<_NumberPreview> {
  String? _assetPath;
  bool _loading = true;

  static const _words = ['zero','one','two','three','four','five','six','seven','eight','nine'];

  @override
  void initState() {
    super.initState();
    _findAsset().then((p) {
      if (mounted) setState(() { _assetPath = p; _loading = false; });
    });
  }

  Future<String?> _tryLoad(String path) async {
    try {
      await DefaultAssetBundle.of(context).load(path);
      return path;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _findAsset() async {
    final d = widget.digit;
    final idx = int.tryParse(d);
    final word = (idx != null && idx >=0 && idx < _words.length) ? _words[idx] : d;
    final candidates = <String>[
      'assets/signlanguage/$d.jpg',
      'assets/signlanguage/$d.png',
      'assets/signlanguage/$d.webp',
      'assets/signlanguage/numbers/$d.jpg',
      'assets/signlanguage/numbers/$d.png',
      'assets/signlanguage/numbers/$d.webp',
      'assets/signlanguage/numbers/${d}_asl.jpg',
      'assets/signlanguage/numbers/${d}_asl.png',
      'assets/signlanguage/numbers/${d}_sign.jpg',
      'assets/signlanguage/numbers/${word.toLowerCase()}.jpg',
      'assets/signlanguage/numbers/${word.toLowerCase()}.png',
      'assets/signlanguage/${word.toLowerCase()}.jpg',
    ];

    for (final c in candidates) {
      final ok = await _tryLoad(c);
      if (ok != null) return ok;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close_rounded, color: AppColors.text2, size: 18),
              ),
            ),
            const SizedBox(height: 8),
            Text('Number ${widget.digit}', style: AppTextStyles.heading(size: 18)),
            const SizedBox(height: 14),
            if (_loading)
              const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()))
            else if (_assetPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(_assetPath!, fit: BoxFit.contain),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  alignment: Alignment.center,
                  color: AppColors.surface2,
                  child: Text(widget.digit, style: AppTextStyles.display().copyWith(fontSize: 44)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
