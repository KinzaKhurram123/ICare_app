import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleCalendarService {
  static final GoogleCalendarService _instance = GoogleCalendarService._internal();
  factory GoogleCalendarService() => _instance;
  GoogleCalendarService._internal();

  static const String _calendarApiBase = 'https://www.googleapis.com/calendar/v3';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '564788374793-1eptqsl65ohkvsquqhc4qnhlia592v2f.apps.googleusercontent.com',
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar.events',
    ],
  );

  /// Sign in with Google and get Calendar access token
  Future<String?> _getAccessToken() async {
    try {
      // Try silent sign-in first
      GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      account ??= await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      return auth.accessToken;
    } catch (e) {
      debugPrint('Google Calendar auth error: $e');
      return null;
    }
  }

  /// Add a reminder as a Google Calendar event
  /// Returns true on success, false on failure
  Future<bool> addReminderToCalendar({
    required String title,
    required String description,
    required DateTime dateTime,
    int durationMinutes = 30,
  }) async {
    if (kIsWeb) {
      // Web requires different OAuth flow — not supported in this build
      return false;
    }

    final token = await _getAccessToken();
    if (token == null) return false;

    try {
      final dio = Dio();
      final start = dateTime.toUtc().toIso8601String();
      final end = dateTime.add(Duration(minutes: durationMinutes)).toUtc().toIso8601String();

      final response = await dio.post(
        '$_calendarApiBase/calendars/primary/events',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {
          'summary': title,
          'description': description,
          'start': {'dateTime': start, 'timeZone': 'Asia/Karachi'},
          'end': {'dateTime': end, 'timeZone': 'Asia/Karachi'},
          'reminders': {
            'useDefault': false,
            'overrides': [
              {'method': 'popup', 'minutes': 10},
            ],
          },
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      debugPrint('Calendar API error: ${e.response?.data}');
      return false;
    }
  }

  /// Sign out from Google Calendar
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
