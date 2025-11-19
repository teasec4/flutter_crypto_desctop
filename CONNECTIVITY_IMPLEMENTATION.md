# Connectivity Monitoring Implementation

## Overview
Added network connectivity monitoring to the app. When internet is lost, the app:
1. Shows a red banner at the top saying "No Internet Connection"
2. Auto-refreshes data when connection is restored
3. Keeps showing cached data while offline

## What Was Added

### 1. ConnectivityCubit (`lib/core/cubits/connectivity_cubit.dart`)
- Monitors internet connectivity using `connectivity_plus` package
- Emits `ConnectivityOnline` or `ConnectivityOffline` states
- Singleton in service locator for global access

### 2. CoinCubit & PortfolioCubit Integration
Both cubits now:
- Listen to ConnectivityCubit state changes
- Automatically refresh data when connection is restored
- Stop auto-refresh timer when offline (prevents wasted requests)
- Keep showing cached data while offline

### 3. ConnectivityBanner Widget (`lib/presentation/widgets/connectivity_banner.dart`)
- Global banner that shows when offline
- Red background with WiFi-off icon
- Positioned at the top of the app

### 4. Service Locator Setup
- ConnectivityCubit registered as singleton
- Automatically initialized when app starts

## How It Works

```
User loses internet
    ↓
ConnectivityCubit detects offline
    ↓
Emits ConnectivityOffline state
    ↓
CoinCubit & PortfolioCubit catch it
    ↓
Banner shows at top
    ↓
User still sees cached data

---

User regains internet
    ↓
ConnectivityCubit detects online
    ↓
Emits ConnectivityOnline state
    ↓
CoinCubit & PortfolioCubit catch it
    ↓
Auto-refresh triggered (silent background)
    ↓
Banner disappears
```

## Files Changed

- `pubspec.yaml` - Added `connectivity_plus` dependency
- `lib/di/service_locator.dart` - Registered ConnectivityCubit
- `lib/main.dart` - Added ConnectivityBanner to UI, passed cubit to CoinCubit & PortfolioCubit
- `lib/presentation/pages/coin_cubit.dart` - Added connectivity listening
- `lib/presentation/pages/portfolio_cubit.dart` - Added connectivity listening

## Files Created

- `lib/core/cubits/connectivity_cubit.dart` - Connectivity monitoring logic
- `lib/presentation/widgets/connectivity_banner.dart` - UI banner

## Testing

To test offline behavior:
1. Turn off internet on your device/emulator
2. Red banner should appear at top
3. Cached data should still show
4. Turn internet back on
5. Banner should disappear
6. Data should auto-refresh

## Notes

- Auto-refresh timer still works when online
- No changes to existing error handling - that remains the same
- Cached data is preserved and shown while offline
- This is a non-breaking addition - all existing code still works
