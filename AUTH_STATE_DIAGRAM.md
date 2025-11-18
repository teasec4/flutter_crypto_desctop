# Authentication State Diagram

## Complete State Machine

```
                              ┌─────────────────────────────────┐
                              │    App Startup                   │
                              └──────────────┬────────────────────┘
                                             │
                                             ▼
                              ┌──────────────────────────┐
                              │  checkAuthStatus()       │
                              │  (Runs on app start)     │
                              └──────────┬───────────────┘
                                         │
                    ┌────────────────────┼────────────────────┐
                    │                    │                    │
        ┌───────────▼────────┐  ┌────────▼──────────┐  ┌─────▼──────────┐
        │  No saved session  │  │ Session found     │  │ Session expired│
        │  → AuthInitial     │  │ → checkAuth calls │  │ → AuthInitial  │
        │  (Login page)      │  │    getCurrentUser │  │ (Login page)   │
        └────────────────────┘  └────────┬──────────┘  └────────────────┘
                                         │
                                         ▼
                              ┌──────────────────────────┐
                              │ User has valid session   │
                              └──────────┬───────────────┘
                                         │
                                         ▼
                              ┌──────────────────────────┐
                              │  AuthInitializing        │
                              │  (Show splash screen)    │
                              │                          │
                              │  Loading:                │
                              │  • Portfolio             │
                              │  • Coins                 │
                              │  (in parallel)           │
                              └──────────┬───────────────┘
                                         │
                                         ▼
                              ┌──────────────────────────┐
                              │  AuthAuthenticated       │
                              │  (Show home page)        │
                              └──────────┬───────────────┘
                                         │
                    ┌────────────────────┼──────────────────┐
                    │                    │                  │
                    │          (User interacts)             │
                    │                                       │
                    ▼                                       ▼
        ┌──────────────────────┐              ┌─────────────────────┐
        │  User logs out       │              │ Refresh data        │
        │  logout()            │              │ (auto every 5 min)  │
        │                      │              │                     │
        │  AuthLoading         │              │ Background sync     │
        │  → Clear portfolio   │              │ (silently)          │
        │  → Clear coins       │              │                     │
        │  → AuthInitial       │              │ (stays authenticated)│
        └──────────────────────┘              └─────────────────────┘


═══════════════════════════════════════════════════════════════════════════════

        ┌──────────────────────────────────────────────────────────┐
        │           User on Login/Register Page                     │
        └──────────────┬───────────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
    ┌────────┐    ┌────────┐    ┌──────────┐
    │ Login  │    │Register│    │ Input    │
    │        │    │        │    │ validation
    └────┬───┘    └────┬───┘    └──────────┘
         │             │
         │      ┌──────┘
         │      │
         ▼      ▼
    ┌──────────────────────────────┐
    │  login(email, password)      │
    │  register(...displayName)    │
    │                              │
    │  Emit: AuthLoading           │
    │  (Show spinner in UI)        │
    └──────────┬────────────────────┘
               │
        ┌──────┴───────┐
        │              │
    ┌───▼────┐    ┌────▼────┐
    │Success │    │ Failure │
    │        │    │         │
    └───┬────┘    └────┬────┘
        │              │
        ▼              ▼
   ┌─────────────┐  ┌──────────────┐
   │Authenticated│  │AuthFailure   │
   │             │  │(error message│
   │Emit:        │  │)             │
   │AuthInitia-  │  │              │
   │lizing       │  │Show error    │
   │(Splash on)  │  │in UI         │
   └─────┬───────┘  └──────────────┘
         │
         ▼
   ┌─────────────────────────────┐
   │ _initializeUserData()       │
   │ Parallel load:              │
   │ • portfolio                 │
   │ • coins                     │
   │ (Future.wait)               │
   └────────┬────────────────────┘
            │
            ▼
   ┌─────────────────────────────┐
   │ Emit AuthAuthenticated      │
   │ (Splash off, home page on)  │
   └─────────────────────────────┘
```

## State Transition Rules

### Valid Transitions

