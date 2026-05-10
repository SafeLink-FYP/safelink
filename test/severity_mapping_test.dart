import 'package:flutter_test/flutter_test.dart';
import 'package:safelink/features/alerts/utils/severity_mapping.dart';

void main() {
  group('mapMagnitudeToSeverity', () {
    test('M < 4.0 is low', () {
      expect(mapMagnitudeToSeverity(0.0), 'low');
      expect(mapMagnitudeToSeverity(3.9), 'low');
    });

    test('4.0 ≤ M < 5.5 is medium', () {
      expect(mapMagnitudeToSeverity(4.0), 'medium');
      expect(mapMagnitudeToSeverity(5.4), 'medium');
    });

    test('5.5 ≤ M < 7.0 is high', () {
      expect(mapMagnitudeToSeverity(5.5), 'high');
      expect(mapMagnitudeToSeverity(6.9), 'high');
    });

    test('M ≥ 7.0 is critical', () {
      expect(mapMagnitudeToSeverity(7.0), 'critical');
      expect(mapMagnitudeToSeverity(9.5), 'critical');
    });
  });

  group('mapFloodRiskToSeverity', () {
    test('score < 25 is low', () {
      expect(mapFloodRiskToSeverity(0), 'low');
      expect(mapFloodRiskToSeverity(24.9), 'low');
    });

    test('25 ≤ score < 50 is medium', () {
      expect(mapFloodRiskToSeverity(25), 'medium');
      expect(mapFloodRiskToSeverity(49.9), 'medium');
    });

    test('50 ≤ score < 75 is high', () {
      expect(mapFloodRiskToSeverity(50), 'high');
      expect(mapFloodRiskToSeverity(74.9), 'high');
    });

    test('score ≥ 75 is critical', () {
      expect(mapFloodRiskToSeverity(75), 'critical');
      expect(mapFloodRiskToSeverity(100), 'critical');
    });
  });
}
