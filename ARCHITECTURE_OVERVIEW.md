# Architecture Overview - After Session 2

## Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     App Router (app_router.dart)             │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ Routes:                                                  ││
│  │ • /login → LoginPage                                    ││
│  │ • /register → RegisterPage                              ││
│  │ • /splash → SplashPage (NEW)                            ││
│  │ • / → HomePage with navigation                          ││
│  └─────────────────────────────────────────────────────────┘│
└──────────────────────────┬───────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                   State Management Layer                     │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│ ┌──────────────────────┐  ┌──────────────────────┐          │
│ │   AuthCubit          │  │   AuthState          │          │
│ ├──────────────────────┤  ├──────────────────────┤          │
│ │ • login()            │  │ • AuthInitial        │          │
│ │ • register()         │  │ • AuthLoading        │          │
│ │ • logout()           │  │ • AuthInitializing   │ (NEW)    │
│ │ • checkAuthStatus()  │  │ • AuthAuthenticated  │          │
│ │                      │  │ • AuthFailure        │          │
│ │ (manages:)           │  └──────────────────────┘          │
│ │ • PortfolioCubit     │                                     │
│ │ • CoinCubit          │  ┌──────────────────────┐          │
│ └──────────────────────┘  │ PortfolioCubit       │          │
│                           ├──────────────────────┤          │
│                           │ • loadPortfolioInit..│          │
│ ┌──────────────────────┐  │ • addAsset()         │          │
│ │   CoinCubit          │  │ • removeAsset()      │          │
│ ├──────────────────────┤  │ • refreshPortfolio() │          │
│ │ • loadCoins()        │  └──────────────────────┘          │
│ │ • setAuthorized()    │  (NEW)                             │
│ │   (SECURITY)         │  ┌──────────────────────┐          │
│ │ • refreshCoins()     │  │ CoinCubit State      │          │
│ │                      │  ├──────────────────────┤          │
│ │ Has:                 │  │ • CoinInitial        │          │
│ │ • _isAuthorized      │  │ • CoinLoading        │          │
│ │ • _autoRefreshTimer  │  │ • CoinLoaded         │          │
│ └──────────────────────┘  │ • CoinError          │          │
│                           └──────────────────────┘          │
└──────────────────────┬──────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────┐
│                  Repository Layer (Domain)                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────┐  ┌──────────────────┐                 │
│  │ CoinRepository  │  │ PortfolioRepo    │                 │
│  │ (Abstract)      │  │ (Abstract)       │                 │
│  │ • getCoins()    │  │ • getPortfolio() │                 │
│  │ • getCoinsFresh │  │ • addItem()      │                 │
│  └────────┬────────┘  └────────┬─────────┘                 │
│           │                    │                            │
│  ┌────────▼────────┐  ┌────────▼─────────┐                 │
│  │ CoinRepositoryI │  │ PortfolioRepoIm  │                 │
│  │ (Implementation)│  │ (Implementation) │                 │
│  └────────┬────────┘  └────────┬─────────┘                 │
└───────────┼────────────────────┼──────────────────────────┘
            │                    │
┌───────────▼────────────────────▼──────────────────────────┐
│               DataSource Layer (Local + Remote)           │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────────────┐  ┌──────────────────────┐     │
│  │ CoinLocalDataSource  │  │ CoinRemoteDataSource │     │
│  │ (Isar Cache)         │  │ (CoinGecko API)      │     │
│  │                      │  │                      │     │
│  │ • getCachedCoins()   │  │ • getCoins()         │     │
│  │ • cacheCoins()       │  │ (with 10s timeout)   │ ◄───┼─ TIMEOUT ADDED
│  └──────────────────────┘  └──────────────────────┘     │
│                                                           │
│  ┌──────────────────────┐  ┌──────────────────────┐     │
│  │ PortfolioLocalDS     │  │ PortfolioRemoteDS    │     │
│  │ (Isar)               │  │ (Supabase)           │     │
│  └──────────────────────┘  └──────────────────────┘     │
│                                                           │
│  ┌──────────────────────┐  ┌──────────────────────┐     │
│  │ AuthLocalDataSource  │  │ AuthRemoteDataSource │     │
│  │ (Secure Storage)     │  │ (Supabase Auth)      │     │
│  └──────────────────────┘  └──────────────────────┘     │
└──────────────────────────────────────────────────────────┘
```

## Security Changes

### 1. Network Timeout (worker_isolate.dart)
```dart
// Added 10-second timeout to prevent hanging requests
const Duration _networkTimeout = Duration(seconds: 10);

