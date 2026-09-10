import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/build_type.dart';
import '../../data/models/profile.dart';
import '../../data/models/track.dart';
import '../../data/models/world_record.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/personal_times_repository.dart';
import '../../data/repositories/tracks_repository.dart';
import '../../data/repositories/world_records_repository.dart';
import '../../data/supabase_client.dart';
import '../../core/widgets/app_footer.dart';
import '../online/online_placeholder_screen.dart';
import 'widgets/combo_toggle.dart';
import 'widgets/stats_alert_card.dart';
import 'widgets/top_pagination.dart';
import 'widgets/tracks_table.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final _authRepository = AuthRepository();
  final _tracksRepository = TracksRepository();
  final _worldRecordsRepository = WorldRecordsRepository();
  final _personalTimesRepository = PersonalTimesRepository();

  late final TabController _tabController;
  final _timeTrialsScrollController = ScrollController();

  BuildType _buildType = BuildType.optimal;
  bool _isLoading = true;
  List<Track> _tracks = [];
  List<WorldRecord> _worldRecords = [];
  Map<int, int> _bestTimesByTrack = {};
  Profile? _profile;

  TracksSortColumn? _sortColumn;
  SortDirection _sortDirection = SortDirection.ascending;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timeTrialsScrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      _tracksRepository.fetchAll(),
      _worldRecordsRepository.fetchAll(),
      _authRepository.fetchCurrentProfile(),
    ]);
    await _loadBestTimes();
    if (!mounted) return;
    setState(() {
      _tracks = results[0] as List<Track>;
      _worldRecords = results[1] as List<WorldRecord>;
      _profile = results[2] as Profile;
      _isLoading = false;
    });
  }

  Future<void> _loadBestTimes() async {
    final userId = supabase.auth.currentSession!.user.id;
    final bestTimes = await _personalTimesRepository.fetchBestTimesByTrack(
      userId: userId,
      buildType: _buildType,
    );
    if (!mounted) return;
    setState(() => _bestTimesByTrack = bestTimes);
  }

  void _onSort(TracksSortColumn column) {
    setState(() {
      if (_sortColumn == column) {
        _sortDirection = _sortDirection == SortDirection.ascending
            ? SortDirection.descending
            : SortDirection.ascending;
      } else {
        _sortColumn = column;
        _sortDirection = SortDirection.ascending;
      }
    });
  }

  List<Track> get _sortedTracks {
    if (_sortColumn == null) return _tracks;

    final ascending = _sortDirection == SortDirection.ascending;
    final wrByTrack = {for (final wr in _worldRecords) wr.trackId: wr};

    int? gapMsFor(Track track) {
      final personalMs = _bestTimesByTrack[track.id];
      final wr = wrByTrack[track.id];
      if (personalMs == null || wr == null) return null;
      return personalMs - wr.timeMs;
    }

    int compareNullable(num? a, num? b) {
      if (a == null && b == null) return 0;
      if (a == null) return 1;
      if (b == null) return -1;
      final cmp = a.compareTo(b);
      return ascending ? cmp : -cmp;
    }

    final sorted = [..._tracks];
    sorted.sort((a, b) {
      switch (_sortColumn!) {
        case TracksSortColumn.track:
          final cmp = a.name.compareTo(b.name);
          return ascending ? cmp : -cmp;
        case TracksSortColumn.bestTime:
          return compareNullable(
            _bestTimesByTrack[a.id],
            _bestTimesByTrack[b.id],
          );
        case TracksSortColumn.gap:
          return compareNullable(gapMsFor(a), gapMsFor(b));
      }
    });
    return sorted;
  }

  Future<void> _onTrackTap(Track track) async {
    await context.push('/track/${track.id}', extra: _buildType);
    await _loadBestTimes();
  }

  Future<void> _openRegister() async {
    final savedBuildType = await context.push<BuildType>(
      '/register',
      extra: _buildType,
    );
    if (savedBuildType != null) {
      setState(() => _buildType = savedBuildType);
    }
    await _loadBestTimes();
    if (_timeTrialsScrollController.hasClients) {
      _timeTrialsScrollController.jumpTo(0);
    }
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
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: MediaQuery.paddingOf(context).top + 15,
                bottom: 16,
              ),
              child: Row(
                children: [
                  const Icon(Icons.public, color: AppColors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'MKWS',
                    style: AppTextStyles.bangers(
                      fontSize: 20,
                      color: AppColors.white,
                    ),
                  ),
                  const Spacer(),
                  TopPagination(
                    activeIndex: _tabController.index,
                    onChanged: (index) => _tabController.animateTo(index),
                  ),
                ],
              ),
            ),
            if (!_isLoading && _tabController.index == 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: ComboToggle(
                  value: _buildType,
                  onChanged: (value) {
                    setState(() => _buildType = value);
                    _loadBestTimes();
                  },
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _TimeTrialsPage(
                          scrollController: _timeTrialsScrollController,
                          tracks: _sortedTracks,
                          worldRecords: _worldRecords,
                          bestTimesByTrack: _bestTimesByTrack,
                          sortColumn: _sortColumn,
                          sortDirection: _sortDirection,
                          onSort: _onSort,
                          onTrackTap: _onTrackTap,
                        ),
                        const OnlinePlaceholderScreen(),
                      ],
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

class _TimeTrialsPage extends StatelessWidget {
  final ScrollController scrollController;
  final List<Track> tracks;
  final List<WorldRecord> worldRecords;
  final Map<int, int> bestTimesByTrack;
  final TracksSortColumn? sortColumn;
  final SortDirection sortDirection;
  final ValueChanged<TracksSortColumn> onSort;
  final ValueChanged<Track> onTrackTap;

  const _TimeTrialsPage({
    required this.scrollController,
    required this.tracks,
    required this.worldRecords,
    required this.bestTimesByTrack,
    required this.sortColumn,
    required this.sortDirection,
    required this.onSort,
    required this.onTrackTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          sliver: SliverToBoxAdapter(
            child: StatsAlertCard(
              tracks: tracks,
              worldRecords: worldRecords,
              bestTimesByTrack: bestTimesByTrack,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverPersistentHeader(
            pinned: true,
            delegate: TracksTableHeaderDelegate(
              sortColumn: sortColumn,
              sortDirection: sortDirection,
              onSort: onSort,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverToBoxAdapter(
            child: TracksTableRows(
              tracks: tracks,
              worldRecords: worldRecords,
              bestTimesByTrack: bestTimesByTrack,
              onTrackTap: onTrackTap,
            ),
          ),
        ),
      ],
    );
  }
}
