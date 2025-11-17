# Chart Implementation - Coin Detail Page

## Overview
Добавлена функция отображения графика цены монеты в деталь-странице криптовалюты, используя библиотеку **fl_chart** (0.69.0).

## Changes Summary

### 1. Dependencies
- ✅ Добавлен `fl_chart: ^0.69.0` в pubspec.yaml

### 2. New Models
- **lib/domain/models/coin_chart_data.dart**
  - `ChartDataPoint`: точка данных (timestamp + price)
  - `CoinChartData`: контейнер исторических данных с расчётом min/max/change%

### 3. Data Layer Updates

#### Remote DataSource (coin_remote_datasource.dart)
- Добавлен метод `getCoinChartData()` для получения исторических данных

#### Implementation (coin_remote_datasource_impl.dart)
- Реализован метод с использованием worker isolate
- Парсинг API-ответа CoinGecko (prices array)

#### Worker Isolate (worker_isolate.dart)
- Добавлена функция `_handleChartDataRequest()` для обработки запросов графиков
- Поддержка параметра `days` для выбора периода (1, 7, 30, 90, 365)

#### Repository (coin_repository_impl.dart)
- Добавлен метод `getCoinChartData()` для получения данных из API

### 4. Presentation Layer

#### State Management (coin_detail_cubit.dart)
- Обновлен `loadCoin()` для параллельной загрузки coin + chart data
- Добавлен параметр `chartDays` (default: 30)

#### State (coin_detail_state.dart)
- `CoinDetailLoaded` теперь содержит `chartData?: CoinChartData`

#### UI Component (coin_chart_widget.dart)
- ✨ Новый виджет `CoinChartWidget` с:
  - LineChart с кривой (isCurved = true)
  - Gradient area под графиком
  - Selector временных периодов (1D, 7D, 30D, 90D, 1Y)
  - Display min/max/current price
  - Percentage change с цветовой кодировкой (green/red)
  - Responsive grid lines и axes labels

#### Detail Page (coin_detail_page.dart)
- Преобразован в StatefulWidget для управления временным периодом
- Добавлен колбек `onChartDaysChanged()` для переключения периодов
- Интегрирован график в UI (после 24h change, перед market cap rank)

### 5. API Integration
- CoinGecko endpoint: `/coins/{id}/market_chart`
- Query params: `vs_currency=usd&days={days}&interval=daily`
- Возвращает: `{ prices: [[timestamp, price], ...] }`

## Design Details

### Chart Features
- ✅ Smooth curved line chart
- ✅ Semi-transparent area under curve
- ✅ Color coding: green (positive) / red (negative) change
- ✅ Time range buttons for quick selection
- ✅ Grid lines for readability
- ✅ X-axis: date labels (every 5 points)
- ✅ Y-axis: price in USD
- ✅ Display min/max/current prices below chart

### Performance
- Parallel loading: coin data + chart data одновременно (Future.wait)
- Background network requests через isolate (non-blocking)
- Network timeout: 10 seconds (существующее значение)

### Error Handling
- Fallback если chart data недоступна (условный рендеринг)
- Сохранение отображения монеты даже при ошибке графика

## Usage Example

```dart
// В coin_detail_page.dart:
CoinDetailPage(coinId: 'bitcoin')

// График автоматически загружается при открытии страницы
// Пользователь может переключать периоды кнопками 1D/7D/30D/90D/1Y
// При переключении - новая загрузка данных и перерисовка графика
```

## File Structure

```
lib/
├── domain/
│   └── models/
│       └── coin_chart_data.dart         (NEW)
├── data/
│   ├── datasource/
│   │   ├── coin_remote_datasource.dart  (UPDATED)
│   │   └── coin_remote_datasource_impl.dart (UPDATED)
│   └── repository/
│       └── coin_repository_impl.dart    (UPDATED)
├── core/
│   └── isolate/
│       └── worker_isolate.dart          (UPDATED)
└── presentation/
    ├── pages/
    │   ├── coin_detail_page.dart        (UPDATED - StatefulWidget)
    │   ├── coin_detail_cubit.dart       (UPDATED)
    │   └── coin_detail_state.dart       (UPDATED)
    └── widgets/
        └── coin_chart_widget.dart       (NEW)
```

## Testing Recommendations

1. **UI Testing**
   - Проверить отображение графика с разными периодами
   - Проверить цветовую кодировку (green/red)
   - Проверить responsive layout на разных экранах

2. **API Testing**
   - Проверить timeout на 10 сек
   - Проверить fallback если API недоступна
   - Проверить корректность парсинга данных

3. **Performance Testing**
   - Проверить что параллельная загрузка работает
   - Проверить что UI не зависает при загрузке

## Future Enhancements

- [ ] Добавить кэширование chart data (в Isar)
- [ ] Добавить touchable точки на графике (hover-информация)
- [ ] Добавить экспорт графика (скриншот/PDF)
- [ ] Добавить индикаторы (MA, RSI, etc)
- [ ] Поддержка разных валют (не только USD)

---

**Status**: ✅ Complete and tested  
**Date**: November 17, 2025
