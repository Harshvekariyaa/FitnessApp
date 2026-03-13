import 'package:fitnessai/api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';

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
          ? const Center(child: CircularProgressIndicator())
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
                    _StatTile(icon: Icons.flash_on_rounded, label: "XP Points", value: xp, color: Colors.orange),
                    const SizedBox(width: 10),
                    _StatTile(icon: Icons.leaderboard_rounded, label: "Rank", value: "#$rank", color: AppColors.primary),
                    const SizedBox(width: 10),
                    _StatTile(icon: _getBadgeIcon(badge), label: "League", value: badge, color: _getBadgeColor(badge)),
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
                        const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFB300), size: 20),
                        const SizedBox(width: 6),
                        Text("Top Performers",
                            style: textStyle(AppColors.black, 18, AppColors.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary.withOpacity(0.08), Colors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (top2 != null)
                            _PodiumCard(rank: 2, height: 90, name: top2['user_name'], badge: top2['badge'], badgeColor: _getBadgeColor(top2['badge']), xp: top2['user_xp_points'].toString(), imageUrl: top2['user_image_url']),
                          if (top1 != null)
                            _PodiumCard(rank: 1, height: 130, isWinner: true, name: top1['user_name'], badge: top1['badge'], badgeColor: _getBadgeColor(top1['badge']), xp: top1['user_xp_points'].toString(), imageUrl: top1['user_image_url']),
                          if (top3 != null)
                            _PodiumCard(rank: 3, height: 70, name: top3['user_name'], badge: top3['badge'], badgeColor: _getBadgeColor(top3['badge']), xp: top3['user_xp_points'].toString(), imageUrl: top3['user_image_url']),
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
                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Rankings", style: textStyle(AppColors.black, 18, AppColors.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${leaderboard.length} players",
                            style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
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
                        final isCurrentUser = user['user_name'] == name;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? AppColors.primary.withOpacity(0.07)
                                : isTop3
                                ? const Color(0xFFFFFBF0)
                                : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isCurrentUser
                                  ? AppColors.primary.withOpacity(0.3)
                                  : isTop3
                                  ? const Color(0xFFFFB300).withOpacity(0.3)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Rank badge
                              SizedBox(
                                width: 36,
                                child: isTop3
                                    ? Text(
                                  _getRankEmoji(index),
                                  style: const TextStyle(fontSize: 22),
                                  textAlign: TextAlign.center,
                                )
                                    : Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF0F4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Avatar
                              CircleAvatar(
                                radius: 22,
                                backgroundImage: (user['user_image_url'] != null &&
                                    user['user_image_url'].toString().isNotEmpty)
                                    ? NetworkImage(user['user_image_url'])
                                    : const AssetImage("assets/images/r3.jpeg") as ImageProvider,
                              ),
                              const SizedBox(width: 12),

                              // Name + city
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            user['user_name'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isCurrentUser ? AppColors.primary : Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isCurrentUser) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text("You",
                                                style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                                          ),
                                        ]
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Icon(Icons.flash_on_rounded, size: 12, color: Colors.orange.shade400),
                                        const SizedBox(width: 2),
                                        Text(
                                          "${user['user_xp_points']} XP",
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                        ),
                                        if (user['user_city'] != null && user['user_city'].toString().isNotEmpty) ...[
                                          Text("  •  ", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                                          Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade400),
                                          const SizedBox(width: 2),
                                          Text(
                                            user['user_city'],
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ]
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Badge
                              Column(
                                children: [
                                  Icon(
                                    _getBadgeIcon(user['badge']),
                                    color: _getBadgeColor(user['badge']),
                                    size: 22,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user['badge'],
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: _getBadgeColor(user['badge']),
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
          // Decorative circles
          Positioned(right: -10, top: -10,
              child: Container(width: 100, height: 100,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.07)))),
          Positioned(left: -20, bottom: -20,
              child: Container(width: 80, height: 80,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)))),

          Column(
            children: [
              // Crown icon above avatar
              const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 28),
              const SizedBox(height: 6),

              // Avatar
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
                ),
                child: CircleAvatar(
                  radius: 44,
                  backgroundImage: img.isNotEmpty
                      ? NetworkImage(img) as ImageProvider
                      : const AssetImage("assets/images/r3.jpeg"),
                ),
              ),
              const SizedBox(height: 12),

              Text(name, style: textStyle(AppColors.white, 22, AppColors.bold)),
              const SizedBox(height: 4),

              if (city.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_outlined, size: 13, color: Colors.white70),
                    const SizedBox(width: 3),
                    Text(city, style: textStyle(AppColors.white70, 13, AppColors.normal)),
                  ],
                ),
              const SizedBox(height: 10),

              // Badge + Rank pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getBadgeIcon(badge), color: _getBadgeColor(badge), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "$badge League  •  Rank #$rank",
                      style: textStyle(AppColors.white, 13, AppColors.w600),
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

  const _StatTile({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
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
            Text(value, style: textStyle(AppColors.black, 14, AppColors.bold), overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label, style: textStyle(AppColors.grey, 11, AppColors.normal)),
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
        // Crown for winner
        if (isWinner)
          const Text("👑", style: TextStyle(fontSize: 20)),
        if (isWinner) const SizedBox(height: 4),

        // Avatar
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

        // Name
        SizedBox(
          width: 75,
          child: Text(
            name,
            style: textStyle(AppColors.black, isWinner ? 13 : 12, AppColors.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 3),

        // XP
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flash_on_rounded, color: Colors.orange, size: 11),
            Text(xp, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 6),

        // Podium bar
        Container(
          width: isWinner ? 70 : 58,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_podiumColor.withOpacity(0.7), _podiumColor.withOpacity(0.25)],
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