```
AuthInitial          → AuthLoading       (login/register/checkAuthStatus)
AuthLoading          → AuthInitializing  (on success)
AuthLoading          → AuthFailure       (on error)
AuthInitializing     → AuthAuthenticated (data loaded)
AuthInitializing     → AuthFailure       (on error)
AuthAuthenticated    → AuthLoading       (logout)
AuthAuthenticated    → AuthInitializing  (refresh)
AuthFailure          → AuthLoading       (retry login)
AuthFailure          → AuthInitial       (dismiss error)
Any                  → AuthInitial       (logout complete)
```

### Invalid Transitions

These should NOT happen (state machine prevents them):
```
AuthInitial → AuthAuthenticated (must go through Loading/Initializing)
AuthLoading → AuthInitial (must resolve to something)
AuthAuthenticated → AuthLoading (only logout allowed)
etc.
```

## CoinCubit State Relation

When `AuthInitializing` (loading data):
```
┌──────────────────────────────────┐
│ AuthInitializing                 │
└────────────────┬─────────────────┘
                 │
        ┌────────▼────────┐
        │setAuthorized()  │
        │(true)           │
        └────────┬────────┘
                 │
    ┌────────────┴────────────┐
    │                         │
    ▼                         ▼
┌──────────┐          ┌──────────────┐
│CoinInitial        │CoinLoading    │
│  (data cleared)   │  (loading from│
│  (on login start) │   cache/net)  │
└──────────────────┘  └──────────────┘
                          │
                          ▼
                    ┌──────────────┐
                    │CoinLoaded    │
                    │(data ready)  │
                    └──────────────┘
```

When `AuthInitial` (logged out):
```
┌──────────────────────┐
│ AuthInitial          │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ coinCubit.           │
│ setAuthorized(false) │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ CoinInitial          │
│ (data cleared)       │
│ (timer stopped)      │
└──────────────────────┘
```

## PortfolioCubit State Relation

```
AuthInitializing
│
├─ portfolioCubit.loadPortfolioInitial(email)
│  ├─ PortfolioLoading
│  └─ PortfolioLoaded (or PortfolioError)
│
AuthAuthenticated
│
├─ Auto-refresh every 5 minutes
│  └─ PortfolioLoaded (silently update)
│
└─ User logout
   └─ PortfolioInitial (cleared)
```

## Edge Cases

### Case 1: App restart during login
```
User clicks login
│
├─ AuthLoading
│
├─ App restarts (before AuthInitializing reached)
│
└─ checkAuthStatus() on app start
   ├─ If session invalid → AuthInitial (login page)
   └─ If session valid → AuthInitializing (splash)
```

### Case 2: Network failure during initialization
```
AuthInitializing
│
├─ _initializeUserData() fails
│
├─ Error logged (doesn't break login)
│
└─ AuthAuthenticated emitted anyway
   (User sees home page with empty/stale data)
```

### Case 3: User logs out during initialization
```
AuthInitializing
│
├─ User somehow triggers logout
│
├─ _autoRefreshTimer cancelled
│
└─ AuthInitial
   (Current data discarded)
```

## Router Redirect Logic

```
Current State       Current Location      Action
─────────────────   ────────────────      ──────
AuthInitial         /                     Redirect to /login
AuthInitial         /login                Allow
AuthInitial         /register             Allow
AuthInitial         /splash               Redirect to /login

AuthLoading         /                     Redirect to /login
AuthLoading         /login                Allow
AuthLoading         /register             Allow
AuthLoading         /splash               Redirect to /login

AuthInitializing    /                     Redirect to /splash
AuthInitializing    /login                Redirect to /splash
AuthInitializing    /register             Redirect to /splash
AuthInitializing    /splash               Allow

AuthAuthenticated   /                     Allow
AuthAuthenticated   /portfolio            Allow
AuthAuthenticated   /settings             Allow
AuthAuthenticated   /login                Redirect to /
AuthAuthenticated   /register             Redirect to /

AuthFailure         (all)                 Redirect to /login
                                          Show error message
```

---

