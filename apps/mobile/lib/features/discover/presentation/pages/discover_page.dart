import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/discover_filter_model.dart';
import '../../domain/models/discover_program_model.dart';
import '../../domain/models/training_style_model.dart';
import '../../domain/models/exercise_collection_model.dart';

import '../widgets/discover_header.dart';
import '../widgets/discover_search_bar.dart';
import '../widgets/filter_chips_bar.dart';
import '../widgets/program_card.dart';
import '../widgets/trending_programs_section.dart';
import '../widgets/recommended_programs_section.dart';
import '../widgets/popular_exercises_section.dart';
import '../widgets/training_styles_section.dart';
import '../widgets/collection_section.dart';
import '../widgets/daily_workout_section.dart';

import '../widgets/dialogs/program_detail_sheet.dart';
import '../widgets/dialogs/advanced_filter_sheet.dart';
import '../widgets/dialogs/saved_programs_sheet.dart';
import '../../../../widgets/ai_workout_bottom_sheet.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final _searchController = TextEditingController();
  DiscoverFilter _filter = const DiscoverFilter();

  @override
  void initState() {
    super.initState();
    fitnessRepository.addListener(_refresh);
  }

  @override
  void dispose() {
    fitnessRepository.removeListener(_refresh);
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _openProgramDetail(DiscoverProgram program) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProgramDetailSheet(program: program),
    );
  }

  void _openAdvancedFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFilterSheet(
        initialFilter: _filter,
        onApply: (newFilter) {
          setState(() => _filter = newFilter);
        },
      ),
    );
  }

  void _openAiProgramGenerator() {
    AiWorkoutBottomSheet.show(context);
  }

  void _openSavedPrograms() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SavedProgramsSheet(
        onProgramTap: _openProgramDetail,
      ),
    );
  }

  void _onSelectTrainingStyle(TrainingStyle style) {
    setState(() {
      _filter = _filter.copyWith(
        selectedCategory: () => style.name,
      );
    });
  }

  void _onSelectCollection(ExerciseCollection col) {
    setState(() {
      _filter = _filter.copyWith(
        searchQuery: col.muscleGroup,
      );
      _searchController.text = col.muscleGroup;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final savedCount = fitnessRepository.savedProgramIds.length;
    final filteredPrograms = fitnessRepository.getFilteredPrograms(_filter);
    final isSearchingOrFiltering = _filter.hasActiveFilter;

    return Scaffold(
      backgroundColor: isLight ? AppColors.lightBg : AppColors.darkBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            // 1. Header (Title + 9+ badge + Actions)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: DiscoverHeader(
                savedCount: savedCount,
                onSavedTap: _openSavedPrograms,
                onAiTap: _openAiProgramGenerator,
              ),
            ),

            // 2. Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DiscoverSearchBar(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _filter = _filter.copyWith(searchQuery: val);
                  });
                },
                onClear: () {
                  _searchController.clear();
                  setState(() {
                    _filter = _filter.copyWith(searchQuery: '');
                  });
                },
              ),
            ),

            const SizedBox(height: 12),

            // 3. Filter Chips Bar
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: FilterChipsBar(
                filter: _filter,
                onFilterChanged: (newFilter) {
                  setState(() => _filter = newFilter);
                },
                onOpenAdvancedFilter: _openAdvancedFilter,
              ),
            ),

            const SizedBox(height: 20),

            // 4. Content Area
            if (isSearchingOrFiltering)
              _buildFilteredResults(filteredPrograms, isLight)
            else
              _buildDiscoverSections(isLight),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredResults(List<DiscoverProgram> programs, bool isLight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KẾT QUẢ TÌM KIẾM (${programs.length})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isLight
                      ? AppColors.lightTextMuted
                      : AppColors.darkTextMuted,
                ),
              ),
              InkWell(
                onTap: () {
                  _searchController.clear();
                  setState(() => _filter = const DiscoverFilter());
                },
                child: Text(
                  'Xóa bộ lọc',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isLight
                        ? AppColors.primaryBlue
                        : AppColors.primaryBlueLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (programs.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.search_off_rounded,
                      size: 36, color: AppColors.primaryBlue),
                  const SizedBox(height: 12),
                  Text(
                    'Không tìm thấy chương trình phù hợp.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isLight
                          ? AppColors.lightTextPrimary
                          : AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Thử thay đổi từ khóa tìm kiếm hoặc điều chỉnh lại các bộ lọc độ khó, mục tiêu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isLight
                          ? AppColors.lightTextMuted
                          : AppColors.darkTextMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _filter = const DiscoverFilter());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Đặt lại bộ lọc'),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: programs.length,
              itemBuilder: (context, index) {
                final p = programs[index];
                return ProgramCard(
                  program: p,
                  onTap: () => _openProgramDetail(p),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDiscoverSections(bool isLight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Program Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              _openAiProgramGenerator();
            },
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.aiPurple, AppColors.statusRecovery],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.aiPurple.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tạo giáo án AI riêng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Cá nhân hóa theo thể trạng, mục tiêu & lịch rảnh của bạn',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: Colors.white),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 1. Trending Programs
        TrendingProgramsSection(
          onProgramTap: _openProgramDetail,
        ),

        const SizedBox(height: 28),

        // 2. Recommended For You
        RecommendedProgramsSection(
          onProgramTap: _openProgramDetail,
        ),

        const SizedBox(height: 28),

        // 3. Popular Exercises
        const PopularExercisesSection(),

        const SizedBox(height: 28),

        // 4. Training Styles
        TrainingStylesSection(
          onSelectStyle: _onSelectTrainingStyle,
        ),

        const SizedBox(height: 28),

        // 5. Our Collection
        CollectionSection(
          onCollectionTap: _onSelectCollection,
        ),

        const SizedBox(height: 28),

        // 6. Daily Workout Explorer
        const DailyWorkoutSection(),
      ],
    );
  }
}
