# Light Theme Text Contrast Fix

## Problem
In light theme, secondary text (symbols, amounts, ranks) was too dim:
- Using `colorScheme.outline` which is light gray (#E2E8F0) in light theme
- Almost invisible against light background

## Solution
Created `_getSecondaryTextColor()` helper function that returns adaptive colors:

**Light Theme:** `Colors.grey.shade700` (dark gray for contrast)
**Dark Theme:** `Colors.grey.shade400` (light gray for contrast)

## Files Updated

### 1. coin_tile.dart
- Market cap rank (order number)
- Coin symbol (BTC, ETH, etc.)
- Added bold weight to symbol

### 2. portfolio_page.dart
- Coin name
- Amount information
- Added bold weight to amount text

### 3. settings_view.dart
- Section titles (Notifications, Appearance, etc.)
- Better visual hierarchy

## Result
✅ Text is readable in both themes
✅ Proper contrast ratio
✅ Clean, consistent appearance
✅ No hardcoded colors - using adaptive logic

## Implementation Pattern
```dart
Color _getSecondaryTextColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (isDark) {
    return Colors.grey.shade400;
  } else {
    return Colors.grey.shade700;
  }
}
```

This pattern can be reused for other adaptive colors throughout the app.
