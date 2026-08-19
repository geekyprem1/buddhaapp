import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../app/admin_strings.dart';

class ModulePlaceholderPage extends StatelessWidget {
  const ModulePlaceholderPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: EmptyState(
        icon: Icons.edit_note_outlined,
        message: '$title\n\n${AdminStrings.comingNext}',
      ),
    );
  }
}
