import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitflow_contracts/fitflow_contracts.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/fitness_ui.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  final _name = TextEditingController();
  final _birthYear = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _targetWeight = TextEditingController();
  int _step = 0;
  String _gender = '';
  String _experience = 'BEGINNER';
  String _goal = 'BUILD CONSISTENCY';
  String _days = '3';
  String _minutes = '30';
  final Set<String> _equipment = {'BODYWEIGHT'};
  final Set<String> _focusAreas = {};

  bool _isHeightCm = true;
  bool _isWeightKg = true;
  late final FixedExtentScrollController _yearController;
  final int _currentYear = DateTime.now().year;
  late int _selectedYear;

  // Validation states
  String? _heightError;
  String? _weightError;
  String? _nameError;

  static const _titles = <String>[
    'BẮT ĐẦU',
    'CÁ NHÂN HÓA',
    'CÁ NHÂN HÓA',
    'CƠ THỂ BẠN',
    'CƠ THỂ BẠN',
    'KINH NGHIỆM',
    'MỤC TIÊU',
    'ƯU TIÊN',
    'LỊCH TRÌNH',
    'LỊCH TRÌNH',
    'DỤNG CỤ',
    'HOÀN TẤT',
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = _currentYear - 20;
    _yearController = FixedExtentScrollController(
      initialItem: _selectedYear - 1920,
    );
    _birthYear.text = _selectedYear.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    _name.dispose();
    _birthYear.dispose();
    _height.dispose();
    _weight.dispose();
    _targetWeight.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _next() {
    if (!_isStepValid(showErrors: true)) {
      HapticFeedback.heavyImpact();
      return;
    }
    if (_step == _titles.length - 1) {
      _finish();
      return;
    }
    setState(() => _step += 1);
    _controller.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  bool _isStepValid({bool showErrors = false}) {
    setState(() {
      _heightError = null;
      _weightError = null;
      _nameError = null;
    });

    switch (_step) {
      case 1:
        return _gender.isNotEmpty;
      case 2:
        return true;
      case 3:
        final value = double.tryParse(_height.text);
        if (value == null) {
          if (showErrors) {
            setState(() => _heightError = 'Vui lòng nhập chiều cao');
          }
          return false;
        }
        final cm = _isHeightCm ? value : value / 0.0328084;
        final isValid = cm >= 100 && cm <= 250;
        if (!isValid && showErrors) {
          setState(() => _heightError = 'Chiều cao không hợp lệ (100-250cm)');
        }
        return isValid;
      case 4:
        final value = double.tryParse(_weight.text);
        if (value == null) {
          if (showErrors) {
            setState(() => _weightError = 'Vui lòng nhập cân nặng');
          }
          return false;
        }
        final kg = _isWeightKg ? value : value / 2.20462;
        final isValid = kg >= 25 && kg <= 300;
        if (!isValid && showErrors) {
          setState(() => _weightError = 'Cân nặng không hợp lệ (25-300kg)');
        }
        return isValid;
      case 7:
        return _focusAreas.isNotEmpty;
      case 11:
        final isValid = _name.text.trim().isNotEmpty;
        if (!isValid && showErrors) {
          setState(() => _nameError = 'Vui lòng nhập tên của bạn');
        }
        return isValid;
      default:
        return true;
    }
  }

  Future<void> _finish() async {
    final age = _currentYear - _selectedYear;

    double hVal = double.tryParse(_height.text) ?? 170;
    if (!_isHeightCm) hVal = hVal / 0.0328084;

    double wVal = double.tryParse(_weight.text) ?? 70;
    if (!_isWeightKg) wVal = wVal / 2.20462;

    double twVal = double.tryParse(_targetWeight.text) ?? wVal;
    if (!_isWeightKg) twVal = twVal / 2.20462;

    final profile = FitflowProfile(
      name: _name.text.trim(),
      gender: _gender,
      age: '$age',
      heightCm: hVal.toStringAsFixed(1),
      weightKg: wVal.toStringAsFixed(1),
      targetWeightKg: twVal.toStringAsFixed(1),
      experience: _experience,
      equipment: _equipment.toList()..sort(),
      focusAreas: _focusAreas.toList()..sort(),
      sessionMinutes: _minutes,
      trainingGoal: _goal,
      trainingLevel: _experience,
      daysPerWeek: _days,
    );
    fitnessRepository.setMetric(_isHeightCm);
    await fitnessRepository.completeOnboarding(profile);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    if (_step > 0)
                      IconButton(
                        tooltip: 'Quay lại',
                        onPressed: () {
                          setState(() {
                            _step -= 1;
                            _heightError = null;
                            _weightError = null;
                            _nameError = null;
                          });
                          _controller.previousPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                          );
                        },
                        icon: const Icon(Icons.arrow_back),
                      )
                    else
                      const SizedBox(width: 48),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.2),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          _titles[_step],
                          key: ValueKey(_step),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: LinearProgressIndicator(
                  value: (_step + 1) / _titles.length,
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(2),
                  color: AppColors.primaryBlue,
                  backgroundColor: AppColors.surfaceHighest,
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _welcome(),
                    _choiceStep(
                        'GIỚI TÍNH CỦA BẠN?',
                        'Giúp FITFLOW cá nhân hóa các thuật toán tiêu thụ calo và đề xuất khối lượng tập.',
                        ['NAM', 'NỮ', 'KHÁC'],
                        _gender,
                        (value) => setState(() => _gender = value)),
                    _yearPickerStep('BẠN SINH NĂM NÀO?',
                        'Độ tuổi giúp chúng tôi xác định cường độ tim mạch an toàn cho bạn.'),
                    _numberStep(
                        'CHIỀU CAO HIỆN TẠI?',
                        'Thông tin này cực kỳ quan trọng để tính toán chỉ số BMI và tỷ lệ cơ thể.',
                        _height,
                        '170',
                        suffix: _isHeightCm ? 'CM' : 'FT',
                        errorText: _heightError,
                        showUnitToggle: true,
                        isMetric: _isHeightCm, onToggle: () {
                      final val = double.tryParse(_height.text);
                      if (val != null) {
                        _height.text = _isHeightCm
                            ? (val * 0.0328084).toStringAsFixed(1)
                            : (val / 0.0328084).toStringAsFixed(1);
                      }
                      setState(() => _isHeightCm = !_isHeightCm);
                    }),
                    _numberStep(
                        'CÂN NẶNG CỦA BẠN?',
                        'Đừng lo lắng, đây chỉ là điểm bắt đầu. Chúng ta sẽ cùng nhau cải thiện nó.',
                        _weight,
                        '70',
                        suffix: _isWeightKg ? 'KG' : 'LB',
                        errorText: _weightError,
                        showUnitToggle: true,
                        isMetric: _isWeightKg, onToggle: () {
                      final val = double.tryParse(_weight.text);
                      if (val != null) {
                        _weight.text = _isWeightKg
                            ? (val * 2.20462).toStringAsFixed(1)
                            : (val / 2.20462).toStringAsFixed(1);
                      }
                      setState(() => _isWeightKg = !_isWeightKg);
                    }),
                    _choiceStep(
                        'KINH NGHIỆM CỦA BẠN?',
                        'Chúng tôi sẽ điều chỉnh độ khó của bài tập và thời gian nghỉ dựa trên kinh nghiệm của bạn.',
                        ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'],
                        _experience,
                        (value) => setState(() => _experience = value),
                        descriptions: const [
                          'Mới bắt đầu hoặc quay lại sau thời gian dài.',
                          'Đã tập đều đặn và nắm vững kỹ thuật cơ bản.',
                          'Tự tin kiểm soát cường độ và kỹ thuật khó.'
                        ]),
                    _choiceStep(
                        'MỤC TIÊU LỚN NHẤT?',
                        'FITFLOW sẽ tối ưu hóa lịch tập để bạn đạt kết quả nhanh nhất.',
                        [
                          'BUILD CONSISTENCY',
                          'BUILD STRENGTH',
                          'IMPROVE CONDITIONING',
                          'IMPROVE MOBILITY'
                        ],
                        _goal,
                        (value) => setState(() => _goal = value),
                        labelBuilder: (v) => v
                            .replaceAll('IMPROVE ', '')
                            .replaceAll('BUILD ', '')),
                    _multiStep(
                        'VÙNG CƠ ƯU TIÊN?',
                        'Bạn muốn tập trung phát triển vùng cơ nào nhất trong giai đoạn này?',
                        const [
                          'CHEST',
                          'BACK',
                          'SHOULDERS',
                          'ARMS',
                          'LEGS',
                          'CORE'
                        ],
                        _focusAreas,
                        (value) => setState(() => _toggle(_focusAreas, value))),
                    _choiceStep(
                        'TẦN SUẤT TẬP LUYỆN?',
                        'Hãy chọn số buổi bạn chắc chắn có thể duy trì hàng tuần.',
                        ['2', '3', '4', '5', '6'],
                        _days,
                        (value) => setState(() => _days = value),
                        labelBuilder: (value) => '$value BUỔI / TUẦN'),
                    _choiceStep(
                        'THỜI GIAN MỖI BUỔI?',
                        'Chúng tôi sẽ sắp xếp số lượng bài tập phù hợp với quỹ thời gian của bạn.',
                        ['30', '45', '60', '90'],
                        _minutes,
                        (value) => setState(() => _minutes = value),
                        labelBuilder: (value) => '$value PHÚT'),
                    _multiStep(
                        'DỤNG CỤ HIỆN CÓ?',
                        'FITFLOW sẽ chỉ gợi ý các bài tập mà bạn có đủ dụng cụ để thực hiện.',
                        const [
                          'BODYWEIGHT',
                          'DUMBBELLS',
                          'BARBELL',
                          'CABLE',
                          'MACHINES',
                          'CARDIO'
                        ],
                        _equipment,
                        (value) => setState(() => _toggle(_equipment, value))),
                    _ready(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ScaleButton(
                    onTap: _next,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                          _step == _titles.length - 1
                              ? 'BẮT ĐẦU HÀNH TRÌNH'
                              : 'TIẾP TỤC',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _welcome() => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('F',
                style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 88,
                    fontWeight: FontWeight.w900,
                    height: .8)),
            const SizedBox(height: 32),
            const Text('CHÀO MỪNG\nĐẾN VỚI FITFLOW.',
                style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    letterSpacing: -1.0)),
            const SizedBox(height: 16),
            const Text(
                'Chúng tôi sẽ giúp bạn xây dựng một lộ trình tập luyện khoa học, cá nhân hóa hoàn toàn dựa trên cơ thể và mục tiêu của riêng bạn.',
                style: TextStyle(
                    color: AppColors.textSecondary, height: 1.5, fontSize: 15)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('ĐĂNG NHẬP VỚI FITFLOW ID',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
                child: const Text('TẠO TÀI KHOẢN MỚI',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      );

  Widget _yearPickerStep(String title, String hint) => _stepLayout(
        title,
        hint,
        SizedBox(
          height: 250,
          child: ListWheelScrollView.useDelegate(
            controller: _yearController,
            itemExtent: 60,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedYear = 1920 + index;
              });
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                final year = 1920 + index;
                if (year > _currentYear - 13) return null;
                final isSelected = year == _selectedYear;
                return Center(
                  child: Text(
                    year.toString(),
                    style: TextStyle(
                      fontSize: isSelected ? 34 : 24,
                      fontWeight:
                          isSelected ? FontWeight.w900 : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.textDisabled,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

  Widget _numberStep(
    String title,
    String hint,
    TextEditingController controller,
    String placeholder, {
    required String suffix,
    String? errorText,
    bool showUnitToggle = false,
    bool isMetric = true,
    VoidCallback? onToggle,
  }) =>
      _stepLayout(
        title,
        hint,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween(begin: 0, end: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              key: ValueKey(suffix),
              child: TextField(
                controller: controller,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 34),
                decoration: InputDecoration(
                    hintText: placeholder,
                    suffixText: suffix,
                    errorText: errorText,
                    errorStyle: const TextStyle(fontWeight: FontWeight.w600),
                    suffixStyle: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w900)),
                onChanged: (_) {
                  if (errorText != null) setState(() {});
                },
              ),
            ),
            if (showUnitToggle) ...[
              const SizedBox(height: 32),
              Row(
                children: [
                  Text(
                    isMetric
                        ? 'ĐANG DÙNG HỆ MÉT (CM/KG)'
                        : 'ĐANG DÙNG HỆ ANH (FT/LB)',
                    style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  ScaleButton(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onToggle?.call();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isMetric ? 'ĐỔI SANG FT/LB' : 'ĐỔI SANG CM/KG',
                        style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w800,
                            fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );

  Widget _choiceStep(String title, String hint, List<String> values,
          String selected, ValueChanged<String> onChanged,
          {List<String>? descriptions,
          String Function(String)? labelBuilder}) =>
      _stepLayout(
        title,
        hint,
        Column(
          children: List.generate(values.length, (index) {
            final value = values[index];
            final active = value == selected;
            return Semantics(
              button: true,
              selected: active,
              label: labelBuilder?.call(value) ?? value,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ScaleButton(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChanged(value);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primaryBlue
                          : (Theme.of(context).brightness == Brightness.light
                              ? AppColors.lightSurfaceMid
                              : AppColors.darkSurfaceMid),
                      border: Border.all(
                          color: active
                              ? AppColors.primaryBlue
                              : AppColors.border.withValues(alpha: 0.5),
                          width: 1.5),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: AppColors.primaryBlue
                                    .withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    child: Row(children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(labelBuilder?.call(value) ?? value,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: active
                                        ? AppColors.white
                                        : AppColors.textPrimary)),
                            if (descriptions != null) ...[
                              const SizedBox(height: 4),
                              Text(descriptions[index],
                                  style: TextStyle(
                                      color: active
                                          ? AppColors.white
                                              .withValues(alpha: 0.8)
                                          : AppColors.textMuted,
                                      fontSize: 12,
                                      height: 1.3)),
                            ],
                          ])),
                      if (active)
                        const Icon(Icons.check_circle, color: AppColors.white),
                    ]),
                  ),
                ),
              ),
            );
          }),
        ),
      );

  Widget _multiStep(String title, String hint, List<String> values,
          Set<String> selected, ValueChanged<String> onChanged) =>
      _stepLayout(
        title,
        hint,
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: values.map((value) {
            final active = selected.contains(value);
            return ScaleButton(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(value);
              },
              child: FilterChip(
                label: Text(value),
                selected: active,
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  onChanged(value);
                },
                selectedColor: AppColors.primaryBlue,
                backgroundColor:
                    Theme.of(context).brightness == Brightness.light
                        ? AppColors.lightSurfaceMid
                        : AppColors.darkSurfaceMid,
                checkmarkColor: AppColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                labelStyle: TextStyle(
                    color: active ? AppColors.white : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800),
                side: BorderSide(
                    color: active
                        ? AppColors.primaryBlue
                        : AppColors.border.withValues(alpha: 0.3),
                    width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }).toList(),
        ),
      );

  Widget _ready() => _stepLayout(
        'TÊN CỦA BẠN LÀ GÌ?',
        'Tên này sẽ xuất hiện trên lộ trình và trong các buổi tập của bạn.',
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                  labelText: 'TÊN CỦA BẠN',
                  hintText: 'VD: VINH',
                  errorText: _nameError),
              onChanged: (_) {
                if (_nameError != null) setState(() {});
              }),
          const SizedBox(height: 24),
          TextField(
              controller: _targetWeight,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                  labelText: 'CÂN NẶNG MỤC TIÊU (TÙY CHỌN)',
                  suffixText: _isWeightKg ? 'KG' : 'LB')),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.lightSurfaceMid
                    : AppColors.darkSurfaceMid,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.border.withValues(alpha: 0.3))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TỔNG QUAN LỘ TRÌNH',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppColors.primaryBlue)),
                const SizedBox(height: 12),
                Text(
                    '$_days BUỔI / TUẦN  ·  $_minutes PHÚT / BUỔI\n${_goal.replaceAll('IMPROVE ', '').replaceAll('BUILD ', '')}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        height: 1.6,
                        fontSize: 16)),
              ],
            ),
          ),
        ]),
      );

  Widget _stepLayout(String title, String hint, Widget content) => ListView(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: -0.8)),
          const SizedBox(height: 12),
          Text(hint,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.6,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 48),
          content,
        ],
      );

  void _toggle(Set<String> values, String value) {
    if (values.contains(value)) {
      values.remove(value);
    } else {
      values.add(value);
    }
  }
}
