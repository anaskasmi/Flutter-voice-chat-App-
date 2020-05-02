import 'dart:convert';

class VoiceMessage implements Comparable {
  int id;
  int durationInSec;
  String ownerId;
  String ownerFullName;
  String url;
  int createdAt;
  String pictureUrl;
  VoiceMessage({
    this.id,
    this.durationInSec,
    this.ownerId,
    this.ownerFullName,
    this.url,
    this.createdAt,
    this.pictureUrl,
  }) {
    id ??= 0;
    durationInSec ??= 100;
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
      id: id ?? this.id,
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
      'id': id,
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
      id: map['id'],
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
    return 'VoiceMessage(id: $id, durationInSec: $durationInSec, ownerId: $ownerId, ownerFullName: $ownerFullName, url: $url, createdAt: $createdAt, pictureUrl: $pictureUrl)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is VoiceMessage &&
        o.id == id &&
        o.durationInSec == durationInSec &&
        o.ownerId == ownerId &&
        o.ownerFullName == ownerFullName &&
        o.url == url &&
        o.createdAt == createdAt &&
        o.pictureUrl == pictureUrl;
  }

  @override
  int compareTo(other) {
    if (this.id == null || other == null) {
      return null;
    }

    if (this.id < other.id) {
      return 1;
    }

    if (this.id > other.id) {
      return -1;
    }

    if (this.id == other.id) {
      return 0;
    }

    return null;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        durationInSec.hashCode ^
        ownerId.hashCode ^
        ownerFullName.hashCode ^
        url.hashCode ^
        createdAt.hashCode ^
        pictureUrl.hashCode;
  }
}
