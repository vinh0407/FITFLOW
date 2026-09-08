class DailyMealItem {
  const DailyMealItem({
    required this.id,
    required this.mealType,
    required this.dishName,
    required this.servingWeight,
    required this.kcal,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.iconEmoji = 'meal',
  });

  final String id;

  /// Bữa sáng, Bữa phụ sáng, Bữa trưa, Bữa phụ chiều, Bữa tối, Bữa phụ tối
  final String mealType;
  final String dishName;
  final String servingWeight;
  final int kcal;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final String iconEmoji;

  Map<String, dynamic> toJson() => {
        'id': id,
        'mealType': mealType,
        'dishName': dishName,
        'servingWeight': servingWeight,
        'kcal': kcal,
        'proteinGrams': proteinGrams,
        'carbsGrams': carbsGrams,
        'fatGrams': fatGrams,
        'iconEmoji': iconEmoji,
      };

  factory DailyMealItem.fromJson(Map<String, dynamic> json) => DailyMealItem(
        id: '${json['id'] ?? ''}',
        mealType: '${json['mealType'] ?? ''}',
        dishName: '${json['dishName'] ?? ''}',
        servingWeight: '${json['servingWeight'] ?? ''}',
        kcal: (json['kcal'] as num?)?.toInt() ?? 0,
        proteinGrams: (json['proteinGrams'] as num?)?.toDouble() ?? 0.0,
        carbsGrams: (json['carbsGrams'] as num?)?.toDouble() ?? 0.0,
        fatGrams: (json['fatGrams'] as num?)?.toDouble() ?? 0.0,
        iconEmoji: '${json['iconEmoji'] ?? 'meal'}',
      );
}

class DailyMenuPlan {
  const DailyMenuPlan({
    required this.targetKcal,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    required this.meals,
  });

  final int targetKcal;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;
  final List<DailyMealItem> meals;

  static const default2455KcalPlan = DailyMenuPlan(
    targetKcal: 2455,
    targetProtein: 210,
    targetCarbs: 219,
    targetFat: 72,
    meals: [
      DailyMealItem(
        id: 'm1',
        mealType: 'Bữa sáng',
        dishName: 'Bánh mì nguyên cám + 3 trứng ốp la + 1 chuối',
        servingWeight: '350g',
        kcal: 550,
        proteinGrams: 35.0,
        carbsGrams: 60.0,
        fatGrams: 18.0,
        iconEmoji: 'breakfast',
      ),
      DailyMealItem(
        id: 'm2',
        mealType: 'Bữa phụ sáng',
        dishName: 'Whey Protein Isolate + 30g hạt hạnh nhân',
        servingWeight: '250ml',
        kcal: 280,
        proteinGrams: 30.0,
        carbsGrams: 8.0,
        fatGrams: 14.0,
        iconEmoji: 'snack',
      ),
      DailyMealItem(
        id: 'm3',
        mealType: 'Bữa trưa',
        dishName: 'Ức gà áp chảo + Cơm gạo lứt + Bông cải xanh',
        servingWeight: '450g',
        kcal: 620,
        proteinGrams: 52.0,
        carbsGrams: 65.0,
        fatGrams: 10.0,
        iconEmoji: 'lunch',
      ),
      DailyMealItem(
        id: 'm4',
        mealType: 'Bữa phụ chiều',
        dishName: 'Sữa chua Hy Lạp + Yến mạch + Quả việt quất',
        servingWeight: '200g',
        kcal: 260,
        proteinGrams: 22.0,
        carbsGrams: 32.0,
        fatGrams: 5.0,
        iconEmoji: 'snack',
      ),
      DailyMealItem(
        id: 'm5',
        mealType: 'Bữa tối',
        dishName: 'Cá hồi nướng + Khoai lang + Salad dầu olive',
        servingWeight: '400g',
        kcal: 580,
        proteinGrams: 45.0,
        carbsGrams: 42.0,
        fatGrams: 22.0,
        iconEmoji: 'dinner',
      ),
      DailyMealItem(
        id: 'm6',
        mealType: 'Bữa phụ tối',
        dishName: 'Sữa tươi không đường + Casein protein trước ngủ',
        servingWeight: '220ml',
        kcal: 165,
        proteinGrams: 26.0,
        carbsGrams: 12.0,
        fatGrams: 3.0,
        iconEmoji: 'night-snack',
      ),
    ],
  );
}
