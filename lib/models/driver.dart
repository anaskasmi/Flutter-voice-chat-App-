import 'dart:convert';

class Driver {
  String id;
  String badgeId;
  String firstName;
  String lastName;
  String email;
  String lisenceNumber;
  String licenseExpiry;
  String permitExpiry;
  String abstractExpiry;
  String pictureUrl;
  String homePhone;
  String address;
  String status;
  String licenseClass;
  String taxiHost;
  String startDate;
  String endDate;
  String licenseUrl;
  String permitUrl;
  String taxiHostUrl;
  String abstractUrl;
  String spFileUrl;
  String createdAt;
  String updatedAt;
  bool isAllowedToUseChat;
  Driver({
    this.id,
    this.badgeId,
    this.firstName,
    this.lastName,
    this.email,
    this.lisenceNumber,
    this.licenseExpiry,
    this.permitExpiry,
    this.abstractExpiry,
    this.pictureUrl,
    this.homePhone,
    this.address,
    this.status,
    this.licenseClass,
    this.taxiHost,
    this.startDate,
    this.endDate,
    this.licenseUrl,
    this.permitUrl,
    this.taxiHostUrl,
    this.abstractUrl,
    this.spFileUrl,
    this.createdAt,
    this.updatedAt,
    this.isAllowedToUseChat,
  }) {
    this.firstName ??= "";
    this.lastName ??= "";
    this.email ??= "";
    this.lisenceNumber ??= "";
    this.licenseExpiry ??= "";
    this.permitExpiry ??= "";
    this.abstractExpiry ??= "";
    this.pictureUrl ??=
    "https://mytaxioffice.com/storage/uploads/IMAGES/man.png";
    this.homePhone ??= "";
    this.address ??= "";
    this.status ??= "";
    this.licenseClass ??= "";
    this.taxiHost ??= "";
    this.startDate ??= "";
    this.endDate ??= "";
    this.licenseUrl ??= "";
    this.permitUrl ??= "";
    this.taxiHostUrl ??= "";
    this.abstractUrl ??= "";
    this.spFileUrl ??= "";
    this.createdAt ??= "";
    this.updatedAt ??= "";
  }

  Driver copyWith({
    String id,
    String badgeId,
    String firstName,
    String lastName,
    String email,
    String lisenceNumber,
    String licenseExpiry,
    String permitExpiry,
    String abstractExpiry,
    String pictureUrl,
    String homePhone,
    String address,
    String status,
    String licenseClass,
    String taxiHost,
    String startDate,
    String endDate,
    String licenseUrl,
    String permitUrl,
    String taxiHostUrl,
    String abstractUrl,
    String spFileUrl,
    String createdAt,
    String updatedAt,
  }) {
    return Driver(
      id: id ?? this.id,
      badgeId: badgeId ?? this.badgeId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      lisenceNumber: lisenceNumber ?? this.lisenceNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      permitExpiry: permitExpiry ?? this.permitExpiry,
      abstractExpiry: abstractExpiry ?? this.abstractExpiry,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      homePhone: homePhone ?? this.homePhone,
      address: address ?? this.address,
      status: status ?? this.status,
      licenseClass: licenseClass ?? this.licenseClass,
      taxiHost: taxiHost ?? this.taxiHost,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      licenseUrl: licenseUrl ?? this.licenseUrl,
      permitUrl: permitUrl ?? this.permitUrl,
      taxiHostUrl: taxiHostUrl ?? this.taxiHostUrl,
      abstractUrl: abstractUrl ?? this.abstractUrl,
      spFileUrl: spFileUrl ?? this.spFileUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'badgeId': badgeId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'lisenceNumber': lisenceNumber,
      'licenseExpiry': licenseExpiry,
      'permitExpiry': permitExpiry,
      'abstractExpiry': abstractExpiry,
      'pictureUrl': pictureUrl,
      'homePhone': homePhone,
      'address': address,
      'status': status,
      'licenseClass': licenseClass,
      'taxiHost': taxiHost,
      'startDate': startDate,
      'endDate': endDate,
      'licenseUrl': licenseUrl,
      'permitUrl': permitUrl,
      'taxiHostUrl': taxiHostUrl,
      'abstractUrl': abstractUrl,
      'spFileUrl': spFileUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static Driver fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Driver(
      id: map['id'],
      badgeId: map['badgeId'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      lisenceNumber: map['lisenceNumber'],
      licenseExpiry: map['licenseExpiry'],
      permitExpiry: map['permitExpiry'],
      abstractExpiry: map['abstractExpiry'],
      pictureUrl: map['pictureUrl'],
      homePhone: map['homePhone'],
      address: map['address'],
      status: map['status'],
      licenseClass: map['licenseClass'],
      taxiHost: map['taxiHost'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      licenseUrl: map['licenseUrl'],
      permitUrl: map['permitUrl'],
      taxiHostUrl: map['taxiHostUrl'],
      abstractUrl: map['abstractUrl'],
      spFileUrl: map['spFileUrl'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  String toJson() => json.encode(toMap());

  static Driver fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Driver(id: $id, badgeId: $badgeId, firstName: $firstName, lastName: $lastName, email: $email, lisenceNumber: $lisenceNumber, licenseExpiry: $licenseExpiry, permitExpiry: $permitExpiry, abstractExpiry: $abstractExpiry, pictureUrl: $pictureUrl, homePhone: $homePhone, address: $address, status: $status, licenseClass: $licenseClass, taxiHost: $taxiHost, startDate: $startDate, endDate: $endDate, licenseUrl: $licenseUrl, permitUrl: $permitUrl, taxiHostUrl: $taxiHostUrl, abstractUrl: $abstractUrl, spFileUrl: $spFileUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Driver &&
        o.id == id &&
        o.badgeId == badgeId &&
        o.firstName == firstName &&
        o.lastName == lastName &&
        o.email == email &&
        o.lisenceNumber == lisenceNumber &&
        o.licenseExpiry == licenseExpiry &&
        o.permitExpiry == permitExpiry &&
        o.abstractExpiry == abstractExpiry &&
        o.pictureUrl == pictureUrl &&
        o.homePhone == homePhone &&
        o.address == address &&
        o.status == status &&
        o.licenseClass == licenseClass &&
        o.taxiHost == taxiHost &&
        o.startDate == startDate &&
        o.endDate == endDate &&
        o.licenseUrl == licenseUrl &&
        o.permitUrl == permitUrl &&
        o.taxiHostUrl == taxiHostUrl &&
        o.abstractUrl == abstractUrl &&
        o.spFileUrl == spFileUrl &&
        o.createdAt == createdAt &&
        o.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    badgeId.hashCode ^
    firstName.hashCode ^
    lastName.hashCode ^
    email.hashCode ^
    lisenceNumber.hashCode ^
    licenseExpiry.hashCode ^
    permitExpiry.hashCode ^
    abstractExpiry.hashCode ^
    pictureUrl.hashCode ^
    homePhone.hashCode ^
    address.hashCode ^
    status.hashCode ^
    licenseClass.hashCode ^
    taxiHost.hashCode ^
    startDate.hashCode ^
    endDate.hashCode ^
    licenseUrl.hashCode ^
    permitUrl.hashCode ^
    taxiHostUrl.hashCode ^
    abstractUrl.hashCode ^
    spFileUrl.hashCode ^
    createdAt.hashCode ^
    updatedAt.hashCode;
  }
}
