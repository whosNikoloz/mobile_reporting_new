# Navigation Changes - Drawer to Bottom Navigation

This document explains the navigation architecture changes.

## What Changed

The app navigation has been updated from a side drawer to bottom navigation with the following improvements:

### Old Structure
- Hamburger menu drawer on the left
- Profile info in drawer header
- Navigation items in drawer
- Logout button at bottom of drawer

### New Structure
- **Bottom Navigation Bar** with 3 tabs
- **Profile Button** in top-left corner of app bar
- **Page Title** centered in app bar
- **Profile Dialog** for user info and logout

## Navigation Components

### Main Navigation Widget (`lib/widgets/main_navigation.dart`)

This is the main wrapper that provides:
- Bottom navigation bar
- App bar with profile button and page title
- Content area for each screen

```dart
MainNavigation(
  initialIndex: 0, // Optional: 0 = Dashboard, 1 = Statistics, 2 = Bills/Finances
)
```

### Bottom Navigation Items

1. **Dashboard (დეშბორდი)** - Index 0
   - Icon: `Icons.dashboard`
   - Route: `MainScreen`

2. **Statistics (სტატისტიკა)** - Index 1
   - Icon: `Icons.bar_chart`
   - Route: `StatisticsMainScreen`

3. **Bills/Finances (ჩეკები/ფინანსები)** - Index 2
   - Icon: `Icons.receipt`
   - Route: `BillsMainScreen` or `FinancesMainScreen` (based on user type)
   - Label changes based on user type

### Profile Dialog

Clicking the profile button (top-left) shows:
- User avatar icon
- Company name
- Email address
- Logout button

## Updated Screens

All main screens have been modified to work within the navigation wrapper:

### Removed from Each Screen:
- ❌ `Scaffold` wrapper
- ❌ `AppBar` (now handled by MainNavigation)
- ❌ `drawer` property
- ❌ Drawer import

### Updated Screens:
✅ `bills_main_screen.dart` - Returns Column instead of Scaffold
✅ `main_screen.dart` - Returns SingleChildScrollView instead of Scaffold
✅ `statistics_main_screen.dart` - Returns FutureBuilder instead of Scaffold
✅ `finances_main_screen.dart` - Returns FutureBuilder instead of Scaffold
✅ `splash_screen.dart` - Navigates to MainNavigation after login

## Entry Points

### After Login
`SplashScreen` → Validates token → Loads stores → `MainNavigation()`

### After Logout
Profile Dialog → Clear preferences → `SplashScreen` → `SignInScreen`

## Theme Integration

The navigation uses the light theme:
- **Background**: White
- **Selected tab**: Blue (`AppTheme.primaryBlue`)
- **Unselected tab**: Grey (`AppTheme.secondaryTextColor`)
- **Profile button**: Blue with light blue background
- **Shadows**: Subtle elevation on bottom nav

## Usage Example

```dart
// Navigate to specific tab
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => const MainNavigation(initialIndex: 1), // Statistics tab
  ),
);

// Navigate to default (Dashboard)
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => const MainNavigation(),
  ),
);
```

## Migration Notes

If you create new main screens:

1. **Don't use Scaffold** - Return content widget directly
2. **Don't add AppBar** - It's provided by MainNavigation
3. **Don't add drawer** - Use bottom navigation
4. **Use theme colors** - Import and use `AppTheme` constants

Example:
```dart
class MyNewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Don't wrap in Scaffold!
    return Column(
      children: [
        // Your content here
      ],
    );
  }
}
```

Then add it to `main_navigation.dart`:
```dart
Widget _getCurrentScreen() {
  switch (_currentIndex) {
    case 0:
      return const MainScreen();
    case 1:
      return const StatisticsMainScreen();
    case 2:
      return _userType == 'RETAIL'
          ? const FinancesMainScreen()
          : const BillsMainScreen();
    case 3: // New screen
      return const MyNewScreen();
    default:
      return const MainScreen();
  }
}
```

## Deleted/Deprecated

- `drawer_widget.dart` - No longer used (can be deleted)
- Individual screen AppBars - Removed
- Individual screen Scaffolds - Removed
