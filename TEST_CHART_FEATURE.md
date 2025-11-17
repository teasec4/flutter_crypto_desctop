# Testing Chart Feature

## Quick Start

### 1. Run the app
```bash
flutter run
```

### 2. Navigate to coin detail
- Авторизуйтесь
- На странице "Content" (монеты) нажмите на любую монету
- Должна открыться страница деталей монеты с графиком

### 3. Test Chart Features

#### Feature: Graph Display
- [ ] На странице видна карточка "Price Chart"
- [ ] График загружается и отображается корректно
- [ ] График имеет зелёную кривую для положительного изменения цены
- [ ] График имеет красную кривую для отрицательного изменения цены
- [ ] Под графиком отображаются min/current/max цены

#### Feature: Time Period Selection
- [ ] Кнопки 1D, 7D, 30D, 90D, 1Y видны и кликаются
- [ ] При клике на кнопку - выделяется (фон меняется на основной цвет)
- [ ] При клике - график обновляется с новыми данными
- [ ] При клике - process indicator показывает загрузку (можно добавить)

#### Feature: Data Display
- [ ] Процент изменения отображается рядом с заголовком "Price Chart"
- [ ] Процент зелёный если положительный, красный если отрицательный
- [ ] Min/Max/Current цены отображаются внизу графика
- [ ] Цены обновляются при переключении временных периодов

#### Feature: Error Handling
- [ ] Если API недоступна - график не показывается (или error message)
- [ ] Основная информация о монете всё ещё видна
- [ ] Других компонентов страницы не повреждены

#### Feature: Performance
- [ ] График загружается быстро (< 2 сек)
- [ ] При переключении периодов нет зависания UI
- [ ] Нет утечек памяти при переключении страниц

### 4. Test Different Coins

```
Протестировать на:
- BTC (Bitcoin) - большие цены, стабильный график
- ETH (Ethereum) - средние цены
- DOGE (Dogecoin) - маленькие цены, волатильные
- SHIB (Shiba Inu) - очень маленькие цены (научная нотация)
```

### 5. Test Different Time Periods

```
Проверить что данные различаются при:
1D   - 1 день (24 часа)
7D   - 7 дней (неделя)
30D  - 30 дней (месяц)
90D  - 90 дней (квартал)
1Y   - 1 год (365 дней)

Особенно проверить что:
- Изменение процента различается между периодами
- Диапазон цен расширяется по мере увеличения периода
```

### 6. Test Responsive Layout

```
- На мобильном экране (маленьком)
- На планшете (средний)
- На десктопе (большой)
- На очень широком экране (landscape)

График должен корректно масштабироваться
```

### 7. Test Error Cases

```bash
# Отключить интернет и переключить период
- Должна быть ошибка (timeout или connection error)
- Основная информация о монете должна остаться

# Включить интернет обратно
- График должен загрузиться при переходе на другую монету
```

## Checklist перед Merge

- [ ] No compilation errors (`flutter analyze`)
- [ ] No runtime errors (check console logs)
- [ ] Chart displays correctly on all tested coins
- [ ] Time period buttons work correctly
- [ ] Data updates when switching periods
- [ ] Error handling works (graceful fallback)
- [ ] No UI freezing during data load
- [ ] Responsive design works on all screen sizes
- [ ] Memory doesn't leak (check DevTools)

## Known Limitations

1. Chart data is NOT cached (always fresh from API)
   - Это хорошо для актуальности, но требует интернета
   - Можно добавить кэширование в будущем в Isar

2. Grid lines и labels могут быть плотными на маленьких экранах
   - Можно добавить responsive logic позже

3. Нет touch/hover interactions на графике
   - Можно добавить detailed tooltip при наведении

## Performance Benchmarks

Ожидаемое время загрузки:
- Coin info: ~500ms
- Chart data: ~800-1200ms (в зависимости от периода)
- Parallel loading: ~1200-1500ms (оба одновременно)

## Debug Tips

### View Network Requests
```dart
// В worker_isolate.dart можно добавить логирование:
developer.log('Fetching chart: $url');
```

### Check Chart Data Structure
```dart
// В CoinDetailCubit:
print('Chart data: ${chartData?.dataPoints.length} points');
print('Min: ${chartData?.minPrice}, Max: ${chartData?.maxPrice}');
```

### Performance Profiling
- Открыть DevTools: `flutter pub global run devtools`
- Check Timeline tab для performance анализа

---

**Happy Testing!** 🚀
