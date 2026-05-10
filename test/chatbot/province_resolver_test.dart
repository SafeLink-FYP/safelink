import 'package:flutter_test/flutter_test.dart';
import 'package:safelink/features/chatbot/services/province_resolver.dart';

void main() {
  group('ProvinceResolver — city → province mapping', () {
    test('major Punjab cities map to punjab', () {
      expect(ProvinceResolver.provinceFromCity('Lahore'), 'punjab');
      expect(ProvinceResolver.provinceFromCity('faisalabad'), 'punjab');
      expect(ProvinceResolver.provinceFromCity('  Multan  '), 'punjab');
    });

    test('major Sindh cities map to sindh', () {
      expect(ProvinceResolver.provinceFromCity('Karachi'), 'sindh');
      expect(ProvinceResolver.provinceFromCity('hyderabad'), 'sindh');
      expect(ProvinceResolver.provinceFromCity('thatta'), 'sindh');
    });

    test('KPK cities map to kpk', () {
      expect(ProvinceResolver.provinceFromCity('peshawar'), 'kpk');
      expect(ProvinceResolver.provinceFromCity('Abbottabad'), 'kpk');
    });

    test('Balochistan cities map to balochistan', () {
      expect(ProvinceResolver.provinceFromCity('quetta'), 'balochistan');
      expect(ProvinceResolver.provinceFromCity('gwadar'), 'balochistan');
    });

    test('GB / AJK / ICT cities resolve correctly', () {
      expect(ProvinceResolver.provinceFromCity('skardu'), 'gilgit_baltistan');
      expect(ProvinceResolver.provinceFromCity('muzaffarabad'), 'ajk');
      expect(ProvinceResolver.provinceFromCity('islamabad'), 'islamabad');
    });

    test('unknown city returns null', () {
      expect(ProvinceResolver.provinceFromCity('atlantis'), null);
      expect(ProvinceResolver.provinceFromCity(''), null);
      expect(ProvinceResolver.provinceFromCity(null), null);
    });

    test('input is case-insensitive and tolerates whitespace', () {
      expect(ProvinceResolver.provinceFromCity('LAHORE'), 'punjab');
      expect(ProvinceResolver.provinceFromCity('  KARACHI  '), 'sindh');
    });

    test('multi-word cities round-trip', () {
      expect(ProvinceResolver.provinceFromCity('Rahim Yar Khan'), 'punjab');
      expect(ProvinceResolver.provinceFromCity('dera ghazi khan'), 'punjab');
      expect(ProvinceResolver.provinceFromCity('mirpur khas'), 'sindh');
    });

    test('coverage: at least 100 cities indexed', () {
      // The Phase 2 backend KB ships an entity_extractor.CITY_TO_PROVINCE
      // with ~120 cities. The Dart mirror should track close behind.
      expect(ProvinceResolver.cityCount, greaterThanOrEqualTo(100));
    });
  });
}
