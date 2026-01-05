import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class UniversalFormField extends StatefulWidget {
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final String? suffixText;
  final String? prefixText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final void Function(String)? onFieldSubmitted;
  final VoidCallback? onTap;
  final TextAlign textAlign;
  final TextStyle? hintStyle;
  final TextStyle? inputTextStyle;
  final bool isObscureText;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final Color? backgroundColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final bool enabled;

  // Dropdown Properties
  final bool hasDropdown;
  final List<String>? dropdownItems;
  final String? initialDropdownValue;
  final Function(String?)? onDropdownChanged;
  final Function(String?)? mealname;
  final Map<String, String>? dropdownItemLabels;

  // Date Picker Properties
  final bool isDatePicker;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime)? onDateSelected;
  final String? dateFormat;

  // Multi-Select Properties
  final bool isMultiSelect;
  final List<String>? multiSelectItems;
  final List<String>? initialSelectedItems;
  final Function(List<String>)? onMultiSelectChanged;
  final String? multiSelectDialogTitle;

  const UniversalFormField({

    super.key,
    this.inputFormatters,

    this.hintText,
    this.suffixText,
    this.prefixText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.textAlign = TextAlign.start,
    this.hintStyle,
    this.inputTextStyle,
    this.isObscureText = false,
    this.contentPadding,
    this.focusedBorder,
    this.enabledBorder,
    this.backgroundColor,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.hasDropdown = false,
    this.dropdownItems,
    this.initialDropdownValue,
    this.onDropdownChanged,
    this.mealname,
    this.dropdownItemLabels,
    this.isDatePicker = false,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.dateFormat,
    this.isMultiSelect = false,
    this.multiSelectItems,
    this.initialSelectedItems,
    this.onMultiSelectChanged,
    this.multiSelectDialogTitle,
  });

  @override
  State<UniversalFormField> createState() => _UniversalFormFieldState();
}

class _UniversalFormFieldState extends State<UniversalFormField> {
  String? selectedDropdownValue;
  DateTime? selectedDate;
  List<String> selectedMultiItems = [];
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    selectedDropdownValue = widget.initialDropdownValue;
    selectedDate = widget.initialDate ?? DateTime.now();
    selectedMultiItems = widget.initialSelectedItems ?? [];
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDatePicker) {
      return _buildDatePickerField();
    }

    if (widget.isMultiSelect) {
      return _buildMultiSelectField();
    }

    if (widget.hasDropdown) {
      return _buildDropdownField();
    }

    return _buildTextFormField();
  }

  Widget _buildTextFormField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: Color(0xFF7C3AED).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: TextFormField(
        inputFormatters: widget.inputFormatters,
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onFieldSubmitted,
        onTap: widget.onTap,
        validator: widget.validator,
        obscureText: widget.isObscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textAlign: widget.textAlign,
        readOnly: widget.readOnly,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        enabled: widget.enabled,
        style: widget.inputTextStyle ?? TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: widget.hintStyle ?? TextStyle(fontSize: 14, color: Colors.grey[500]),
          suffixText: widget.suffixText,
          prefixText: widget.prefixText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          filled: true,
          fillColor: widget.backgroundColor ?? (_isFocused ? Color(0xFF7C3AED).withOpacity(0.05) : Colors.grey[50]),
          contentPadding: widget.contentPadding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: widget.enabledBorder ?? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
          focusedBorder: widget.focusedBorder ?? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFF7C3AED), width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red, width: 1)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red, width: 2)),
          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: widget.backgroundColor ?? Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedDropdownValue,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'اختر من القائمة',
          hintStyle: widget.hintStyle ?? TextStyle(fontSize: 14, color: Colors.grey[500]),
          prefixIcon: widget.prefixIcon,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: widget.contentPadding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        style: widget.inputTextStyle ?? TextStyle(fontSize: 16, color: Colors.black87),
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
        isExpanded: true,
        validator: widget.validator,
        items: widget.dropdownItems?.map((String item) {
          String displayText = widget.dropdownItemLabels?[item] ?? item;
          return DropdownMenuItem<String>(value: item, child: Text(displayText, overflow: TextOverflow.ellipsis));
        }).toList(),
        onChanged: widget.enabled ? (String? value) {
          setState(() => selectedDropdownValue = value);
          widget.onDropdownChanged?.call(value);
          widget.mealname?.call(value);
          if (widget.onChanged != null && value != null) widget.onChanged!(value);
          widget.controller?.text = value ?? '';
        } : null,
      ),
    );
  }

  Widget _buildDatePickerField() {
    final format = widget.dateFormat ?? 'dd/MM/yyyy';
    final displayDate = widget.controller?.text.isNotEmpty == true
        ? widget.controller!.text
        : DateFormat(format, 'ar').format(selectedDate!);

    return InkWell(
      onTap: widget.enabled ? _selectDate : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: widget.backgroundColor ?? Colors.grey[50],
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        padding: widget.contentPadding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            if (widget.prefixIcon != null) ...[widget.prefixIcon!, SizedBox(width: 12)],
            Expanded(child: Text(displayDate, style: widget.inputTextStyle ?? TextStyle(fontSize: 16, color: Colors.black87))),
            Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      locale: Locale('ar'), // ⭐
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Color(0xFF7C3AED), onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      widget.onDateSelected?.call(picked);
      if (widget.controller != null) {
        final format = widget.dateFormat ?? 'dd/MM/yyyy';
        widget.controller!.text = DateFormat(format, 'ar').format(picked); // ⭐
      }
    }
  }

  Widget _buildMultiSelectField() {
    final selectedCount = selectedMultiItems.length;
    final displayText = selectedCount == 0 ? widget.hintText ?? 'اختر من القائمة' : '$selectedCount ${selectedCount == 1 ? 'عنصر محدد' : 'عناصر محددة'}';

    return InkWell(
      onTap: widget.enabled ? _showMultiSelectDialog : null,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: widget.backgroundColor ?? Colors.grey[50], border: Border.all(color: Colors.grey[300]!, width: 1)),
        padding: widget.contentPadding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            if (widget.prefixIcon != null) ...[widget.prefixIcon!, SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayText, style: TextStyle(fontSize: 16, color: selectedCount == 0 ? Colors.grey[500] : Colors.black87)),
                  if (selectedCount > 0) ...[
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: selectedMultiItems.map((item) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Color(0xFF7C3AED).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(item, style: TextStyle(fontSize: 12, color: Color(0xFF7C3AED))),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Future<void> _showMultiSelectDialog() async {
    final List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) => MultiSelectDialog(
        title: widget.multiSelectDialogTitle ?? 'اختر العناصر',
        items: widget.multiSelectItems ?? [],
        initialSelectedItems: selectedMultiItems,
      ),
    );

    if (result != null) {
      setState(() => selectedMultiItems = result);
      widget.onMultiSelectChanged?.call(result);
      widget.controller?.text = result.join(', ');
    }
  }
}

class MultiSelectDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> initialSelectedItems;

  const MultiSelectDialog({super.key, required this.title, required this.items, required this.initialSelectedItems});

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.initialSelectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            final isSelected = _selectedItems.contains(item);
            return CheckboxListTile(
              title: Text(item),
              value: isSelected,
              activeColor: Color(0xFF7C3AED),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) _selectedItems.add(item); else _selectedItems.remove(item);
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء', style: TextStyle(color: Colors.grey[700]))),
        ElevatedButton(onPressed: () => Navigator.pop(context, _selectedItems), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF7C3AED), foregroundColor: Colors.white), child: Text('تأكيد')),
      ],
    );
  }
}
