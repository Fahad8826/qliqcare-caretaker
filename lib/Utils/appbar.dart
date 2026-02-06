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
  final double topPadding = MediaQuery.of(context).padding.top;

  return Container(
    height: preferredSize.height + topPadding,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            leading ??
                IconButton(
                  onPressed: onLeadingPressed ?? () {},
                  icon: const Icon(
                    FontAwesomeIcons.bars,
                    color: AppColors.buttonText,
                    size: 22,
                  ),
                ),

            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.buttonText,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            if (actions != null && actions!.isNotEmpty)
              Row(mainAxisSize: MainAxisSize.min, children: actions!)
            else
              const SizedBox(width: 48),
          ],
        ),
      ),
    ),
  );
}

  @override
  Size get preferredSize => const Size.fromHeight(88);
}