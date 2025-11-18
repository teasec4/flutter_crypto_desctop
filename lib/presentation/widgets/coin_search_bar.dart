import 'package:flutter/material.dart';

/// Beautiful animated search bar for coins with modern design
/// Adapts to both light and dark themes automatically
class CoinSearchBar extends StatefulWidget {
  final Future<void> Function(String) onChanged;
  final VoidCallback onClear;
  final bool isExpanded;

  const CoinSearchBar({
    super.key,
    required this.onChanged,
    required this.onClear,
    this.isExpanded = false,
  });

  @override
  State<CoinSearchBar> createState() => _CoinSearchBarState();
}

class _CoinSearchBarState extends State<CoinSearchBar>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animationController;
  late FocusNode _focusNode;
  late Animation<double> _focusAnimation;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _focusAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _focusNode.addListener(_updateFocusAnimation);
  }

  void _updateFocusAnimation() {
    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    // Define colors based on theme
    final bgColorUnfocused = isDark
        ? Colors.grey.shade800
        : Colors.grey.shade100;
    final bgColorFocused = isDark ? Colors.blue.shade900 : Colors.blue.shade50;
    final borderColorUnfocused = isDark
        ? Colors.grey.shade700
        : Colors.grey.shade300;
    final borderColorFocused = isDark
        ? Colors.blue.shade400
        : Colors.blue.shade600;
    final iconColorUnfocused = isDark
        ? Colors.grey.shade500
        : Colors.grey.shade600;
    final iconColorFocused = colorScheme.primary;
    final textColor = colorScheme.onSurface;
    final hintColor = isDark ? Colors.grey.shade500 : Colors.grey.shade600;
    final clearButtonBg = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final clearButtonIcon = isDark
        ? Colors.grey.shade400
        : Colors.grey.shade600;

    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            // Gradient background
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  bgColorUnfocused,
                  bgColorFocused,
                  _focusAnimation.value,
                )!,
                Color.lerp(
                  bgColorUnfocused,
                  bgColorFocused.withAlpha(200),
                  _focusAnimation.value,
                )!,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Color.lerp(
                borderColorUnfocused,
                borderColorFocused,
                _focusAnimation.value,
              )!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(
                  alpha: 0.05 + (_focusAnimation.value * 0.15),
                ),
                blurRadius: 8 + (_focusAnimation.value * 6),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Search icon with animation
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, _) {
                    return Transform.scale(
                      scale: 0.9 + (_focusAnimation.value * 0.1),
                      child: Icon(
                        Icons.search,
                        color: Color.lerp(
                          iconColorUnfocused,
                          iconColorFocused,
                          _focusAnimation.value,
                        ),
                        size: 20,
                      ),
                    );
                  },
                ),
              ),

              // Text field
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search coins by name or symbol...',
                    hintStyle: TextStyle(
                      color: hintColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  cursorColor: colorScheme.primary,
                  cursorWidth: 2,
                ),
              ),

              // Clear button with animation
              if (_controller.text.isNotEmpty)
                ScaleTransition(
                  scale: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: _handleClear,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: clearButtonBg.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: clearButtonIcon,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
