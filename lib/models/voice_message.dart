import 'dart:convert';

class VoiceMessage {
  int durationInSec;
  String ownerId;
  String ownerFullName;
  String url;
  int createdAt;
  String pictureUrl;
  VoiceMessage({
    this.durationInSec,
    this.ownerId,
    this.ownerFullName,
    this.url,
    this.createdAt,
    this.pictureUrl,
  }) {
    durationInSec ??= 0;
    ownerId ??= "";
    ownerFullName ??= "";
    url ??= "";
    createdAt ??= DateTime.now().millisecondsSinceEpoch;
    pictureUrl ??= "";
  }

  VoiceMessage copyWith({
    int id,
    int durationInSec,
    String ownerId,
    String ownerFullName,
    String url,
    int createdAt,
    String pictureUrl,
  }) {
    return VoiceMessage(
      durationInSec: durationInSec ?? this.durationInSec,
      ownerId: ownerId ?? this.ownerId,
      ownerFullName: ownerFullName ?? this.ownerFullName,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
      pictureUrl: pictureUrl ?? this.pictureUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'durationInSec': durationInSec,
      'ownerId': ownerId,
      'ownerFullName': ownerFullName,
      'url': url,
      'createdAt': createdAt,
      'pictureUrl': pictureUrl,
    };
  }

  static VoiceMessage fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return VoiceMessage(
      durationInSec: map['durationInSec'],
      ownerId: map['ownerId'],
      ownerFullName: map['ownerFullName'],
      url: map['url'],
      createdAt: map['createdAt'],
      pictureUrl: map['pictureUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  static VoiceMessage fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'VoiceMessage(durationInSec: $durationInSec, ownerId: $ownerId, ownerFullName: $ownerFullName, url: $url, createdAt: $createdAt, pictureUrl: $pictureUrl)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is VoiceMessage &&
        o.durationInSec == durationInSec &&
        o.ownerId == ownerId &&
        o.ownerFullName == ownerFullName &&
        o.url == url &&
        o.createdAt == createdAt &&
        o.pictureUrl == pictureUrl;
  }

  @override
  int get hashCode {
    return durationInSec.hashCode ^
        ownerId.hashCode ^
        ownerFullName.hashCode ^
        url.hashCode ^
        createdAt.hashCode ^
        pictureUrl.hashCode;
  }
}
