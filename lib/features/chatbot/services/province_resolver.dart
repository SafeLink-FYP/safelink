// Dart mirror of the backend's `entity_extractor.CITY_TO_PROVINCE` map.
//
// Phase 4 locked decision: the Flutter client sends only `city`. The backend
// derives `province` from this map. We keep a parallel Dart copy here ONLY
// for the offline path — when the chatbot is offline the backend isn't
// reachable, so the offline router needs to know which province a city
// belongs to in order to surface province-specific helplines.
//
// **Drift risk**: this map duplicates backend state. Any city added on the
// backend must also be added here. A Phase 5 task is to add a parity check
// (`scripts/check_city_province_parity.py`) that fails CI on drift.

class ProvinceResolver {
  // Province codes match `helplines.json` province keys exactly.
  static const Map<String, String> _cityToProvince = {
    // Punjab
    'lahore': 'punjab',
    'faisalabad': 'punjab',
    'rawalpindi': 'punjab',
    'multan': 'punjab',
    'gujranwala': 'punjab',
    'sialkot': 'punjab',
    'bahawalpur': 'punjab',
    'sargodha': 'punjab',
    'sheikhupura': 'punjab',
    'rahim yar khan': 'punjab',
    'jhang': 'punjab',
    'kasur': 'punjab',
    'okara': 'punjab',
    'sahiwal': 'punjab',
    'wah cantt': 'punjab',
    'dera ghazi khan': 'punjab',
    'gujrat': 'punjab',
    'chakwal': 'punjab',
    'attock': 'punjab',
    'jhelum': 'punjab',
    'mandi bahauddin': 'punjab',
    'mianwali': 'punjab',
    'khanewal': 'punjab',
    'muzaffargarh': 'punjab',
    'vehari': 'punjab',
    'pakpattan': 'punjab',
    'bahawalnagar': 'punjab',
    'muridke': 'punjab',
    'kamoke': 'punjab',
    'chiniot': 'punjab',
    'burewala': 'punjab',
    'sadiqabad': 'punjab',
    'hafizabad': 'punjab',
    'daska': 'punjab',
    'chishtian': 'punjab',
    'gojra': 'punjab',

    // Sindh
    'karachi': 'sindh',
    'hyderabad': 'sindh',
    'sukkur': 'sindh',
    'larkana': 'sindh',
    'mirpur khas': 'sindh',
    'nawabshah': 'sindh',
    'shaheed benazirabad': 'sindh',
    'khairpur': 'sindh',
    'jacobabad': 'sindh',
    'shikarpur': 'sindh',
    'dadu': 'sindh',
    'thatta': 'sindh',
    'badin': 'sindh',
    'tando allahyar': 'sindh',
    'tando adam': 'sindh',
    'umerkot': 'sindh',
    'ghotki': 'sindh',

    // KPK
    'peshawar': 'kpk',
    'mardan': 'kpk',
    'abbottabad': 'kpk',
    'swabi': 'kpk',
    'kohat': 'kpk',
    'mansehra': 'kpk',
    'swat': 'kpk',
    'mingora': 'kpk',
    'chitral': 'kpk',
    'bannu': 'kpk',
    'nowshera': 'kpk',
    'dera ismail khan': 'kpk',
    'haripur': 'kpk',
    'charsadda': 'kpk',
    'battagram': 'kpk',
    'dir': 'kpk',
    'shangla': 'kpk',
    'buner': 'kpk',
    'tank': 'kpk',

    // Balochistan
    'quetta': 'balochistan',
    'gwadar': 'balochistan',
    'turbat': 'balochistan',
    'khuzdar': 'balochistan',
    'hub': 'balochistan',
    'chaman': 'balochistan',
    'zhob': 'balochistan',
    'dera bugti': 'balochistan',
    'loralai': 'balochistan',
    'lasbela': 'balochistan',
    'mastung': 'balochistan',
    'qila saifullah': 'balochistan',
    'noshki': 'balochistan',

    // Gilgit-Baltistan
    'gilgit': 'gilgit_baltistan',
    'skardu': 'gilgit_baltistan',
    'hunza': 'gilgit_baltistan',
    'chilas': 'gilgit_baltistan',
    'ghizer': 'gilgit_baltistan',
    'astore': 'gilgit_baltistan',
    'shigar': 'gilgit_baltistan',
    'kharmang': 'gilgit_baltistan',
    'ghanche': 'gilgit_baltistan',
    'diamer': 'gilgit_baltistan',

    // AJK
    'muzaffarabad': 'ajk',
    'mirpur': 'ajk',
    'kotli': 'ajk',
    'rawalakot': 'ajk',
    'bhimber': 'ajk',
    'bagh': 'ajk',
    'neelum': 'ajk',
    'haveli': 'ajk',
    'sudhanoti': 'ajk',

    // ICT
    'islamabad': 'islamabad',
  };

  /// Resolve a city name to its province code, or null if unknown.
  /// Lowercases + trims input; tolerates extra whitespace.
  static String? provinceFromCity(String? city) {
    if (city == null) return null;
    final key = city.trim().toLowerCase();
    if (key.isEmpty) return null;
    return _cityToProvince[key];
  }

  /// Convenience: returns true if [city] is a known Pakistani city.
  static bool knowsCity(String? city) => provinceFromCity(city) != null;

  /// Used by tests + parity check.
  static int get cityCount => _cityToProvince.length;
  static Iterable<String> get knownCities => _cityToProvince.keys;
}
