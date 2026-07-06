import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';

/// A reusable, responsive search bar.
///
/// Adapts its horizontal padding/border radius to the available width
/// so it looks right on phones, tablets, and foldables, and can be
/// dropped into any screen (teams, members, meetings, etc.) by just
/// passing an [onChanged] callback.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.onChanged,
    this.controller,
    this.hintText = 'Search',
    this.onClear,
    this.horizontalPadding,
    this.autofocus = false,
  });

  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String hintText;
  final VoidCallback? onClear;
  final double? horizontalPadding;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Scale padding & radius a little with screen width.
        final hPad =
            horizontalPadding ??
            (width < 360
                ? 16.0
                : width < 600
                ? 20.0
                : 28.0);
        final radius = width < 360 ? 12.0 : 16.0;
        final fontSize = width < 360 ? 14.0 : 15.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: SizedBox(
            width: double.infinity,
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: TextStyle(fontSize: fontSize),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: fontSize,
                  color: Colors.grey.shade500,
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.textDark),
                suffixIcon: (controller?.text.isNotEmpty ?? false)
                    ? IconButton(
                        icon: Icon(Icons.close, color: AppColors.textDark),
                        onPressed: () {
                          controller?.clear();
                          onChanged('');
                          onClear?.call();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius),
                  borderSide: BorderSide(color: AppColors.textDark, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius),
                  borderSide: BorderSide(color: AppColors.textDark, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius),
                  borderSide: BorderSide(color: AppColors.textDark, width: 0.5),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
