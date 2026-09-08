import 'package:flutter/material.dart';
import 'package:fitflow_contracts/fitflow_contracts.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/fitness_ui.dart';
import '../../../../widgets/one_rm_calculator_modal.dart';
import '../../../progress/domain/models/weight_record_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool notifications = true;
  bool haptics = true;
  bool healthSync = true;
  double minPlate = 2.5;

  @override
  Widget build(BuildContext context) {
    final profile = fitnessRepository.profile;
    final displayName =
        profile.name.trim().isEmpty ? 'ATHLETE' : profile.name.toUpperCase();

    final smm = fitnessRepository.skeletalMuscleMass;
    final bodyFat = fitnessRepository.bodyFatPercentage;

    return Scaffold(
      body: AnimatedBuilder(
        animation: fitnessRepository,
        builder: (context, _) {
          final isMetric = fitnessRepository.useMetric;
          final weight = fitnessRepository.currentWeight;
          final displayWeight = isMetric ? weight : weight * 2.20462;
          final weightUnit = isMetric ? 'kg' : 'lb';
          final displaySmm = isMetric ? smm : smm * 2.20462;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              children: [
                const Text(
                  'HỒ SƠ CÁ NHÂN',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Athlete Header Card - High Prominence
                FitnessCard(
                  padding: 20,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              gradient: AppColors.blueGradient,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                displayName.substring(0, 1),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlueGlow,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'BUILDER',
                                        style: TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Big 3 Tổng: 347.5 $weightUnit · Top 15%',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: AppColors.textMuted),
                            onPressed: _showEditProfileDialog,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'CẤP ĐỘ LUYỆN TẬP',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            '${fitnessRepository.history.length} BUỔI ĐÃ GHI NHẬN',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ThinProgress(
                          value: (fitnessRepository.history.length / 20)
                              .clamp(0.1, 1.0)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Section 1: Body Composition Metrics - Medium Prominence
                const SectionTitle('CHỈ SỐ THỂ CHẤT',
                    subtitle: 'Theo dõi sự thay đổi vóc dáng'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'CÂN NẶNG',
                        displayWeight.toStringAsFixed(1),
                        weightUnit,
                        'Mục tiêu: ${isMetric ? "80.0" : "176.4"} $weightUnit',
                        AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'CƠ XƯƠNG (SMM)',
                        displaySmm.toStringAsFixed(1),
                        weightUnit,
                        '+0.6$weightUnit tuần này',
                        AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'TỶ LỆ MỠ',
                        bodyFat.toStringAsFixed(1),
                        '%',
                        'Khỏe mạnh',
                        AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FitnessCard(
                  padding: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TIẾN TRÌNH CÂN NẶNG 7 TUẦN',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            '+1.4 $weightUnit',
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildWeightSparkline(isMetric, weightUnit),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Section: Tools & Utilities
                const SectionTitle('CÔNG CỤ TẬP LUYỆN'),
                FitnessCard(
                  padding: 4,
                  child: Column(
                    children: [
                      SettingTile(
                        title: 'Máy tính 1RM',
                        subtitle: 'Ước tính tải trọng tối đa',
                        icon: Icons.calculate_outlined,
                        showDivider: false,
                        onTap: () => OneRmCalculatorModal.show(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Section 4: Settings - Low Prominence (List Style)
                const SectionTitle('CÀI ĐẶT ỨNG DỤNG'),
                FitnessCard(
                  padding: 4,
                  child: Column(
                    children: [
                      SettingTile(
                        title: 'Thông báo nhắc nhở',
                        subtitle: 'Lịch tập và uống nước',
                        icon: Icons.notifications_outlined,
                        trailing: Switch(
                          value: notifications,
                          onChanged: (v) => setState(() => notifications = v),
                          activeTrackColor:
                              AppColors.primaryBlue.withValues(alpha: 0.5),
                          activeThumbColor: AppColors.primaryBlue,
                        ),
                      ),
                      SettingTile(
                        title: 'Rung phản hồi (Haptic)',
                        subtitle: 'Phản hồi khi chạm và tập',
                        icon: Icons.vibration,
                        trailing: Switch(
                          value: haptics,
                          onChanged: (v) => setState(() => haptics = v),
                          activeTrackColor:
                              AppColors.primaryBlue.withValues(alpha: 0.5),
                          activeThumbColor: AppColors.primaryBlue,
                        ),
                      ),
                      SettingTile(
                        title: 'Đồng bộ sức khỏe',
                        subtitle: 'Apple Health / Google Fit',
                        icon: Icons.favorite_border,
                        trailing: Switch(
                          value: healthSync,
                          onChanged: (v) => setState(() => healthSync = v),
                          activeTrackColor:
                              AppColors.primaryBlue.withValues(alpha: 0.5),
                          activeThumbColor: AppColors.primaryBlue,
                        ),
                      ),
                      SettingTile(
                        title: 'Tạ đĩa nhỏ nhất',
                        subtitle: '${minPlate.toStringAsFixed(1)} $weightUnit',
                        icon: Icons.fitness_center,
                        onTap: _showMinPlateDialog,
                      ),
                      SettingTile(
                        title: 'Đơn vị tính',
                        subtitle:
                            isMetric ? 'Kilogram & Centimet' : 'Pound & Foot',
                        icon: Icons.straighten,
                        onTap: () => fitnessRepository.toggleUnits(),
                      ),
                      SettingTile(
                        title: 'Giao diện',
                        subtitle:
                            Theme.of(context).brightness == Brightness.dark
                                ? 'Tối · Chạm để dùng giao diện sáng'
                                : 'Sáng · Chạm để dùng giao diện tối',
                        icon: Theme.of(context).brightness == Brightness.dark
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        showDivider: false,
                        onTap: () => fitnessRepository.setThemeMode(
                          Theme.of(context).brightness == Brightness.dark
                              ? ThemeMode.light
                              : ThemeMode.dark,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                // Sign Out Button
                TextButton.icon(
                  onPressed: _confirmLogout,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text(
                    'ĐĂNG XUẤT TÀI KHOẢN',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                const Center(
                  child: Text(
                    'VINCECORE FITNESS v2.4.0\nTRAIN SMARTER. MOVE BETTER.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: 10,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(
      String label, String value, String unit, String sub, Color color) {
    return FitnessCard(
      padding: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              Text(
                ' $unit',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSparkline(bool isMetric, String weightUnit) {
    final analysis = fitnessRepository.getWeightAnalysis(WeightPeriod.weekly);
    final weights = analysis.points
        .map((point) => isMetric ? point.weightKg : point.weightKg * 2.20462)
        .toList(growable: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        gradient: AppColors.darkCardGradient,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderBlue),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 62,
            child: CustomPaint(
              painter: _WeightSparklinePainter(weights),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${weights.first.toStringAsFixed(1)} $weightUnit',
                style: const TextStyle(
                  color: AppColors.gray300,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${weights.last.toStringAsFixed(1)} $weightUnit · THIS WEEK',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMinPlateDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('TẠ ĐĨA NHỎ NHẤT',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1.25, 2.5, 5.0].map((plate) {
            final isMetric = fitnessRepository.useMetric;
            final displayPlate = isMetric ? plate : plate * 2.20462;
            final unit = isMetric ? 'kg' : 'lb';
            return ListTile(
              title: Text('${displayPlate.toStringAsFixed(2)} $unit',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              trailing: minPlate == plate
                  ? const Icon(Icons.check_circle, color: AppColors.primaryBlue)
                  : null,
              onTap: () {
                setState(() => minPlate = plate);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final current = fitnessRepository.profile;
    final isMetric = fitnessRepository.useMetric;

    final hVal = double.tryParse(current.heightCm) ?? 170;
    final displayH = isMetric ? hVal : hVal * 0.0328084;

    final wVal = double.tryParse(current.weightKg) ?? 70;
    final displayW = isMetric ? wVal : wVal * 2.20462;

    final twVal = double.tryParse(current.targetWeightKg) ?? wVal;
    final displayTW = isMetric ? twVal : twVal * 2.20462;

    final nameCtrl = TextEditingController(text: current.name);
    final ageCtrl = TextEditingController(text: current.age);
    final heightCtrl = TextEditingController(text: displayH.toStringAsFixed(1));
    final weightCtrl = TextEditingController(text: displayW.toStringAsFixed(1));
    final targetWeightCtrl =
        TextEditingController(text: displayTW.toStringAsFixed(1));

    var goal = current.trainingGoal;
    var level = current.trainingLevel;
    var days = current.daysPerWeek;

    showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
                backgroundColor: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: const Text('CHỈNH SỬA HỒ SƠ',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Tên hiển thị'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: ageCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Tuổi'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: heightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                            labelText: 'Chiều cao (${isMetric ? "cm" : "ft"})'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                            labelText:
                                'Cân nặng hiện tại (${isMetric ? "kg" : "lb"})'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: targetWeightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                            labelText:
                                'Cân nặng mục tiêu (${isMetric ? "kg" : "lb"})'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: goal,
                        decoration: const InputDecoration(
                            labelText: 'Mục tiêu tập luyện'),
                        dropdownColor: AppColors.surfaceMid,
                        items: const [
                          'BUILD CONSISTENCY',
                          'BUILD STRENGTH',
                          'IMPROVE CONDITIONING',
                          'IMPROVE MOBILITY'
                        ]
                            .map((value) => DropdownMenuItem(
                                value: value, child: Text(value)))
                            .toList(),
                        onChanged: (value) =>
                            setDialogState(() => goal = value ?? goal),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: level,
                        decoration:
                            const InputDecoration(labelText: 'Trình độ'),
                        dropdownColor: AppColors.surfaceMid,
                        items: const ['BEGINNER', 'INTERMEDIATE', 'ADVANCED']
                            .map((value) => DropdownMenuItem(
                                value: value, child: Text(value)))
                            .toList(),
                        onChanged: (value) =>
                            setDialogState(() => level = value ?? level),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: days,
                        decoration: const InputDecoration(
                            labelText: 'Buổi tập mỗi tuần'),
                        dropdownColor: AppColors.surfaceMid,
                        items: const ['2', '3', '4', '5', '6']
                            .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text('$value buổi / tuần')))
                            .toList(),
                        onChanged: (value) =>
                            setDialogState(() => days = value ?? days),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('HỦY',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      double h = double.tryParse(heightCtrl.text) ?? displayH;
                      if (!isMetric) h = h / 0.0328084;

                      double w = double.tryParse(weightCtrl.text) ?? displayW;
                      if (!isMetric) w = w / 2.20462;

                      double tw =
                          double.tryParse(targetWeightCtrl.text) ?? displayTW;
                      if (!isMetric) tw = tw / 2.20462;

                      await fitnessRepository.saveProfile(FitflowProfile(
                        name: nameCtrl.text.trim(),
                        gender: current.gender,
                        age: ageCtrl.text.trim(),
                        heightCm: h.toStringAsFixed(1),
                        weightKg: w.toStringAsFixed(1),
                        targetWeightKg: tw.toStringAsFixed(1),
                        experience: current.experience,
                        equipment: current.equipment,
                        focusAreas: current.focusAreas,
                        sessionMinutes: current.sessionMinutes,
                        restingHeartRate: current.restingHeartRate,
                        healthNotes: current.healthNotes,
                        trainingGoal: goal,
                        trainingLevel: level,
                        daysPerWeek: days,
                      ));
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      minimumSize: const Size(100, 44),
                    ),
                    child: const Text('LƯU'),
                  ),
                ],
              )),
    );
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('ĐĂNG XUẤT?',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text(
          'Dữ liệu buổi tập và chỉ số của bạn vẫn được lưu trên thiết bị này.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await fitnessRepository.signOut();
              if (!mounted) return;
              Navigator.of(context).pop();
            },
            child: const Text(
              'ĐĂNG XUẤT',
              style: TextStyle(
                  color: AppColors.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightSparklinePainter extends CustomPainter {
  const _WeightSparklinePainter(this.weights);

  final List<double> weights;

  @override
  void paint(Canvas canvas, Size size) {
    if (weights.length < 2) return;
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final range =
        (maxWeight - minWeight).abs() < 0.1 ? 1.0 : maxWeight - minWeight;
    final points = <Offset>[];

    for (var index = 0; index < weights.length; index++) {
      final x = size.width * index / (weights.length - 1);
      final normalized = (weights[index] - minWeight) / range;
      final y = size.height - 6 - normalized * (size.height - 16);
      points.add(Offset(x, y));
    }

    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath
      ..lineTo(points.last.dx, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = AppColors.primaryGradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        )
        ..color = AppColors.primaryBlueGlow,
    );

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    for (final point in points) {
      canvas.drawCircle(point, 3, Paint()..color = AppColors.primaryBlue);
      canvas.drawCircle(
        point,
        1.2,
        Paint()..color = AppColors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeightSparklinePainter oldDelegate) =>
      oldDelegate.weights != weights;
}
