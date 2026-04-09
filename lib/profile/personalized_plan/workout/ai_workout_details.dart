import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:fitnessai/api/api_service.dart';
import 'package:fitnessai/workout/ai_exercise_screen.dart';
import 'package:flutter/material.dart';

import '../../../workout/exercise_detailed_screen.dart';
import '../../../workout/exercise_screen.dart'; // adjust path as needed

// ── Design Tokens ──────────────────────────────────────────────────────────
const _textDark  = Color(0xFF1A2340);
const _textMid   = Color(0xFF4A5568);
const _textSoft  = Color(0xFF94A3B8);
const _border    = Color(0xFFE2E8F0);
const _cardWhite = Colors.white;

class AiWorkoutDetails extends StatefulWidget {
  final int    workoutId;
  final String name;
  final String goal;
  final String focus;
  final int    duration;
  final String difficulty;
  final String bodyType;
  final String createdAt;

  const AiWorkoutDetails({
    super.key,
    required this.workoutId,
    required this.name,
    required this.goal,
    required this.focus,
    required this.duration,
    required this.difficulty,
    required this.bodyType,
    required this.createdAt,
  });

  @override
  State<AiWorkoutDetails> createState() => _AiWorkoutDetailsState();
}

class _AiWorkoutDetailsState extends State<AiWorkoutDetails>
    with SingleTickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _exercisesFuture;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  bool _isStartingWorkout = false;
  bool _isCardExpanded = true;

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _fmtDate(String raw) {
    try {
      final dt = DateTime.parse(raw.replaceFirst(' ', 'T'));
      const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${m[dt.month]} ${dt.day}, ${dt.year}';
    } catch (_) { return raw; }
  }

  Color _diffColor(String d) {
    switch (d.toLowerCase()) {
      case 'beginner':     return const Color(0xFF2E7D32);
      case 'intermediate': return const Color(0xFFE65100);
      case 'advanced':     return const Color(0xFFC62828);
      default:             return _textSoft;
    }
  }

  IconData _diffIcon(String d) {
    switch (d.toLowerCase()) {
      case 'beginner':     return Icons.signal_cellular_alt_1_bar_rounded;
      case 'intermediate': return Icons.signal_cellular_alt_2_bar_rounded;
      case 'advanced':     return Icons.signal_cellular_alt_rounded;
      default:             return Icons.signal_cellular_alt_1_bar_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    _exercisesFuture = UserApiService.getResumeWorkout(widget.workoutId);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────
  // START WORKOUT LOGIC
  // ──────────────────────────────────────────────────────────
  Future<void> _handleStartWorkout() async {
    setState(() => _isStartingWorkout = true);

    try {
      final sessionResponse =
      await UserApiService.starAitWorkout(widget.workoutId);

      final sessionId = sessionResponse['data']['session_id'] as String;

      final exercisesData =
      await UserApiService.fetchAiWorkoutExercises(widget.workoutId);

      // ✅ FIX: exercisesData is already a List
      final exercises = (exercisesData as List<dynamic>).map((e) {
        final item = Map<String, dynamic>.from(e as Map);

        item['is_completed'] = 0;
        item['sets_completed'] = 0;
        item['reps_completed'] = 0;

        // ⚠️ Important: don't overwrite duration if API already provides it
        item['exercise_duration_sec'] =
            item['exercise_duration_sec'] ?? 0;

        return item;
      }).toList();

      if (!mounted) return;

      print("-------");
      print(exercises);
      print(sessionId);
      print(widget.workoutId);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AiExerciseScreen(
            sessionId: sessionId,
            aiWorkoutId: widget.workoutId,
            exercises: exercises,
            startIndex: 0,
          ),
        ),
      ).then((_) {
        if (mounted) setState(() => _isStartingWorkout = false);
      });


    } catch (e) {
      if (mounted) {
        setState(() => _isStartingWorkout = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to start workout: $e"),
            backgroundColor: const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar("AI Workout Details"),
      backgroundColor: AppColors.scaffoldBackground,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _exercisesFuture,
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) return _loader();
            if (snap.hasError) return _error();
            final list = snap.data ?? [];
            if (list.isEmpty) return _empty();
            return _content(list);
          },
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // MAIN CONTENT
  // ──────────────────────────────────────────────────────────
  Widget _content(List<Map<String, dynamic>> exercises) {
    final totalCal  = exercises.fold<int>(0, (s, e) =>
    s + ((e['exercise_calories_burn'] as num?)?.toInt() ?? 0));
    final totalSets = exercises.fold<int>(0, (s, e) =>
    s + ((e['exercise_sets'] as num?)?.toInt() ?? 0));
    final totalXp   = exercises.fold<int>(0, (s, e) =>
    s + ((e['exercise_xp'] as num?)?.toInt() ?? 0));

    return Stack(
      children: [
        // Background subtle decoration
        Positioned(
          top: -60, right: -60,
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.04),
            ),
          ),
        ),
        Positioned(
          top: 120, left: -40,
          child: Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.03),
            ),
          ),
        ),

        Column(
          children: [
            _heroInfoCard(
              exerciseCount: exercises.length,
              totalCal: totalCal,
              totalSets: totalSets,
              totalXp: totalXp,
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                physics: const BouncingScrollPhysics(),
                itemCount: exercises.length,
                itemBuilder: (_, i) => _animatedCard(exercises[i], i),
              ),
            ),
          ],
        ),

        // Floating Start Button
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: _floatingStartButton(),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────
  // HERO INFO CARD  (collapsible)
  // ──────────────────────────────────────────────────────────
  Widget _heroInfoCard({
    required int exerciseCount,
    required int totalCal,
    required int totalSets,
    required int totalXp,
  }) {
    final diffColor = _diffColor(widget.difficulty);

    return GestureDetector(
      onTap: () => setState(() => _isCardExpanded = !_isCardExpanded),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        decoration: BoxDecoration(
          color: _cardWhite,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _border.withOpacity(0.8)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative accent (only visible when expanded)
            if (_isCardExpanded)
              Positioned(
                top: 0, right: 0,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(22),
                      bottomLeft: Radius.circular(60),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.08),
                        AppColors.primary.withOpacity(0.03),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Always-visible header row ──
                  Row(
                    children: [
                      // Goal pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome_rounded,
                                color: Colors.white, size: 10),
                            const SizedBox(width: 4),
                            Text(
                              _cap(widget.goal).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Difficulty badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: diffColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: diffColor.withOpacity(0.3), width: 1),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(_diffIcon(widget.difficulty),
                              color: diffColor, size: 11),
                          const SizedBox(width: 4),
                          Text(
                            _cap(widget.difficulty),
                            style: TextStyle(
                              color: diffColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ]),
                      ),

                      const Spacer(),

                      // Chevron toggle
                      AnimatedRotation(
                        turns: _isCardExpanded ? 0.0 : -0.5,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_up_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Always visible: name + meta tags ──
                  const SizedBox(height: 10),

                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Wrap(spacing: 6, runSpacing: 6, children: [
                    _metaTag(Icons.center_focus_strong_rounded,
                        _cap(widget.focus), AppColors.primary),
                    _metaTag(Icons.accessibility_new_rounded,
                        _cap(widget.bodyType), _textMid),
                    _metaTag(Icons.calendar_today_rounded,
                        _fmtDate(widget.createdAt), _textSoft),
                  ]),

                  // ── Collapsible: stats only ──
                  AnimatedCrossFade(
                    firstChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Stats divider
                        Row(children: [
                          Expanded(child: Divider(color: _border, height: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('STATS', style: TextStyle(
                              color: _textSoft, fontSize: 9,
                              fontWeight: FontWeight.w800, letterSpacing: 1.5,
                            )),
                          ),
                          Expanded(child: Divider(color: _border, height: 1)),
                        ]),

                        const SizedBox(height: 14),

                        // Stats tiles
                        Row(children: [
                          _statTile(Icons.timer_outlined,
                              '${widget.duration}', 'min'),
                          _vertDivider(),
                          _statTile(Icons.fitness_center_rounded,
                              '$exerciseCount', 'exr'),
                          _vertDivider(),
                          _statTile(Icons.repeat_rounded,
                              '$totalSets', 'sets'),
                          _vertDivider(),
                          _statTile(Icons.local_fire_department_outlined,
                              '$totalCal', 'kcal'),
                          _vertDivider(),
                          _statTile(Icons.star_rounded, '$totalXp', 'xp'),
                        ]),
                      ],
                    ),
                    secondChild: const SizedBox(width: double.infinity),
                    crossFadeState: _isCardExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 300),
                    sizeCurve: Curves.easeInOut,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaTag(IconData icon, String label, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w700,
          )),
        ]),
      );

  Widget _statTile(IconData icon, String value, String unit) => Expanded(
    child: Column(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 15, color: AppColors.primary),
      ),
      const SizedBox(height: 5),
      Text(value, style: const TextStyle(
        color: _textDark, fontSize: 14, fontWeight: FontWeight.w900,
      )),
      Text(unit, style: const TextStyle(
        color: _textSoft, fontSize: 9, fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      )),
    ]),
  );

  Widget _vertDivider() => Container(
    width: 1, height: 44, color: _border,
  );

  // ──────────────────────────────────────────────────────────
  // ANIMATED EXERCISE CARD WRAPPER
  // ──────────────────────────────────────────────────────────
  Widget _animatedCard(Map<String, dynamic> e, int i) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + i * 80),
      curve: Curves.easeOutCubic,
      builder: (_, val, child) => Transform.translate(
        offset: Offset(0, 20 * (1 - val)),
        child: Opacity(opacity: val, child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExerciseDetailScreen(
                exeId: e['exercise_id'],
              ),
            ),
          ),
          child: _exerciseCard(e, i),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // EXERCISE CARD
  // ──────────────────────────────────────────────────────────
  Widget _exerciseCard(Map<String, dynamic> e, int index) {
    final name        = e['exercise_name']          ?? '';
    final sets        = (e['exercise_sets']          as num?)?.toInt() ?? 0;
    final reps        = (e['exercise_reps']          as num?)?.toInt() ?? 0;
    final durationSec = (e['exercise_duration_sec']  as num?)?.toInt() ?? 0;
    final xp          = (e['exercise_xp']            as num?)?.toInt() ?? 0;
    final cal         = (e['exercise_calories_burn'] as num?)?.toInt() ?? 0;
    final desc        = e['exercise_description']    ?? '';
    final gifUrl      = e['exercise_gif_full_url']   ?? '';
    final order       = (e['exercise_order']         as num?)?.toInt() ?? (index + 1);
    final isTime      = durationSec > 0;

    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GIF thumbnail with order badge
          Stack(
            children: [
              Container(
                width: 95, height: 110,
                color: Colors.white,
                child: gifUrl.isNotEmpty
                    ? Image.network(
                  gifUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
                    : _placeholder(),
              ),
              Positioned(
                top: 7, left: 7,
                child: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$order',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Info section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textSoft,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  Wrap(spacing: 5, runSpacing: 5, children: [
                    _chip('$sets sets', Icons.repeat_rounded,
                        AppColors.primary),
                    if (isTime)
                      _chip('${durationSec}s', Icons.timer_outlined,
                          const Color(0xFF7C3AED))
                    else if (reps > 0)
                      _chip('$reps reps', Icons.fitness_center_rounded,
                          const Color(0xFF7C3AED)),
                    _chip('$cal kcal',
                        Icons.local_fire_department_outlined,
                        const Color(0xFFEA580C)),
                    _chip('+$xp XP', Icons.star_rounded,
                        const Color(0xFFD97706)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, IconData icon, Color accent) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: accent.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: accent.withOpacity(0.2)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 10, color: accent),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(
        color: accent, fontSize: 10, fontWeight: FontWeight.w700,
      )),
    ]),
  );

  Widget _placeholder() => Center(
    child: Icon(Icons.fitness_center_rounded,
        color: _textSoft.withOpacity(0.5), size: 22),
  );

  // ──────────────────────────────────────────────────────────
  // FLOATING START BUTTON
  // ──────────────────────────────────────────────────────────
  Widget _floatingStartButton() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.scaffoldBackground.withOpacity(0.0),
          AppColors.scaffoldBackground,
          AppColors.scaffoldBackground,
        ],
      ),
    ),
    child: GestureDetector(
      onTap: _isStartingWorkout ? null : _handleStartWorkout,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _isStartingWorkout
                  ? AppColors.primary.withOpacity(0.6)
                  : AppColors.primary,
              _isStartingWorkout
                  ? AppColors.primary.withOpacity(0.5)
                  : AppColors.primary.withOpacity(0.85),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary
                  .withOpacity(_isStartingWorkout ? 0.15 : 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isStartingWorkout) ...[
              SizedBox(
                width: 20, height: 20,
                child: buildLoader(),
              ),
              const SizedBox(width: 12),
              const Text(
                'Starting…',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ] else ...[
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Start Workout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );

  // ──────────────────────────────────────────────────────────
  // STATE SCREENS
  // ──────────────────────────────────────────────────────────
  Widget _loader() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
        width: 48, height: 48,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: AppColors.primary,
          backgroundColor: AppColors.primary.withOpacity(0.1),
        ),
      ),
      const SizedBox(height: 20),
      Text('Loading exercises…',
          style: TextStyle(
            color: _textMid, fontSize: 13, fontWeight: FontWeight.w600,
          )),
    ]),
  );

  Widget _error() => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.cloud_off_rounded,
              color: Color(0xFFC62828), size: 34),
        ),
        const SizedBox(height: 20),
        const Text('Could not load exercises',
            style: TextStyle(color: _textDark, fontSize: 16,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Check your connection and try again',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textSoft, fontSize: 12, height: 1.5)),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => setState(() {
            _exercisesFuture =
                UserApiService.getResumeWorkout(widget.workoutId);
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text('Retry',
                style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ),
      ]),
    ),
  );

  Widget _empty() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.fitness_center_rounded,
            color: AppColors.primary.withOpacity(0.4), size: 34),
      ),
      const SizedBox(height: 20),
      const Text('No exercises found',
          style: TextStyle(color: _textDark, fontSize: 16,
              fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      const Text('This workout has no exercises yet',
          style: TextStyle(color: _textSoft, fontSize: 12)),
    ]),
  );
}