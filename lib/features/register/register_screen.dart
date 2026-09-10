import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/time_format.dart';
import '../../data/models/build_type.dart';
import '../../data/models/personal_time.dart';
import '../../data/models/track.dart';
import '../../data/models/world_record.dart';
import '../../data/repositories/personal_times_repository.dart';
import '../../data/repositories/tracks_repository.dart';
import '../../data/repositories/world_records_repository.dart';
import '../../data/supabase_client.dart';
import '../home/widgets/combo_toggle.dart';
import 'widgets/track_picker_sheet.dart';

class RegisterScreen extends StatefulWidget {
  final BuildType initialBuildType;

  const RegisterScreen({super.key, required this.initialBuildType});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _tracksRepository = TracksRepository();
  final _worldRecordsRepository = WorldRecordsRepository();
  final _personalTimesRepository = PersonalTimesRepository();
  final _timeController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  List<Track> _tracks = [];
  List<WorldRecord> _worldRecords = [];
  Map<int, int> _bestTimesByTrack = {};

  Track? _selectedTrack;
  DateTime? _selectedDate;
  late BuildType _buildType;

  String? _trackError;
  String? _timeError;

  @override
  void initState() {
    super.initState();
    _buildType = widget.initialBuildType;
    _load();
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final tracks = await _tracksRepository.fetchAll();
    final worldRecords = await _worldRecordsRepository.fetchAll();
    await _loadBestTimes();
    if (!mounted) return;
    setState(() {
      _tracks = tracks;
      _worldRecords = worldRecords;
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

  Future<void> _pickTrack() async {
    final track = await showTrackPickerSheet(context, _tracks);
    if (track == null) return;
    setState(() {
      _selectedTrack = track;
      _trackError = null;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
  }

  int? _parseTimeToMs(String text) {
    final match = RegExp(r'^(\d):(\d{2})\.(\d{3})$').firstMatch(text);
    if (match == null) return null;
    final minutes = int.parse(match.group(1)!);
    final seconds = int.parse(match.group(2)!);
    final millis = int.parse(match.group(3)!);
    return minutes * 60000 + seconds * 1000 + millis;
  }

  Future<void> _save() async {
    setState(() {
      _trackError = null;
      _timeError = null;
    });

    if (_selectedTrack == null) {
      setState(() => _trackError = 'Selecciona un circuito');
      return;
    }

    final timeMs = _parseTimeToMs(_timeController.text);
    if (timeMs == null) {
      setState(() => _timeError = 'Formato de tiempo inválido');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final userId = supabase.auth.currentSession!.user.id;
      await _personalTimesRepository.insert(
        PersonalTime(
          userId: userId,
          trackId: _selectedTrack!.id,
          timeMs: timeMs,
          recordDate: _selectedDate ?? DateTime.now(),
          buildType: _buildType,
        ),
      );
      if (mounted) context.pop(_buildType);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    WorldRecord? wr;
    if (_selectedTrack != null) {
      for (final w in _worldRecords) {
        if (w.trackId == _selectedTrack!.id) {
          wr = w;
          break;
        }
      }
    }
    final pbMs = _selectedTrack == null
        ? null
        : _bestTimesByTrack[_selectedTrack!.id];

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
                top: MediaQuery.paddingOf(context).top + 22,
                bottom: 22,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavbarButton(
                    label: 'CANCELAR',
                    backgroundColor: AppColors.tableDark,
                    textColor: AppColors.grayMuted,
                    onTap: () => context.pop(),
                  ),
                  _NavbarButton(
                    label: 'GUARDAR',
                    backgroundColor: AppColors.pillInactive,
                    textColor: AppColors.white,
                    onTap: _isSaving ? null : _save,
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Track',
                        style: AppTextStyles.interMedium14(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickTrack,
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.grayLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedTrack?.name ?? '',
                                  style: AppTextStyles.interRegular14(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_trackError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _trackError!,
                          style: AppTextStyles.interRegular14(
                            color: AppColors.dangerRed,
                          ),
                        ),
                      ],
                      if (_selectedTrack != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Track WR - ${wr == null ? 'No time set' : formatTimeMs(wr.timeMs)}',
                          style: AppTextStyles.interMedium14(
                            color: AppColors.grayMuted,
                          ),
                        ),
                        Text(
                          'PB - ${pbMs == null ? 'No time set' : formatTimeMs(pbMs)}',
                          style: AppTextStyles.interMedium14(
                            color: AppColors.grayMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        'Time',
                        style: AppTextStyles.interMedium14(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.grayLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.centerLeft,
                        child: TextField(
                          controller: _timeController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [_TimeInputFormatter()],
                          style: AppTextStyles.interRegular14(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: 'M:ss.mmm',
                            hintStyle: AppTextStyles.interRegular14(
                              color: AppColors.grayInputText,
                            ),
                          ),
                        ),
                      ),
                      if (_timeError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _timeError!,
                          style: AppTextStyles.interRegular14(
                            color: AppColors.dangerRed,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        'Date',
                        style: AppTextStyles.interMedium14(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickDate,
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.grayLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedDate == null
                                      ? 'Today'
                                      : '${_selectedDate!.day.toString().padLeft(2, '0')}/'
                                            '${_selectedDate!.month.toString().padLeft(2, '0')}/'
                                            '${_selectedDate!.year}',
                                  style: AppTextStyles.interRegular14(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.black,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ComboToggle(
                        value: _buildType,
                        onChanged: (value) {
                          setState(() => _buildType = value);
                          _loadBestTimes();
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavbarButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;

  const _NavbarButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: AppTextStyles.bangers(fontSize: 15, color: textColor),
        ),
      ),
    );
  }
}

class _TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 6) digits = digits.substring(0, 6);

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 1) buffer.write(':');
      if (i == 3) buffer.write('.');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
