class LoginResponse {
  final bool isSuccess;
  final int code;
  final String token;
  final String refreshToken;
  final String message;

  LoginResponse({
    required this.isSuccess,
    required this.code,
    required this.token,
    required this.refreshToken,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      isSuccess: json['isSuccess'],
      code: json['code'],
      token: json['data']['token'],
      refreshToken: json['data']['refreshToken'],
      message: json['message'],
    );
  }
}
