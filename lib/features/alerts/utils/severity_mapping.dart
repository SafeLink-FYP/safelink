/// Pure mappings from raw ML model outputs to the four-bucket severity
/// label the UI uses. Extracted from `AlertController` so they can be
/// unit-tested without instantiating GetX or Supabase.
///
/// Bucket boundaries are deliberate: they match the cutoffs the
/// designers picked for the alert palette in `app_theme.dart`. Changing
/// them is a UX decision — keep this file in sync with the alert
/// rendering cards in `alert_detail_view.dart` if they move.
library;

/// Earthquake mainshock magnitude → severity bucket.
String mapMagnitudeToSeverity(double magnitude) {
  if (magnitude >= 7.0) return 'critical';
  if (magnitude >= 5.5) return 'high';
  if (magnitude >= 4.0) return 'medium';
  return 'low';
}

/// Flood risk score (0..100) → severity bucket.
String mapFloodRiskToSeverity(double riskScore) {
  if (riskScore >= 75) return 'critical';
  if (riskScore >= 50) return 'high';
  if (riskScore >= 25) return 'medium';
  return 'low';
}
