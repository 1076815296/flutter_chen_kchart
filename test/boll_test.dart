import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_chen_kchart/entity/k_line_entity.dart';
import 'package:flutter_chen_kchart/utils/data_util.dart';

void main() {
  group('BOLL Calculation Tests', () {
    late List<KLineEntity> dataList;

    setUp(() {
      // 创建测试数据 - 模拟 25 个 K 线数据点
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

      // 计算 BOLL
      DataUtil.calcBOLL(dataList, 20, 2);
    });

    test('前 19 个数据点的 BOLL 值应该为 null', () {
      for (int i = 0; i < 19; i++) {
        expect(dataList[i].up, isNull,
            reason: 'Index $i: up should be null before 20 periods');
        expect(dataList[i].mb, isNull,
            reason: 'Index $i: mb should be null before 20 periods');
        expect(dataList[i].dn, isNull,
            reason: 'Index $i: dn should be null before 20 periods');
        expect(dataList[i].BOLLMA, isNull,
            reason: 'Index $i: BOLLMA should be null before 20 periods');
      }
    });

    test('第 20 个数据点开始应该有 BOLL 值', () {
      final index = 19; // 第 20 个数据点（索引 19）
      expect(dataList[index].up, isNotNull,
          reason: 'Index $index: up should not be null after 20 periods');
      expect(dataList[index].mb, isNotNull,
          reason: 'Index $index: mb should not be null after 20 periods');
      expect(dataList[index].dn, isNotNull,
          reason: 'Index $index: dn should not be null after 20 periods');
      expect(dataList[index].BOLLMA, isNotNull,
          reason: 'Index $index: BOLLMA should not be null after 20 periods');
    });

    test('BOLL 上轨应该 >= 中轨 >= 下轨', () {
      for (int i = 19; i < dataList.length; i++) {
        final up = dataList[i].up!;
        final mb = dataList[i].mb!;
        final dn = dataList[i].dn!;

        expect(up, greaterThanOrEqualTo(mb),
            reason: 'Index $i: up ($up) should be >= mb ($mb)');
        expect(mb, greaterThanOrEqualTo(dn),
            reason: 'Index $i: mb ($mb) should be >= dn ($dn)');

        // 验证上轨和下轨的宽度（标准差的 2 倍）
        final expectedWidth = (up - dn) / 2;
        expect(expectedWidth, greaterThan(0),
            reason: 'Index $i: BOLL width should be positive');
      }
    });

    test('BOLL 计算逻辑验证', () {
      // 手动计算第 20 个数据点的 BOLL 值
      final n = 20;
      final k = 2;
      final index = 19;

      // 计算 MA(20)
      double sum = 0;
      for (int i = 0; i < n; i++) {
        sum += dataList[index - i].close;
      }
      final expectedMA = sum / n;

      // 计算标准差
      double md = 0;
      for (int j = index - n + 1; j <= index; j++) {
        double c = dataList[j].close;
        double value = c - expectedMA;
        md += value * value;
      }
      md = md / (n - 1);
      md = sqrt(md);

      final expectedMB = expectedMA;
      final expectedUp = expectedMB + k * md;
      final expectedDn = expectedMB - k * md;

      // 验证计算结果
      expect(dataList[index].BOLLMA, closeTo(expectedMA, 0.0001),
          reason: 'BOLLMA calculation');
      expect(dataList[index].mb, closeTo(expectedMB, 0.0001),
          reason: 'MB calculation');
      expect(dataList[index].up, closeTo(expectedUp, 0.0001),
          reason: 'UP calculation');
      expect(dataList[index].dn, closeTo(expectedDn, 0.0001),
          reason: 'DN calculation');
    });

    test('所有有效 BOLL 值不应该为 0', () {
      for (int i = 19; i < dataList.length; i++) {
        expect(dataList[i].up, isNot(equals(0)),
            reason: 'Index $i: up should not be 0');
        expect(dataList[i].mb, isNot(equals(0)),
            reason: 'Index $i: mb should not be 0');
        expect(dataList[i].dn, isNot(equals(0)),
            reason: 'Index $i: dn should not be 0');
      }
    });
  });
}
