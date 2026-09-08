enum DiscoverSortBy {
  popular,
  rating,
  newest,
  saved,
  difficulty,
  duration,
}

class DiscoverFilter {
  const DiscoverFilter({
    this.searchQuery = '',
    this.selectedDifficulty,
    this.selectedGoal,
    this.selectedFrequency,
    this.selectedCategory,
    this.selectedEquipment,
    this.sortBy = DiscoverSortBy.popular,
    this.onlySaved = false,
  });

  final String searchQuery;
  final String? selectedDifficulty;
  final String? selectedGoal;
  final int? selectedFrequency;
  final String? selectedCategory;
  final String? selectedEquipment;
  final DiscoverSortBy sortBy;
  final bool onlySaved;

  bool get hasActiveFilter =>
      searchQuery.trim().isNotEmpty ||
      selectedDifficulty != null ||
      selectedGoal != null ||
      selectedFrequency != null ||
      selectedCategory != null ||
      selectedEquipment != null ||
      onlySaved;

  DiscoverFilter copyWith({
    String? searchQuery,
    String? Function()? selectedDifficulty,
    String? Function()? selectedGoal,
    int? Function()? selectedFrequency,
    String? Function()? selectedCategory,
    String? Function()? selectedEquipment,
    DiscoverSortBy? sortBy,
    bool? onlySaved,
  }) {
    return DiscoverFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDifficulty: selectedDifficulty != null
          ? selectedDifficulty()
          : this.selectedDifficulty,
      selectedGoal: selectedGoal != null ? selectedGoal() : this.selectedGoal,
      selectedFrequency: selectedFrequency != null
          ? selectedFrequency()
          : this.selectedFrequency,
      selectedCategory:
          selectedCategory != null ? selectedCategory() : this.selectedCategory,
      selectedEquipment: selectedEquipment != null
          ? selectedEquipment()
          : this.selectedEquipment,
      sortBy: sortBy ?? this.sortBy,
      onlySaved: onlySaved ?? this.onlySaved,
    );
  }

  static const List<String> difficulties = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Professional',
  ];

  static const List<String> goals = [
    'Muscle Gain',
    'Hypertrophy',
    'Strength',
    'Powerlifting',
    'Powerbuilding',
    'Fat Loss',
    'Endurance',
    'General Fitness',
    'Mobility',
    'Conditioning',
  ];

  static const List<int> frequencies = [2, 3, 4, 5, 6, 7];

  static const List<String> categories = [
    'Powerlifting',
    'Hypertrophy',
    'Powerbuilding',
    'Bodyweight',
    'Women',
    'Cardio & Fat Loss',
  ];

  static const List<String> equipmentList = [
    'Full Gym',
    'Barbell & Rack',
    'Dumbbells Only',
    'Cables & Machines',
    'Bodyweight / Calisthenics',
  ];
}
