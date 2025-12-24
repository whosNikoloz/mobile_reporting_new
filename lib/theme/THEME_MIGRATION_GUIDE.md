# Theme Migration Guide - Dark to Light Mode

This guide explains the theme changes and how to update remaining screens.

## What Was Changed

The app has been converted from dark mode to light mode with a white and blue color scheme.

### Color Mappings

Replace dark mode colors with light mode equivalents:

| Old (Dark Mode) | New (Light Mode) | Usage |
|----------------|------------------|-------|
| `Colors.grey.shade900` | `Colors.white` | Background, Scaffold, AppBar |
| `Colors.grey.shade300` | `AppTheme.primaryTextColor` | Primary text |
| `Colors.grey.shade500` | `AppTheme.secondaryTextColor` or `AppTheme.dividerColor` | Secondary text, borders |
| `Color.fromARGB(255, 0, 68, 124)` | `AppTheme.primaryBlue` | Accent color, buttons, icons |

### Theme Constants

Use these constants from `AppTheme`:

```dart
// Import the theme
import 'package:mobile_reporting/theme/app_theme.dart';

// Colors
AppTheme.primaryBlue          // Color(0xFF00447C) - Main blue
AppTheme.lightBlue            // Color(0xFF2196F3) - Light blue accent
AppTheme.backgroundColor      // Colors.white - Main background
AppTheme.surfaceColor         // Color(0xFFF5F5F5) - Card backgrounds
AppTheme.cardColor            // Colors.white - Card color
AppTheme.primaryTextColor     // Color(0xFF212121) - Main text
AppTheme.secondaryTextColor   // Color(0xFF757575) - Secondary text
AppTheme.hintTextColor        // Color(0xFF9E9E9E) - Hints, placeholders
AppTheme.borderColor          // Color(0xFFE0E0E0) - Input borders
AppTheme.dividerColor         // Color(0xFFBDBDBD) - Dividers
```

## Updated Screens

✅ `main.dart` - Theme configured
✅ `bills_main_screen.dart` - Full light theme
✅ `sign_in_screen.dart` - Full light theme

## Screens to Update

Apply the same pattern to these screens:

- `splash_screen.dart`
- `main_screen.dart`
- `bill_screen.dart`
- `finances_main_screen.dart`
- `finances_screen.dart`
- `statistics_main_screen.dart`
- `statistics_screen.dart`
- `drawer_widget.dart`
- `picker_widget.dart`
- Any other custom screens

## Step-by-Step Migration for Each Screen

### 1. Add Theme Import

```dart
import 'package:mobile_reporting/theme/app_theme.dart';
```

### 2. Update Scaffold

```dart
// Before
Scaffold(
  backgroundColor: Colors.grey.shade900,
  appBar: AppBar(
    backgroundColor: Colors.grey.shade900,
  ),
)

// After
Scaffold(
  backgroundColor: Colors.white,
  appBar: AppBar(
    backgroundColor: Colors.white,
    iconTheme: const IconThemeData(color: AppTheme.primaryBlue),
  ),
)
```

### 3. Update Text Colors

```dart
// Before
Text(
  'Example',
  style: TextStyle(
    color: Colors.grey.shade300,
    fontSize: 18,
  ),
)

// After
Text(
  'Example',
  style: const TextStyle(
    color: AppTheme.primaryTextColor,
    fontSize: 18,
  ),
)
```

### 4. Update TextField

```dart
// Before
TextField(
  style: TextStyle(color: Colors.grey.shade500),
  decoration: InputDecoration(
    hintStyle: TextStyle(color: Colors.grey.shade500),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromARGB(255, 0, 68, 124)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromARGB(255, 0, 68, 124)),
    ),
  ),
)

// After
TextField(
  style: const TextStyle(color: AppTheme.primaryTextColor),
  decoration: InputDecoration(
    hintStyle: const TextStyle(color: AppTheme.hintTextColor),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppTheme.borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: AppTheme.primaryBlue,
        width: 2.0,
      ),
    ),
  ),
)
```

### 5. Update Dividers

```dart
// Before
Divider(color: Colors.grey.shade500)

// After
const Divider(color: AppTheme.dividerColor)
```

### 6. Update Buttons

```dart
// Before
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 0, 68, 124),
  ),
)

// After
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryBlue,
    foregroundColor: Colors.white,
  ),
)
```

### 7. Update Icons

```dart
// Before
Icon(Icons.menu, color: Color.fromARGB(255, 0, 68, 124))

// After
const Icon(Icons.menu, color: AppTheme.primaryBlue)
```

### 8. Update Container Decorations

```dart
// Before
Container(
  decoration: BoxDecoration(
    border: Border(
      bottom: BorderSide(color: Colors.grey.shade500),
    ),
  ),
)

// After
Container(
  decoration: const BoxDecoration(
    border: Border(
      bottom: BorderSide(color: AppTheme.dividerColor),
    ),
  ),
)
```

## Quick Search & Replace Patterns

Use your IDE's find and replace (be careful, review each change):

1. `Colors.grey.shade900` → `Colors.white`
2. `Colors.grey.shade300` → `AppTheme.primaryTextColor`
3. `Colors.grey.shade500` → Review context:
   - Text → `AppTheme.secondaryTextColor`
   - Borders → `AppTheme.borderColor` or `AppTheme.dividerColor`
4. `Color.fromARGB(255, 0, 68, 124)` → `AppTheme.primaryBlue`

## Testing

After updating each screen:

1. Build and run the app
2. Navigate to the updated screen
3. Check for:
   - Readable text (dark on light background)
   - Visible borders and dividers
   - Proper button colors
   - Consistent blue accent color

## Example: Before & After

### Before (Dark Mode)
```dart
Scaffold(
  backgroundColor: Colors.grey.shade900,
  appBar: AppBar(
    backgroundColor: Colors.grey.shade900,
    title: Text(
      'Title',
      style: TextStyle(color: Colors.grey.shade300),
    ),
  ),
  body: Container(
    child: Text(
      'Content',
      style: TextStyle(color: Colors.grey.shade500),
    ),
  ),
)
```

### After (Light Mode)
```dart
Scaffold(
  backgroundColor: Colors.white,
  appBar: AppBar(
    backgroundColor: Colors.white,
    iconTheme: const IconThemeData(color: AppTheme.primaryBlue),
    title: const Text(
      'Title',
      style: TextStyle(
        color: AppTheme.primaryTextColor,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
  body: Container(
    child: const Text(
      'Content',
      style: TextStyle(color: AppTheme.secondaryTextColor),
    ),
  ),
)
```

## Need Help?

- Check `bills_main_screen.dart` for a complete example
- Check `sign_in_screen.dart` for form field examples
- All theme constants are in `lib/theme/app_theme.dart`
