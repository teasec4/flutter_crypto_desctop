# Crypto Desktop App

A **Flutter desktop application** to track cryptocurrency prices and manage your portfolio. Built with **Flutter**, **BLoC**, **Isar**, **Supabase**, and **CoinGecko API**.

**Latest Update (Session 2):** Enhanced security with network timeouts, authorization-based loading, and splash screen during initialization.

---

## Features

### Core Features
- 🪙 View list of cryptocurrencies with real-time USD prices
- 💼 Create and manage cryptocurrency portfolio
- 📊 Responsive desktop layout (sidebar, compact, mobile)
- 🔄 Auto-refresh data every 5 minutes
- 💾 Local caching with Isar for offline access

### Security Features (Session 2)
- 🔒 Network request timeouts (10s) prevent hanging connections
- 🔐 Authorization-based data loading - coins only load after auth
- ✅ Data validation - gracefully handles invalid values
- 🚪 Clean logout - all data cleared immediately

### UX Improvements (Session 2)
- 🎨 Beautiful splash screen during login
- ⚡ Parallel data loading (portfolio + coins simultaneously)
- 🎯 Smooth transitions and visual feedback
- 👤 Personalized welcome message on splash

---

## Screenshots

later:)

---

## Tech Stack

| Layer         | Technologies                     |
|---------------|---------------------------------|
| UI / Frontend | Flutter Desktop, Dart           |
| State         | BLoC / Cubit                     |
| Database      | Isar                             |
| API           | CoinGecko API                     |
| Navigation    | go_router (planned)              |

---

## Getting Started

### Prerequisites

- Flutter 3.x or newer
- Desktop support enabled (`flutter config --enable-windows-desktop` / macOS / Linux)

### Installation

```bash
git clone https://github.com/teasec4/flutter_crypto_desctop
cd crypto_desktop_app
flutter pub get
flutter run -d windows   # or -d macos / -d linux
```
### Usage
- Launch the app	
- Navigate using the sidebar or drawer
- See live crypto prices fetched from CoinGecko
- Expandable to add portfolio management and history


### Project Structure 
```
lib/
├── core/
│    └── network/coin_service.dart  # API requests
├── domain/
│    ├── models/coin.dart
│    └── repository/coin_repo.dart
├── presentation/
│    └── pages/content_view.dart
└── main.dart
```

---

## Documentation

Complete documentation available for Session 2 improvements:

| Document | Purpose |
|----------|---------|
| [`DOCUMENTATION_INDEX.md`](DOCUMENTATION_INDEX.md) | **Start here** - Complete guide to all docs |
| [`QUICK_START_CHANGES.md`](QUICK_START_CHANGES.md) | Quick overview of what changed |
| [`SECURITY_IMPROVEMENTS.md`](SECURITY_IMPROVEMENTS.md) | Detailed security enhancements |
| [`SPLASH_SCREEN_IMPLEMENTATION.md`](SPLASH_SCREEN_IMPLEMENTATION.md) | How splash screen works & customization |
| [`SESSION_SUMMARY.md`](SESSION_SUMMARY.md) | Summary of all work done |
| [`ARCHITECTURE_OVERVIEW.md`](ARCHITECTURE_OVERVIEW.md) | System architecture and diagrams |
| [`AUTH_STATE_DIAGRAM.md`](AUTH_STATE_DIAGRAM.md) | Complete state machine diagrams |
| [`CHANGES_CHECKLIST.md`](CHANGES_CHECKLIST.md) | Detailed checklist of all changes |

---

## Recent Changes (Session 2)

### Security Enhancements
✓ Network timeouts (10-second limit on all HTTP requests)  
✓ Authorization guards (coins only load after auth verification)  
✓ Data validation (graceful handling of invalid values)  
✓ Clean logout (all data cleared immediately)  

### UX Improvements
✓ Splash screen after login showing progress  
✓ Parallel data loading (portfolio + coins simultaneously)  
✓ Personalized welcome message on splash  
✓ Empty state UI with icon and helpful message  

### Files Changed
- 7 code files modified
- 1 new code file (`splash_page.dart`)
- 8 documentation files added

See [`CHANGES_CHECKLIST.md`](CHANGES_CHECKLIST.md) for complete list.

---

### Future Plans
- [ ] Animated splash screen transitions
- [ ] Loading percentage on splash
- [ ] Retry button if data loading fails
- [ ] Real-time WebSocket price updates
- [ ] Advanced portfolio analytics
- [ ] Price history charts
- [ ] Portfolio export (CSV/PDF)

### Known Limitations
- Network timeout is fixed at 10 seconds (customizable in code)
- Splash screen shows for minimum duration of parallel load

---

### License
MIT License © Kovalev Maksim

---

## Support & Questions

For questions about the implementation, see the comprehensive documentation files listed above. Each document has specific examples and detailed explanations.

**Latest Update:** November 17, 2025