class AccountData {
  final String id;
  String title;
  String username;
  String password;
  String? website;
  String? notes;
  int colorIndex; // For UI decoration
  DateTime updatedAt;

  AccountData({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.website,
    this.notes,
    this.colorIndex = 0,
    required this.updatedAt,
  });

  // Create a copy for editing
  AccountData copyWith({
    String? title,
    String? username,
    String? password,
    String? website,
    String? notes,
    int? colorIndex,
    DateTime? updatedAt,
  }) {
    return AccountData(
      id: this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      colorIndex: colorIndex ?? this.colorIndex,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
