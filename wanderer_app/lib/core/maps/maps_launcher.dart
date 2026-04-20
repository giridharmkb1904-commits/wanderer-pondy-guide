import 'package:url_launcher/url_launcher.dart';

/// Opens a place in Google Maps (app if available, otherwise browser).
/// Uses the `search` endpoint which resolves a query string server-side.
class MapsLauncher {
  MapsLauncher._();

  static Future<void> openQuery(String query, {String? city = 'Pondicherry'}) async {
    final q = Uri.encodeComponent(
      city == null || city.isEmpty ? query : '$query, $city',
    );
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // best-effort; user can copy address manually
    }
  }

  static Future<void> openCoords(double lat, double lng, {String? label}) async {
    final q = label != null
        ? '${Uri.encodeComponent(label)}@$lat,$lng'
        : '$lat,$lng';
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // best-effort; user can copy address manually
    }
  }
}
