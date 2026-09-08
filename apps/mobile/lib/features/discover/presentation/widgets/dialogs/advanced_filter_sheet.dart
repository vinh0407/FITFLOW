import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vincecore/core/theme/app_colors.dart';
import 'package:vincecore/features/discover/domain/models/discover_filter_model.dart';

class AdvancedFilterSheet extends StatefulWidget {
  const AdvancedFilterSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  final DiscoverFilter initialFilter;
  final ValueChanged<DiscoverFilter> onApply;

  @override
  State<AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends State<AdvancedFilterSheet> {
  late String? _difficulty;
  late String? _goal;
  late int? _frequency;
  late String? _equipment;
  late DiscoverSortBy _sortBy;
  late bool _onlySaved;

  @override
  void initState() {
    super.initState();
    _difficulty = widget.initialFilter.selectedDifficulty;
    _goal = widget.initialFilter.selectedGoal;
    _frequency = widget.initialFilter.selectedFrequency;
    _equipment = widget.initialFilter.selectedEquipment;
    _sortBy = widget.initialFilter.sortBy;
    _onlySaved = widget.initialFilter.onlySaved;
  }

  void _reset() {
    setState(() {
      _difficulty = null;
      _goal = null;
      _frequency = null;
      _equipment = null;
      _sortBy = DiscoverSortBy.popular;
      _onlySaved = false;
    });
  }

  void _apply() {
    HapticFeedback.mediumImpact();
    widget.onApply(
      widget.initialFilter.copyWith(
        selectedDifficulty: () => _difficulty,
        selectedGoal: () => _goal,
        selectedFrequency: () => _frequency,
        selectedEquipment: () => _equipment,
        sortBy: _sortBy,
        onlySaved: _onlySaved,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isLight ? Colors.black12 : Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BỘ LỌC NÂNG CAO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isLight
                      ? AppColors.lightTextPrimary
                      : AppColors.darkTextPrimary,
                ),
              ),
              TextButton(
                onPressed: _reset,
                child: Text(
                  'Đặt lại',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isLight
                        ? AppColors.primaryBlue
                        : AppColors.primaryBlueLight,
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: ListView(
              children: [
                // 1. Difficulty
                _buildSectionTitle('ĐỘ KHÓ / LEVEL', isLight),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip('Tất cả', _difficulty == null, () {
                      setState(() => _difficulty = null);
                    }, isLight),
                    ...DiscoverFilter.difficulties.map((d) {
                      return _buildChip(d, _difficulty == d, () {
                        setState(() => _difficulty = d);
                      }, isLight);
                    }),
                  ],
                ),

                const SizedBox(height: 18),

                // 2. Training Goal
                _buildSectionTitle('MỤC TIÊU TẬP LUYỆN', isLight),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip('Tất cả', _goal == null, () {
                      setState(() => _goal = null);
                    }, isLight),
                    ...DiscoverFilter.goals.map((g) {
                      return _buildChip(g, _goal == g, () {
                        setState(() => _goal = g);
                      }, isLight);
                    }),
                  ],
                ),

                const SizedBox(height: 18),

                // 3. Frequency
                _buildSectionTitle('TẦN SUẤT (NGÀY/TUẦN)', isLight),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip('Tất cả', _frequency == null, () {
                      setState(() => _frequency = null);
                    }, isLight),
                    ...DiscoverFilter.frequencies.map((f) {
                      return _buildChip('$f ngày/tuần', _frequency == f, () {
                        setState(() => _frequency = f);
                      }, isLight);
                    }),
                  ],
                ),

                const SizedBox(height: 18),

                // 4. Equipment
                _buildSectionTitle('DỤNG CỤ TẬP', isLight),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip('Tất cả', _equipment == null, () {
                      setState(() => _equipment = null);
                    }, isLight),
                    ...DiscoverFilter.equipmentList.map((eq) {
                      return _buildChip(eq, _equipment == eq, () {
                        setState(() => _equipment = eq);
                      }, isLight);
                    }),
                  ],
                ),

                const SizedBox(height: 18),

                // 5. Sort by
                _buildSectionTitle('SẮP XẾP THEO', isLight),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip(
                        'Phổ biến nhất', _sortBy == DiscoverSortBy.popular, () {
                      setState(() => _sortBy = DiscoverSortBy.popular);
                    }, isLight),
                    _buildChip(
                        'Đánh giá cao nhất ⭐', _sortBy == DiscoverSortBy.rating,
                        () {
                      setState(() => _sortBy = DiscoverSortBy.rating);
                    }, isLight),
                    _buildChip('Mới nhất', _sortBy == DiscoverSortBy.newest,
                        () {
                      setState(() => _sortBy = DiscoverSortBy.newest);
                    }, isLight),
                  ],
                ),

                const SizedBox(height: 18),

                // 6. Only saved switch
                SwitchListTile(
                  title: Text(
                    'Chỉ hiện giáo án đã ghim (Saved) 🔖',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isLight
                          ? AppColors.lightTextPrimary
                          : AppColors.darkTextPrimary,
                    ),
                  ),
                  value: _onlySaved,
                  activeThumbColor: AppColors.primaryBlue,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _onlySaved = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Apply button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'ÁP DỤNG BỘ LỌC',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isLight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
          color: isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted,
        ),
      ),
    );
  }

  Widget _buildChip(
      String label, bool isSelected, VoidCallback onTap, bool isLight) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : (isLight ? const Color(0xFFF1F3F5) : const Color(0xFF242426)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            color: isSelected
                ? Colors.white
                : (isLight
                    ? AppColors.lightTextPrimary
                    : AppColors.darkTextPrimary),
          ),
        ),
      ),
    );
  }
}
