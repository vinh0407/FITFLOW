import 'package:flutter/material.dart';
import 'package:vincecore/features/discover/presentation/pages/discover_page.dart';

/// Legacy export wrapper so all existing references to `ProgramsPage` continue
/// to work seamlessly while displaying the rich, comprehensive `DiscoverPage`.
class ProgramsPage extends StatelessWidget {
  const ProgramsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DiscoverPage();
  }
}
