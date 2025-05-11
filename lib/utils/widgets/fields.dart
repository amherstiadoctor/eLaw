import 'package:flutter/material.dart';
import 'package:sp_code/config/responsive_sizer/responsive_sizer.dart';
import 'package:sp_code/config/theme.dart';

enum InputKeys { input }

const inputKeysMap = {InputKeys.input: Key("input_field")};

class Input extends StatefulWidget {
  const Input({
    super.key,
    this.label = 'Input Label',
    this.placeholder = 'Input your answer',
    this.onTextChange,
    this.isError = false,
    this.errorMessage = '',
    this.textInputType = TextInputType.text,
    this.errorStyle,
    this.isPasswordField = false,
    this.contentPadding,
    this.initText,
    this.fillColor,
  });
  final EdgeInsets? contentPadding;
  final String label;
  final String placeholder;
  final String errorMessage;
  final bool isError;
  final Function(String)? onTextChange;
  final TextInputType textInputType;
  final TextStyle? errorStyle;
  final bool isPasswordField;
  final String? initText;
  final Color? fillColor;

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  late bool _isObscure;

  late TextEditingController textEditingController;

  @override
  void initState() {
    _isObscure = widget.isPasswordField;
    textEditingController = TextEditingController(text: widget.initText ?? "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = const TextStyle(
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w400,
      color: AppTheme.primary,
    );
    final placeholderStyle = const TextStyle(
      fontSize: 16,
      height: 20 / 16,
      fontWeight: FontWeight.w400,
      color: AppTheme.grey3,
    );
    final errorMessageStyle =
        widget.errorStyle ??
        const TextStyle(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w400,
          color: AppTheme.red,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: labelStyle, textScaleFactor: 1.responsiveW),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: TextField(
                key: inputKeysMap[InputKeys.input],
                obscureText: _isObscure,
                onChanged: widget.onTextChange,
                keyboardType: widget.textInputType,
                cursorColor: AppTheme.grey3,
                controller: textEditingController,
                decoration: InputDecoration(
                  fillColor: widget.fillColor ?? AppTheme.white,
                  isDense: true,
                  contentPadding:
                      widget.contentPadding ??
                      EdgeInsets.only(
                        top: 4.responsiveW,
                        bottom: 8.responsiveW,
                      ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primary),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryShade),
                  ),
                  focusedErrorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.red),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.red),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: widget.placeholder,
                  hintStyle: placeholderStyle,
                  errorText: widget.isError ? widget.errorMessage : null,
                  errorStyle: errorMessageStyle,
                  suffixIconConstraints: BoxConstraints.tight(
                    Size(20.responsiveW, 20.responsiveW),
                  ),
                  suffixIcon:
                      widget.isPasswordField
                          ? InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              _isObscure = !_isObscure;
                              setState(() {});
                            },
                            child:
                                _isObscure
                                    ? const Icon(Icons.visibility_rounded)
                                    : const Icon(Icons.visibility_off_rounded),
                          )
                          : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
