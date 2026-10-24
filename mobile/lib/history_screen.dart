import 'package:flutter/material.dart';

import 'widgets/skinx_header.dart';
import 'widgets/skinx_icon.dart';

const _ink = Color(0xFF193B38);
const _teal = Color(0xFF14665E);
const _muted = Color(0xFF8C9D9B);

class ScreeningRecord {
  const ScreeningRecord({
    required this.patientName,
    required this.savedAt,
    required this.savedDetails,
    required this.thumbnailAsset,
  });

  final String patientName;
  final DateTime savedAt;
  final String savedDetails;
  final String thumbnailAsset;
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    this.records,
    this.onRecordTap,
    this.onLanguageTap,
    this.languageCode = 'EN',
  });

  // Supply your real records here later. Without them, the reference samples show.
  final List<ScreeningRecord>? records;
  final ValueChanged<ScreeningRecord>? onRecordTap;
  final VoidCallback? onLanguageTap;
  final String languageCode;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  DateTime? _selectedDate;

  List<ScreeningRecord> get _records => widget.records ?? _sampleRecords;

  List<ScreeningRecord> get _visibleRecords {
    return _records.where((record) {
      final searchableText = [
        record.patientName,
        _dateLabel(record.savedAt),
        _timeLabel(record.savedAt),
        record.savedAt.toIso8601String(),
      ].join(' ').toLowerCase();

      final matchesSearch = searchableText.contains(_query.trim().toLowerCase());
      final matchesDate = _selectedDate == null || DateUtils.isSameDay(record.savedAt, _selectedDate);
      return matchesSearch && matchesDate;
    }).toList();
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedDate = null;
    });
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: _teal,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted || date == null) return;
    setState(() => _selectedDate = date);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final records = _visibleRecords;
    final showSampleNotice = widget.records == null;

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          // Keep the list readable instead of stretching it across a tablet.
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkinXHeader(
                  languageCode: widget.languageCode,
                  onLanguageTap: widget.onLanguageTap,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Screening history',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Find and reopen saved screenings.',
                  style: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: _muted, height: 1.4),
                ),
                const SizedBox(height: 18),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 52),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    style: const TextStyle(fontFamily: 'Roboto', fontSize: 13, color: _ink),
                    cursorColor: _teal,
                    decoration: InputDecoration(
                      hintText: 'Search patient or date',
                      hintStyle: const TextStyle(fontFamily: 'Roboto', fontSize: 13, color: Color(0xFFA4B5B1)),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 16, right: 10),
                        child: SkinXIcon(SkinXIconType.search, size: 18, color: Color(0xFF647D78)),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 24),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(color: Color(0xFFE1EAE2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(color: Color(0xFFE1EAE2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(color: _teal),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    InkWell(
                      onTap: _resetFilters,
                      borderRadius: BorderRadius.circular(24),
                      child: _FilterChip(
                        selected: _query.isEmpty && _selectedDate == null,
                        child: Text(
                          'All records • ${_records.length}',
                          style: const TextStyle(fontFamily: 'Roboto', fontSize: 13, color: _teal, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Filter by date',
                      color: Colors.white,
                      onSelected: (value) async {
                        if (value == 'any') {
                          setState(() => _selectedDate = null);
                        } else {
                          await _chooseDate();
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'any', child: Text('Any date')),
                        PopupMenuItem(value: 'choose', child: Text('Choose date')),
                      ],
                      child: _FilterChip(
                        selected: false,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SkinXIcon(SkinXIconType.calendar, size: 16),
                            const SizedBox(width: 7),
                            Text(
                              _selectedDate == null ? 'Any date' : _dateLabel(_selectedDate!),
                              style: const TextStyle(fontFamily: 'Roboto', fontSize: 13, color: _muted),
                            ),
                            const SizedBox(width: 7),
                            const SkinXIcon(SkinXIconType.chevronDown, size: 12, color: _muted),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Saved screenings',
                        style: TextStyle(fontFamily: 'Roboto', fontSize: 18, color: _ink, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (showSampleNotice)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF5E6),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: const Color(0xFFF0DEB9)),
                        ),
                        child: const Text(
                          'SAMPLE RECORDS',
                          style: TextStyle(fontFamily: 'Roboto', fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFFB18843), letterSpacing: 0.3),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (records.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      _records.isEmpty ? 'No saved screenings yet.' : 'No screenings match your search.',
                      style: const TextStyle(fontFamily: 'Roboto', fontSize: 14, color: _muted),
                    ),
                  )
                else
                  for (var index = 0; index < records.length; index++) ...[
                    _RecordCard(
                      record: records[index],
                      onTap: widget.onRecordTap == null ? null : () => widget.onRecordTap!(records[index]),
                    ),
                    if (index < records.length - 1) const SizedBox(height: 12),
                  ],
                if (showSampleNotice) ...[
                  const SizedBox(height: 20),
                  const _SampleNotice(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.selected, required this.child});

  final bool selected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFEAF2E8) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: selected ? _teal : const Color(0xFFE1EAE2)),
      ),
      child: child,
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record, this.onTap});

  final ScreeningRecord record;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EEE7)),
        boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset(record.thumbnailAsset, width: 56, height: 64, fit: BoxFit.cover),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.patientName,
                        style: const TextStyle(fontFamily: 'Roboto', fontSize: 16, fontWeight: FontWeight.w600, color: _ink, height: 1.25),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 1),
                            child: SkinXIcon(SkinXIconType.calendar, size: 13, color: _muted),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${_dateLabel(record.savedAt)} • ${_timeLabel(record.savedAt)}',
                              style: const TextStyle(fontFamily: 'Roboto', fontSize: 12, color: _muted, height: 1.25),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        record.savedDetails,
                        style: const TextStyle(fontFamily: 'Roboto', fontSize: 12, color: _teal, fontWeight: FontWeight.w600, height: 1.25),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const SkinXIcon(SkinXIconType.chevronRight, size: 17, color: Color(0xFFA8CBA9)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SampleNotice extends StatelessWidget {
  const _SampleNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD3E5CD)),
      ),
      child: const Row(
        children: [
          SkinXIcon(SkinXIconType.folderLock, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'These are illustrative records shown for demonstration. Your saved screenings will appear here.',
              style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: Color(0xFF718B80), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

String _dateLabel(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}

String _timeLabel(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

final _sampleRecords = [
  ScreeningRecord(
    patientName: 'Patient A',
    savedAt: DateTime(2026, 10, 3, 10, 24),
    savedDetails: 'Photo & notes saved',
    thumbnailAsset: 'assets/screening_arm_sample.png',
  ),
  ScreeningRecord(
    patientName: 'Patient B',
    savedAt: DateTime(2026, 9, 25, 14, 8),
    savedDetails: 'Photo & notes saved',
    thumbnailAsset: 'assets/screening_shoulder_sample.png',
  ),
  ScreeningRecord(
    patientName: 'Patient A',
    savedAt: DateTime(2026, 9, 12, 9, 15),
    savedDetails: 'Photo saved',
    thumbnailAsset: 'assets/screening_arm_sample.png',
  ),
];
