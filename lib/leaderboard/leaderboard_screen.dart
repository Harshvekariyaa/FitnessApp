import 'package:fitnessai/api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';

// ─── Shimmer primitive ────────────────────────────────────────────────────────
class _Shimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  final bool circle;

  const _Shimmer({
    required this.width,
    required this.height,
    this.radius = 10,
    this.circle = false,
  });

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius:
          widget.circle ? null : BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(-1.5 + _anim.value * 3, 0),
            end: Alignment(-0.5 + _anim.value * 3, 0),
            colors: [
              Colors.grey.shade300,
              Colors.grey.shade200,
              Colors.grey.shade300,
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Full-screen skeleton matching LeaderboardScreen layout ──────────────────
class _LeaderboardSkeleton extends StatelessWidget {
  const _LeaderboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // ── Hero header skeleton ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Column(
              children: [
                // Crown placeholder
                const _Shimmer(width: 28, height: 28, radius: 6),
                const SizedBox(height: 10),
                // Avatar
                const _Shimmer(width: 94, height: 94, radius: 47, circle: true),
                const SizedBox(height: 12),
                // Name
                const _Shimmer(width: 140, height: 18, radius: 6),
                const SizedBox(height: 8),
                // City
                const _Shimmer(width: 90, height: 13, radius: 5),
                const SizedBox(height: 12),
                // Badge pill
                const _Shimmer(width: 180, height: 32, radius: 30),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Stat tiles skeleton ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(3, (i) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        children: const [
                          _Shimmer(
                              width: 34, height: 34, radius: 17, circle: true),
                          SizedBox(height: 7),
                          _Shimmer(width: 50, height: 14, radius: 5),
                          SizedBox(height: 4),
                          _Shimmer(width: 40, height: 11, radius: 4),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 28),

          // ── Podium skeleton ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Shimmer(width: 160, height: 18, radius: 6),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _podiumBarSkeleton(height: 90, avatarRadius: 22),
                      _podiumBarSkeleton(height: 130, avatarRadius: 30, isWinner: true),
                      _podiumBarSkeleton(height: 70, avatarRadius: 22),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Rankings list skeleton ────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 30),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _Shimmer(width: 100, height: 18, radius: 6),
                    _Shimmer(width: 70, height: 26, radius: 10),
                  ],
                ),
                const SizedBox(height: 16),
                ...List.generate(8, (_) => _rankRowSkeleton()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _podiumBarSkeleton(
      {required double height,
        required double avatarRadius,
        bool isWinner = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isWinner) ...[
          const _Shimmer(width: 24, height: 20, radius: 4),
          const SizedBox(height: 4),
        ],
        _Shimmer(
            width: avatarRadius * 2,
            height: avatarRadius * 2,
            radius: avatarRadius,
            circle: true),
        const SizedBox(height: 6),
        const _Shimmer(width: 60, height: 12, radius: 5),
        const SizedBox(height: 4),
        const _Shimmer(width: 40, height: 11, radius: 4),
        const SizedBox(height: 6),
        _Shimmer(
            width: isWinner ? 70 : 58, height: height, radius: 10),
      ],
    );
  }

  Widget _rankRowSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Rank badge
          const _Shimmer(width: 32, height: 32, radius: 8),
          const SizedBox(width: 10),
          // Avatar
          const _Shimmer(
              width: 44, height: 44, radius: 22, circle: true),
          const SizedBox(width: 12),
          // Name + XP
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _Shimmer(width: 110, height: 13, radius: 5),
                SizedBox(height: 5),
                _Shimmer(width: 80, height: 11, radius: 4),
              ],
            ),
          ),
          // Badge
          Column(
            children: const [
              _Shimmer(width: 22, height: 22, radius: 4),
              SizedBox(height: 3),
              _Shimmer(width: 36, height: 10, radius: 4),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── LeaderboardScreen ────────────────────────────────────────────────────────
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List leaderboard = [];
  bool isLoading = true;

  String name = "";
  String badge = "";
  String rank = "";
  String xp = "";
  String img = "";
  String city = "";
  String gender = "";

  @override
  void initState() {
    super.initState();
    _refreshPage();
  }

  Future<void> loadProfile() async {
    final data = await UserApiService.getUserProfile();
    name   = data!["user_name"] ?? "";
    xp     = data["user_xp_points"].toString();
    badge  = data["badge"] ?? "";
    rank   = data["rank"].toString();
    img    = data["user_image_url"].toString();
    city   = data["user_city"] ?? "";
    gender = data["user_gender"] ?? "";
  }

  Future<void> _refreshPage() async {
    setState(() => isLoading = true);
    await Future.wait([loadLeaderboard(), loadProfile()]);
    setState(() => isLoading = false);
  }

  Future<void> loadLeaderboard() async {
    leaderboard = await UserApiService.getLeaderBoard();
  }

  Color _getBadgeColor(String badge) {
    switch (badge.trim().toLowerCase()) {
      case "diamond":  return const Color(0xFF6A1B9A);
      case "platinum": return Colors.blueAccent;
      case "gold":     return const Color(0xFFFFB300);
      case "silver":   return const Color(0xFF9E9E9E);
      case "bronze":   return const Color(0xFFCD7F32);
      default:         return Colors.white54;
    }
  }

  IconData _getBadgeIcon(String badge) {
    switch (badge.trim().toLowerCase()) {
      case "diamond":  return Icons.diamond;
      case "platinum": return Icons.star;
      case "gold":     return Icons.emoji_events;
      case "silver":   return Icons.workspace_premium;
      case "bronze":   return Icons.military_tech;
      default:         return Icons.workspace_premium;
    }
  }

  String _getRankEmoji(int index) {
    switch (index) {
      case 0: return "🥇";
      case 1: return "🥈";
      case 2: return "🥉";
      default: return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final top1 = leaderboard.length > 0 ? leaderboard[0] : null;
    final top2 = leaderboard.length > 1 ? leaderboard[1] : null;
    final top3 = leaderboard.length > 2 ? leaderboard[2] : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: commonAppBar("Leaderboard"),
      body: isLoading
          ? const _LeaderboardSkeleton()   // ← was CircularProgressIndicator
          : RefreshIndicator(
        onRefresh: _refreshPage,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ===== HERO HEADER =====
              _buildHeroHeader(),

              const SizedBox(height: 20),

              // ===== QUICK STATS =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _StatTile(
                        icon: Icons.flash_on_rounded,
                        label: "XP Points",
                        value: xp,
                        color: Colors.orange),
                    const SizedBox(width: 10),
                    _StatTile(
                        icon: Icons.leaderboard_rounded,
                        label: "Rank",
                        value: "#$rank",
                        color: AppColors.primary),
                    const SizedBox(width: 10),
                    _StatTile(
                        icon: _getBadgeIcon(badge),
                        label: "League",
                        value: badge,
                        color: _getBadgeColor(badge)),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ===== PODIUM =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.emoji_events_rounded,
                            color: Color(0xFFFFB300), size: 20),
                        const SizedBox(width: 6),
                        Text("Top Performers",
                            style: textStyle(
                                AppColors.black, 18, AppColors.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding:
                      const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.08),
                            Colors.transparent
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color:
                            AppColors.primary.withOpacity(0.12)),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (top2 != null)
                            _PodiumCard(
                                rank: 2,
                                height: 90,
                                name: top2['user_name'],
                                badge: top2['badge'],
                                badgeColor:
                                _getBadgeColor(top2['badge']),
                                xp: top2['user_xp_points'].toString(),
                                imageUrl: top2['user_image_url']),
                          if (top1 != null)
                            _PodiumCard(
                                rank: 1,
                                height: 130,
                                isWinner: true,
                                name: top1['user_name'],
                                badge: top1['badge'],
                                badgeColor:
                                _getBadgeColor(top1['badge']),
                                xp: top1['user_xp_points'].toString(),
                                imageUrl: top1['user_image_url']),
                          if (top3 != null)
                            _PodiumCard(
                                rank: 3,
                                height: 70,
                                name: top3['user_name'],
                                badge: top3['badge'],
                                badgeColor:
                                _getBadgeColor(top3['badge']),
                                xp: top3['user_xp_points'].toString(),
                                imageUrl: top3['user_image_url']),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ===== LEADERBOARD LIST =====
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.fromLTRB(16, 24, 16, 30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Rankings",
                            style: textStyle(
                                AppColors.black, 18, AppColors.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                            AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${leaderboard.length} players",
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      itemCount: leaderboard.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final user = leaderboard[index];
                        final isTop3 = index < 3;
                        final isCurrentUser =
                            user['user_name'] == name;

                        return Container(
                          margin:
                          const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? AppColors.primary.withOpacity(0.07)
                                : isTop3
                                ? const Color(0xFFFFFBF0)
                                : const Color(0xFFF9FAFB),
                            borderRadius:
                            BorderRadius.circular(16),
                            border: Border.all(
                              color: isCurrentUser
                                  ? AppColors.primary
                                  .withOpacity(0.3)
                                  : isTop3
                                  ? const Color(0xFFFFB300)
                                  .withOpacity(0.3)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 36,
                                child: isTop3
                                    ? Text(
                                  _getRankEmoji(index),
                                  style: const TextStyle(
                                      fontSize: 22),
                                  textAlign: TextAlign.center,
                                )
                                    : Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                        0xFFEEF0F4),
                                    borderRadius:
                                    BorderRadius.circular(
                                        8),
                                  ),
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                        FontWeight.bold,
                                        color: Colors.black54),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              CircleAvatar(
                                radius: 22,
                                backgroundImage: (user[
                                'user_image_url'] !=
                                    null &&
                                    user['user_image_url']
                                        .toString()
                                        .isNotEmpty)
                                    ? NetworkImage(
                                    user['user_image_url'])
                                    : const AssetImage(
                                    "assets/images/r3.jpeg")
                                as ImageProvider,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            user['user_name'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                              FontWeight.bold,
                                              color: isCurrentUser
                                                  ? AppColors.primary
                                                  : Colors.black87,
                                            ),
                                            overflow:
                                            TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isCurrentUser) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius:
                                              BorderRadius.circular(
                                                  6),
                                            ),
                                            child: const Text("You",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white,
                                                    fontWeight:
                                                    FontWeight.w600)),
                                          ),
                                        ]
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Icon(
                                            Icons.flash_on_rounded,
                                            size: 12,
                                            color: Colors
                                                .orange.shade400),
                                        const SizedBox(width: 2),
                                        Text(
                                          "${user['user_xp_points']} XP",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors
                                                  .grey.shade500),
                                        ),
                                        if (user['user_city'] !=
                                            null &&
                                            user['user_city']
                                                .toString()
                                                .isNotEmpty) ...[
                                          Text("  •  ",
                                              style: TextStyle(
                                                  color: Colors
                                                      .grey.shade400,
                                                  fontSize: 12)),
                                          Icon(
                                              Icons
                                                  .location_on_outlined,
                                              size: 12,
                                              color: Colors
                                                  .grey.shade400),
                                          const SizedBox(width: 2),
                                          Text(
                                            user['user_city'],
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors
                                                    .grey.shade500),
                                            overflow:
                                            TextOverflow.ellipsis,
                                          ),
                                        ]
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Icon(
                                    _getBadgeIcon(user['badge']),
                                    color: _getBadgeColor(
                                        user['badge']),
                                    size: 22,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user['badge'],
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: _getBadgeColor(
                                            user['badge']),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.powerOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
              right: -10,
              top: -10,
              child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.07)))),
          Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05)))),
          Column(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: Color(0xFFFFD700), size: 28),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8)
                  ],
                ),
                child: CircleAvatar(
                  radius: 44,
                  backgroundImage: img.isNotEmpty
                      ? NetworkImage(img) as ImageProvider
                      : const AssetImage("assets/images/r3.jpeg"),
                ),
              ),
              const SizedBox(height: 12),
              Text(name,
                  style: textStyle(AppColors.white, 22, AppColors.bold)),
              const SizedBox(height: 4),
              if (city.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 13, color: Colors.white70),
                    const SizedBox(width: 3),
                    Text(city,
                        style: textStyle(
                            AppColors.white70, 13, AppColors.normal)),
                  ],
                ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(30),
                  border:
                  Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getBadgeIcon(badge),
                        color: _getBadgeColor(badge), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "$badge League  •  Rank #$rank",
                      style: textStyle(
                          AppColors.white, 13, AppColors.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== STAT TILE =====
class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 7),
            Text(value,
                style: textStyle(AppColors.black, 14, AppColors.bold),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label,
                style: textStyle(AppColors.grey, 11, AppColors.normal)),
          ],
        ),
      ),
    );
  }
}

