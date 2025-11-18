import 'package:flutter/material.dart';

/// Beautiful animated search bar for coins with modern design
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
    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(
                  alpha: 0.1 + (_focusAnimation.value * 0.2),
                ),
                blurRadius: 12 + (_focusAnimation.value * 8),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              // Gradient background
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    Colors.grey.shade800,
                    Colors.blue.shade900.withValues(alpha: 0.15),
                    _focusAnimation.value,
                  )!,
                  Color.lerp(
                    Colors.grey.shade900,
                    Colors.blue.shade800.withValues(alpha: 0.1),
                    _focusAnimation.value,
                  )!,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Color.lerp(
                  Colors.grey.shade700,
                  Colors.blue.shade400,
                  _focusAnimation.value,
                )!,
                width: 1.5,
              ),
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
                            Colors.grey.shade500,
                            Colors.blue.shade400,
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search coins by name or symbol...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    cursorColor: Colors.blue.shade400,
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
                            color: Colors.grey.shade800.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.grey.shade400,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
