import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../app/admin_strings.dart';

/// en / hi / mr tabs in one control (T1.8).
class LocalisedTextField extends StatefulWidget {
  const LocalisedTextField({
    required this.value,
    required this.onChanged,
    required this.label,
    this.maxLines = 1,
    this.enabled = true,
    super.key,
  });

  final LocalisedText value;
  final ValueChanged<LocalisedText> onChanged;
  final String label;
  final int maxLines;
  final bool enabled;

  @override
  State<LocalisedTextField> createState() => _LocalisedTextFieldState();
}

class _LocalisedTextFieldState extends State<LocalisedTextField>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final TextEditingController _en;
  late final TextEditingController _hi;
  late final TextEditingController _mr;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _en = TextEditingController(text: widget.value.en);
    _hi = TextEditingController(text: widget.value.hi);
    _mr = TextEditingController(text: widget.value.mr);
  }

  @override
  void didUpdateWidget(LocalisedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_en, widget.value.en);
    _sync(_hi, widget.value.hi);
    _sync(_mr, widget.value.mr);
  }

  void _sync(TextEditingController controller, String next) {
    if (controller.text != next) {
      controller.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    _en.dispose();
    _hi.dispose();
    _mr.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      LocalisedText(en: _en.text, hi: _hi.text, mr: _mr.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              TabBar(
                controller: _tabs,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.accent,
                tabs: const [
                  Tab(text: AdminStrings.english),
                  Tab(text: AdminStrings.hindi),
                  Tab(text: AdminStrings.marathi),
                ],
              ),
              SizedBox(
                height: widget.maxLines > 1 ? 12.0 + widget.maxLines * 22 : 56,
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _box(_en),
                    _box(_hi),
                    _box(_mr),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _box(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: TextField(
        controller: controller,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        onChanged: (_) => _emit(),
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
