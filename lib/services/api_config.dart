class ApiConfig {
  static const String baseUrl = 'http://localhost:5000/api';
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String doctorsEndpoint = '/doctors';
  static const String patientsEndpoint = '/paitents';
  static const String pharmacyEndpoint = '/pharmacy';
  static const String appointmentsEndpoint = '/appointments';
  
  // Auth endpoints
  static const String register = '$authEndpoint/register';
  static const String login = '$authEndpoint/login';
  static const String forgetPassword = '$authEndpoint/forget_password';
  static const String checkOTP = '$authEndpoint/checkOTP';
  static const String resetPassword = '$authEndpoint/reset_password';
}