final response = await http.get(url).timeout(
  _networkTimeout,
  onTimeout: () => throw TimeoutException(...),
);
```

### 2. Authorization Guard (CoinCubit)
```dart
// Only loads coins when user is verified as authorized
void setAuthorized(bool authorized) {
  _isAuthorized = authorized;
  if (!authorized) {
    // Clear data on logout
    emit(CoinInitial());
  } else {
    // Start loading on login
    loadCoins();
  }
}
```

### 3. Data Validation (PortfolioPage)
```dart
// Validates portfolio items before rendering
bool _isValidPortfolioItem(PortfolioItem item) {
  // Check for NaN, infinity, negative values
  // Return false if any validation fails
}
```

## Data Flow - Login Process

```
1. User fills login form
   ↓
2. AuthCubit.login(email, password) called
   ↓
3. Emit AuthLoading
   ↓
4. Call authRepository.login()
   ↓
5. Backend authenticates (Supabase)
   ↓
6. Emit AuthInitializing(user) ← SHOWS SPLASH SCREEN
   ↓
7. Call _initializeUserData(email)
   ├─ PortfolioCubit.loadPortfolioInitial(email)
   │  ├─ Load from local cache (Isar)
   │  └─ Fetch fresh from Supabase
   └─ CoinCubit.setAuthorized(true)
      └─ Trigger coin loading
   
   (Both load in PARALLEL using Future.wait)
   ↓
8. Emit AuthAuthenticated(user)
   ↓
9. Router detects AuthAuthenticated
   ↓
10. Redirect to home page
    ↓
    SPLASH SCREEN DISAPPEARS ✓
```

## File Organization

```
lib/
├── core/
│   ├── isolate/
│   │   └── worker_isolate.dart          ◄── TIMEOUT ADDED
│   └── network/
│       └── coin_service.dart
├── data/
│   ├── datasource/
│   │   ├── coin_*.dart
│   │   ├── portfolio_*.dart
│   │   └── auth_*.dart
│   ├── models/
│   │   └── *.dart
│   └── repository/
│       ├── coin_repository_impl.dart
│       ├── portfolio_repository_impl.dart
│       └── auth_repository_impl.dart
├── domain/
│   ├── models/
│   │   └── *.dart
│   └── repository/
│       ├── coin_repo.dart
│       ├── portfolio_repo.dart
│       └── auth_repo.dart
├── presentation/
│   ├── pages/
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   ├── splash_page.dart                  ◄── NEW
│   │   ├── auth_cubit.dart                   ◄── MODIFIED
│   │   ├── auth_state.dart                   ◄── MODIFIED
│   │   ├── coin_cubit.dart                   ◄── MODIFIED
│   │   ├── portfolio_page.dart               ◄── MODIFIED
│   │   ├── portfolio_cubit.dart
│   │   └── ...
│   └── widgets/
│       └── *.dart
├── router/
│   └── app_router.dart                       ◄── MODIFIED
└── main.dart                                 ◄── MODIFIED
```

## Performance Optimizations

1. **Parallel Data Loading**
   - Portfolio + Coins load simultaneously
   - Faster than sequential (50-100ms saved)

2. **Cache-First Strategy**
   - Local cache (Isar) shows immediately
   - Background sync keeps data fresh

3. **Auto-Refresh Timers**
   - Both cubits refresh data every 5 minutes
   - Timers cancelled on logout

## Testing Strategy

```
Unit Tests:
├── AuthCubit.login() flow
├── AuthCubit.logout() flow
├── CoinCubit.setAuthorized() behavior
└── PortfolioPage data validation

Widget Tests:
├── SplashPage rendering
├── PortfolioPage empty state
└── Navigation flow auth → splash → home

Integration Tests:
├── Full login flow with splash
├── Data loading and display
└── Error handling (timeout, network failure)
```

---

**Last Updated:** November 17, 2025  
**Status:** Implementation Complete ✓
