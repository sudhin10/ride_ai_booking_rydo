class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String role;
  final double walletBalance;
  final String homeAddress;
  final String workAddress;
  final String emergencyContact;
  final bool voiceNavigationEnabled;
  final bool voiceNavigationPrompted;
  final double ttsSpeechRate;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.avatarUrl = '',
    this.role = 'rider',
    this.walletBalance = 0,
    this.homeAddress = '',
    this.workAddress = '',
    this.emergencyContact = '',
    this.voiceNavigationEnabled = false,
    this.voiceNavigationPrompted = false,
    this.ttsSpeechRate = 0.5,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['_id'] ?? j['id'] ?? '',
        name: j['name'] ?? '',
        email: j['email'] ?? '',
        phone: j['phone'] ?? '',
        avatarUrl: j['avatarUrl'] ?? '',
        role: j['role'] ?? 'rider',
        walletBalance: (j['walletBalance'] ?? 0).toDouble(),
        homeAddress: j['homeAddress'] ?? '',
        workAddress: j['workAddress'] ?? '',
        emergencyContact: j['emergencyContact'] ?? '',
        voiceNavigationEnabled: j['voiceNavigationEnabled'] ?? false,
        voiceNavigationPrompted: j['voiceNavigationPrompted'] ?? false,
        ttsSpeechRate: (j['ttsSpeechRate'] ?? 0.5).toDouble(),
      );

  UserModel copyWith({String? name, String? phone, String? avatarUrl, double? walletBalance}) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email,
        phone: phone ?? this.phone,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        role: role,
        walletBalance: walletBalance ?? this.walletBalance,
        homeAddress: homeAddress,
        workAddress: workAddress,
        emergencyContact: emergencyContact,
        voiceNavigationEnabled: voiceNavigationEnabled,
        voiceNavigationPrompted: voiceNavigationPrompted,
        ttsSpeechRate: ttsSpeechRate,
      );
}
