import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/app_theme.dart';

class LanguageSelector extends StatelessWidget {
  final String sourceLanguage;
  final String targetLanguage;
  final List<String> availableLanguages;
  final VoidCallback onSwap;
  final Function(String) onSourceChanged;
  final Function(String) onTargetChanged;

  const LanguageSelector({
    super.key,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.availableLanguages,
    required this.onSwap,
    required this.onSourceChanged,
    required this.onTargetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Source language
          Expanded(
            child: _buildLanguageDropdown(
              currentLanguage: sourceLanguage,
              availableLanguages: availableLanguages,
              onChanged: onSourceChanged,
            ),
          ),
          
          // Swap button
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.rightLeft,
              size: 12,
              color: AppTheme.secondaryTextColor,
            ),
            onPressed: onSwap,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: EdgeInsets.zero,
          ),
          
          // Target language
          Expanded(
            child: _buildLanguageDropdown(
              currentLanguage: targetLanguage,
              availableLanguages: availableLanguages,
              onChanged: onTargetChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown({
    required String currentLanguage,
    required List<String> availableLanguages,
    required Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentLanguage,
          isDense: true,
          isExpanded: true,
          icon: const Icon(
            Icons.arrow_drop_down,
            size: 18,
            color: AppTheme.secondaryTextColor,
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textColor,
          ),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
          items: availableLanguages
              .map((language) => DropdownMenuItem(
                    value: language,
                    child: Text(language),
                  ))
              .toList(),
        ),
      ),
    );
  }
}