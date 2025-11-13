# Crypto Desktop App

A simple **Flutter desktop application** to track cryptocurrency prices and portfolio. Built with **Flutter**, **BLoC**, **Isar**, and **CoinGecko API**.

---

## Features

- View a list of cryptocurrencies (BTC, ETH, DOGE) with current USD prices
- Responsive layout with **NavigationRail** for desktop:
    - Full sidebar on wide screens
    - Compact sidebar on medium screens
    - Hamburger menu with drawer on narrow screens
- Clickable navigation (Home / Portfolio / Settings)
- Async data fetching from CoinGecko API
- Easily extensible for portfolio tracking and local storage

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

### Future Plans
- Add Isar caching for offline data
- Implement user portfolio with add/remove assets
- Real-time price updates
- Dark/light theme support
- Filtering and sorting coins

### License
MIT License © Kovalev Maksim
--- 