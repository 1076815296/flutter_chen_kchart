import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_chen_kchart/entity/k_line_entity.dart';
import 'package:flutter_chen_kchart/utils/data_util.dart';

/// 测试：验证 DataUtil.calculate() 的重要性
///
/// 这个测试展示了：
/// 1. 未调用 DataUtil.calculate() 时，技术指标数据为空
/// 2. 调用后，技术指标数据被正确计算
void main() {
  group('DataUtil.calculate() 测试', () {
    late List<KLineEntity> dataList;

    setUp(() {
      // 创建 25 个模拟 K 线数据
      dataList = List.generate(25, (index) {
        final basePrice = 100.0 + index * 0.5;
        return KLineEntity.fromCustom(
          open: basePrice,
          high: basePrice + 2.0,
          low: basePrice - 2.0,
          close: basePrice + 1.0,
          vol: 1000.0,
          time: 1609459200000 + index * 86400000,
        );
      });
    });

    test('未调用 DataUtil.calculate() 时，MA 值为空', () {
      // 创建新的数据副本，不调用 calculate
      final uncalculatedData = List<KLineEntity>.from(
        dataList.map((e) => KLineEntity.fromCustom(
              open: e.open,
              high: e.high,
              low: e.low,
              close: e.close,
              vol: e.vol,
              time: e.time,
            )),
      );

      // 验证：MA 值为 null
      expect(uncalculatedData[19].maValueList, isNull,
          reason: '未调用 calculate 时，maValueList 应该为 null');

      // 这就是为什么看不到 MA 线的原因！
    });

    test('调用 DataUtil.calculate() 后，MA 值被正确计算', () {
      // 创建新的数据副本
      final calculatedData = List<KLineEntity>.from(
        dataList.map((e) => KLineEntity.fromCustom(
              open: e.open,
              high: e.high,
              low: e.low,
              close: e.close,
              vol: e.vol,
              time: e.time,
            )),
      );

      // 调用 calculate - 这是关键步骤！
      DataUtil.calculate(calculatedData);

      // 验证：MA 值被正确计算
      expect(calculatedData[19].maValueList, isNotNull,
          reason: '调用 calculate 后，maValueList 不应该为 null');

      expect(calculatedData[19].maValueList!.length, equals(3),
          reason: '应该有 3 个 MA 值 (MA5, MA10, MA20)');

      expect(calculatedData[19].maValueList![0], greaterThan(0),
          reason: 'MA5 值应该大于 0');

      // 现在可以看到 MA 线了！
    });

    test('未调用 DataUtil.calculate() 时，BOLL 值为空', () {
      final uncalculatedData = List<KLineEntity>.from(
        dataList.map((e) => KLineEntity.fromCustom(
              open: e.open,
              high: e.high,
              low: e.low,
              close: e.close,
              vol: e.vol,
              time: e.time,
            )),
      );

      // 验证：BOLL 值为 null
      expect(uncalculatedData[19].up, isNull,
          reason: '未调用 calculate 时，up 应该为 null');
      expect(uncalculatedData[19].mb, isNull,
          reason: '未调用 calculate 时，mb 应该为 null');
      expect(uncalculatedData[19].dn, isNull,
          reason: '未调用 calculate 时，dn 应该为 null');

      // 这就是为什么看不到 BOLL 线的原因！
    });

    test('调用 DataUtil.calculate() 后，BOLL 值被正确计算', () {
      final calculatedData = List<KLineEntity>.from(
        dataList.map((e) => KLineEntity.fromCustom(
              open: e.open,
              high: e.high,
              low: e.low,
              close: e.close,
              vol: e.vol,
              time: e.time,
            )),
      );

      // 调用 calculate - 这是关键步骤！
      DataUtil.calculate(calculatedData);

      // 验证：BOLL 值被正确计算
      expect(calculatedData[19].up, isNotNull,
          reason: '调用 calculate 后，up 不应该为 null');
      expect(calculatedData[19].mb, isNotNull,
          reason: '调用 calculate 后，mb 不应该为 null');
      expect(calculatedData[19].dn, isNotNull,
          reason: '调用 calculate 后，dn 不应该为 null');

      // 验证 BOLL 的正确性：上轨 >= 中轨 >= 下轨
      expect(calculatedData[19].up! >= calculatedData[19].mb!, isTrue,
          reason: '上轨应该 >= 中轨');
      expect(calculatedData[19].mb! >= calculatedData[19].dn!, isTrue,
          reason: '中轨应该 >= 下轨');

      // 现在可以看到 BOLL 线了！
    });

    test('展示：正确的使用方式', () {
      // ❌ 错误方式
      final wrongData = dataList;
      // wrongData 直接传给 KChartWidget - 不会有任何线条！

      // ✅ 正确方式
      final correctData = List<KLineEntity>.from(
        dataList.map((e) => KLineEntity.fromCustom(
              open: e.open,
              high: e.high,
              low: e.low,
              close: e.close,
              vol: e.vol,
              time: e.time,
            )),
      );

      // 🔥 关键步骤：计算技术指标
      DataUtil.calculate(correctData);

      // 验证：数据已计算
      expect(correctData[4].maValueList, isNotNull);
      expect(correctData[19].up, isNotNull);

      // 现在可以传递给 KChartWidget 了
      // KChartWidget(correctData, mainState: MainState.BOLL)
      // ✅ 可以看到 BOLL 线了！
    });
  });
}
