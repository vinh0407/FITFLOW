import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/fitness_data.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/fitness_ui.dart';

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  double water = 0;
  String query = '';
  String category = 'ALL';

  // Meal Plan state
  Map<String, FoodRecord?> _mealPlan = {
    'Bữa sáng': null,
    'Bữa trưa': null,
    'Bữa chiều': null,
    'Bữa tối': null,
  };

  FoodRecord? _randomFoodForMeal(String mealName) {
    final foods = fitnessRepository.foods;
    final preferredCategory = switch (mealName) {
      'Bữa sáng' => 'CARBS',
      'Bữa trưa' || 'Bữa tối' => 'PROTEIN',
      'Bữa chiều' => 'FATS',
      _ => 'ALL',
    };
    final choices = preferredCategory == 'ALL'
        ? foods
        : foods.where((food) => food.category == preferredCategory).toList();
    final pool = choices.isEmpty ? foods : choices;
    if (pool.isEmpty) return null;
    return pool[Random().nextInt(pool.length)];
  }

  void _randomizeMeal(String mealName) {
    setState(() => _mealPlan[mealName] = _randomFoodForMeal(mealName));
    HapticFeedback.selectionClick();
  }

  void _randomizeMealPlan() {
    setState(() {
      _mealPlan = {
        'Bữa sáng': _randomFoodForMeal('Bữa sáng'),
        'Bữa trưa': _randomFoodForMeal('Bữa trưa'),
        'Bữa chiều': _randomFoodForMeal('Bữa chiều'),
        'Bữa tối': _randomFoodForMeal('Bữa tối'),
      };
    });
    HapticFeedback.mediumImpact();
  }

  @override
  void initState() {
    super.initState();
    fitnessRepository.addListener(_refresh);
    // Generate default meal plan on first load
    WidgetsBinding.instance.addPostFrameCallback((_) => _randomizeMealPlan());
  }

  @override
  void dispose() {
    fitnessRepository.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final profile = fitnessRepository.profile;
    final weight = double.tryParse(profile.weightKg) ?? 0;
    final meals = fitnessRepository.meals
        .where((meal) => _isToday(meal.createdAt))
        .toList();
    final kcal = meals.fold<int>(0, (sum, meal) => sum + meal.kcal);
    final protein = meals.fold<double>(0, (sum, meal) => sum + meal.protein);
    final carbs = meals.fold<double>(0, (sum, meal) => sum + meal.carbs);
    final fat = meals.fold<double>(0, (sum, meal) => sum + meal.fat);
    final kcalTarget = weight > 0 ? (weight * 30).round() : 2000;
    final proteinTarget = weight > 0 ? weight * 1.6 : 120.0;
    final foods = fitnessRepository.foods
        .where((food) =>
            (category == 'ALL' || food.category == category) &&
            food.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('DINH DƯỠNG',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.5)),
                TextButton.icon(
                  onPressed: _showAddMealDialog,
                  icon: const Icon(Icons.add, color: AppColors.primaryBlue),
                  label: const Text('THÊM BỮA',
                      style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FitnessCard(
              padding: 20,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NĂNG LƯỢNG HÔM NAY',
                              style: TextStyle(
                                color: isLight
                                    ? AppColors.lightTextMuted
                                    : AppColors.darkTextMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$kcal',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                                color: isLight
                                    ? AppColors.lightTextPrimary
                                    : AppColors.darkTextPrimary,
                              ),
                            ),
                            Text(
                              '/ $kcalTarget KCAL · ${kcalTarget - kcal > 0 ? kcalTarget - kcal : 0} KCAL CÒN LẠI',
                              style: TextStyle(
                                color: isLight
                                    ? AppColors.lightTextSecondary
                                    : AppColors.darkTextSecondary,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Semantics(
                        label:
                            'Tiến độ năng lượng: $kcal trên $kcalTarget kcal',
                        child: SizedBox(
                          width: 74,
                          height: 74,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: (kcal / kcalTarget).clamp(0, 1),
                                strokeWidth: 7,
                                backgroundColor: isLight
                                    ? AppColors.lightBorder
                                    : AppColors.surfaceHighest,
                                color: isLight
                                    ? AppColors.primaryBlue
                                    : AppColors.primaryBlueLight,
                              ),
                              Text(
                                '${((kcal / kcalTarget).clamp(0, 1) * 100).round()}%',
                                style: TextStyle(
                                  color: isLight
                                      ? AppColors.primaryBlue
                                      : AppColors.primaryBlueLight,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Segmented Multi-Color Macro Bar
                  _buildSegmentedMacroBar(
                    protein: protein,
                    proteinTarget: proteinTarget,
                    carbs: carbs,
                    carbsTarget: kcalTarget * .5 / 4,
                    fat: fat,
                    fatTarget: kcalTarget * .25 / 9,
                    isLight: isLight,
                  ),
                  const SizedBox(height: 16),

                  // Macro Indicators Triad
                  Row(
                    children: [
                      _macroPill(
                        'ĐẠM',
                        '${protein.toStringAsFixed(0)}/${proteinTarget.toStringAsFixed(0)}g',
                        AppColors.primaryBlue,
                        isLight,
                      ),
                      const SizedBox(width: 8),
                      _macroPill(
                        'TINH BỘT',
                        '${carbs.toStringAsFixed(0)}/${(kcalTarget * .5 / 4).toStringAsFixed(0)}g',
                        AppColors.amberYellow,
                        isLight,
                      ),
                      const SizedBox(width: 8),
                      _macroPill(
                        'CHẤT BÉO',
                        '${fat.toStringAsFixed(0)}/${(kcalTarget * .25 / 9).toStringAsFixed(0)}g',
                        AppColors.mintGreen,
                        isLight,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            FitnessCard(
              padding: 16,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('NƯỚC UỐNG',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .5)),
                          Text('${water.toStringAsFixed(2)} / 2.50 L',
                              style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w900)),
                        ]),
                    const SizedBox(height: 10),
                    ThinProgress(value: water / 2.5),
                    const SizedBox(height: 12),
                    Row(children: [
                      _waterButton('+250 ML', .25),
                      const SizedBox(width: 8),
                      _waterButton('+500 ML', .5),
                      const SizedBox(width: 8),
                      _waterButton('-250 ML', -.25),
                    ]),
                  ]),
            ),

            // ── MEAL PLAN HÔM NAY ──────────────────────
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KẾ HOẠCH BỮA ĂN HÔM NAY',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Gợi ý thực đơn ngẫu nhiên phù hợp mục tiêu',
                      style: TextStyle(
                        fontSize: 11,
                        color: isLight
                            ? AppColors.lightTextMuted
                            : AppColors.darkTextMuted,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: _randomizeMealPlan,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.shuffle_rounded,
                            size: 14,
                            color: isLight
                                ? AppColors.primaryBlue
                                : AppColors.primaryBlueLight),
                        const SizedBox(width: 4),
                        Text(
                          'Gợi ý mới',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: isLight
                                ? AppColors.primaryBlue
                                : AppColors.primaryBlueLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Meal plan cards (2x2 grid)
            Row(
              children: [
                Expanded(
                    child: _buildMealPlanCard('Bữa sáng',
                        Icons.wb_sunny_outlined, _mealPlan['Bữa sáng'], isLight,
                        onRandomize: () => _randomizeMeal('Bữa sáng'))),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildMealPlanCard(
                        'Bữa trưa',
                        Icons.light_mode_outlined,
                        _mealPlan['Bữa trưa'],
                        isLight,
                        onRandomize: () => _randomizeMeal('Bữa trưa'))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _buildMealPlanCard(
                        'Bữa chiều',
                        Icons.wb_twilight_outlined,
                        _mealPlan['Bữa chiều'],
                        isLight,
                        onRandomize: () => _randomizeMeal('Bữa chiều'))),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildMealPlanCard(
                        'Bữa tối',
                        Icons.nightlight_outlined,
                        _mealPlan['Bữa tối'],
                        isLight,
                        onRandomize: () => _randomizeMeal('Bữa tối'))),
              ],
            ),
            // ────────────────────────────────────────────

            const SectionTitle('NHẬT KÝ BỮA ĂN',
                subtitle: 'Dữ liệu bạn đã ghi hôm nay'),
            if (meals.isEmpty)
              EmptyPanel(
                  title: 'CHƯA CÓ BỮA ĂN NÀO',
                  message:
                      'Thêm thực phẩm từ thư viện hoặc ghi một bữa tự nhập.',
                  action: 'THÊM BỮA ĂN',
                  onAction: _showAddMealDialog)
            else
              ...meals.map(_mealCard),
            const SectionTitle('THƯ VIỆN THỰC PHẨM & DINH DƯỠNG',
                subtitle: 'Giá trị dinh dưỡng chuẩn trên khẩu phần thực tế'),
            TextField(
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Tìm thực phẩm (Ức gà, Yến mạch, Bơ...)'),
              onChanged: (value) => setState(() => query = value),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  {'id': 'ALL', 'label': 'TẤT CẢ'},
                  {'id': 'PROTEIN', 'label': 'ĐẠM (PROTEIN)'},
                  {'id': 'CARBS', 'label': 'TINH BỘT (CARBS)'},
                  {'id': 'FATS', 'label': 'CHẤT BÉO TỐT'},
                  {'id': 'VEGETABLES', 'label': 'RAU XANH'},
                  {'id': 'FRUIT', 'label': 'TRÁI CÂY'},
                  {'id': 'DAIRY', 'label': 'SỮA & CHẾ PHẨM'},
                  {'id': 'SNACKS', 'label': 'HẠT & PHỤ'},
                ].map((item) {
                  final active = category == item['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(item['label']!),
                      selected: active,
                      onSelected: (_) => setState(() => category = item['id']!),
                      selectedColor: AppColors.primaryBlue,
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        color:
                            active ? AppColors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color:
                              active ? AppColors.primaryBlue : AppColors.border,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            if (foods.isEmpty)
              const EmptyPanel(
                  title: 'KHÔNG TÌM THẤY THỰC PHẨM',
                  message: 'Thử từ khóa khác hoặc chọn lại danh mục.')
            else
              ...foods.map(_foodCard),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedMacroBar({
    required double protein,
    required double proteinTarget,
    required double carbs,
    required double carbsTarget,
    required double fat,
    required double fatTarget,
    required bool isLight,
  }) {
    final proteinKcal = protein * 4;
    final carbsKcal = carbs * 4;
    final fatKcal = fat * 9;
    final totalConsumedKcal = proteinKcal + carbsKcal + fatKcal;

    double pFlex =
        totalConsumedKcal > 0 ? (proteinKcal / totalConsumedKcal) : 0.33;
    double cFlex =
        totalConsumedKcal > 0 ? (carbsKcal / totalConsumedKcal) : 0.45;
    double fFlex = totalConsumedKcal > 0 ? (fatKcal / totalConsumedKcal) : 0.22;

    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurfaceMid : AppColors.darkSurfaceMid,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Row(
          children: [
            if (pFlex > 0)
              Expanded(
                flex: (pFlex * 100).round().clamp(1, 100),
                child: Container(color: AppColors.primaryBlue),
              ),
            const SizedBox(width: 2),
            if (cFlex > 0)
              Expanded(
                flex: (cFlex * 100).round().clamp(1, 100),
                child: Container(color: AppColors.amberYellow),
              ),
            const SizedBox(width: 2),
            if (fFlex > 0)
              Expanded(
                flex: (fFlex * 100).round().clamp(1, 100),
                child: Container(color: AppColors.mintGreen),
              ),
          ],
        ),
      ),
    );
  }

  Widget _macroPill(String label, String value, Color color, bool isLight) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightSurfaceMid : AppColors.darkSurfaceMid,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isLight
                        ? AppColors.lightTextMuted
                        : AppColors.darkTextMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isLight
                    ? AppColors.lightTextPrimary
                    : AppColors.darkTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _waterButton(String label, double amount) => Expanded(
        child: OutlinedButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() => water = (water + amount).clamp(0, 5));
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ),
      );

  Widget _buildMealPlanCard(
    String mealName,
    IconData icon,
    FoodRecord? food,
    bool isLight, {
    required VoidCallback onRandomize,
  }) {
    return InkWell(
      onTap: food != null ? () => _showFoodDetail(food) : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primaryBlue),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    mealName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                      color: isLight
                          ? AppColors.lightTextMuted
                          : AppColors.darkTextMuted,
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Đổi gợi ý $mealName',
                  child: IconButton(
                    onPressed: onRandomize,
                    tooltip: 'Đổi gợi ý $mealName',
                    visualDensity: VisualDensity.compact,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                    icon: Icon(
                      Icons.shuffle_rounded,
                      size: 17,
                      color: isLight
                          ? AppColors.primaryBlue
                          : AppColors.primaryBlueLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (food == null)
              Text(
                'Nhấn "Gợi ý mới"',
                style: TextStyle(
                  fontSize: 11,
                  color: isLight
                      ? AppColors.lightTextMuted
                      : AppColors.darkTextMuted,
                ),
              )
            else ...[
              if (food.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    food.imageUrl,
                    height: 66,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 66,
                      color: AppColors.primaryBlueGlow,
                      child: const Center(
                          child: Icon(Icons.restaurant,
                              color: AppColors.primaryBlue, size: 26)),
                    ),
                  ),
                )
              else
                Container(
                  height: 66,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueGlow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                      child: Icon(Icons.restaurant,
                          color: AppColors.primaryBlue, size: 26)),
                ),
              const SizedBox(height: 7),
              Text(
                food.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isLight
                      ? AppColors.lightTextPrimary
                      : AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${food.kcal}kcal · ${food.protein.toStringAsFixed(0)}P',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () => _saveFood(food),
                borderRadius: BorderRadius.circular(7),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      'Thêm vào nhật ký',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isLight
                            ? AppColors.primaryBlue
                            : AppColors.primaryBlueLight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _mealCard(MealRecord meal) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Dismissible(
          key: ValueKey(meal.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.delete_outline, color: AppColors.white, size: 22),
                SizedBox(width: 6),
                Text(
                  'XÓA',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          onDismissed: (_) async {
            await fitnessRepository.deleteMeal(meal.id);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.surface,
                content: Text(
                  'ĐÃ XÓA ${meal.items.toUpperCase()} KHỎI NHẬT KÝ',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
          },
          child: FitnessCard(
            padding: 14,
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlueGlow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.restaurant,
                    color: AppColors.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(meal.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 3),
                    Text(
                        '${meal.items} · ${meal.protein.toStringAsFixed(0)}g Protein',
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  ])),
              Text('${meal.kcal} KCAL',
                  style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w900,
                      fontSize: 13)),
            ]),
          ),
        ),
      );

  Widget _foodCard(FoodRecord food) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FitnessCard(
          padding: 12,
          onTap: () => _showFoodDetail(food),
          child: Row(
            children: [
              // Food image thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 60,
                  height: 60,
                  color: AppColors.surfaceMid,
                  child: food.imageUrl.isNotEmpty
                      ? Image.network(
                          food.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.restaurant,
                            color: AppColors.primaryBlue,
                            size: 26,
                          ),
                        )
                      : const Icon(
                          Icons.restaurant,
                          color: AppColors.primaryBlue,
                          size: 26,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (food.subCategory.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          food.subCategory.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    Text(
                      food.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${food.kcal} Kcal',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${food.protein.toStringAsFixed(0)}P · ${food.carbs.toStringAsFixed(0)}C · ${food.fat.toStringAsFixed(0)}F',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          food.serving,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Segmented Macro Bar Mini (Protein: Red, Carbs: Amber, Fat: Blue)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: SizedBox(
                        height: 3,
                        child: Row(
                          children: [
                            if (food.protein > 0)
                              Expanded(
                                flex: (food.protein * 4).round().clamp(1, 100),
                                child: Container(color: AppColors.primaryBlue),
                              ),
                            if (food.carbs > 0)
                              Expanded(
                                flex: (food.carbs * 4).round().clamp(1, 100),
                                child: Container(color: AppColors.warning),
                              ),
                            if (food.fat > 0)
                              Expanded(
                                flex: (food.fat * 9).round().clamp(1, 100),
                                child: Container(color: AppColors.info),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                tooltip: 'Ghi ${food.name}',
                icon: const Icon(Icons.add_circle,
                    color: AppColors.primaryBlue, size: 28),
                onPressed: () => _saveFood(food),
              ),
            ],
          ),
        ),
      );

  void _showFoodDetail(FoodRecord food) {
    double portionMultiplier = 1.0;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final totalKcal = (food.kcal * portionMultiplier).round();
          final totalProtein = food.protein * portionMultiplier;
          final totalCarbs = food.carbs * portionMultiplier;
          final totalFat = food.fat * portionMultiplier;

          return SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.82,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHighest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        // Large Food Image Banner
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMid,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: food.imageUrl.isNotEmpty
                                ? Image.network(
                                    food.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(
                                        Icons.restaurant,
                                        color: AppColors.primaryBlue,
                                        size: 48,
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.restaurant,
                                      color: AppColors.primaryBlue,
                                      size: 48,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          food.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlueGlow,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                food.category,
                                style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (food.subCategory.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceHighest,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  food.subCategory,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Benefits Callout Box
                        if (food.benefits.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMid,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.stars_rounded,
                                    color: AppColors.primaryBlue, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    food.benefits,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                      height: 1.4,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 18),

                        // Portion Multiplier Steppers
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'KHẨU PHẦN NẠP',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              '${(portionMultiplier * 100).round()}% (${food.serving})',
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            for (final mult in [0.5, 1.0, 1.5, 2.0])
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  child: OutlinedButton(
                                    onPressed: () {
                                      HapticFeedback.selectionClick();
                                      setSheetState(
                                          () => portionMultiplier = mult);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      backgroundColor: portionMultiplier == mult
                                          ? AppColors.primaryBlue
                                          : AppColors.surfaceMid,
                                      side: BorderSide(
                                        color: portionMultiplier == mult
                                            ? AppColors.primaryBlue
                                            : AppColors.border,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      '${mult}x',
                                      style: TextStyle(
                                        color: portionMultiplier == mult
                                            ? AppColors.white
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Macros Matrix
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMid,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('CALORIES',
                                      style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 4),
                                  Text('$totalKcal Kcal',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          color: AppColors.primaryBlue)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('PROTEIN',
                                      style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 4),
                                  Text('${totalProtein.toStringAsFixed(1)}g',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          color: AppColors.textPrimary)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('CARBS',
                                      style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 4),
                                  Text('${totalCarbs.toStringAsFixed(1)}g',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          color: AppColors.textPrimary)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('FAT',
                                      style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 4),
                                  Text('${totalFat.toStringAsFixed(1)}g',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          color: AppColors.textPrimary)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(ctx);
                      final messenger = ScaffoldMessenger.of(context);
                      await fitnessRepository.recordMeal(
                        title: 'BỮA DINH DƯỠNG (${food.category})',
                        items: '${food.name} (${portionMultiplier}x)',
                        kcal: totalKcal,
                        protein: totalProtein,
                        carbs: totalCarbs,
                        fat: totalFat,
                      );
                      if (!mounted) return;
                      setState(() {});
                      messenger.showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.surface,
                          content: Text(
                            'ĐÃ GHI ${food.name.toUpperCase()} (+$totalKcal KCAL)',
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      );
                    },
                    icon:
                        const Icon(Icons.add, color: AppColors.white, size: 20),
                    label: Text(
                      'GHI VÀO NHẬT KÝ HÔM NAY (+$totalKcal KCAL)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveFood(FoodRecord food) async {
    HapticFeedback.lightImpact();
    await fitnessRepository.recordMeal(
        title: 'BỮA NẠP THÊM',
        items: food.name,
        kcal: food.kcal,
        protein: food.protein,
        carbs: food.carbs,
        fat: food.fat);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('ĐÃ GHI ${food.name.toUpperCase()} VÀO NHẬT KÝ.')));
  }

  void _showAddMealDialog() {
    final name = TextEditingController();
    final kcal = TextEditingController();
    final protein = TextEditingController(text: '0');
    final carbs = TextEditingController(text: '0');
    final fat = TextEditingController(text: '0');
    showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: const Text('THÊM BỮA ĂN'),
              content: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                    controller: name,
                    decoration: const InputDecoration(
                        labelText: 'Tên món hoặc bữa ăn')),
                const SizedBox(height: 8),
                TextField(
                    controller: kcal,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Kcal')),
                const SizedBox(height: 8),
                TextField(
                    controller: protein,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Protein (g)')),
                const SizedBox(height: 8),
                TextField(
                    controller: carbs,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Carbs (g)')),
                const SizedBox(height: 8),
                TextField(
                    controller: fat,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Fat (g)')),
              ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('HỦY')),
                ElevatedButton(
                    onPressed: () async {
                      final value = int.tryParse(kcal.text);
                      if (name.text.trim().isEmpty ||
                          value == null ||
                          value < 0) {
                        return;
                      }
                      await fitnessRepository.recordMeal(
                          title: 'BỮA TỰ NHẬP',
                          items: name.text.trim(),
                          kcal: value,
                          protein: double.tryParse(protein.text) ?? 0,
                          carbs: double.tryParse(carbs.text) ?? 0,
                          fat: double.tryParse(fat.text) ?? 0);
                      if (!mounted) return;
                      setState(() {});
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                    },
                    child: const Text('LƯU')),
              ],
            ));
  }
}
