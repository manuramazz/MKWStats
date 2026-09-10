import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_footer.dart';
import '../../data/models/build_type.dart';
import '../../data/models/personal_time.dart';
import '../../data/models/profile.dart';
import '../../data/models/track.dart';
import '../../data/models/world_record.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/personal_times_repository.dart';
import '../../data/repositories/tracks_repository.dart';
import '../../data/repositories/world_records_repository.dart';
import '../../data/supabase_client.dart';
import '../home/widgets/combo_toggle.dart';
import 'widgets/collapsible_section.dart';
import 'widgets/my_times_table.dart';
import 'widgets/progression_chart.dart';
import 'widgets/track_header.dart';
import 'widgets/track_stats_row.dart';
import 'widgets/wr_build_strip.dart';
import 'widgets/wr_video_player.dart';

class TrackDetailScreen extends StatefulWidget {
  final int trackId;
  final BuildType initialBuildType;

  const TrackDetailScreen({
    super.key,
    required this.trackId,
    required this.initialBuildType,
  });

  @override
  State<TrackDetailScreen> createState() => _TrackDetailScreenState();
}

class _TrackDetailScreenState extends State<TrackDetailScreen> {
  final _tracksRepository = TracksRepository();
  final _worldRecordsRepository = WorldRecordsRepository();
  final _personalTimesRepository = PersonalTimesRepository();
  final _authRepository = AuthRepository();

  late BuildType _buildType;
  bool _isLoading = true;
  Track? _track;
  WorldRecord? _worldRecord;
  List<PersonalTime> _personalTimes = [];
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _buildType = widget.initialBuildType;
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      _tracksRepository.fetchById(widget.trackId),
      _worldRecordsRepository.fetchByTrackId(widget.trackId),
      _authRepository.fetchCurrentProfile(),
    ]);
    await _loadPersonalTimes();
    if (!mounted) return;
    setState(() {
      _track = results[0] as Track;
      _worldRecord = results[1] as WorldRecord?;
      _profile = results[2] as Profile;
      _isLoading = false;
    });
  }

  Future<void> _loadPersonalTimes() async {
    final userId = supabase.auth.currentSession!.user.id;
    final times = await _personalTimesRepository.fetchForTrack(
      userId: userId,
      trackId: widget.trackId,
      buildType: _buildType,
    );
    if (!mounted) return;
    setState(() => _personalTimes = times);
  }

  int? get _personalBestMs {
    if (_personalTimes.isEmpty) return null;
    return _personalTimes.map((t) => t.timeMs).reduce((a, b) => a < b ? a : b);
  }

  Future<void> _openRegister() async {
    final savedBuildType = await context.push<BuildType>(
      '/register',
      extra: _buildType,
    );
    if (savedBuildType != null) {
      setState(() => _buildType = savedBuildType);
    }
    await _loadPersonalTimes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              color: AppColors.navbarBrown,
              padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
              child: SizedBox(
                height: 66,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => context.pop(),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.white,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 200,
                        child: ComboToggle(
                          value: _buildType,
                          onChanged: (value) {
                            setState(() => _buildType = value);
                            _loadPersonalTimes();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TrackHeader(track: _track!),
                          const SizedBox(height: 16),
                          TrackStatsRow(
                            personalBestMs: _personalBestMs,
                            wrTimeMs: _worldRecord?.timeMs,
                          ),
                          const SizedBox(height: 12),
                          WrBuildStrip(
                            character: _worldRecord?.character,
                            kart: _worldRecord?.kart,
                          ),
                          const SizedBox(height: 16),
                          CollapsibleSection(
                            title: 'Progression',
                            initiallyExpanded: true,
                            child: ProgressionChart(
                              times: _personalTimes,
                              wrTimeMs: _worldRecord?.timeMs,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CollapsibleSection(
                            title: 'My times',
                            initiallyExpanded: false,
                            child: MyTimesTable(
                              times: _personalTimes,
                              wrTimeMs: _worldRecord?.timeMs,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CollapsibleSection(
                            title: 'WR video',
                            initiallyExpanded: false,
                            child: WrVideoPlayer(
                              videoUrl: _worldRecord?.videoUrl,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            AppFooter(
              username: _profile?.username ?? '',
              onAddTap: _openRegister,
            ),
          ],
        ),
      ),
    );
  }
}
