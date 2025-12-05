import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/app_text_style.dart';
import 'custom_button.dart';
import 'input_field.dart';

class EntityTypeDialog extends StatefulWidget {
  final Function(String entityType, String? jshshir, String? stir, String? mfo) onContinue;

  const EntityTypeDialog({
    Key? key,
    required this.onContinue,
  }) : super(key: key);

  @override
  State<EntityTypeDialog> createState() => _EntityTypeDialogState();
}

class _EntityTypeDialogState extends State<EntityTypeDialog> {
  String? _selectedEntityType; // 'individual' or 'legal'
  final TextEditingController _jshshirController = TextEditingController();
  final TextEditingController _stirController = TextEditingController();
  final TextEditingController _mfoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen to text changes to update button state
    _jshshirController.addListener(_onTextChanged);
    _stirController.addListener(_onTextChanged);
    _mfoController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {}); // Trigger rebuild to update button state
  }

  @override
  void dispose() {
    _jshshirController.removeListener(_onTextChanged);
    _stirController.removeListener(_onTextChanged);
    _mfoController.removeListener(_onTextChanged);
    _jshshirController.dispose();
    _stirController.dispose();
    _mfoController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    if (_selectedEntityType == null) {
      return false;
    }
    if (_selectedEntityType == 'individual') {
      return _jshshirController.text.trim().isNotEmpty;
    } else if (_selectedEntityType == 'legal') {
      return _stirController.text.trim().isNotEmpty && 
             _mfoController.text.trim().isNotEmpty;
    }
    return false;
  }

  void _handleContinue() {
    if (!_validateInputs()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Iltimos, barcha maydonlarni to\'ldiring'),
          backgroundColor: AppColor.errorRed,
        ),
      );
      return;
    }

    Navigator.of(context).pop();
    widget.onContinue(
      _selectedEntityType!,
      _selectedEntityType == 'individual' ? _jshshirController.text.trim() : null,
      _selectedEntityType == 'legal' ? _stirController.text.trim() : null,
      _selectedEntityType == 'legal' ? _mfoController.text.trim() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Yuridik shaxs turini tanlang",
                style: boldBlack.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Radio option for Individual
              _buildRadioOption(
                title: "Физическое лицо",
                value: 'individual',
                onTap: () {
                  setState(() {
                    _selectedEntityType = 'individual';
                  });
                },
              ),
              const SizedBox(height: 12),
              // Radio option for Legal entity
              _buildRadioOption(
                title: "Юридическое лицо",
                value: 'legal',
                onTap: () {
                  setState(() {
                    _selectedEntityType = 'legal';
                  });
                },
              ),
              const SizedBox(height: 24),
              // Conditional input fields
              if (_selectedEntityType == 'individual') ...[
                InputField(
                  title: "JSHSHIR",
                  value: _jshshirController,
                  onChange: (value) {}, // InputField doesn't use this, we use listener instead
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'JSHSHIR kiriting';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  maxLength: 14,
                  hint: "JSHSHIR raqamini kiriting",
                ),
              ] else if (_selectedEntityType == 'legal') ...[
                InputField(
                  title: "STIR",
                  value: _stirController,
                  onChange: (value) {}, // InputField doesn't use this, we use listener instead
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'STIR kiriting';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  maxLength: 9,
                  hint: "STIR raqamini kiriting",
                ),
                const SizedBox(height: 10),
                InputField(
                  title: "МФО",
                  value: _mfoController,
                  onChange: (value) {}, // InputField doesn't use this, we use listener instead
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'МФО kiriting';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  hint: "МФО raqamini kiriting",
                ),
              ],
              const SizedBox(height: 24),
              // Continue button
              Button(
                title: "Davom etish",
                onPress: _handleContinue,
                disable: !_validateInputs(),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Bekor qilish",
                  style: mediumBlack.copyWith(color: AppColor.secondaryText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedEntityType == value;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColor.primary.withOpacity(0.1) 
              : AppColor.grayBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? AppColor.primary 
                : AppColor.primary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColor.primary : AppColor.secondaryText,
                  width: 2,
                ),
                color: isSelected ? AppColor.primary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: AppColor.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: mediumBlack.copyWith(
                  fontSize: 16,
                  color: isSelected ? AppColor.primary : AppColor.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

