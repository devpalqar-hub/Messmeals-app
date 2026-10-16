import 'package:shared_preferences/shared_preferences.dart';

/// GCC countries use the Riyal symbol per the owner's request — this is a
/// simplification (Kuwait/Bahrain/Oman technically use Dinar/Rial with
/// different subunits), not a full locale/currency-code implementation.
const Set<String> gccCountryIsoCodes = {
  'SA', // Saudi Arabia
  'AE', // UAE
  'QA', // Qatar
  'KW', // Kuwait
  'BH', // Bahrain
  'OM', // Oman
};

const String _prefsKey = 'currencyCountryIso';

/// The mess's country (ISO code) and the currency symbol it maps to.
/// Backend has no country field for a mess yet, so this is stored locally
/// on the device — set once when a mess is created/signed up for, read
/// everywhere a price is displayed.
String selectedCurrencyCountryIso = 'IN';
String currencySymbol = '₹';

String symbolForCountry(String isoCode) {
  return gccCountryIsoCodes.contains(isoCode.toUpperCase()) ? 'ر.س' : '₹';
}

Future<void> loadCurrencyPreference() async {
  final prefs = await SharedPreferences.getInstance();
  selectedCurrencyCountryIso = prefs.getString(_prefsKey) ?? 'IN';
  currencySymbol = symbolForCountry(selectedCurrencyCountryIso);
}

Future<void> setCurrencyCountry(String isoCode) async {
  selectedCurrencyCountryIso = isoCode;
  currencySymbol = symbolForCountry(isoCode);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_prefsKey, isoCode);
}
