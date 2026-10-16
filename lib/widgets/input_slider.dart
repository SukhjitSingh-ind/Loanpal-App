import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputSlider extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String Function(double)? formatLabel;
  final String prefix;
  final String suffix;
  final bool isPercentage;

  const InputSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.formatLabel,
    this.prefix = '',
    this.suffix = '',
    this.isPercentage = false,
  });

  @override
  State<InputSlider> createState() => _InputSliderState();
}

class _InputSliderState extends State<InputSlider> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _submitText();
      }
    });
  }

  @override
  void didUpdateWidget(InputSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // INFO: Only sync the text field from the slider when the field is not
    // focused; otherwise the user's in-progress typing would be overwritten.
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      _controller.text = _formatValue(widget.value);
    }
  }

  String _formatValue(double val) {
    if (widget.isPercentage) {
      return val.toStringAsFixed(1);
    }
    return val.toInt().toString();
  }

  void _submitText() {
    final String text = _controller.text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (text.isEmpty) {
      _controller.text = _formatValue(widget.value);
      return;
    }

    final double? val = double.tryParse(text);
    if (val != null) {
      final double clamped = val.clamp(widget.min, widget.max);
      widget.onChanged(clamped);
      _controller.text = _formatValue(clamped);
    } else {
      _controller.text = _formatValue(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: widget.isPercentage,
                ),
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  prefixText: widget.prefix,
                  suffixText: widget.suffix,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
                onSubmitted: (_) => _submitText(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: widget.value,
          min: widget.min,
          max: widget.max,
          divisions: widget.divisions,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
