import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qlickcare/Utils/appcolors.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onLeadingPressed;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.onLeadingPressed,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    final double iconSize = isPortrait ? size.width * 0.07 : size.height * 0.08;
    final double titleSize = isPortrait
        ? size.width * 0.055
        : size.height * 0.065;

    return Container(
      height: isPortrait ? size.height * 0.14 : 78,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            size.width * 0.04,
            size.height * 0.01,
            size.width * 0.04,
            size.height * 0.02,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // LEFT ICON (default → menu)
              leading ??
                  IconButton(
                    onPressed: onLeadingPressed ?? () {},
                    icon: Icon(
                      FontAwesomeIcons.bars,
                      color: AppColors.buttonText,
                      size: iconSize,
                    ),
                  ),

              // TITLE
              Text(
                title,
                style: TextStyle(
                  color: AppColors.buttonText,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // RIGHT ACTIONS OR EMPTY SPACE
              actions != null
                  ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
                  : SizedBox(width: iconSize), // keeps alignment centered
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(95);
}
