import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/fitness_repository.dart';
import '../../../../../core/theme/app_colors.dart';

class AddWeightSheet extends StatefulWidget {
  const AddWeightSheet({super.key});

  @override
  State<AddWeightSheet> createState() => _AddWeightSheetState();
}

class _AddWeightSheetState extends State<AddWeightSheet> {
  late final TextEditingController _weightController;
  final _noteController = TextEditingController();
  final DateTime _selectedDate = DateTime.now();
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: fitnessRepository.currentWeight.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final text = _weightController.text.trim().replaceAll(',', '.');
    final val = double.tryParse(text);
    if (val == null || !val.isFinite || val < 25 || val > 300) {
      setState(() => _error = 'Vui lòng nhập cân nặng hợp lệ (25 - 300 kg)');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await fitnessRepository.logWeight(
        val,
        date: _selectedDate,
        notes: _noteController.text.trim(),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Chưa lưu được cân nặng. Vui lòng thử lại.';
        });
      }
      return;
    }
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã cập nhật cân nặng: ${val.toStringAsFixed(1)} kg 🎉'),
        backgroundColor: const Color(0xFF151515),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return SingleChildScrollView(
        child: Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 18),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(
                'GHI NHẬN CÂN NẶNG',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isLight
                      ? AppColors.lightTextPrimary
                      : AppColors.darkTextPrimary,
                ),
              )),
              IconButton(
                tooltip: 'Đóng',
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close_rounded,
                  color: isLight
                      ? AppColors.lightTextPrimary
                      : AppColors.darkTextPrimary,
                ),
              ),
            ],
          ),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _error!,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

          const SizedBox(height: 10),

          // Weight numeric input
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: isLight
                          ? AppColors.lightTextPrimary
                          : AppColors.darkTextPrimary,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Cân nặng (kg)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Text(
                  'kg',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isLight
                        ? AppColors.lightTextMuted
                        : AppColors.darkTextMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Note input
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'Ghi chú (VD: Buổi sáng sau khi thức dậy...)',
              hintStyle: TextStyle(
                fontSize: 13,
                color: isLight
                    ? AppColors.lightTextMuted
                    : AppColors.darkTextMuted,
              ),
              filled: true,
              fillColor:
                  isLight ? const Color(0xFFF8F9FA) : const Color(0xFF242426),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'LƯU CÂN NẶNG',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
