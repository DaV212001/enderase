import 'package:flutter/material.dart';

class BookmarkButton extends StatelessWidget {
  final bool isBookmarked;
  final bool isLoading;
  final VoidCallback onPressed;

  const BookmarkButton({
    super.key,
    required this.isBookmarked,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: isLoading ? null : onPressed, // just disables while loading
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Icon(
          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          key: ValueKey(isBookmarked),
          size: 28,
          color: isBookmarked
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
        ),
      ),
    );
  }
}
