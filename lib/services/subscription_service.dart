import 'dart:convert';
import '../config/api_config.dart';
import 'api_client.dart';

class SubscriptionService {
  static const String _baseEndpoint = '/api/v1/subscriptions';
  static final ApiClient _apiClient = ApiClient();

  /// Subscribe to a plan
  ///
  /// Parameters:
  /// - `guid`: Optional GUID for the subscription
  ///
  /// Returns:
  /// - `Map<String, dynamic>` containing subscription details
  ///
  /// Throws:
  /// - `Exception` if the subscription fails
  static Future<Map<String, dynamic>> subscribe({String? guid}) async {
    print('Starting subscription process...');

    try {
      final headers = {
        if (guid != null) 'x-jarvis-guid': guid,
      };

      print(
          'Making subscription request to: ${ApiConfig.jarvisBaseUrl}$_baseEndpoint/subscribe');
      print('Headers: $headers');

      final response = await _apiClient.get(
        '${ApiConfig.jarvisBaseUrl}$_baseEndpoint/subscribe',
        headers: headers,
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Successfully subscribed. Response: $jsonResponse');
        return jsonResponse;
      } else {
        print('Subscription failed with status code: ${response.statusCode}');
        print('Error message: ${response.reasonPhrase}');
        throw Exception('Failed to subscribe: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error during subscription: $e');
      rethrow;
    }
  }

  /// Get current subscription usage
  ///
  /// Returns:
  /// - `Map<String, dynamic>` containing usage details with subscription type
  ///
  /// Throws:
  /// - `Exception` if fetching usage fails
  static Future<Map<String, dynamic>> getUsage() async {
    print('Fetching subscription usage...');

    try {
      print(
          'Making usage request to: ${ApiConfig.jarvisBaseUrl}$_baseEndpoint/me');

      final response = await _apiClient.get(
        '${ApiConfig.jarvisBaseUrl}$_baseEndpoint/me',
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Successfully fetched usage. Response: $jsonResponse');

        // Extract subscription type from response
        final subscriptionType = jsonResponse['name'] ?? 'basic';
        print('Current subscription type: $subscriptionType');

        return {
          'subscriptionType': subscriptionType,
          'data': jsonResponse,
        };
      } else {
        print('Failed to fetch usage with status code: ${response.statusCode}');
        print('Error message: ${response.reasonPhrase}');
        throw Exception('Failed to fetch usage: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching usage: $e');
      rethrow;
    }
  }
}
