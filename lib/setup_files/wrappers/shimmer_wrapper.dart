import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWrapper extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final bool? isEnabled;

  const ShimmerWrapper({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return isEnabled == true ? _buildShimmerLayout(child, context) : child;
  }

  Widget _buildShimmerLayout(Widget widget, BuildContext context) {
    // Check for Padding widget and apply padding to its child recursively
    if (widget is Padding) {
      return Padding(
        padding: widget.padding,
        child: _buildShimmerLayout(widget.child!, context),
      );
    }
    if (widget is Expanded) {
      return Expanded(child: _buildShimmerLayout(widget.child, context));
    }

    // Traverse through the widget tree for Column or Row
    if (widget is Column || widget is Row) {
      if (widget is Column) {
        return Column(
          mainAxisSize: widget.mainAxisSize,
          crossAxisAlignment: (widget).crossAxisAlignment,
          mainAxisAlignment: (widget).mainAxisAlignment,
          children: (widget as MultiChildRenderObjectWidget).children
              .map((child) => _buildShimmerLayout(child, context))
              .toList(),
        );
      } else {
        return Row(
          mainAxisSize: (widget as Row).mainAxisSize,
          crossAxisAlignment: (widget).crossAxisAlignment,
          mainAxisAlignment: (widget).mainAxisAlignment,
          children: (widget as MultiChildRenderObjectWidget).children
              .map((child) => _buildShimmerLayout(child, context))
              .toList(),
        );
      }
    }
    // Handle Container widgets
    else if (widget is Container) {
      return Shimmer.fromColors(
        baseColor:
            baseColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        highlightColor:
            highlightColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        child: Container(
          width: widget
              .constraints
              ?.maxWidth, // null lets the container take the child’s size
          height: widget
              .constraints
              ?.maxHeight, // null lets the container take the child’s size
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: widget.decoration is BoxDecoration
                ? (widget.decoration as BoxDecoration).borderRadius
                : null,
            shape: widget.decoration is BoxDecoration
                ? (widget.decoration as BoxDecoration).shape
                : BoxShape.rectangle,
          ),
          child: widget
              .child, // Allow the child to dictate the size when width/height is not specified
        ),
      );
    } else if (widget is ListTile) {
      return Shimmer.fromColors(
        baseColor:
            baseColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        highlightColor:
            highlightColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        child: ListTile(
          contentPadding: widget.contentPadding,
          leading: widget.leading != null
              ? _buildShimmerLayout(widget.leading!, context)
              : null,
          title: widget.title != null
              ? _buildShimmerLayout(widget.title!, context)
              : null,
          subtitle: widget.subtitle != null
              ? _buildShimmerLayout(widget.subtitle!, context)
              : null,
          trailing: widget.trailing != null
              ? _buildShimmerLayout(widget.trailing!, context)
              : null,
        ),
      );
    }
    // Handle Text widgets
    else if (widget is Text) {
      final TextStyle? style = widget.style;
      final double fontSize =
          style?.fontSize ?? 14.0; // Use fontSize or default 14.0
      final double height = fontSize * 1.2; // Adjust height based on font size
      final double width = _calculateTextWidth(
        widget.data ?? '',
        style,
        context,
      ); // Calculate width based on text

      return Shimmer.fromColors(
        baseColor:
            baseColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        highlightColor:
            highlightColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            width: width, // Width based on text length
            height: height, // Height based on font size
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.grey[300],
            ),
          ),
        ),
      );
    } else if (widget is AutoSizeText) {
      final TextStyle? style = widget.style;
      final double fontSize =
          style?.fontSize ?? 14.0; // Use fontSize or default 14.0
      final double height = fontSize * 1.2; // Adjust height based on font size
      final double width = _calculateTextWidth(
        widget.data ?? '',
        style,
        context,
      ); // Calculate width based on text

      return Shimmer.fromColors(
        baseColor:
            baseColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        highlightColor:
            highlightColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            width: width, // Width based on text length
            height: height, // Height based on font size
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.grey[300],
            ),
          ),
        ),
      );
    } else if (widget is Image) {
      return Shimmer.fromColors(
        baseColor:
            baseColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        highlightColor:
            highlightColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      );
    } else if (widget is CachedNetworkImage) {
      return Shimmer.fromColors(
        baseColor:
            baseColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        highlightColor:
            highlightColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      );
    }
    // Handle SizedBox widgets
    else if (widget is SizedBox) {
      return widget.child != null
          ? _buildShimmerLayout(widget.child!, context)
          : SizedBox(height: widget.height, width: widget.width);
    } else if (widget is CircleAvatar) {
      return Shimmer.fromColors(
        baseColor:
            baseColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        highlightColor:
            highlightColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        child: Container(
          width: widget.radius != null
              ? widget.radius! * 2
              : 40.0, // Default size
          height: widget.radius != null ? widget.radius! * 2 : 40.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
        ),
      );
    } else if (widget is Icon) {
      return Shimmer.fromColors(
        baseColor:
            baseColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        highlightColor:
            highlightColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        child: Icon(
          widget.icon,
          size: widget.size ?? IconTheme.of(context).size ?? 24.0,
          color: Colors.grey[300], // solid placeholder color
        ),
      );
    } else if (widget is RatingBarIndicator) {
      return _buildShimmerLayout(
        Row(
          children: List.generate(
            widget.itemCount,
            (index) => Icon(
              Icons.star_rounded,
              color: Theme.of(context).primaryColor,
              size: widget.itemSize,
            ),
          ),
        ),
        context,
      );
    }
    // If it's a different type of widget, return a grey box as a placeholder
    else {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Shimmer.fromColors(
              baseColor:
                  baseColor ??
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
              highlightColor:
                  highlightColor ??
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              child: Container(
                color: baseColor ?? Colors.grey[300]!,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        constraints.maxWidth, // Inherit width from the parent
                    maxHeight:
                        constraints.maxHeight, // Inherit height from the parent
                  ),
                  child: widget, // Render the passed widget inside the shimmer
                ),
              ),
            ),
          );
        },
      );
    }
  }

  // Method to calculate the width of the text based on its content and style
  double _calculateTextWidth(
    String text,
    TextStyle? style,
    BuildContext context,
  ) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: style ?? DefaultTextStyle.of(context).style,
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(); // Layout the text to measure it

    return textPainter.width; // Return the width of the text
  }
}
