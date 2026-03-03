# flutter_chen_kchart 使用指南

## ⚠️ 重要：数据计算

### 🔥 必须调用 DataUtil.calculate()

**这是最重要的步骤！** 在将数据传递给 `KChartWidget` 之前，**必须**先调用 `DataUtil.calculate()` 来计算所有技术指标。

```dart
import 'package:flutter_chen_kchart/flutter_chen_kchart.dart';
import 'package:flutter_chen_kchart/utils/data_util.dart';

// ❌ 错误示例：直接使用原始数据
List<KLineEntity> dataList = fetchKLineData();
KChartWidget(dataList, ...) // 不会有任何 MA/BOLL 线条！

// ✅ 正确示例：先计算技术指标
List<KLineEntity> dataList = fetchKLineData();
DataUtil.calculate(dataList); // 🔥 必须调用！
KChartWidget(dataList, ...) // 现在可以看到 MA/BOLL 线条了
```

---

## 📊 DataUtil.calculate() 计算内容

调用 `DataUtil.calculate()` 后，会计算以下指标：

| 指标 | 说明 | 参数 |
|------|------|------|
| MA | 移动平均线 | 默认 [5, 10, 20] |
| BOLL | 布林带 | 默认 n=20, k=2 |
| MACD | 指数平滑移动平均线 | 默认参数 |
| KDJ | 随机指标 | 默认参数 |
| RSI | 相对强弱指标 | 默认参数 |
| WR | 威廉指标 | 默认参数 |
| CCI | 顺势指标 | 默认参数 |

---

## 🎯 完整使用示例

### 1. 基础用法

```dart
import 'package:flutter/material.dart';
import 'package:flutter_chen_kchart/flutter_chen_kchart.dart';
import 'package:flutter_chen_kchart/utils/data_util.dart';

class KChartPage extends StatefulWidget {
  @override
  _KChartPageState createState() => _KChartPageState();
}

class _KChartPageState extends State<KChartPage> {
  List<KLineEntity> dataList = [];
  MainState mainState = MainState.MA;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. 获取原始数据（从 API 或本地）
    List<KLineEntity> rawData = await fetchKLineData();

    // 2. 🔥 关键：计算技术指标
    DataUtil.calculate(rawData);

    // 3. 更新 UI
    setState(() {
      dataList = rawData;
    });
  }

  Future<List<KLineEntity>> fetchKLineData() async {
    // 你的数据获取逻辑
    // 例如：从 API 获取或本地数据库读取
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('K线图表'),
        actions: [
          // 切换 MA/BOLL
          IconButton(
            icon: Text(mainState == MainState.MA ? 'MA' : 'BOLL'),
            onPressed: () {
              setState(() {
                mainState = mainState == MainState.MA
                    ? MainState.BOLL
                    : MainState.MA;
              });
            },
          ),
        ],
      ),
      body: KChartWidget(
        dataList,
        mainState: mainState, // MA 或 BOLL
        secondaryState: SecondaryState.MACD,
        isLine: false,
        maDayList: [5, 10, 20], // MA 周期
        chartColors: ChartColors(), // 可选：自定义颜色
        chartStyle: ChartStyle(),   // 可选：自定义样式
      ),
    );
  }
}
```

### 2. 从 API 获取数据并计算

```dart
Future<void> loadKLineFromAPI() async {
  try {
    // 从 Binance API 获取数据
    final response = await Dio().get(
      'https://api.binance.com/api/v3/klines',
      queryParameters: {
        'symbol': 'BTCUSDT',
        'interval': '1h',
        'limit': 100,
      },
    );

    // 解析数据
    List<KLineEntity> dataList = response.data.map((item) {
      return KLineEntity.fromJson({
        'time': item[0],
        'open': double.parse(item[1]),
        'high': double.parse(item[2]),
        'low': double.parse(item[3]),
        'close': double.parse(item[4]),
        'vol': double.parse(item[5]),
      });
    }).toList();

    // 🔥 关键步骤：计算所有技术指标
    DataUtil.calculate(dataList);

    // 更新 UI
    setState(() {
      this.dataList = dataList;
    });
  } catch (e) {
    print('获取数据失败: $e');
  }
}
```

### 3. 更新数据时重新计算

```dart
// 添加新数据后需要重新计算
void addNewKLineData(KLineEntity newData) {
  dataList.add(newData);

  // 🔥 每次数据变化后都要重新计算
  DataUtil.calculate(dataList);

  setState(() {});
}
```

### 4. 自定义 BOLL 参数

```dart
// 使用自定义参数计算 BOLL
DataUtil.calculate(
  dataList,
  [5, 10, 20], // MA 周期
  20,          // BOLL 的 n 参数
  2,           // BOLL 的 k 参数
);
```

---

## 🐛 常见问题

### Q1: 为什么看不到 MA/BOLL 线条？

**A:** 没有调用 `DataUtil.calculate()`。确保在传递数据给 `KChartWidget` 之前先调用它。

### Q2: 切换到 BOLL 后没有反应？

**A:** 确保数据已经计算过 BOLL。`DataUtil.calculate()` 会自动计算所有指标，包括 BOLL。

### Q3: 数据更新后线条消失？

**A:** 每次数据变化后都需要重新调用 `DataUtil.calculate()`。

### Q4: BOLL 线条从哪根 K 线开始显示？

**A:** BOLL(20, 2) 从第 20 根 K 线开始显示（索引 19）。

---

## 📋 数据格式要求

`KLineEntity` 必须包含以下字段：

```dart
KLineEntity(
  open: 100.0,  // 开盘价
  high: 105.0,  // 最高价
  low: 95.0,    // 最低价
  close: 102.0, // 收盘价
  vol: 1000.0,  // 成交量
  time: 1609459200000, // 时间戳（毫秒）
)
```

---

## 🔄 数据更新流程

```
原始数据 → DataUtil.calculate() → 计算后的数据 → KChartWidget
   ↓              ↓                      ↓              ↓
 K线数据    MA/BOLL/MACD等        包含技术指标      显示图表
```

---

## ✅ 检查清单

使用前请确认：

- [ ] 已导入 `DataUtil`
- [ ] 在传递数据前调用了 `DataUtil.calculate()`
- [ ] 数据格式正确（包含 open, high, low, close, vol, time）
- [ ] 数据量足够（BOLL 至少需要 20 根 K 线）
- [ ] 切换指标时数据已计算过

---

## 📞 技术支持

如果遇到问题，请：
1. 检查是否调用了 `DataUtil.calculate()`
2. 查看数据格式是否正确
3. 确认数据量是否足够
4. 在 GitHub 提交 Issue
