import 'package:meta/meta.dart';

const int bmiMin = 18;
const int bmiMax = 35;

@immutable
class BmiProfile {
  const BmiProfile({required this.bmi, required this.label, required this.tone, required this.focus});
  final int bmi;
  final String label;
  final String tone;
  final String focus;
}

int roundBmi(num value) => value.round();

const bmiProfiles = <BmiProfile>[
  BmiProfile(bmi: 18, label: 'LOWER WEIGHT', tone: 'BUILD', focus: 'Foundational strength'),
  BmiProfile(bmi: 19, label: 'LOWER HEALTHY', tone: 'BUILD', focus: 'Strength + mobility'),
  BmiProfile(bmi: 20, label: 'HEALTHY RANGE', tone: 'BALANCE', focus: 'Full-body strength'),
  BmiProfile(bmi: 21, label: 'HEALTHY RANGE', tone: 'BALANCE', focus: 'Strength + conditioning'),
  BmiProfile(bmi: 22, label: 'HEALTHY RANGE', tone: 'PERFORM', focus: 'Strength + cardio'),
  BmiProfile(bmi: 23, label: 'HEALTHY RANGE', tone: 'PERFORM', focus: 'Progressive strength'),
  BmiProfile(bmi: 24, label: 'HEALTHY RANGE', tone: 'BALANCE', focus: 'Strength + conditioning'),
  BmiProfile(bmi: 25, label: 'UPPER HEALTHY', tone: 'PROGRESS', focus: 'Joint-friendly strength'),
  BmiProfile(bmi: 26, label: 'OVERWEIGHT RANGE', tone: 'PROGRESS', focus: 'Low-impact strength'),
  BmiProfile(bmi: 27, label: 'OVERWEIGHT RANGE', tone: 'PROGRESS', focus: 'Strength + walking'),
  BmiProfile(bmi: 28, label: 'OVERWEIGHT RANGE', tone: 'FOUNDATION', focus: 'Low-impact conditioning'),
  BmiProfile(bmi: 29, label: 'OVERWEIGHT RANGE', tone: 'FOUNDATION', focus: 'Mobility + strength'),
  BmiProfile(bmi: 30, label: 'HIGHER BMI RANGE', tone: 'FOUNDATION', focus: 'Supported movement'),
  BmiProfile(bmi: 31, label: 'HIGHER BMI RANGE', tone: 'FOUNDATION', focus: 'Seated + supported strength'),
  BmiProfile(bmi: 32, label: 'HIGHER BMI RANGE', tone: 'FOUNDATION', focus: 'Low-impact movement'),
  BmiProfile(bmi: 33, label: 'HIGHER BMI RANGE', tone: 'FOUNDATION', focus: 'Mobility + daily movement'),
  BmiProfile(bmi: 34, label: 'HIGHER BMI RANGE', tone: 'FOUNDATION', focus: 'Gentle full-body work'),
  BmiProfile(bmi: 35, label: 'HIGHER BMI RANGE', tone: 'FOUNDATION', focus: 'Supported full-body work'),
];
