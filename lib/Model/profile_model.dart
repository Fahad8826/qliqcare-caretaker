class Profile {
  int? userId;
  String? fullName;
  String? email;
  String? phoneNumber;
  String? gender;
  int? age;
  String? qualification;
  int? experienceYears;

  List<int> specializationIds; // Changed from specializations
  List<String> workTypes;

  int? locationId;
  String? locationName;
  String? locationOfTheCaretaker;
  double? latitude;
  double? longitude;

  String? availabilityStatus;
  String? bio;
  String? profilePicture;

  int? partnerId;
  String? partnerName;
  bool? isVerified;
  String? registrationStatus;

  Profile({
    this.userId,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.gender,
    this.age,
    this.qualification,
    this.experienceYears,
    this.locationId,
    this.locationName,
    this.locationOfTheCaretaker,
    this.latitude,
    this.longitude,
    this.availabilityStatus,
    this.bio,
    this.profilePicture,
    this.partnerId,
    this.partnerName,
    this.isVerified,
    this.registrationStatus,
    List<int>? specializationIds,
    List<String>? workTypes,
  }) : specializationIds = specializationIds ?? [],
       workTypes = workTypes ?? [];

  // ========================
  // FROM JSON
  // ========================
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: _toInt(json["user_id"]),
      fullName: json["full_name"],
      email: json["email"],
      phoneNumber: json["phone_number"],
      gender: json["gender"],
      age: _toInt(json["age"]),
      qualification: json["qualification"],
      experienceYears: _toInt(json["experience_years"]),

      // Extract specialization IDs from objects
      specializationIds: (json["specializations"] as List? ?? [])
          .map<int?>((e) => _toInt((e is Map) ? e["id"] : e))
          .whereType<int>()
          .toList(),

      workTypes: List<String>.from(json["work_types"] ?? []),

      locationId: _toInt(json["location_id"]),
      locationName: json["location_name"],
      locationOfTheCaretaker: json["location_of_the_caretaker"],
      latitude: _toDouble(json["latitude"]),
      longitude: _toDouble(json["longitude"]),

      availabilityStatus: json["availability_status"],
      bio: json["bio"],
      profilePicture: json["profile_picture"],

      partnerId: _toInt(json["partner"]),
      partnerName: json["partner_name"],
      isVerified: json["is_verified"],
      registrationStatus: json["registration_status"],
    );
  }

  // ========================
  // TO JSON (for API updates)
  // ========================
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "full_name": fullName,
      "email": email,
      "phone_number": phoneNumber,
      "gender": gender,
      "age": age, // Always send age
      "qualification": qualification,
      "experience_years": experienceYears,
      "bio": bio,
      "availability_status": availabilityStatus,

      // Django expects these exact field names
      "specialization_ids": specializationIds,
      "work_types": workTypes,
      "location": locationId, // NOTE: "location" not "location_id"
    };

    // Add optional fields only if they have values
    if (locationOfTheCaretaker != null && locationOfTheCaretaker!.isNotEmpty) {
      data["location_of_the_caretaker"] = locationOfTheCaretaker;
    }
    if (latitude != null) data["latitude"] = latitude;
    if (longitude != null) data["longitude"] = longitude;

    return data;
  }
}

// ==================================
// SAFE PARSERS
// ==================================
int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}