// ===== PODIUM CARD =====
class _PodiumCard extends StatelessWidget {
  final int rank;
  final double height;
  final bool isWinner;
  final String name;
  final String badge;
  final Color badgeColor;
  final String xp;
  final String? imageUrl;

  const _PodiumCard({
    required this.rank,
    required this.height,
    this.isWinner = false,
    required this.name,
    required this.badge,
    required this.badgeColor,
    required this.xp,
    this.imageUrl,
  });

  Color get _podiumColor {
    switch (rank) {
      case 1: return const Color(0xFFFFB300);
      case 2: return const Color(0xFF9E9E9E);
      case 3: return const Color(0xFFCD7F32);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarRadius = isWinner ? 30.0 : 22.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isWinner) ...[
          const Text("👑", style: TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
        ],
        Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _podiumColor, width: 2.5),
          ),
          child: CircleAvatar(
            radius: avatarRadius,
            backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
                ? NetworkImage(imageUrl!) as ImageProvider
                : const AssetImage("assets/images/r3.jpeg"),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 75,
          child: Text(
            name,
            style: textStyle(
                AppColors.black, isWinner ? 13 : 12, AppColors.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flash_on_rounded, color: Colors.orange, size: 11),
            Text(xp,
                style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: isWinner ? 70 : 58,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _podiumColor.withOpacity(0.7),
                _podiumColor.withOpacity(0.25)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Center(
            child: Text(
              "#$rank",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isWinner ? 16 : 13),
            ),
          ),
        ),
      ],
    );
  }
}