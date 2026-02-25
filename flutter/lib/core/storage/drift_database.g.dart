// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $TripsTable extends Trips with TableInfo<$TripsTable, TripRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverTripIdMeta =
      const VerificationMeta('serverTripId');
  @override
  late final GeneratedColumn<String> serverTripId = GeneratedColumn<String>(
      'server_trip_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>('tags', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($TripsTable.$convertertags);
  static const VerificationMeta _visibilityMeta =
      const VerificationMeta('visibility');
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
      'visibility', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('private'));
  @override
  late final GeneratedColumnWithTypeConverter<AppLatLng?, String> centerPoint =
      GeneratedColumn<String>('center_point', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<AppLatLng?>($TripsTable.$convertercenterPointn);
  static const VerificationMeta _zoomMeta = const VerificationMeta('zoom');
  @override
  late final GeneratedColumn<double> zoom = GeneratedColumn<double>(
      'zoom', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(12.0));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _serverUpdatedAtMeta =
      const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>('server_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverTripId,
        userId,
        name,
        description,
        startDate,
        endDate,
        tags,
        visibility,
        centerPoint,
        zoom,
        localUpdatedAt,
        serverUpdatedAt,
        syncStatus,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(Insertable<TripRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_trip_id')) {
      context.handle(
          _serverTripIdMeta,
          serverTripId.isAcceptableOrUnknown(
              data['server_trip_id']!, _serverTripIdMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('visibility')) {
      context.handle(
          _visibilityMeta,
          visibility.isAcceptableOrUnknown(
              data['visibility']!, _visibilityMeta));
    }
    if (data.containsKey('zoom')) {
      context.handle(
          _zoomMeta, zoom.isAcceptableOrUnknown(data['zoom']!, _zoomMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
          _serverUpdatedAtMeta,
          serverUpdatedAt.isAcceptableOrUnknown(
              data['server_updated_at']!, _serverUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_serverUpdatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverTripId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_trip_id']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date']),
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      tags: $TripsTable.$convertertags.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!),
      visibility: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}visibility'])!,
      centerPoint: $TripsTable.$convertercenterPointn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}center_point'])),
      zoom: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}zoom'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}server_updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
  static TypeConverter<AppLatLng, String> $convertercenterPoint =
      const LatLngConverter();
  static TypeConverter<AppLatLng?, String?> $convertercenterPointn =
      NullAwareTypeConverter.wrap($convertercenterPoint);
}

class TripRow extends DataClass implements Insertable<TripRow> {
  final String id;
  final String? serverTripId;
  final String userId;
  final String name;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> tags;
  final String visibility;
  final AppLatLng? centerPoint;
  final double zoom;
  final DateTime localUpdatedAt;
  final DateTime serverUpdatedAt;
  final String syncStatus;
  final DateTime createdAt;
  const TripRow(
      {required this.id,
      this.serverTripId,
      required this.userId,
      required this.name,
      this.description,
      this.startDate,
      this.endDate,
      required this.tags,
      required this.visibility,
      this.centerPoint,
      required this.zoom,
      required this.localUpdatedAt,
      required this.serverUpdatedAt,
      required this.syncStatus,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverTripId != null) {
      map['server_trip_id'] = Variable<String>(serverTripId);
    }
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    {
      map['tags'] = Variable<String>($TripsTable.$convertertags.toSql(tags));
    }
    map['visibility'] = Variable<String>(visibility);
    if (!nullToAbsent || centerPoint != null) {
      map['center_point'] = Variable<String>(
          $TripsTable.$convertercenterPointn.toSql(centerPoint));
    }
    map['zoom'] = Variable<double>(zoom);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      serverTripId: serverTripId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverTripId),
      userId: Value(userId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      tags: Value(tags),
      visibility: Value(visibility),
      centerPoint: centerPoint == null && nullToAbsent
          ? const Value.absent()
          : Value(centerPoint),
      zoom: Value(zoom),
      localUpdatedAt: Value(localUpdatedAt),
      serverUpdatedAt: Value(serverUpdatedAt),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory TripRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripRow(
      id: serializer.fromJson<String>(json['id']),
      serverTripId: serializer.fromJson<String?>(json['serverTripId']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      visibility: serializer.fromJson<String>(json['visibility']),
      centerPoint: serializer.fromJson<AppLatLng?>(json['centerPoint']),
      zoom: serializer.fromJson<double>(json['zoom']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime>(json['serverUpdatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverTripId': serializer.toJson<String?>(serverTripId),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'tags': serializer.toJson<List<String>>(tags),
      'visibility': serializer.toJson<String>(visibility),
      'centerPoint': serializer.toJson<AppLatLng?>(centerPoint),
      'zoom': serializer.toJson<double>(zoom),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'serverUpdatedAt': serializer.toJson<DateTime>(serverUpdatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TripRow copyWith(
          {String? id,
          Value<String?> serverTripId = const Value.absent(),
          String? userId,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<DateTime?> startDate = const Value.absent(),
          Value<DateTime?> endDate = const Value.absent(),
          List<String>? tags,
          String? visibility,
          Value<AppLatLng?> centerPoint = const Value.absent(),
          double? zoom,
          DateTime? localUpdatedAt,
          DateTime? serverUpdatedAt,
          String? syncStatus,
          DateTime? createdAt}) =>
      TripRow(
        id: id ?? this.id,
        serverTripId:
            serverTripId.present ? serverTripId.value : this.serverTripId,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        startDate: startDate.present ? startDate.value : this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        tags: tags ?? this.tags,
        visibility: visibility ?? this.visibility,
        centerPoint: centerPoint.present ? centerPoint.value : this.centerPoint,
        zoom: zoom ?? this.zoom,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
      );
  TripRow copyWithCompanion(TripsCompanion data) {
    return TripRow(
      id: data.id.present ? data.id.value : this.id,
      serverTripId: data.serverTripId.present
          ? data.serverTripId.value
          : this.serverTripId,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      tags: data.tags.present ? data.tags.value : this.tags,
      visibility:
          data.visibility.present ? data.visibility.value : this.visibility,
      centerPoint:
          data.centerPoint.present ? data.centerPoint.value : this.centerPoint,
      zoom: data.zoom.present ? data.zoom.value : this.zoom,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripRow(')
          ..write('id: $id, ')
          ..write('serverTripId: $serverTripId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('tags: $tags, ')
          ..write('visibility: $visibility, ')
          ..write('centerPoint: $centerPoint, ')
          ..write('zoom: $zoom, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverTripId,
      userId,
      name,
      description,
      startDate,
      endDate,
      tags,
      visibility,
      centerPoint,
      zoom,
      localUpdatedAt,
      serverUpdatedAt,
      syncStatus,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripRow &&
          other.id == this.id &&
          other.serverTripId == this.serverTripId &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.description == this.description &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.tags == this.tags &&
          other.visibility == this.visibility &&
          other.centerPoint == this.centerPoint &&
          other.zoom == this.zoom &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class TripsCompanion extends UpdateCompanion<TripRow> {
  final Value<String> id;
  final Value<String?> serverTripId;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<List<String>> tags;
  final Value<String> visibility;
  final Value<AppLatLng?> centerPoint;
  final Value<double> zoom;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime> serverUpdatedAt;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.serverTripId = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.tags = const Value.absent(),
    this.visibility = const Value.absent(),
    this.centerPoint = const Value.absent(),
    this.zoom = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCompanion.insert({
    required String id,
    this.serverTripId = const Value.absent(),
    required String userId,
    required String name,
    this.description = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.tags = const Value.absent(),
    this.visibility = const Value.absent(),
    this.centerPoint = const Value.absent(),
    this.zoom = const Value.absent(),
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    required String syncStatus,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        name = Value(name),
        localUpdatedAt = Value(localUpdatedAt),
        serverUpdatedAt = Value(serverUpdatedAt),
        syncStatus = Value(syncStatus),
        createdAt = Value(createdAt);
  static Insertable<TripRow> custom({
    Expression<String>? id,
    Expression<String>? serverTripId,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? tags,
    Expression<String>? visibility,
    Expression<String>? centerPoint,
    Expression<double>? zoom,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverTripId != null) 'server_trip_id': serverTripId,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (tags != null) 'tags': tags,
      if (visibility != null) 'visibility': visibility,
      if (centerPoint != null) 'center_point': centerPoint,
      if (zoom != null) 'zoom': zoom,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? serverTripId,
      Value<String>? userId,
      Value<String>? name,
      Value<String?>? description,
      Value<DateTime?>? startDate,
      Value<DateTime?>? endDate,
      Value<List<String>>? tags,
      Value<String>? visibility,
      Value<AppLatLng?>? centerPoint,
      Value<double>? zoom,
      Value<DateTime>? localUpdatedAt,
      Value<DateTime>? serverUpdatedAt,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return TripsCompanion(
      id: id ?? this.id,
      serverTripId: serverTripId ?? this.serverTripId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      tags: tags ?? this.tags,
      visibility: visibility ?? this.visibility,
      centerPoint: centerPoint ?? this.centerPoint,
      zoom: zoom ?? this.zoom,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverTripId.present) {
      map['server_trip_id'] = Variable<String>(serverTripId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (tags.present) {
      map['tags'] =
          Variable<String>($TripsTable.$convertertags.toSql(tags.value));
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (centerPoint.present) {
      map['center_point'] = Variable<String>(
          $TripsTable.$convertercenterPointn.toSql(centerPoint.value));
    }
    if (zoom.present) {
      map['zoom'] = Variable<double>(zoom.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('serverTripId: $serverTripId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('tags: $tags, ')
          ..write('visibility: $visibility, ')
          ..write('centerPoint: $centerPoint, ')
          ..write('zoom: $zoom, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlacesTable extends Places with TableInfo<$PlacesTable, PlaceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverPlaceIdMeta =
      const VerificationMeta('serverPlaceId');
  @override
  late final GeneratedColumn<String> serverPlaceId = GeneratedColumn<String>(
      'server_place_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
      'trip_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<AppLatLng, String> coordinates =
      GeneratedColumn<String>('coordinates', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<AppLatLng>($PlacesTable.$convertercoordinates);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _visitTimeMeta =
      const VerificationMeta('visitTime');
  @override
  late final GeneratedColumn<String> visitTime = GeneratedColumn<String>(
      'visit_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dayNumberMeta =
      const VerificationMeta('dayNumber');
  @override
  late final GeneratedColumn<int> dayNumber = GeneratedColumn<int>(
      'day_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> photoUrls =
      GeneratedColumn<String>('photo_urls', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($PlacesTable.$converterphotoUrls);
  static const VerificationMeta _placeTypeMeta =
      const VerificationMeta('placeType');
  @override
  late final GeneratedColumn<String> placeType = GeneratedColumn<String>(
      'place_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
      'rating', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _serverUpdatedAtMeta =
      const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>('server_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverPlaceId,
        tripId,
        name,
        address,
        coordinates,
        notes,
        visitTime,
        dayNumber,
        orderIndex,
        photoUrls,
        placeType,
        rating,
        localUpdatedAt,
        serverUpdatedAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'places';
  @override
  VerificationContext validateIntegrity(Insertable<PlaceRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_place_id')) {
      context.handle(
          _serverPlaceIdMeta,
          serverPlaceId.isAcceptableOrUnknown(
              data['server_place_id']!, _serverPlaceIdMeta));
    }
    if (data.containsKey('trip_id')) {
      context.handle(_tripIdMeta,
          tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta));
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('visit_time')) {
      context.handle(_visitTimeMeta,
          visitTime.isAcceptableOrUnknown(data['visit_time']!, _visitTimeMeta));
    }
    if (data.containsKey('day_number')) {
      context.handle(_dayNumberMeta,
          dayNumber.isAcceptableOrUnknown(data['day_number']!, _dayNumberMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('place_type')) {
      context.handle(_placeTypeMeta,
          placeType.isAcceptableOrUnknown(data['place_type']!, _placeTypeMeta));
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
          _serverUpdatedAtMeta,
          serverUpdatedAt.isAcceptableOrUnknown(
              data['server_updated_at']!, _serverUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_serverUpdatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaceRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverPlaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_place_id']),
      tripId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trip_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      coordinates: $PlacesTable.$convertercoordinates.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}coordinates'])!),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      visitTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}visit_time']),
      dayNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_number']),
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      photoUrls: $PlacesTable.$converterphotoUrls.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_urls'])!),
      placeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}place_type']),
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rating']),
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}server_updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $PlacesTable createAlias(String alias) {
    return $PlacesTable(attachedDatabase, alias);
  }

  static TypeConverter<AppLatLng, String> $convertercoordinates =
      const LatLngConverter();
  static TypeConverter<List<String>, String> $converterphotoUrls =
      const StringListConverter();
}

class PlaceRow extends DataClass implements Insertable<PlaceRow> {
  final String id;
  final String? serverPlaceId;
  final String tripId;
  final String name;
  final String? address;
  final AppLatLng coordinates;
  final String? notes;
  final String? visitTime;
  final int? dayNumber;
  final int orderIndex;
  final List<String> photoUrls;
  final String? placeType;
  final int? rating;
  final DateTime localUpdatedAt;
  final DateTime serverUpdatedAt;
  final String syncStatus;
  const PlaceRow(
      {required this.id,
      this.serverPlaceId,
      required this.tripId,
      required this.name,
      this.address,
      required this.coordinates,
      this.notes,
      this.visitTime,
      this.dayNumber,
      required this.orderIndex,
      required this.photoUrls,
      this.placeType,
      this.rating,
      required this.localUpdatedAt,
      required this.serverUpdatedAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverPlaceId != null) {
      map['server_place_id'] = Variable<String>(serverPlaceId);
    }
    map['trip_id'] = Variable<String>(tripId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    {
      map['coordinates'] = Variable<String>(
          $PlacesTable.$convertercoordinates.toSql(coordinates));
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || visitTime != null) {
      map['visit_time'] = Variable<String>(visitTime);
    }
    if (!nullToAbsent || dayNumber != null) {
      map['day_number'] = Variable<int>(dayNumber);
    }
    map['order_index'] = Variable<int>(orderIndex);
    {
      map['photo_urls'] =
          Variable<String>($PlacesTable.$converterphotoUrls.toSql(photoUrls));
    }
    if (!nullToAbsent || placeType != null) {
      map['place_type'] = Variable<String>(placeType);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  PlacesCompanion toCompanion(bool nullToAbsent) {
    return PlacesCompanion(
      id: Value(id),
      serverPlaceId: serverPlaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverPlaceId),
      tripId: Value(tripId),
      name: Value(name),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      coordinates: Value(coordinates),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      visitTime: visitTime == null && nullToAbsent
          ? const Value.absent()
          : Value(visitTime),
      dayNumber: dayNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(dayNumber),
      orderIndex: Value(orderIndex),
      photoUrls: Value(photoUrls),
      placeType: placeType == null && nullToAbsent
          ? const Value.absent()
          : Value(placeType),
      rating:
          rating == null && nullToAbsent ? const Value.absent() : Value(rating),
      localUpdatedAt: Value(localUpdatedAt),
      serverUpdatedAt: Value(serverUpdatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory PlaceRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaceRow(
      id: serializer.fromJson<String>(json['id']),
      serverPlaceId: serializer.fromJson<String?>(json['serverPlaceId']),
      tripId: serializer.fromJson<String>(json['tripId']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String?>(json['address']),
      coordinates: serializer.fromJson<AppLatLng>(json['coordinates']),
      notes: serializer.fromJson<String?>(json['notes']),
      visitTime: serializer.fromJson<String?>(json['visitTime']),
      dayNumber: serializer.fromJson<int?>(json['dayNumber']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      photoUrls: serializer.fromJson<List<String>>(json['photoUrls']),
      placeType: serializer.fromJson<String?>(json['placeType']),
      rating: serializer.fromJson<int?>(json['rating']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime>(json['serverUpdatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverPlaceId': serializer.toJson<String?>(serverPlaceId),
      'tripId': serializer.toJson<String>(tripId),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String?>(address),
      'coordinates': serializer.toJson<AppLatLng>(coordinates),
      'notes': serializer.toJson<String?>(notes),
      'visitTime': serializer.toJson<String?>(visitTime),
      'dayNumber': serializer.toJson<int?>(dayNumber),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'photoUrls': serializer.toJson<List<String>>(photoUrls),
      'placeType': serializer.toJson<String?>(placeType),
      'rating': serializer.toJson<int?>(rating),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'serverUpdatedAt': serializer.toJson<DateTime>(serverUpdatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  PlaceRow copyWith(
          {String? id,
          Value<String?> serverPlaceId = const Value.absent(),
          String? tripId,
          String? name,
          Value<String?> address = const Value.absent(),
          AppLatLng? coordinates,
          Value<String?> notes = const Value.absent(),
          Value<String?> visitTime = const Value.absent(),
          Value<int?> dayNumber = const Value.absent(),
          int? orderIndex,
          List<String>? photoUrls,
          Value<String?> placeType = const Value.absent(),
          Value<int?> rating = const Value.absent(),
          DateTime? localUpdatedAt,
          DateTime? serverUpdatedAt,
          String? syncStatus}) =>
      PlaceRow(
        id: id ?? this.id,
        serverPlaceId:
            serverPlaceId.present ? serverPlaceId.value : this.serverPlaceId,
        tripId: tripId ?? this.tripId,
        name: name ?? this.name,
        address: address.present ? address.value : this.address,
        coordinates: coordinates ?? this.coordinates,
        notes: notes.present ? notes.value : this.notes,
        visitTime: visitTime.present ? visitTime.value : this.visitTime,
        dayNumber: dayNumber.present ? dayNumber.value : this.dayNumber,
        orderIndex: orderIndex ?? this.orderIndex,
        photoUrls: photoUrls ?? this.photoUrls,
        placeType: placeType.present ? placeType.value : this.placeType,
        rating: rating.present ? rating.value : this.rating,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  PlaceRow copyWithCompanion(PlacesCompanion data) {
    return PlaceRow(
      id: data.id.present ? data.id.value : this.id,
      serverPlaceId: data.serverPlaceId.present
          ? data.serverPlaceId.value
          : this.serverPlaceId,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      coordinates:
          data.coordinates.present ? data.coordinates.value : this.coordinates,
      notes: data.notes.present ? data.notes.value : this.notes,
      visitTime: data.visitTime.present ? data.visitTime.value : this.visitTime,
      dayNumber: data.dayNumber.present ? data.dayNumber.value : this.dayNumber,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      photoUrls: data.photoUrls.present ? data.photoUrls.value : this.photoUrls,
      placeType: data.placeType.present ? data.placeType.value : this.placeType,
      rating: data.rating.present ? data.rating.value : this.rating,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaceRow(')
          ..write('id: $id, ')
          ..write('serverPlaceId: $serverPlaceId, ')
          ..write('tripId: $tripId, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('coordinates: $coordinates, ')
          ..write('notes: $notes, ')
          ..write('visitTime: $visitTime, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('photoUrls: $photoUrls, ')
          ..write('placeType: $placeType, ')
          ..write('rating: $rating, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverPlaceId,
      tripId,
      name,
      address,
      coordinates,
      notes,
      visitTime,
      dayNumber,
      orderIndex,
      photoUrls,
      placeType,
      rating,
      localUpdatedAt,
      serverUpdatedAt,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaceRow &&
          other.id == this.id &&
          other.serverPlaceId == this.serverPlaceId &&
          other.tripId == this.tripId &&
          other.name == this.name &&
          other.address == this.address &&
          other.coordinates == this.coordinates &&
          other.notes == this.notes &&
          other.visitTime == this.visitTime &&
          other.dayNumber == this.dayNumber &&
          other.orderIndex == this.orderIndex &&
          other.photoUrls == this.photoUrls &&
          other.placeType == this.placeType &&
          other.rating == this.rating &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.syncStatus == this.syncStatus);
}

class PlacesCompanion extends UpdateCompanion<PlaceRow> {
  final Value<String> id;
  final Value<String?> serverPlaceId;
  final Value<String> tripId;
  final Value<String> name;
  final Value<String?> address;
  final Value<AppLatLng> coordinates;
  final Value<String?> notes;
  final Value<String?> visitTime;
  final Value<int?> dayNumber;
  final Value<int> orderIndex;
  final Value<List<String>> photoUrls;
  final Value<String?> placeType;
  final Value<int?> rating;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime> serverUpdatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const PlacesCompanion({
    this.id = const Value.absent(),
    this.serverPlaceId = const Value.absent(),
    this.tripId = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.coordinates = const Value.absent(),
    this.notes = const Value.absent(),
    this.visitTime = const Value.absent(),
    this.dayNumber = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.photoUrls = const Value.absent(),
    this.placeType = const Value.absent(),
    this.rating = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlacesCompanion.insert({
    required String id,
    this.serverPlaceId = const Value.absent(),
    required String tripId,
    required String name,
    this.address = const Value.absent(),
    required AppLatLng coordinates,
    this.notes = const Value.absent(),
    this.visitTime = const Value.absent(),
    this.dayNumber = const Value.absent(),
    required int orderIndex,
    this.photoUrls = const Value.absent(),
    this.placeType = const Value.absent(),
    this.rating = const Value.absent(),
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    required String syncStatus,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tripId = Value(tripId),
        name = Value(name),
        coordinates = Value(coordinates),
        orderIndex = Value(orderIndex),
        localUpdatedAt = Value(localUpdatedAt),
        serverUpdatedAt = Value(serverUpdatedAt),
        syncStatus = Value(syncStatus);
  static Insertable<PlaceRow> custom({
    Expression<String>? id,
    Expression<String>? serverPlaceId,
    Expression<String>? tripId,
    Expression<String>? name,
    Expression<String>? address,
    Expression<String>? coordinates,
    Expression<String>? notes,
    Expression<String>? visitTime,
    Expression<int>? dayNumber,
    Expression<int>? orderIndex,
    Expression<String>? photoUrls,
    Expression<String>? placeType,
    Expression<int>? rating,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverPlaceId != null) 'server_place_id': serverPlaceId,
      if (tripId != null) 'trip_id': tripId,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (coordinates != null) 'coordinates': coordinates,
      if (notes != null) 'notes': notes,
      if (visitTime != null) 'visit_time': visitTime,
      if (dayNumber != null) 'day_number': dayNumber,
      if (orderIndex != null) 'order_index': orderIndex,
      if (photoUrls != null) 'photo_urls': photoUrls,
      if (placeType != null) 'place_type': placeType,
      if (rating != null) 'rating': rating,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlacesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? serverPlaceId,
      Value<String>? tripId,
      Value<String>? name,
      Value<String?>? address,
      Value<AppLatLng>? coordinates,
      Value<String?>? notes,
      Value<String?>? visitTime,
      Value<int?>? dayNumber,
      Value<int>? orderIndex,
      Value<List<String>>? photoUrls,
      Value<String?>? placeType,
      Value<int?>? rating,
      Value<DateTime>? localUpdatedAt,
      Value<DateTime>? serverUpdatedAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return PlacesCompanion(
      id: id ?? this.id,
      serverPlaceId: serverPlaceId ?? this.serverPlaceId,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      address: address ?? this.address,
      coordinates: coordinates ?? this.coordinates,
      notes: notes ?? this.notes,
      visitTime: visitTime ?? this.visitTime,
      dayNumber: dayNumber ?? this.dayNumber,
      orderIndex: orderIndex ?? this.orderIndex,
      photoUrls: photoUrls ?? this.photoUrls,
      placeType: placeType ?? this.placeType,
      rating: rating ?? this.rating,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverPlaceId.present) {
      map['server_place_id'] = Variable<String>(serverPlaceId.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (coordinates.present) {
      map['coordinates'] = Variable<String>(
          $PlacesTable.$convertercoordinates.toSql(coordinates.value));
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (visitTime.present) {
      map['visit_time'] = Variable<String>(visitTime.value);
    }
    if (dayNumber.present) {
      map['day_number'] = Variable<int>(dayNumber.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (photoUrls.present) {
      map['photo_urls'] = Variable<String>(
          $PlacesTable.$converterphotoUrls.toSql(photoUrls.value));
    }
    if (placeType.present) {
      map['place_type'] = Variable<String>(placeType.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlacesCompanion(')
          ..write('id: $id, ')
          ..write('serverPlaceId: $serverPlaceId, ')
          ..write('tripId: $tripId, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('coordinates: $coordinates, ')
          ..write('notes: $notes, ')
          ..write('visitTime: $visitTime, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('photoUrls: $photoUrls, ')
          ..write('placeType: $placeType, ')
          ..write('rating: $rating, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutesTable extends Routes with TableInfo<$RoutesTable, RouteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
      'trip_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<List<AppLatLng>, String>
      coordinates = GeneratedColumn<String>('coordinates', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<AppLatLng>>($RoutesTable.$convertercoordinates);
  static const VerificationMeta _transportModeMeta =
      const VerificationMeta('transportMode');
  @override
  late final GeneratedColumn<String> transportMode = GeneratedColumn<String>(
      'transport_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('car'));
  static const VerificationMeta _distanceMeta =
      const VerificationMeta('distance');
  @override
  late final GeneratedColumn<double> distance = GeneratedColumn<double>(
      'distance', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
      'duration', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dayNumberMeta =
      const VerificationMeta('dayNumber');
  @override
  late final GeneratedColumn<int> dayNumber = GeneratedColumn<int>(
      'day_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _routeCategoryMeta =
      const VerificationMeta('routeCategory');
  @override
  late final GeneratedColumn<String> routeCategory = GeneratedColumn<String>(
      'route_category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('ground'));
  static const VerificationMeta _startPlaceIdMeta =
      const VerificationMeta('startPlaceId');
  @override
  late final GeneratedColumn<String> startPlaceId = GeneratedColumn<String>(
      'start_place_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _endPlaceIdMeta =
      const VerificationMeta('endPlaceId');
  @override
  late final GeneratedColumn<String> endPlaceId = GeneratedColumn<String>(
      'end_place_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _routeGeojsonMeta =
      const VerificationMeta('routeGeojson');
  @override
  late final GeneratedColumn<String> routeGeojson = GeneratedColumn<String>(
      'route_geojson', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<AppLatLng>, String>
      waypointsJson = GeneratedColumn<String>(
              'waypoints_json', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<AppLatLng>>($RoutesTable.$converterwaypointsJson);
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _serverUpdatedAtMeta =
      const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>('server_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tripId,
        coordinates,
        transportMode,
        distance,
        duration,
        dayNumber,
        name,
        description,
        routeCategory,
        startPlaceId,
        endPlaceId,
        orderIndex,
        routeGeojson,
        waypointsJson,
        localUpdatedAt,
        serverUpdatedAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routes';
  @override
  VerificationContext validateIntegrity(Insertable<RouteRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(_tripIdMeta,
          tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta));
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('transport_mode')) {
      context.handle(
          _transportModeMeta,
          transportMode.isAcceptableOrUnknown(
              data['transport_mode']!, _transportModeMeta));
    }
    if (data.containsKey('distance')) {
      context.handle(_distanceMeta,
          distance.isAcceptableOrUnknown(data['distance']!, _distanceMeta));
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    }
    if (data.containsKey('day_number')) {
      context.handle(_dayNumberMeta,
          dayNumber.isAcceptableOrUnknown(data['day_number']!, _dayNumberMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('route_category')) {
      context.handle(
          _routeCategoryMeta,
          routeCategory.isAcceptableOrUnknown(
              data['route_category']!, _routeCategoryMeta));
    }
    if (data.containsKey('start_place_id')) {
      context.handle(
          _startPlaceIdMeta,
          startPlaceId.isAcceptableOrUnknown(
              data['start_place_id']!, _startPlaceIdMeta));
    }
    if (data.containsKey('end_place_id')) {
      context.handle(
          _endPlaceIdMeta,
          endPlaceId.isAcceptableOrUnknown(
              data['end_place_id']!, _endPlaceIdMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    }
    if (data.containsKey('route_geojson')) {
      context.handle(
          _routeGeojsonMeta,
          routeGeojson.isAcceptableOrUnknown(
              data['route_geojson']!, _routeGeojsonMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
          _serverUpdatedAtMeta,
          serverUpdatedAt.isAcceptableOrUnknown(
              data['server_updated_at']!, _serverUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_serverUpdatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RouteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RouteRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tripId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trip_id'])!,
      coordinates: $RoutesTable.$convertercoordinates.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}coordinates'])!),
      transportMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transport_mode'])!,
      distance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}distance']),
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration']),
      dayNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_number']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      routeCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}route_category'])!,
      startPlaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_place_id']),
      endPlaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_place_id']),
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      routeGeojson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}route_geojson']),
      waypointsJson: $RoutesTable.$converterwaypointsJson.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}waypoints_json'])!),
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}server_updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $RoutesTable createAlias(String alias) {
    return $RoutesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<AppLatLng>, String> $convertercoordinates =
      const LatLngListConverter();
  static TypeConverter<List<AppLatLng>, String> $converterwaypointsJson =
      const LatLngListConverter();
}

class RouteRow extends DataClass implements Insertable<RouteRow> {
  final String id;
  final String tripId;
  final List<AppLatLng> coordinates;
  final String transportMode;
  final double? distance;
  final int? duration;
  final int? dayNumber;
  final String? name;
  final String? description;
  final String routeCategory;
  final String? startPlaceId;
  final String? endPlaceId;
  final int orderIndex;
  final String? routeGeojson;
  final List<AppLatLng> waypointsJson;
  final DateTime localUpdatedAt;
  final DateTime serverUpdatedAt;
  final String syncStatus;
  const RouteRow(
      {required this.id,
      required this.tripId,
      required this.coordinates,
      required this.transportMode,
      this.distance,
      this.duration,
      this.dayNumber,
      this.name,
      this.description,
      required this.routeCategory,
      this.startPlaceId,
      this.endPlaceId,
      required this.orderIndex,
      this.routeGeojson,
      required this.waypointsJson,
      required this.localUpdatedAt,
      required this.serverUpdatedAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    {
      map['coordinates'] = Variable<String>(
          $RoutesTable.$convertercoordinates.toSql(coordinates));
    }
    map['transport_mode'] = Variable<String>(transportMode);
    if (!nullToAbsent || distance != null) {
      map['distance'] = Variable<double>(distance);
    }
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<int>(duration);
    }
    if (!nullToAbsent || dayNumber != null) {
      map['day_number'] = Variable<int>(dayNumber);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['route_category'] = Variable<String>(routeCategory);
    if (!nullToAbsent || startPlaceId != null) {
      map['start_place_id'] = Variable<String>(startPlaceId);
    }
    if (!nullToAbsent || endPlaceId != null) {
      map['end_place_id'] = Variable<String>(endPlaceId);
    }
    map['order_index'] = Variable<int>(orderIndex);
    if (!nullToAbsent || routeGeojson != null) {
      map['route_geojson'] = Variable<String>(routeGeojson);
    }
    {
      map['waypoints_json'] = Variable<String>(
          $RoutesTable.$converterwaypointsJson.toSql(waypointsJson));
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  RoutesCompanion toCompanion(bool nullToAbsent) {
    return RoutesCompanion(
      id: Value(id),
      tripId: Value(tripId),
      coordinates: Value(coordinates),
      transportMode: Value(transportMode),
      distance: distance == null && nullToAbsent
          ? const Value.absent()
          : Value(distance),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      dayNumber: dayNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(dayNumber),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      routeCategory: Value(routeCategory),
      startPlaceId: startPlaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(startPlaceId),
      endPlaceId: endPlaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(endPlaceId),
      orderIndex: Value(orderIndex),
      routeGeojson: routeGeojson == null && nullToAbsent
          ? const Value.absent()
          : Value(routeGeojson),
      waypointsJson: Value(waypointsJson),
      localUpdatedAt: Value(localUpdatedAt),
      serverUpdatedAt: Value(serverUpdatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory RouteRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RouteRow(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      coordinates: serializer.fromJson<List<AppLatLng>>(json['coordinates']),
      transportMode: serializer.fromJson<String>(json['transportMode']),
      distance: serializer.fromJson<double?>(json['distance']),
      duration: serializer.fromJson<int?>(json['duration']),
      dayNumber: serializer.fromJson<int?>(json['dayNumber']),
      name: serializer.fromJson<String?>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      routeCategory: serializer.fromJson<String>(json['routeCategory']),
      startPlaceId: serializer.fromJson<String?>(json['startPlaceId']),
      endPlaceId: serializer.fromJson<String?>(json['endPlaceId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      routeGeojson: serializer.fromJson<String?>(json['routeGeojson']),
      waypointsJson:
          serializer.fromJson<List<AppLatLng>>(json['waypointsJson']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime>(json['serverUpdatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'coordinates': serializer.toJson<List<AppLatLng>>(coordinates),
      'transportMode': serializer.toJson<String>(transportMode),
      'distance': serializer.toJson<double?>(distance),
      'duration': serializer.toJson<int?>(duration),
      'dayNumber': serializer.toJson<int?>(dayNumber),
      'name': serializer.toJson<String?>(name),
      'description': serializer.toJson<String?>(description),
      'routeCategory': serializer.toJson<String>(routeCategory),
      'startPlaceId': serializer.toJson<String?>(startPlaceId),
      'endPlaceId': serializer.toJson<String?>(endPlaceId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'routeGeojson': serializer.toJson<String?>(routeGeojson),
      'waypointsJson': serializer.toJson<List<AppLatLng>>(waypointsJson),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'serverUpdatedAt': serializer.toJson<DateTime>(serverUpdatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  RouteRow copyWith(
          {String? id,
          String? tripId,
          List<AppLatLng>? coordinates,
          String? transportMode,
          Value<double?> distance = const Value.absent(),
          Value<int?> duration = const Value.absent(),
          Value<int?> dayNumber = const Value.absent(),
          Value<String?> name = const Value.absent(),
          Value<String?> description = const Value.absent(),
          String? routeCategory,
          Value<String?> startPlaceId = const Value.absent(),
          Value<String?> endPlaceId = const Value.absent(),
          int? orderIndex,
          Value<String?> routeGeojson = const Value.absent(),
          List<AppLatLng>? waypointsJson,
          DateTime? localUpdatedAt,
          DateTime? serverUpdatedAt,
          String? syncStatus}) =>
      RouteRow(
        id: id ?? this.id,
        tripId: tripId ?? this.tripId,
        coordinates: coordinates ?? this.coordinates,
        transportMode: transportMode ?? this.transportMode,
        distance: distance.present ? distance.value : this.distance,
        duration: duration.present ? duration.value : this.duration,
        dayNumber: dayNumber.present ? dayNumber.value : this.dayNumber,
        name: name.present ? name.value : this.name,
        description: description.present ? description.value : this.description,
        routeCategory: routeCategory ?? this.routeCategory,
        startPlaceId:
            startPlaceId.present ? startPlaceId.value : this.startPlaceId,
        endPlaceId: endPlaceId.present ? endPlaceId.value : this.endPlaceId,
        orderIndex: orderIndex ?? this.orderIndex,
        routeGeojson:
            routeGeojson.present ? routeGeojson.value : this.routeGeojson,
        waypointsJson: waypointsJson ?? this.waypointsJson,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  RouteRow copyWithCompanion(RoutesCompanion data) {
    return RouteRow(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      coordinates:
          data.coordinates.present ? data.coordinates.value : this.coordinates,
      transportMode: data.transportMode.present
          ? data.transportMode.value
          : this.transportMode,
      distance: data.distance.present ? data.distance.value : this.distance,
      duration: data.duration.present ? data.duration.value : this.duration,
      dayNumber: data.dayNumber.present ? data.dayNumber.value : this.dayNumber,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      routeCategory: data.routeCategory.present
          ? data.routeCategory.value
          : this.routeCategory,
      startPlaceId: data.startPlaceId.present
          ? data.startPlaceId.value
          : this.startPlaceId,
      endPlaceId:
          data.endPlaceId.present ? data.endPlaceId.value : this.endPlaceId,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      routeGeojson: data.routeGeojson.present
          ? data.routeGeojson.value
          : this.routeGeojson,
      waypointsJson: data.waypointsJson.present
          ? data.waypointsJson.value
          : this.waypointsJson,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RouteRow(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('coordinates: $coordinates, ')
          ..write('transportMode: $transportMode, ')
          ..write('distance: $distance, ')
          ..write('duration: $duration, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('routeCategory: $routeCategory, ')
          ..write('startPlaceId: $startPlaceId, ')
          ..write('endPlaceId: $endPlaceId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('routeGeojson: $routeGeojson, ')
          ..write('waypointsJson: $waypointsJson, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tripId,
      coordinates,
      transportMode,
      distance,
      duration,
      dayNumber,
      name,
      description,
      routeCategory,
      startPlaceId,
      endPlaceId,
      orderIndex,
      routeGeojson,
      waypointsJson,
      localUpdatedAt,
      serverUpdatedAt,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouteRow &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.coordinates == this.coordinates &&
          other.transportMode == this.transportMode &&
          other.distance == this.distance &&
          other.duration == this.duration &&
          other.dayNumber == this.dayNumber &&
          other.name == this.name &&
          other.description == this.description &&
          other.routeCategory == this.routeCategory &&
          other.startPlaceId == this.startPlaceId &&
          other.endPlaceId == this.endPlaceId &&
          other.orderIndex == this.orderIndex &&
          other.routeGeojson == this.routeGeojson &&
          other.waypointsJson == this.waypointsJson &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.syncStatus == this.syncStatus);
}

class RoutesCompanion extends UpdateCompanion<RouteRow> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<List<AppLatLng>> coordinates;
  final Value<String> transportMode;
  final Value<double?> distance;
  final Value<int?> duration;
  final Value<int?> dayNumber;
  final Value<String?> name;
  final Value<String?> description;
  final Value<String> routeCategory;
  final Value<String?> startPlaceId;
  final Value<String?> endPlaceId;
  final Value<int> orderIndex;
  final Value<String?> routeGeojson;
  final Value<List<AppLatLng>> waypointsJson;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime> serverUpdatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const RoutesCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.coordinates = const Value.absent(),
    this.transportMode = const Value.absent(),
    this.distance = const Value.absent(),
    this.duration = const Value.absent(),
    this.dayNumber = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.routeCategory = const Value.absent(),
    this.startPlaceId = const Value.absent(),
    this.endPlaceId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.routeGeojson = const Value.absent(),
    this.waypointsJson = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutesCompanion.insert({
    required String id,
    required String tripId,
    this.coordinates = const Value.absent(),
    this.transportMode = const Value.absent(),
    this.distance = const Value.absent(),
    this.duration = const Value.absent(),
    this.dayNumber = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.routeCategory = const Value.absent(),
    this.startPlaceId = const Value.absent(),
    this.endPlaceId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.routeGeojson = const Value.absent(),
    this.waypointsJson = const Value.absent(),
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    required String syncStatus,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tripId = Value(tripId),
        localUpdatedAt = Value(localUpdatedAt),
        serverUpdatedAt = Value(serverUpdatedAt),
        syncStatus = Value(syncStatus);
  static Insertable<RouteRow> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? coordinates,
    Expression<String>? transportMode,
    Expression<double>? distance,
    Expression<int>? duration,
    Expression<int>? dayNumber,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? routeCategory,
    Expression<String>? startPlaceId,
    Expression<String>? endPlaceId,
    Expression<int>? orderIndex,
    Expression<String>? routeGeojson,
    Expression<String>? waypointsJson,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (coordinates != null) 'coordinates': coordinates,
      if (transportMode != null) 'transport_mode': transportMode,
      if (distance != null) 'distance': distance,
      if (duration != null) 'duration': duration,
      if (dayNumber != null) 'day_number': dayNumber,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (routeCategory != null) 'route_category': routeCategory,
      if (startPlaceId != null) 'start_place_id': startPlaceId,
      if (endPlaceId != null) 'end_place_id': endPlaceId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (routeGeojson != null) 'route_geojson': routeGeojson,
      if (waypointsJson != null) 'waypoints_json': waypointsJson,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutesCompanion copyWith(
      {Value<String>? id,
      Value<String>? tripId,
      Value<List<AppLatLng>>? coordinates,
      Value<String>? transportMode,
      Value<double?>? distance,
      Value<int?>? duration,
      Value<int?>? dayNumber,
      Value<String?>? name,
      Value<String?>? description,
      Value<String>? routeCategory,
      Value<String?>? startPlaceId,
      Value<String?>? endPlaceId,
      Value<int>? orderIndex,
      Value<String?>? routeGeojson,
      Value<List<AppLatLng>>? waypointsJson,
      Value<DateTime>? localUpdatedAt,
      Value<DateTime>? serverUpdatedAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return RoutesCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      coordinates: coordinates ?? this.coordinates,
      transportMode: transportMode ?? this.transportMode,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      dayNumber: dayNumber ?? this.dayNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      routeCategory: routeCategory ?? this.routeCategory,
      startPlaceId: startPlaceId ?? this.startPlaceId,
      endPlaceId: endPlaceId ?? this.endPlaceId,
      orderIndex: orderIndex ?? this.orderIndex,
      routeGeojson: routeGeojson ?? this.routeGeojson,
      waypointsJson: waypointsJson ?? this.waypointsJson,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (coordinates.present) {
      map['coordinates'] = Variable<String>(
          $RoutesTable.$convertercoordinates.toSql(coordinates.value));
    }
    if (transportMode.present) {
      map['transport_mode'] = Variable<String>(transportMode.value);
    }
    if (distance.present) {
      map['distance'] = Variable<double>(distance.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (dayNumber.present) {
      map['day_number'] = Variable<int>(dayNumber.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (routeCategory.present) {
      map['route_category'] = Variable<String>(routeCategory.value);
    }
    if (startPlaceId.present) {
      map['start_place_id'] = Variable<String>(startPlaceId.value);
    }
    if (endPlaceId.present) {
      map['end_place_id'] = Variable<String>(endPlaceId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (routeGeojson.present) {
      map['route_geojson'] = Variable<String>(routeGeojson.value);
    }
    if (waypointsJson.present) {
      map['waypoints_json'] = Variable<String>(
          $RoutesTable.$converterwaypointsJson.toSql(waypointsJson.value));
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutesCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('coordinates: $coordinates, ')
          ..write('transportMode: $transportMode, ')
          ..write('distance: $distance, ')
          ..write('duration: $duration, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('routeCategory: $routeCategory, ')
          ..write('startPlaceId: $startPlaceId, ')
          ..write('endPlaceId: $endPlaceId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('routeGeojson: $routeGeojson, ')
          ..write('waypointsJson: $waypointsJson, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaTable extends Media with TableInfo<$MediaTable, MediaItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
      'trip_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _placeIdMeta =
      const VerificationMeta('placeId');
  @override
  late final GeneratedColumn<String> placeId = GeneratedColumn<String>(
      'place_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailPathMeta =
      const VerificationMeta('thumbnailPath');
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
      'thumbnail_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mimeTypeMeta =
      const VerificationMeta('mimeType');
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
      'mime_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fileSizeBytesMeta =
      const VerificationMeta('fileSizeBytes');
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
      'file_size_bytes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
      'width', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
      'height', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('photo'));
  static const VerificationMeta _uploadStatusMeta =
      const VerificationMeta('uploadStatus');
  @override
  late final GeneratedColumn<String> uploadStatus = GeneratedColumn<String>(
      'upload_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('queued'));
  static const VerificationMeta _uploadProgressMeta =
      const VerificationMeta('uploadProgress');
  @override
  late final GeneratedColumn<double> uploadProgress = GeneratedColumn<double>(
      'upload_progress', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _uploadedAtMeta =
      const VerificationMeta('uploadedAt');
  @override
  late final GeneratedColumn<DateTime> uploadedAt = GeneratedColumn<DateTime>(
      'uploaded_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nextAttemptAtMeta =
      const VerificationMeta('nextAttemptAt');
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>('next_attempt_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _workerSessionIdMeta =
      const VerificationMeta('workerSessionId');
  @override
  late final GeneratedColumn<String> workerSessionId = GeneratedColumn<String>(
      'worker_session_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _serverUpdatedAtMeta =
      const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>('server_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tripId,
        placeId,
        url,
        localPath,
        thumbnailPath,
        mimeType,
        fileSizeBytes,
        width,
        height,
        type,
        uploadStatus,
        uploadProgress,
        retryCount,
        errorMessage,
        uploadedAt,
        nextAttemptAt,
        workerSessionId,
        localUpdatedAt,
        serverUpdatedAt,
        syncStatus,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media';
  @override
  VerificationContext validateIntegrity(Insertable<MediaItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(_tripIdMeta,
          tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta));
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('place_id')) {
      context.handle(_placeIdMeta,
          placeId.isAcceptableOrUnknown(data['place_id']!, _placeIdMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
          _thumbnailPathMeta,
          thumbnailPath.isAcceptableOrUnknown(
              data['thumbnail_path']!, _thumbnailPathMeta));
    }
    if (data.containsKey('mime_type')) {
      context.handle(_mimeTypeMeta,
          mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta));
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
          _fileSizeBytesMeta,
          fileSizeBytes.isAcceptableOrUnknown(
              data['file_size_bytes']!, _fileSizeBytesMeta));
    }
    if (data.containsKey('width')) {
      context.handle(
          _widthMeta, width.isAcceptableOrUnknown(data['width']!, _widthMeta));
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta,
          height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('upload_status')) {
      context.handle(
          _uploadStatusMeta,
          uploadStatus.isAcceptableOrUnknown(
              data['upload_status']!, _uploadStatusMeta));
    }
    if (data.containsKey('upload_progress')) {
      context.handle(
          _uploadProgressMeta,
          uploadProgress.isAcceptableOrUnknown(
              data['upload_progress']!, _uploadProgressMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('uploaded_at')) {
      context.handle(
          _uploadedAtMeta,
          uploadedAt.isAcceptableOrUnknown(
              data['uploaded_at']!, _uploadedAtMeta));
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
          _nextAttemptAtMeta,
          nextAttemptAt.isAcceptableOrUnknown(
              data['next_attempt_at']!, _nextAttemptAtMeta));
    }
    if (data.containsKey('worker_session_id')) {
      context.handle(
          _workerSessionIdMeta,
          workerSessionId.isAcceptableOrUnknown(
              data['worker_session_id']!, _workerSessionIdMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
          _serverUpdatedAtMeta,
          serverUpdatedAt.isAcceptableOrUnknown(
              data['server_updated_at']!, _serverUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_serverUpdatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tripId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trip_id'])!,
      placeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}place_id']),
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url']),
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path']),
      thumbnailPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_path']),
      mimeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime_type']),
      fileSizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size_bytes']),
      width: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}width']),
      height: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}height']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      uploadStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}upload_status'])!,
      uploadProgress: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}upload_progress'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      uploadedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}uploaded_at']),
      nextAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_attempt_at']),
      workerSessionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}worker_session_id']),
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}server_updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MediaTable createAlias(String alias) {
    return $MediaTable(attachedDatabase, alias);
  }
}

class MediaItem extends DataClass implements Insertable<MediaItem> {
  final String id;
  final String tripId;
  final String? placeId;
  final String? url;
  final String? localPath;
  final String? thumbnailPath;
  final String? mimeType;
  final int? fileSizeBytes;
  final int? width;
  final int? height;
  final String type;
  final String uploadStatus;
  final double uploadProgress;
  final int retryCount;
  final String? errorMessage;
  final DateTime? uploadedAt;
  final DateTime? nextAttemptAt;
  final String? workerSessionId;
  final DateTime localUpdatedAt;
  final DateTime serverUpdatedAt;
  final String syncStatus;
  final DateTime createdAt;
  const MediaItem(
      {required this.id,
      required this.tripId,
      this.placeId,
      this.url,
      this.localPath,
      this.thumbnailPath,
      this.mimeType,
      this.fileSizeBytes,
      this.width,
      this.height,
      required this.type,
      required this.uploadStatus,
      required this.uploadProgress,
      required this.retryCount,
      this.errorMessage,
      this.uploadedAt,
      this.nextAttemptAt,
      this.workerSessionId,
      required this.localUpdatedAt,
      required this.serverUpdatedAt,
      required this.syncStatus,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    if (!nullToAbsent || placeId != null) {
      map['place_id'] = Variable<String>(placeId);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || fileSizeBytes != null) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['type'] = Variable<String>(type);
    map['upload_status'] = Variable<String>(uploadStatus);
    map['upload_progress'] = Variable<double>(uploadProgress);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || uploadedAt != null) {
      map['uploaded_at'] = Variable<DateTime>(uploadedAt);
    }
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || workerSessionId != null) {
      map['worker_session_id'] = Variable<String>(workerSessionId);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MediaCompanion toCompanion(bool nullToAbsent) {
    return MediaCompanion(
      id: Value(id),
      tripId: Value(tripId),
      placeId: placeId == null && nullToAbsent
          ? const Value.absent()
          : Value(placeId),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      fileSizeBytes: fileSizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSizeBytes),
      width:
          width == null && nullToAbsent ? const Value.absent() : Value(width),
      height:
          height == null && nullToAbsent ? const Value.absent() : Value(height),
      type: Value(type),
      uploadStatus: Value(uploadStatus),
      uploadProgress: Value(uploadProgress),
      retryCount: Value(retryCount),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      uploadedAt: uploadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(uploadedAt),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      workerSessionId: workerSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(workerSessionId),
      localUpdatedAt: Value(localUpdatedAt),
      serverUpdatedAt: Value(serverUpdatedAt),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory MediaItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaItem(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      placeId: serializer.fromJson<String?>(json['placeId']),
      url: serializer.fromJson<String?>(json['url']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      fileSizeBytes: serializer.fromJson<int?>(json['fileSizeBytes']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      type: serializer.fromJson<String>(json['type']),
      uploadStatus: serializer.fromJson<String>(json['uploadStatus']),
      uploadProgress: serializer.fromJson<double>(json['uploadProgress']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      uploadedAt: serializer.fromJson<DateTime?>(json['uploadedAt']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      workerSessionId: serializer.fromJson<String?>(json['workerSessionId']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime>(json['serverUpdatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'placeId': serializer.toJson<String?>(placeId),
      'url': serializer.toJson<String?>(url),
      'localPath': serializer.toJson<String?>(localPath),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'mimeType': serializer.toJson<String?>(mimeType),
      'fileSizeBytes': serializer.toJson<int?>(fileSizeBytes),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'type': serializer.toJson<String>(type),
      'uploadStatus': serializer.toJson<String>(uploadStatus),
      'uploadProgress': serializer.toJson<double>(uploadProgress),
      'retryCount': serializer.toJson<int>(retryCount),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'uploadedAt': serializer.toJson<DateTime?>(uploadedAt),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'workerSessionId': serializer.toJson<String?>(workerSessionId),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'serverUpdatedAt': serializer.toJson<DateTime>(serverUpdatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MediaItem copyWith(
          {String? id,
          String? tripId,
          Value<String?> placeId = const Value.absent(),
          Value<String?> url = const Value.absent(),
          Value<String?> localPath = const Value.absent(),
          Value<String?> thumbnailPath = const Value.absent(),
          Value<String?> mimeType = const Value.absent(),
          Value<int?> fileSizeBytes = const Value.absent(),
          Value<int?> width = const Value.absent(),
          Value<int?> height = const Value.absent(),
          String? type,
          String? uploadStatus,
          double? uploadProgress,
          int? retryCount,
          Value<String?> errorMessage = const Value.absent(),
          Value<DateTime?> uploadedAt = const Value.absent(),
          Value<DateTime?> nextAttemptAt = const Value.absent(),
          Value<String?> workerSessionId = const Value.absent(),
          DateTime? localUpdatedAt,
          DateTime? serverUpdatedAt,
          String? syncStatus,
          DateTime? createdAt}) =>
      MediaItem(
        id: id ?? this.id,
        tripId: tripId ?? this.tripId,
        placeId: placeId.present ? placeId.value : this.placeId,
        url: url.present ? url.value : this.url,
        localPath: localPath.present ? localPath.value : this.localPath,
        thumbnailPath:
            thumbnailPath.present ? thumbnailPath.value : this.thumbnailPath,
        mimeType: mimeType.present ? mimeType.value : this.mimeType,
        fileSizeBytes:
            fileSizeBytes.present ? fileSizeBytes.value : this.fileSizeBytes,
        width: width.present ? width.value : this.width,
        height: height.present ? height.value : this.height,
        type: type ?? this.type,
        uploadStatus: uploadStatus ?? this.uploadStatus,
        uploadProgress: uploadProgress ?? this.uploadProgress,
        retryCount: retryCount ?? this.retryCount,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        uploadedAt: uploadedAt.present ? uploadedAt.value : this.uploadedAt,
        nextAttemptAt:
            nextAttemptAt.present ? nextAttemptAt.value : this.nextAttemptAt,
        workerSessionId: workerSessionId.present
            ? workerSessionId.value
            : this.workerSessionId,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
      );
  MediaItem copyWithCompanion(MediaCompanion data) {
    return MediaItem(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      placeId: data.placeId.present ? data.placeId.value : this.placeId,
      url: data.url.present ? data.url.value : this.url,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      type: data.type.present ? data.type.value : this.type,
      uploadStatus: data.uploadStatus.present
          ? data.uploadStatus.value
          : this.uploadStatus,
      uploadProgress: data.uploadProgress.present
          ? data.uploadProgress.value
          : this.uploadProgress,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      uploadedAt:
          data.uploadedAt.present ? data.uploadedAt.value : this.uploadedAt,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      workerSessionId: data.workerSessionId.present
          ? data.workerSessionId.value
          : this.workerSessionId,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaItem(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('placeId: $placeId, ')
          ..write('url: $url, ')
          ..write('localPath: $localPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('type: $type, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('uploadProgress: $uploadProgress, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('uploadedAt: $uploadedAt, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('workerSessionId: $workerSessionId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        tripId,
        placeId,
        url,
        localPath,
        thumbnailPath,
        mimeType,
        fileSizeBytes,
        width,
        height,
        type,
        uploadStatus,
        uploadProgress,
        retryCount,
        errorMessage,
        uploadedAt,
        nextAttemptAt,
        workerSessionId,
        localUpdatedAt,
        serverUpdatedAt,
        syncStatus,
        createdAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaItem &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.placeId == this.placeId &&
          other.url == this.url &&
          other.localPath == this.localPath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.mimeType == this.mimeType &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.width == this.width &&
          other.height == this.height &&
          other.type == this.type &&
          other.uploadStatus == this.uploadStatus &&
          other.uploadProgress == this.uploadProgress &&
          other.retryCount == this.retryCount &&
          other.errorMessage == this.errorMessage &&
          other.uploadedAt == this.uploadedAt &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.workerSessionId == this.workerSessionId &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class MediaCompanion extends UpdateCompanion<MediaItem> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String?> placeId;
  final Value<String?> url;
  final Value<String?> localPath;
  final Value<String?> thumbnailPath;
  final Value<String?> mimeType;
  final Value<int?> fileSizeBytes;
  final Value<int?> width;
  final Value<int?> height;
  final Value<String> type;
  final Value<String> uploadStatus;
  final Value<double> uploadProgress;
  final Value<int> retryCount;
  final Value<String?> errorMessage;
  final Value<DateTime?> uploadedAt;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> workerSessionId;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime> serverUpdatedAt;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MediaCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.placeId = const Value.absent(),
    this.url = const Value.absent(),
    this.localPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.type = const Value.absent(),
    this.uploadStatus = const Value.absent(),
    this.uploadProgress = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.uploadedAt = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.workerSessionId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaCompanion.insert({
    required String id,
    required String tripId,
    this.placeId = const Value.absent(),
    this.url = const Value.absent(),
    this.localPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.type = const Value.absent(),
    this.uploadStatus = const Value.absent(),
    this.uploadProgress = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.uploadedAt = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.workerSessionId = const Value.absent(),
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    required String syncStatus,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tripId = Value(tripId),
        localUpdatedAt = Value(localUpdatedAt),
        serverUpdatedAt = Value(serverUpdatedAt),
        syncStatus = Value(syncStatus),
        createdAt = Value(createdAt);
  static Insertable<MediaItem> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? placeId,
    Expression<String>? url,
    Expression<String>? localPath,
    Expression<String>? thumbnailPath,
    Expression<String>? mimeType,
    Expression<int>? fileSizeBytes,
    Expression<int>? width,
    Expression<int>? height,
    Expression<String>? type,
    Expression<String>? uploadStatus,
    Expression<double>? uploadProgress,
    Expression<int>? retryCount,
    Expression<String>? errorMessage,
    Expression<DateTime>? uploadedAt,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? workerSessionId,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (placeId != null) 'place_id': placeId,
      if (url != null) 'url': url,
      if (localPath != null) 'local_path': localPath,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (mimeType != null) 'mime_type': mimeType,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (type != null) 'type': type,
      if (uploadStatus != null) 'upload_status': uploadStatus,
      if (uploadProgress != null) 'upload_progress': uploadProgress,
      if (retryCount != null) 'retry_count': retryCount,
      if (errorMessage != null) 'error_message': errorMessage,
      if (uploadedAt != null) 'uploaded_at': uploadedAt,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (workerSessionId != null) 'worker_session_id': workerSessionId,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaCompanion copyWith(
      {Value<String>? id,
      Value<String>? tripId,
      Value<String?>? placeId,
      Value<String?>? url,
      Value<String?>? localPath,
      Value<String?>? thumbnailPath,
      Value<String?>? mimeType,
      Value<int?>? fileSizeBytes,
      Value<int?>? width,
      Value<int?>? height,
      Value<String>? type,
      Value<String>? uploadStatus,
      Value<double>? uploadProgress,
      Value<int>? retryCount,
      Value<String?>? errorMessage,
      Value<DateTime?>? uploadedAt,
      Value<DateTime?>? nextAttemptAt,
      Value<String?>? workerSessionId,
      Value<DateTime>? localUpdatedAt,
      Value<DateTime>? serverUpdatedAt,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return MediaCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      placeId: placeId ?? this.placeId,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      mimeType: mimeType ?? this.mimeType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      width: width ?? this.width,
      height: height ?? this.height,
      type: type ?? this.type,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      workerSessionId: workerSessionId ?? this.workerSessionId,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (placeId.present) {
      map['place_id'] = Variable<String>(placeId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (uploadStatus.present) {
      map['upload_status'] = Variable<String>(uploadStatus.value);
    }
    if (uploadProgress.present) {
      map['upload_progress'] = Variable<double>(uploadProgress.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (uploadedAt.present) {
      map['uploaded_at'] = Variable<DateTime>(uploadedAt.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (workerSessionId.present) {
      map['worker_session_id'] = Variable<String>(workerSessionId.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('placeId: $placeId, ')
          ..write('url: $url, ')
          ..write('localPath: $localPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('type: $type, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('uploadProgress: $uploadProgress, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('uploadedAt: $uploadedAt, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('workerSessionId: $workerSessionId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PublicTripsTable extends PublicTrips
    with TableInfo<$PublicTripsTable, PublicTripRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PublicTripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverPhotoUrlMeta =
      const VerificationMeta('coverPhotoUrl');
  @override
  late final GeneratedColumn<String> coverPhotoUrl = GeneratedColumn<String>(
      'cover_photo_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _placeCountMeta =
      const VerificationMeta('placeCount');
  @override
  late final GeneratedColumn<int> placeCount = GeneratedColumn<int>(
      'place_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
      'duration', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>('tags', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<String>>($PublicTripsTable.$convertertags);
  static const VerificationMeta _visibilityMeta =
      const VerificationMeta('visibility');
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
      'visibility', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('public'));
  static const VerificationMeta _viewCountMeta =
      const VerificationMeta('viewCount');
  @override
  late final GeneratedColumn<int> viewCount = GeneratedColumn<int>(
      'view_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _serverUpdatedAtMeta =
      const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>('server_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        coverPhotoUrl,
        userId,
        username,
        placeCount,
        duration,
        tags,
        visibility,
        viewCount,
        localUpdatedAt,
        serverUpdatedAt,
        syncStatus,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'public_trips';
  @override
  VerificationContext validateIntegrity(Insertable<PublicTripRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('cover_photo_url')) {
      context.handle(
          _coverPhotoUrlMeta,
          coverPhotoUrl.isAcceptableOrUnknown(
              data['cover_photo_url']!, _coverPhotoUrlMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('place_count')) {
      context.handle(
          _placeCountMeta,
          placeCount.isAcceptableOrUnknown(
              data['place_count']!, _placeCountMeta));
    } else if (isInserting) {
      context.missing(_placeCountMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    }
    if (data.containsKey('visibility')) {
      context.handle(
          _visibilityMeta,
          visibility.isAcceptableOrUnknown(
              data['visibility']!, _visibilityMeta));
    }
    if (data.containsKey('view_count')) {
      context.handle(_viewCountMeta,
          viewCount.isAcceptableOrUnknown(data['view_count']!, _viewCountMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
          _serverUpdatedAtMeta,
          serverUpdatedAt.isAcceptableOrUnknown(
              data['server_updated_at']!, _serverUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_serverUpdatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PublicTripRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PublicTripRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      coverPhotoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_photo_url']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      placeCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}place_count'])!,
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration']),
      tags: $PublicTripsTable.$convertertags.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!),
      visibility: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}visibility'])!,
      viewCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}view_count'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}server_updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PublicTripsTable createAlias(String alias) {
    return $PublicTripsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertags =
      const TagsConverter();
}

class PublicTripRow extends DataClass implements Insertable<PublicTripRow> {
  final String id;
  final String name;
  final String? description;
  final String? coverPhotoUrl;
  final String userId;
  final String username;
  final int placeCount;
  final int? duration;
  final List<String> tags;
  final String visibility;
  final int viewCount;
  final DateTime localUpdatedAt;
  final DateTime serverUpdatedAt;
  final String syncStatus;
  final DateTime createdAt;
  const PublicTripRow(
      {required this.id,
      required this.name,
      this.description,
      this.coverPhotoUrl,
      required this.userId,
      required this.username,
      required this.placeCount,
      this.duration,
      required this.tags,
      required this.visibility,
      required this.viewCount,
      required this.localUpdatedAt,
      required this.serverUpdatedAt,
      required this.syncStatus,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || coverPhotoUrl != null) {
      map['cover_photo_url'] = Variable<String>(coverPhotoUrl);
    }
    map['user_id'] = Variable<String>(userId);
    map['username'] = Variable<String>(username);
    map['place_count'] = Variable<int>(placeCount);
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<int>(duration);
    }
    {
      map['tags'] =
          Variable<String>($PublicTripsTable.$convertertags.toSql(tags));
    }
    map['visibility'] = Variable<String>(visibility);
    map['view_count'] = Variable<int>(viewCount);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PublicTripsCompanion toCompanion(bool nullToAbsent) {
    return PublicTripsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      coverPhotoUrl: coverPhotoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPhotoUrl),
      userId: Value(userId),
      username: Value(username),
      placeCount: Value(placeCount),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      tags: Value(tags),
      visibility: Value(visibility),
      viewCount: Value(viewCount),
      localUpdatedAt: Value(localUpdatedAt),
      serverUpdatedAt: Value(serverUpdatedAt),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory PublicTripRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PublicTripRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      coverPhotoUrl: serializer.fromJson<String?>(json['coverPhotoUrl']),
      userId: serializer.fromJson<String>(json['userId']),
      username: serializer.fromJson<String>(json['username']),
      placeCount: serializer.fromJson<int>(json['placeCount']),
      duration: serializer.fromJson<int?>(json['duration']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      visibility: serializer.fromJson<String>(json['visibility']),
      viewCount: serializer.fromJson<int>(json['viewCount']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime>(json['serverUpdatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'coverPhotoUrl': serializer.toJson<String?>(coverPhotoUrl),
      'userId': serializer.toJson<String>(userId),
      'username': serializer.toJson<String>(username),
      'placeCount': serializer.toJson<int>(placeCount),
      'duration': serializer.toJson<int?>(duration),
      'tags': serializer.toJson<List<String>>(tags),
      'visibility': serializer.toJson<String>(visibility),
      'viewCount': serializer.toJson<int>(viewCount),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'serverUpdatedAt': serializer.toJson<DateTime>(serverUpdatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PublicTripRow copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<String?> coverPhotoUrl = const Value.absent(),
          String? userId,
          String? username,
          int? placeCount,
          Value<int?> duration = const Value.absent(),
          List<String>? tags,
          String? visibility,
          int? viewCount,
          DateTime? localUpdatedAt,
          DateTime? serverUpdatedAt,
          String? syncStatus,
          DateTime? createdAt}) =>
      PublicTripRow(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        coverPhotoUrl:
            coverPhotoUrl.present ? coverPhotoUrl.value : this.coverPhotoUrl,
        userId: userId ?? this.userId,
        username: username ?? this.username,
        placeCount: placeCount ?? this.placeCount,
        duration: duration.present ? duration.value : this.duration,
        tags: tags ?? this.tags,
        visibility: visibility ?? this.visibility,
        viewCount: viewCount ?? this.viewCount,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
      );
  PublicTripRow copyWithCompanion(PublicTripsCompanion data) {
    return PublicTripRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      coverPhotoUrl: data.coverPhotoUrl.present
          ? data.coverPhotoUrl.value
          : this.coverPhotoUrl,
      userId: data.userId.present ? data.userId.value : this.userId,
      username: data.username.present ? data.username.value : this.username,
      placeCount:
          data.placeCount.present ? data.placeCount.value : this.placeCount,
      duration: data.duration.present ? data.duration.value : this.duration,
      tags: data.tags.present ? data.tags.value : this.tags,
      visibility:
          data.visibility.present ? data.visibility.value : this.visibility,
      viewCount: data.viewCount.present ? data.viewCount.value : this.viewCount,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PublicTripRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('coverPhotoUrl: $coverPhotoUrl, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('placeCount: $placeCount, ')
          ..write('duration: $duration, ')
          ..write('tags: $tags, ')
          ..write('visibility: $visibility, ')
          ..write('viewCount: $viewCount, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      description,
      coverPhotoUrl,
      userId,
      username,
      placeCount,
      duration,
      tags,
      visibility,
      viewCount,
      localUpdatedAt,
      serverUpdatedAt,
      syncStatus,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PublicTripRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.coverPhotoUrl == this.coverPhotoUrl &&
          other.userId == this.userId &&
          other.username == this.username &&
          other.placeCount == this.placeCount &&
          other.duration == this.duration &&
          other.tags == this.tags &&
          other.visibility == this.visibility &&
          other.viewCount == this.viewCount &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class PublicTripsCompanion extends UpdateCompanion<PublicTripRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> coverPhotoUrl;
  final Value<String> userId;
  final Value<String> username;
  final Value<int> placeCount;
  final Value<int?> duration;
  final Value<List<String>> tags;
  final Value<String> visibility;
  final Value<int> viewCount;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime> serverUpdatedAt;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PublicTripsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.coverPhotoUrl = const Value.absent(),
    this.userId = const Value.absent(),
    this.username = const Value.absent(),
    this.placeCount = const Value.absent(),
    this.duration = const Value.absent(),
    this.tags = const Value.absent(),
    this.visibility = const Value.absent(),
    this.viewCount = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PublicTripsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.coverPhotoUrl = const Value.absent(),
    required String userId,
    required String username,
    required int placeCount,
    this.duration = const Value.absent(),
    required List<String> tags,
    this.visibility = const Value.absent(),
    this.viewCount = const Value.absent(),
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    required String syncStatus,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        userId = Value(userId),
        username = Value(username),
        placeCount = Value(placeCount),
        tags = Value(tags),
        localUpdatedAt = Value(localUpdatedAt),
        serverUpdatedAt = Value(serverUpdatedAt),
        syncStatus = Value(syncStatus),
        createdAt = Value(createdAt);
  static Insertable<PublicTripRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? coverPhotoUrl,
    Expression<String>? userId,
    Expression<String>? username,
    Expression<int>? placeCount,
    Expression<int>? duration,
    Expression<String>? tags,
    Expression<String>? visibility,
    Expression<int>? viewCount,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (coverPhotoUrl != null) 'cover_photo_url': coverPhotoUrl,
      if (userId != null) 'user_id': userId,
      if (username != null) 'username': username,
      if (placeCount != null) 'place_count': placeCount,
      if (duration != null) 'duration': duration,
      if (tags != null) 'tags': tags,
      if (visibility != null) 'visibility': visibility,
      if (viewCount != null) 'view_count': viewCount,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PublicTripsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String?>? coverPhotoUrl,
      Value<String>? userId,
      Value<String>? username,
      Value<int>? placeCount,
      Value<int?>? duration,
      Value<List<String>>? tags,
      Value<String>? visibility,
      Value<int>? viewCount,
      Value<DateTime>? localUpdatedAt,
      Value<DateTime>? serverUpdatedAt,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PublicTripsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      placeCount: placeCount ?? this.placeCount,
      duration: duration ?? this.duration,
      tags: tags ?? this.tags,
      visibility: visibility ?? this.visibility,
      viewCount: viewCount ?? this.viewCount,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (coverPhotoUrl.present) {
      map['cover_photo_url'] = Variable<String>(coverPhotoUrl.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (placeCount.present) {
      map['place_count'] = Variable<int>(placeCount.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (tags.present) {
      map['tags'] =
          Variable<String>($PublicTripsTable.$convertertags.toSql(tags.value));
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (viewCount.present) {
      map['view_count'] = Variable<int>(viewCount.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PublicTripsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('coverPhotoUrl: $coverPhotoUrl, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('placeCount: $placeCount, ')
          ..write('duration: $duration, ')
          ..write('tags: $tags, ')
          ..write('visibility: $visibility, ')
          ..write('viewCount: $viewCount, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserTripsTable extends UserTrips
    with TableInfo<$UserTripsTable, UserTripRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserTripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverPhotoUrlMeta =
      const VerificationMeta('coverPhotoUrl');
  @override
  late final GeneratedColumn<String> coverPhotoUrl = GeneratedColumn<String>(
      'cover_photo_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _visibilityMeta =
      const VerificationMeta('visibility');
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
      'visibility', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('private'));
  static const VerificationMeta _placeCountMeta =
      const VerificationMeta('placeCount');
  @override
  late final GeneratedColumn<int> placeCount = GeneratedColumn<int>(
      'place_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('editing'));
  static const VerificationMeta _lastEditedAtMeta =
      const VerificationMeta('lastEditedAt');
  @override
  late final GeneratedColumn<DateTime> lastEditedAt = GeneratedColumn<DateTime>(
      'last_edited_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _serverUpdatedAtMeta =
      const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>('server_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        name,
        description,
        coverPhotoUrl,
        startDate,
        endDate,
        visibility,
        placeCount,
        status,
        lastEditedAt,
        localUpdatedAt,
        serverUpdatedAt,
        syncStatus,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_trips';
  @override
  VerificationContext validateIntegrity(Insertable<UserTripRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('cover_photo_url')) {
      context.handle(
          _coverPhotoUrlMeta,
          coverPhotoUrl.isAcceptableOrUnknown(
              data['cover_photo_url']!, _coverPhotoUrlMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('visibility')) {
      context.handle(
          _visibilityMeta,
          visibility.isAcceptableOrUnknown(
              data['visibility']!, _visibilityMeta));
    }
    if (data.containsKey('place_count')) {
      context.handle(
          _placeCountMeta,
          placeCount.isAcceptableOrUnknown(
              data['place_count']!, _placeCountMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('last_edited_at')) {
      context.handle(
          _lastEditedAtMeta,
          lastEditedAt.isAcceptableOrUnknown(
              data['last_edited_at']!, _lastEditedAtMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
          _serverUpdatedAtMeta,
          serverUpdatedAt.isAcceptableOrUnknown(
              data['server_updated_at']!, _serverUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_serverUpdatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserTripRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserTripRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      coverPhotoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_photo_url']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date']),
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      visibility: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}visibility'])!,
      placeCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}place_count'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      lastEditedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_edited_at']),
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}server_updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UserTripsTable createAlias(String alias) {
    return $UserTripsTable(attachedDatabase, alias);
  }
}

class UserTripRow extends DataClass implements Insertable<UserTripRow> {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? coverPhotoUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final String visibility;
  final int placeCount;
  final String status;
  final DateTime? lastEditedAt;
  final DateTime localUpdatedAt;
  final DateTime serverUpdatedAt;
  final String syncStatus;
  final DateTime createdAt;
  const UserTripRow(
      {required this.id,
      required this.userId,
      required this.name,
      this.description,
      this.coverPhotoUrl,
      this.startDate,
      this.endDate,
      required this.visibility,
      required this.placeCount,
      required this.status,
      this.lastEditedAt,
      required this.localUpdatedAt,
      required this.serverUpdatedAt,
      required this.syncStatus,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || coverPhotoUrl != null) {
      map['cover_photo_url'] = Variable<String>(coverPhotoUrl);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['visibility'] = Variable<String>(visibility);
    map['place_count'] = Variable<int>(placeCount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastEditedAt != null) {
      map['last_edited_at'] = Variable<DateTime>(lastEditedAt);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserTripsCompanion toCompanion(bool nullToAbsent) {
    return UserTripsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      coverPhotoUrl: coverPhotoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPhotoUrl),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      visibility: Value(visibility),
      placeCount: Value(placeCount),
      status: Value(status),
      lastEditedAt: lastEditedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastEditedAt),
      localUpdatedAt: Value(localUpdatedAt),
      serverUpdatedAt: Value(serverUpdatedAt),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory UserTripRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserTripRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      coverPhotoUrl: serializer.fromJson<String?>(json['coverPhotoUrl']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      visibility: serializer.fromJson<String>(json['visibility']),
      placeCount: serializer.fromJson<int>(json['placeCount']),
      status: serializer.fromJson<String>(json['status']),
      lastEditedAt: serializer.fromJson<DateTime?>(json['lastEditedAt']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime>(json['serverUpdatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'coverPhotoUrl': serializer.toJson<String?>(coverPhotoUrl),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'visibility': serializer.toJson<String>(visibility),
      'placeCount': serializer.toJson<int>(placeCount),
      'status': serializer.toJson<String>(status),
      'lastEditedAt': serializer.toJson<DateTime?>(lastEditedAt),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'serverUpdatedAt': serializer.toJson<DateTime>(serverUpdatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserTripRow copyWith(
          {String? id,
          String? userId,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<String?> coverPhotoUrl = const Value.absent(),
          Value<DateTime?> startDate = const Value.absent(),
          Value<DateTime?> endDate = const Value.absent(),
          String? visibility,
          int? placeCount,
          String? status,
          Value<DateTime?> lastEditedAt = const Value.absent(),
          DateTime? localUpdatedAt,
          DateTime? serverUpdatedAt,
          String? syncStatus,
          DateTime? createdAt}) =>
      UserTripRow(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        coverPhotoUrl:
            coverPhotoUrl.present ? coverPhotoUrl.value : this.coverPhotoUrl,
        startDate: startDate.present ? startDate.value : this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        visibility: visibility ?? this.visibility,
        placeCount: placeCount ?? this.placeCount,
        status: status ?? this.status,
        lastEditedAt:
            lastEditedAt.present ? lastEditedAt.value : this.lastEditedAt,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
      );
  UserTripRow copyWithCompanion(UserTripsCompanion data) {
    return UserTripRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      coverPhotoUrl: data.coverPhotoUrl.present
          ? data.coverPhotoUrl.value
          : this.coverPhotoUrl,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      visibility:
          data.visibility.present ? data.visibility.value : this.visibility,
      placeCount:
          data.placeCount.present ? data.placeCount.value : this.placeCount,
      status: data.status.present ? data.status.value : this.status,
      lastEditedAt: data.lastEditedAt.present
          ? data.lastEditedAt.value
          : this.lastEditedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserTripRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('coverPhotoUrl: $coverPhotoUrl, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('visibility: $visibility, ')
          ..write('placeCount: $placeCount, ')
          ..write('status: $status, ')
          ..write('lastEditedAt: $lastEditedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      name,
      description,
      coverPhotoUrl,
      startDate,
      endDate,
      visibility,
      placeCount,
      status,
      lastEditedAt,
      localUpdatedAt,
      serverUpdatedAt,
      syncStatus,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserTripRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.description == this.description &&
          other.coverPhotoUrl == this.coverPhotoUrl &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.visibility == this.visibility &&
          other.placeCount == this.placeCount &&
          other.status == this.status &&
          other.lastEditedAt == this.lastEditedAt &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class UserTripsCompanion extends UpdateCompanion<UserTripRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> coverPhotoUrl;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<String> visibility;
  final Value<int> placeCount;
  final Value<String> status;
  final Value<DateTime?> lastEditedAt;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime> serverUpdatedAt;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UserTripsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.coverPhotoUrl = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.visibility = const Value.absent(),
    this.placeCount = const Value.absent(),
    this.status = const Value.absent(),
    this.lastEditedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserTripsCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.description = const Value.absent(),
    this.coverPhotoUrl = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.visibility = const Value.absent(),
    this.placeCount = const Value.absent(),
    this.status = const Value.absent(),
    this.lastEditedAt = const Value.absent(),
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    required String syncStatus,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        name = Value(name),
        localUpdatedAt = Value(localUpdatedAt),
        serverUpdatedAt = Value(serverUpdatedAt),
        syncStatus = Value(syncStatus),
        createdAt = Value(createdAt);
  static Insertable<UserTripRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? coverPhotoUrl,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? visibility,
    Expression<int>? placeCount,
    Expression<String>? status,
    Expression<DateTime>? lastEditedAt,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (coverPhotoUrl != null) 'cover_photo_url': coverPhotoUrl,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (visibility != null) 'visibility': visibility,
      if (placeCount != null) 'place_count': placeCount,
      if (status != null) 'status': status,
      if (lastEditedAt != null) 'last_edited_at': lastEditedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserTripsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? name,
      Value<String?>? description,
      Value<String?>? coverPhotoUrl,
      Value<DateTime?>? startDate,
      Value<DateTime?>? endDate,
      Value<String>? visibility,
      Value<int>? placeCount,
      Value<String>? status,
      Value<DateTime?>? lastEditedAt,
      Value<DateTime>? localUpdatedAt,
      Value<DateTime>? serverUpdatedAt,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return UserTripsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      visibility: visibility ?? this.visibility,
      placeCount: placeCount ?? this.placeCount,
      status: status ?? this.status,
      lastEditedAt: lastEditedAt ?? this.lastEditedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (coverPhotoUrl.present) {
      map['cover_photo_url'] = Variable<String>(coverPhotoUrl.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (placeCount.present) {
      map['place_count'] = Variable<int>(placeCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastEditedAt.present) {
      map['last_edited_at'] = Variable<DateTime>(lastEditedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserTripsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('coverPhotoUrl: $coverPhotoUrl, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('visibility: $visibility, ')
          ..write('placeCount: $placeCount, ')
          ..write('status: $status, ')
          ..write('lastEditedAt: $lastEditedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncTasksTable extends SyncTasks
    with TableInfo<$SyncTasksTable, SyncTaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('queued'));
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nextAttemptAtMeta =
      const VerificationMeta('nextAttemptAt');
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>('next_attempt_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dependsOnEntityTypeMeta =
      const VerificationMeta('dependsOnEntityType');
  @override
  late final GeneratedColumn<String> dependsOnEntityType =
      GeneratedColumn<String>('depends_on_entity_type', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dependsOnEntityIdMeta =
      const VerificationMeta('dependsOnEntityId');
  @override
  late final GeneratedColumn<String> dependsOnEntityId =
      GeneratedColumn<String>('depends_on_entity_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _errorCodeMeta =
      const VerificationMeta('errorCode');
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
      'error_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _workerSessionIdMeta =
      const VerificationMeta('workerSessionId');
  @override
  late final GeneratedColumn<String> workerSessionId = GeneratedColumn<String>(
      'worker_session_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityId,
        operation,
        status,
        retryCount,
        nextAttemptAt,
        dependsOnEntityType,
        dependsOnEntityId,
        errorCode,
        errorMessage,
        workerSessionId,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_tasks';
  @override
  VerificationContext validateIntegrity(Insertable<SyncTaskRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
          _nextAttemptAtMeta,
          nextAttemptAt.isAcceptableOrUnknown(
              data['next_attempt_at']!, _nextAttemptAtMeta));
    }
    if (data.containsKey('depends_on_entity_type')) {
      context.handle(
          _dependsOnEntityTypeMeta,
          dependsOnEntityType.isAcceptableOrUnknown(
              data['depends_on_entity_type']!, _dependsOnEntityTypeMeta));
    }
    if (data.containsKey('depends_on_entity_id')) {
      context.handle(
          _dependsOnEntityIdMeta,
          dependsOnEntityId.isAcceptableOrUnknown(
              data['depends_on_entity_id']!, _dependsOnEntityIdMeta));
    }
    if (data.containsKey('error_code')) {
      context.handle(_errorCodeMeta,
          errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('worker_session_id')) {
      context.handle(
          _workerSessionIdMeta,
          workerSessionId.isAcceptableOrUnknown(
              data['worker_session_id']!, _workerSessionIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {entityType, entityId},
      ];
  @override
  SyncTaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncTaskRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_attempt_at']),
      dependsOnEntityType: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}depends_on_entity_type']),
      dependsOnEntityId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}depends_on_entity_id']),
      errorCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_code']),
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      workerSessionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}worker_session_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SyncTasksTable createAlias(String alias) {
    return $SyncTasksTable(attachedDatabase, alias);
  }
}

class SyncTaskRow extends DataClass implements Insertable<SyncTaskRow> {
  final String id;
  final String entityType;
  final String entityId;
  final String operation;
  final String status;
  final int retryCount;
  final DateTime? nextAttemptAt;
  final String? dependsOnEntityType;
  final String? dependsOnEntityId;
  final String? errorCode;
  final String? errorMessage;
  final String? workerSessionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SyncTaskRow(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.operation,
      required this.status,
      required this.retryCount,
      this.nextAttemptAt,
      this.dependsOnEntityType,
      this.dependsOnEntityId,
      this.errorCode,
      this.errorMessage,
      this.workerSessionId,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || dependsOnEntityType != null) {
      map['depends_on_entity_type'] = Variable<String>(dependsOnEntityType);
    }
    if (!nullToAbsent || dependsOnEntityId != null) {
      map['depends_on_entity_id'] = Variable<String>(dependsOnEntityId);
    }
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || workerSessionId != null) {
      map['worker_session_id'] = Variable<String>(workerSessionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncTasksCompanion toCompanion(bool nullToAbsent) {
    return SyncTasksCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      status: Value(status),
      retryCount: Value(retryCount),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      dependsOnEntityType: dependsOnEntityType == null && nullToAbsent
          ? const Value.absent()
          : Value(dependsOnEntityType),
      dependsOnEntityId: dependsOnEntityId == null && nullToAbsent
          ? const Value.absent()
          : Value(dependsOnEntityId),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      workerSessionId: workerSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(workerSessionId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncTaskRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncTaskRow(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      dependsOnEntityType:
          serializer.fromJson<String?>(json['dependsOnEntityType']),
      dependsOnEntityId:
          serializer.fromJson<String?>(json['dependsOnEntityId']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      workerSessionId: serializer.fromJson<String?>(json['workerSessionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'dependsOnEntityType': serializer.toJson<String?>(dependsOnEntityType),
      'dependsOnEntityId': serializer.toJson<String?>(dependsOnEntityId),
      'errorCode': serializer.toJson<String?>(errorCode),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'workerSessionId': serializer.toJson<String?>(workerSessionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncTaskRow copyWith(
          {String? id,
          String? entityType,
          String? entityId,
          String? operation,
          String? status,
          int? retryCount,
          Value<DateTime?> nextAttemptAt = const Value.absent(),
          Value<String?> dependsOnEntityType = const Value.absent(),
          Value<String?> dependsOnEntityId = const Value.absent(),
          Value<String?> errorCode = const Value.absent(),
          Value<String?> errorMessage = const Value.absent(),
          Value<String?> workerSessionId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      SyncTaskRow(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        operation: operation ?? this.operation,
        status: status ?? this.status,
        retryCount: retryCount ?? this.retryCount,
        nextAttemptAt:
            nextAttemptAt.present ? nextAttemptAt.value : this.nextAttemptAt,
        dependsOnEntityType: dependsOnEntityType.present
            ? dependsOnEntityType.value
            : this.dependsOnEntityType,
        dependsOnEntityId: dependsOnEntityId.present
            ? dependsOnEntityId.value
            : this.dependsOnEntityId,
        errorCode: errorCode.present ? errorCode.value : this.errorCode,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        workerSessionId: workerSessionId.present
            ? workerSessionId.value
            : this.workerSessionId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SyncTaskRow copyWithCompanion(SyncTasksCompanion data) {
    return SyncTaskRow(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      status: data.status.present ? data.status.value : this.status,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      dependsOnEntityType: data.dependsOnEntityType.present
          ? data.dependsOnEntityType.value
          : this.dependsOnEntityType,
      dependsOnEntityId: data.dependsOnEntityId.present
          ? data.dependsOnEntityId.value
          : this.dependsOnEntityId,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      workerSessionId: data.workerSessionId.present
          ? data.workerSessionId.value
          : this.workerSessionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncTaskRow(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('dependsOnEntityType: $dependsOnEntityType, ')
          ..write('dependsOnEntityId: $dependsOnEntityId, ')
          ..write('errorCode: $errorCode, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('workerSessionId: $workerSessionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      entityType,
      entityId,
      operation,
      status,
      retryCount,
      nextAttemptAt,
      dependsOnEntityType,
      dependsOnEntityId,
      errorCode,
      errorMessage,
      workerSessionId,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncTaskRow &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.dependsOnEntityType == this.dependsOnEntityType &&
          other.dependsOnEntityId == this.dependsOnEntityId &&
          other.errorCode == this.errorCode &&
          other.errorMessage == this.errorMessage &&
          other.workerSessionId == this.workerSessionId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SyncTasksCompanion extends UpdateCompanion<SyncTaskRow> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> dependsOnEntityType;
  final Value<String?> dependsOnEntityId;
  final Value<String?> errorCode;
  final Value<String?> errorMessage;
  final Value<String?> workerSessionId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncTasksCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.dependsOnEntityType = const Value.absent(),
    this.dependsOnEntityId = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.workerSessionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncTasksCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String operation,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.dependsOnEntityType = const Value.absent(),
    this.dependsOnEntityId = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.workerSessionId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityType = Value(entityType),
        entityId = Value(entityId),
        operation = Value(operation),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<SyncTaskRow> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? dependsOnEntityType,
    Expression<String>? dependsOnEntityId,
    Expression<String>? errorCode,
    Expression<String>? errorMessage,
    Expression<String>? workerSessionId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (dependsOnEntityType != null)
        'depends_on_entity_type': dependsOnEntityType,
      if (dependsOnEntityId != null) 'depends_on_entity_id': dependsOnEntityId,
      if (errorCode != null) 'error_code': errorCode,
      if (errorMessage != null) 'error_message': errorMessage,
      if (workerSessionId != null) 'worker_session_id': workerSessionId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncTasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? operation,
      Value<String>? status,
      Value<int>? retryCount,
      Value<DateTime?>? nextAttemptAt,
      Value<String?>? dependsOnEntityType,
      Value<String?>? dependsOnEntityId,
      Value<String?>? errorCode,
      Value<String?>? errorMessage,
      Value<String?>? workerSessionId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SyncTasksCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      dependsOnEntityType: dependsOnEntityType ?? this.dependsOnEntityType,
      dependsOnEntityId: dependsOnEntityId ?? this.dependsOnEntityId,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
      workerSessionId: workerSessionId ?? this.workerSessionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (dependsOnEntityType.present) {
      map['depends_on_entity_type'] =
          Variable<String>(dependsOnEntityType.value);
    }
    if (dependsOnEntityId.present) {
      map['depends_on_entity_id'] = Variable<String>(dependsOnEntityId.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (workerSessionId.present) {
      map['worker_session_id'] = Variable<String>(workerSessionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncTasksCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('dependsOnEntityType: $dependsOnEntityType, ')
          ..write('dependsOnEntityId: $dependsOnEntityId, ')
          ..write('errorCode: $errorCode, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('workerSessionId: $workerSessionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $PlacesTable places = $PlacesTable(this);
  late final $RoutesTable routes = $RoutesTable(this);
  late final $MediaTable media = $MediaTable(this);
  late final $PublicTripsTable publicTrips = $PublicTripsTable(this);
  late final $UserTripsTable userTrips = $UserTripsTable(this);
  late final $SyncTasksTable syncTasks = $SyncTasksTable(this);
  late final TripDao tripDao = TripDao(this as AppDatabase);
  late final PlaceDao placeDao = PlaceDao(this as AppDatabase);
  late final RouteDao routeDao = RouteDao(this as AppDatabase);
  late final MediaDao mediaDao = MediaDao(this as AppDatabase);
  late final PublicTripsDao publicTripsDao =
      PublicTripsDao(this as AppDatabase);
  late final UserTripsDao userTripsDao = UserTripsDao(this as AppDatabase);
  late final SyncTaskDao syncTaskDao = SyncTaskDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [trips, places, routes, media, publicTrips, userTrips, syncTasks];
}

typedef $$TripsTableCreateCompanionBuilder = TripsCompanion Function({
  required String id,
  Value<String?> serverTripId,
  required String userId,
  required String name,
  Value<String?> description,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<List<String>> tags,
  Value<String> visibility,
  Value<AppLatLng?> centerPoint,
  Value<double> zoom,
  required DateTime localUpdatedAt,
  required DateTime serverUpdatedAt,
  required String syncStatus,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$TripsTableUpdateCompanionBuilder = TripsCompanion Function({
  Value<String> id,
  Value<String?> serverTripId,
  Value<String> userId,
  Value<String> name,
  Value<String?> description,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<List<String>> tags,
  Value<String> visibility,
  Value<AppLatLng?> centerPoint,
  Value<double> zoom,
  Value<DateTime> localUpdatedAt,
  Value<DateTime> serverUpdatedAt,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverTripId => $composableBuilder(
      column: $table.serverTripId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
          column: $table.tags,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get visibility => $composableBuilder(
      column: $table.visibility, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<AppLatLng?, AppLatLng, String>
      get centerPoint => $composableBuilder(
          column: $table.centerPoint,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get zoom => $composableBuilder(
      column: $table.zoom, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$TripsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverTripId => $composableBuilder(
      column: $table.serverTripId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get visibility => $composableBuilder(
      column: $table.visibility, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get centerPoint => $composableBuilder(
      column: $table.centerPoint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get zoom => $composableBuilder(
      column: $table.zoom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$TripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverTripId => $composableBuilder(
      column: $table.serverTripId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get visibility => $composableBuilder(
      column: $table.visibility, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AppLatLng?, String> get centerPoint =>
      $composableBuilder(
          column: $table.centerPoint, builder: (column) => column);

  GeneratedColumn<double> get zoom =>
      $composableBuilder(column: $table.zoom, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TripsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TripsTable,
    TripRow,
    $$TripsTableFilterComposer,
    $$TripsTableOrderingComposer,
    $$TripsTableAnnotationComposer,
    $$TripsTableCreateCompanionBuilder,
    $$TripsTableUpdateCompanionBuilder,
    (TripRow, BaseReferences<_$AppDatabase, $TripsTable, TripRow>),
    TripRow,
    PrefetchHooks Function()> {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> serverTripId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<String> visibility = const Value.absent(),
            Value<AppLatLng?> centerPoint = const Value.absent(),
            Value<double> zoom = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<DateTime> serverUpdatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TripsCompanion(
            id: id,
            serverTripId: serverTripId,
            userId: userId,
            name: name,
            description: description,
            startDate: startDate,
            endDate: endDate,
            tags: tags,
            visibility: visibility,
            centerPoint: centerPoint,
            zoom: zoom,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> serverTripId = const Value.absent(),
            required String userId,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<String> visibility = const Value.absent(),
            Value<AppLatLng?> centerPoint = const Value.absent(),
            Value<double> zoom = const Value.absent(),
            required DateTime localUpdatedAt,
            required DateTime serverUpdatedAt,
            required String syncStatus,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TripsCompanion.insert(
            id: id,
            serverTripId: serverTripId,
            userId: userId,
            name: name,
            description: description,
            startDate: startDate,
            endDate: endDate,
            tags: tags,
            visibility: visibility,
            centerPoint: centerPoint,
            zoom: zoom,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TripsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TripsTable,
    TripRow,
    $$TripsTableFilterComposer,
    $$TripsTableOrderingComposer,
    $$TripsTableAnnotationComposer,
    $$TripsTableCreateCompanionBuilder,
    $$TripsTableUpdateCompanionBuilder,
    (TripRow, BaseReferences<_$AppDatabase, $TripsTable, TripRow>),
    TripRow,
    PrefetchHooks Function()>;
typedef $$PlacesTableCreateCompanionBuilder = PlacesCompanion Function({
  required String id,
  Value<String?> serverPlaceId,
  required String tripId,
  required String name,
  Value<String?> address,
  required AppLatLng coordinates,
  Value<String?> notes,
  Value<String?> visitTime,
  Value<int?> dayNumber,
  required int orderIndex,
  Value<List<String>> photoUrls,
  Value<String?> placeType,
  Value<int?> rating,
  required DateTime localUpdatedAt,
  required DateTime serverUpdatedAt,
  required String syncStatus,
  Value<int> rowid,
});
typedef $$PlacesTableUpdateCompanionBuilder = PlacesCompanion Function({
  Value<String> id,
  Value<String?> serverPlaceId,
  Value<String> tripId,
  Value<String> name,
  Value<String?> address,
  Value<AppLatLng> coordinates,
  Value<String?> notes,
  Value<String?> visitTime,
  Value<int?> dayNumber,
  Value<int> orderIndex,
  Value<List<String>> photoUrls,
  Value<String?> placeType,
  Value<int?> rating,
  Value<DateTime> localUpdatedAt,
  Value<DateTime> serverUpdatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$PlacesTableFilterComposer
    extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverPlaceId => $composableBuilder(
      column: $table.serverPlaceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tripId => $composableBuilder(
      column: $table.tripId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<AppLatLng, AppLatLng, String>
      get coordinates => $composableBuilder(
          column: $table.coordinates,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get visitTime => $composableBuilder(
      column: $table.visitTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayNumber => $composableBuilder(
      column: $table.dayNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
      get photoUrls => $composableBuilder(
          column: $table.photoUrls,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get placeType => $composableBuilder(
      column: $table.placeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$PlacesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverPlaceId => $composableBuilder(
      column: $table.serverPlaceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tripId => $composableBuilder(
      column: $table.tripId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coordinates => $composableBuilder(
      column: $table.coordinates, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get visitTime => $composableBuilder(
      column: $table.visitTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayNumber => $composableBuilder(
      column: $table.dayNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrls => $composableBuilder(
      column: $table.photoUrls, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get placeType => $composableBuilder(
      column: $table.placeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$PlacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverPlaceId => $composableBuilder(
      column: $table.serverPlaceId, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AppLatLng, String> get coordinates =>
      $composableBuilder(
          column: $table.coordinates, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get visitTime =>
      $composableBuilder(column: $table.visitTime, builder: (column) => column);

  GeneratedColumn<int> get dayNumber =>
      $composableBuilder(column: $table.dayNumber, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get photoUrls =>
      $composableBuilder(column: $table.photoUrls, builder: (column) => column);

  GeneratedColumn<String> get placeType =>
      $composableBuilder(column: $table.placeType, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$PlacesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlacesTable,
    PlaceRow,
    $$PlacesTableFilterComposer,
    $$PlacesTableOrderingComposer,
    $$PlacesTableAnnotationComposer,
    $$PlacesTableCreateCompanionBuilder,
    $$PlacesTableUpdateCompanionBuilder,
    (PlaceRow, BaseReferences<_$AppDatabase, $PlacesTable, PlaceRow>),
    PlaceRow,
    PrefetchHooks Function()> {
  $$PlacesTableTableManager(_$AppDatabase db, $PlacesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> serverPlaceId = const Value.absent(),
            Value<String> tripId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<AppLatLng> coordinates = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> visitTime = const Value.absent(),
            Value<int?> dayNumber = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<List<String>> photoUrls = const Value.absent(),
            Value<String?> placeType = const Value.absent(),
            Value<int?> rating = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<DateTime> serverUpdatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlacesCompanion(
            id: id,
            serverPlaceId: serverPlaceId,
            tripId: tripId,
            name: name,
            address: address,
            coordinates: coordinates,
            notes: notes,
            visitTime: visitTime,
            dayNumber: dayNumber,
            orderIndex: orderIndex,
            photoUrls: photoUrls,
            placeType: placeType,
            rating: rating,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> serverPlaceId = const Value.absent(),
            required String tripId,
            required String name,
            Value<String?> address = const Value.absent(),
            required AppLatLng coordinates,
            Value<String?> notes = const Value.absent(),
            Value<String?> visitTime = const Value.absent(),
            Value<int?> dayNumber = const Value.absent(),
            required int orderIndex,
            Value<List<String>> photoUrls = const Value.absent(),
            Value<String?> placeType = const Value.absent(),
            Value<int?> rating = const Value.absent(),
            required DateTime localUpdatedAt,
            required DateTime serverUpdatedAt,
            required String syncStatus,
            Value<int> rowid = const Value.absent(),
          }) =>
              PlacesCompanion.insert(
            id: id,
            serverPlaceId: serverPlaceId,
            tripId: tripId,
            name: name,
            address: address,
            coordinates: coordinates,
            notes: notes,
            visitTime: visitTime,
            dayNumber: dayNumber,
            orderIndex: orderIndex,
            photoUrls: photoUrls,
            placeType: placeType,
            rating: rating,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlacesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlacesTable,
    PlaceRow,
    $$PlacesTableFilterComposer,
    $$PlacesTableOrderingComposer,
    $$PlacesTableAnnotationComposer,
    $$PlacesTableCreateCompanionBuilder,
    $$PlacesTableUpdateCompanionBuilder,
    (PlaceRow, BaseReferences<_$AppDatabase, $PlacesTable, PlaceRow>),
    PlaceRow,
    PrefetchHooks Function()>;
typedef $$RoutesTableCreateCompanionBuilder = RoutesCompanion Function({
  required String id,
  required String tripId,
  Value<List<AppLatLng>> coordinates,
  Value<String> transportMode,
  Value<double?> distance,
  Value<int?> duration,
  Value<int?> dayNumber,
  Value<String?> name,
  Value<String?> description,
  Value<String> routeCategory,
  Value<String?> startPlaceId,
  Value<String?> endPlaceId,
  Value<int> orderIndex,
  Value<String?> routeGeojson,
  Value<List<AppLatLng>> waypointsJson,
  required DateTime localUpdatedAt,
  required DateTime serverUpdatedAt,
  required String syncStatus,
  Value<int> rowid,
});
typedef $$RoutesTableUpdateCompanionBuilder = RoutesCompanion Function({
  Value<String> id,
  Value<String> tripId,
  Value<List<AppLatLng>> coordinates,
  Value<String> transportMode,
  Value<double?> distance,
  Value<int?> duration,
  Value<int?> dayNumber,
  Value<String?> name,
  Value<String?> description,
  Value<String> routeCategory,
  Value<String?> startPlaceId,
  Value<String?> endPlaceId,
  Value<int> orderIndex,
  Value<String?> routeGeojson,
  Value<List<AppLatLng>> waypointsJson,
  Value<DateTime> localUpdatedAt,
  Value<DateTime> serverUpdatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$RoutesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tripId => $composableBuilder(
      column: $table.tripId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<AppLatLng>, List<AppLatLng>, String>
      get coordinates => $composableBuilder(
          column: $table.coordinates,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get transportMode => $composableBuilder(
      column: $table.transportMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayNumber => $composableBuilder(
      column: $table.dayNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routeCategory => $composableBuilder(
      column: $table.routeCategory, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startPlaceId => $composableBuilder(
      column: $table.startPlaceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endPlaceId => $composableBuilder(
      column: $table.endPlaceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routeGeojson => $composableBuilder(
      column: $table.routeGeojson, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<AppLatLng>, List<AppLatLng>, String>
      get waypointsJson => $composableBuilder(
          column: $table.waypointsJson,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$RoutesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tripId => $composableBuilder(
      column: $table.tripId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coordinates => $composableBuilder(
      column: $table.coordinates, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transportMode => $composableBuilder(
      column: $table.transportMode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayNumber => $composableBuilder(
      column: $table.dayNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routeCategory => $composableBuilder(
      column: $table.routeCategory,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startPlaceId => $composableBuilder(
      column: $table.startPlaceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endPlaceId => $composableBuilder(
      column: $table.endPlaceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routeGeojson => $composableBuilder(
      column: $table.routeGeojson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get waypointsJson => $composableBuilder(
      column: $table.waypointsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$RoutesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<AppLatLng>, String> get coordinates =>
      $composableBuilder(
          column: $table.coordinates, builder: (column) => column);

  GeneratedColumn<String> get transportMode => $composableBuilder(
      column: $table.transportMode, builder: (column) => column);

  GeneratedColumn<double> get distance =>
      $composableBuilder(column: $table.distance, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get dayNumber =>
      $composableBuilder(column: $table.dayNumber, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get routeCategory => $composableBuilder(
      column: $table.routeCategory, builder: (column) => column);

  GeneratedColumn<String> get startPlaceId => $composableBuilder(
      column: $table.startPlaceId, builder: (column) => column);

  GeneratedColumn<String> get endPlaceId => $composableBuilder(
      column: $table.endPlaceId, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<String> get routeGeojson => $composableBuilder(
      column: $table.routeGeojson, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<AppLatLng>, String> get waypointsJson =>
      $composableBuilder(
          column: $table.waypointsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$RoutesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoutesTable,
    RouteRow,
    $$RoutesTableFilterComposer,
    $$RoutesTableOrderingComposer,
    $$RoutesTableAnnotationComposer,
    $$RoutesTableCreateCompanionBuilder,
    $$RoutesTableUpdateCompanionBuilder,
    (RouteRow, BaseReferences<_$AppDatabase, $RoutesTable, RouteRow>),
    RouteRow,
    PrefetchHooks Function()> {
  $$RoutesTableTableManager(_$AppDatabase db, $RoutesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tripId = const Value.absent(),
            Value<List<AppLatLng>> coordinates = const Value.absent(),
            Value<String> transportMode = const Value.absent(),
            Value<double?> distance = const Value.absent(),
            Value<int?> duration = const Value.absent(),
            Value<int?> dayNumber = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> routeCategory = const Value.absent(),
            Value<String?> startPlaceId = const Value.absent(),
            Value<String?> endPlaceId = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<String?> routeGeojson = const Value.absent(),
            Value<List<AppLatLng>> waypointsJson = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<DateTime> serverUpdatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoutesCompanion(
            id: id,
            tripId: tripId,
            coordinates: coordinates,
            transportMode: transportMode,
            distance: distance,
            duration: duration,
            dayNumber: dayNumber,
            name: name,
            description: description,
            routeCategory: routeCategory,
            startPlaceId: startPlaceId,
            endPlaceId: endPlaceId,
            orderIndex: orderIndex,
            routeGeojson: routeGeojson,
            waypointsJson: waypointsJson,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tripId,
            Value<List<AppLatLng>> coordinates = const Value.absent(),
            Value<String> transportMode = const Value.absent(),
            Value<double?> distance = const Value.absent(),
            Value<int?> duration = const Value.absent(),
            Value<int?> dayNumber = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> routeCategory = const Value.absent(),
            Value<String?> startPlaceId = const Value.absent(),
            Value<String?> endPlaceId = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<String?> routeGeojson = const Value.absent(),
            Value<List<AppLatLng>> waypointsJson = const Value.absent(),
            required DateTime localUpdatedAt,
            required DateTime serverUpdatedAt,
            required String syncStatus,
            Value<int> rowid = const Value.absent(),
          }) =>
              RoutesCompanion.insert(
            id: id,
            tripId: tripId,
            coordinates: coordinates,
            transportMode: transportMode,
            distance: distance,
            duration: duration,
            dayNumber: dayNumber,
            name: name,
            description: description,
            routeCategory: routeCategory,
            startPlaceId: startPlaceId,
            endPlaceId: endPlaceId,
            orderIndex: orderIndex,
            routeGeojson: routeGeojson,
            waypointsJson: waypointsJson,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RoutesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RoutesTable,
    RouteRow,
    $$RoutesTableFilterComposer,
    $$RoutesTableOrderingComposer,
    $$RoutesTableAnnotationComposer,
    $$RoutesTableCreateCompanionBuilder,
    $$RoutesTableUpdateCompanionBuilder,
    (RouteRow, BaseReferences<_$AppDatabase, $RoutesTable, RouteRow>),
    RouteRow,
    PrefetchHooks Function()>;
typedef $$MediaTableCreateCompanionBuilder = MediaCompanion Function({
  required String id,
  required String tripId,
  Value<String?> placeId,
  Value<String?> url,
  Value<String?> localPath,
  Value<String?> thumbnailPath,
  Value<String?> mimeType,
  Value<int?> fileSizeBytes,
  Value<int?> width,
  Value<int?> height,
  Value<String> type,
  Value<String> uploadStatus,
  Value<double> uploadProgress,
  Value<int> retryCount,
  Value<String?> errorMessage,
  Value<DateTime?> uploadedAt,
  Value<DateTime?> nextAttemptAt,
  Value<String?> workerSessionId,
  required DateTime localUpdatedAt,
  required DateTime serverUpdatedAt,
  required String syncStatus,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$MediaTableUpdateCompanionBuilder = MediaCompanion Function({
  Value<String> id,
  Value<String> tripId,
  Value<String?> placeId,
  Value<String?> url,
  Value<String?> localPath,
  Value<String?> thumbnailPath,
  Value<String?> mimeType,
  Value<int?> fileSizeBytes,
  Value<int?> width,
  Value<int?> height,
  Value<String> type,
  Value<String> uploadStatus,
  Value<double> uploadProgress,
  Value<int> retryCount,
  Value<String?> errorMessage,
  Value<DateTime?> uploadedAt,
  Value<DateTime?> nextAttemptAt,
  Value<String?> workerSessionId,
  Value<DateTime> localUpdatedAt,
  Value<DateTime> serverUpdatedAt,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$MediaTableFilterComposer extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tripId => $composableBuilder(
      column: $table.tripId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get placeId => $composableBuilder(
      column: $table.placeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get width => $composableBuilder(
      column: $table.width, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uploadStatus => $composableBuilder(
      column: $table.uploadStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get uploadProgress => $composableBuilder(
      column: $table.uploadProgress,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get uploadedAt => $composableBuilder(
      column: $table.uploadedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get workerSessionId => $composableBuilder(
      column: $table.workerSessionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$MediaTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tripId => $composableBuilder(
      column: $table.tripId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get placeId => $composableBuilder(
      column: $table.placeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get width => $composableBuilder(
      column: $table.width, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uploadStatus => $composableBuilder(
      column: $table.uploadStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get uploadProgress => $composableBuilder(
      column: $table.uploadProgress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get uploadedAt => $composableBuilder(
      column: $table.uploadedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get workerSessionId => $composableBuilder(
      column: $table.workerSessionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MediaTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get placeId =>
      $composableBuilder(column: $table.placeId, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get uploadStatus => $composableBuilder(
      column: $table.uploadStatus, builder: (column) => column);

  GeneratedColumn<double> get uploadProgress => $composableBuilder(
      column: $table.uploadProgress, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<DateTime> get uploadedAt => $composableBuilder(
      column: $table.uploadedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => column);

  GeneratedColumn<String> get workerSessionId => $composableBuilder(
      column: $table.workerSessionId, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MediaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MediaTable,
    MediaItem,
    $$MediaTableFilterComposer,
    $$MediaTableOrderingComposer,
    $$MediaTableAnnotationComposer,
    $$MediaTableCreateCompanionBuilder,
    $$MediaTableUpdateCompanionBuilder,
    (MediaItem, BaseReferences<_$AppDatabase, $MediaTable, MediaItem>),
    MediaItem,
    PrefetchHooks Function()> {
  $$MediaTableTableManager(_$AppDatabase db, $MediaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tripId = const Value.absent(),
            Value<String?> placeId = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
            Value<String?> mimeType = const Value.absent(),
            Value<int?> fileSizeBytes = const Value.absent(),
            Value<int?> width = const Value.absent(),
            Value<int?> height = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> uploadStatus = const Value.absent(),
            Value<double> uploadProgress = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<DateTime?> uploadedAt = const Value.absent(),
            Value<DateTime?> nextAttemptAt = const Value.absent(),
            Value<String?> workerSessionId = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<DateTime> serverUpdatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MediaCompanion(
            id: id,
            tripId: tripId,
            placeId: placeId,
            url: url,
            localPath: localPath,
            thumbnailPath: thumbnailPath,
            mimeType: mimeType,
            fileSizeBytes: fileSizeBytes,
            width: width,
            height: height,
            type: type,
            uploadStatus: uploadStatus,
            uploadProgress: uploadProgress,
            retryCount: retryCount,
            errorMessage: errorMessage,
            uploadedAt: uploadedAt,
            nextAttemptAt: nextAttemptAt,
            workerSessionId: workerSessionId,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tripId,
            Value<String?> placeId = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
            Value<String?> mimeType = const Value.absent(),
            Value<int?> fileSizeBytes = const Value.absent(),
            Value<int?> width = const Value.absent(),
            Value<int?> height = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> uploadStatus = const Value.absent(),
            Value<double> uploadProgress = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<DateTime?> uploadedAt = const Value.absent(),
            Value<DateTime?> nextAttemptAt = const Value.absent(),
            Value<String?> workerSessionId = const Value.absent(),
            required DateTime localUpdatedAt,
            required DateTime serverUpdatedAt,
            required String syncStatus,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MediaCompanion.insert(
            id: id,
            tripId: tripId,
            placeId: placeId,
            url: url,
            localPath: localPath,
            thumbnailPath: thumbnailPath,
            mimeType: mimeType,
            fileSizeBytes: fileSizeBytes,
            width: width,
            height: height,
            type: type,
            uploadStatus: uploadStatus,
            uploadProgress: uploadProgress,
            retryCount: retryCount,
            errorMessage: errorMessage,
            uploadedAt: uploadedAt,
            nextAttemptAt: nextAttemptAt,
            workerSessionId: workerSessionId,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MediaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MediaTable,
    MediaItem,
    $$MediaTableFilterComposer,
    $$MediaTableOrderingComposer,
    $$MediaTableAnnotationComposer,
    $$MediaTableCreateCompanionBuilder,
    $$MediaTableUpdateCompanionBuilder,
    (MediaItem, BaseReferences<_$AppDatabase, $MediaTable, MediaItem>),
    MediaItem,
    PrefetchHooks Function()>;
typedef $$PublicTripsTableCreateCompanionBuilder = PublicTripsCompanion
    Function({
  required String id,
  required String name,
  Value<String?> description,
  Value<String?> coverPhotoUrl,
  required String userId,
  required String username,
  required int placeCount,
  Value<int?> duration,
  required List<String> tags,
  Value<String> visibility,
  Value<int> viewCount,
  required DateTime localUpdatedAt,
  required DateTime serverUpdatedAt,
  required String syncStatus,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PublicTripsTableUpdateCompanionBuilder = PublicTripsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String?> coverPhotoUrl,
  Value<String> userId,
  Value<String> username,
  Value<int> placeCount,
  Value<int?> duration,
  Value<List<String>> tags,
  Value<String> visibility,
  Value<int> viewCount,
  Value<DateTime> localUpdatedAt,
  Value<DateTime> serverUpdatedAt,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PublicTripsTableFilterComposer
    extends Composer<_$AppDatabase, $PublicTripsTable> {
  $$PublicTripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverPhotoUrl => $composableBuilder(
      column: $table.coverPhotoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get placeCount => $composableBuilder(
      column: $table.placeCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
          column: $table.tags,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get visibility => $composableBuilder(
      column: $table.visibility, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get viewCount => $composableBuilder(
      column: $table.viewCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PublicTripsTableOrderingComposer
    extends Composer<_$AppDatabase, $PublicTripsTable> {
  $$PublicTripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverPhotoUrl => $composableBuilder(
      column: $table.coverPhotoUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get placeCount => $composableBuilder(
      column: $table.placeCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get visibility => $composableBuilder(
      column: $table.visibility, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get viewCount => $composableBuilder(
      column: $table.viewCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PublicTripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PublicTripsTable> {
  $$PublicTripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get coverPhotoUrl => $composableBuilder(
      column: $table.coverPhotoUrl, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<int> get placeCount => $composableBuilder(
      column: $table.placeCount, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get visibility => $composableBuilder(
      column: $table.visibility, builder: (column) => column);

  GeneratedColumn<int> get viewCount =>
      $composableBuilder(column: $table.viewCount, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PublicTripsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PublicTripsTable,
    PublicTripRow,
    $$PublicTripsTableFilterComposer,
    $$PublicTripsTableOrderingComposer,
    $$PublicTripsTableAnnotationComposer,
    $$PublicTripsTableCreateCompanionBuilder,
    $$PublicTripsTableUpdateCompanionBuilder,
    (
      PublicTripRow,
      BaseReferences<_$AppDatabase, $PublicTripsTable, PublicTripRow>
    ),
    PublicTripRow,
    PrefetchHooks Function()> {
  $$PublicTripsTableTableManager(_$AppDatabase db, $PublicTripsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PublicTripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PublicTripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PublicTripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> coverPhotoUrl = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<int> placeCount = const Value.absent(),
            Value<int?> duration = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<String> visibility = const Value.absent(),
            Value<int> viewCount = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<DateTime> serverUpdatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PublicTripsCompanion(
            id: id,
            name: name,
            description: description,
            coverPhotoUrl: coverPhotoUrl,
            userId: userId,
            username: username,
            placeCount: placeCount,
            duration: duration,
            tags: tags,
            visibility: visibility,
            viewCount: viewCount,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String?> coverPhotoUrl = const Value.absent(),
            required String userId,
            required String username,
            required int placeCount,
            Value<int?> duration = const Value.absent(),
            required List<String> tags,
            Value<String> visibility = const Value.absent(),
            Value<int> viewCount = const Value.absent(),
            required DateTime localUpdatedAt,
            required DateTime serverUpdatedAt,
            required String syncStatus,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PublicTripsCompanion.insert(
            id: id,
            name: name,
            description: description,
            coverPhotoUrl: coverPhotoUrl,
            userId: userId,
            username: username,
            placeCount: placeCount,
            duration: duration,
            tags: tags,
            visibility: visibility,
            viewCount: viewCount,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PublicTripsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PublicTripsTable,
    PublicTripRow,
    $$PublicTripsTableFilterComposer,
    $$PublicTripsTableOrderingComposer,
    $$PublicTripsTableAnnotationComposer,
    $$PublicTripsTableCreateCompanionBuilder,
    $$PublicTripsTableUpdateCompanionBuilder,
    (
      PublicTripRow,
      BaseReferences<_$AppDatabase, $PublicTripsTable, PublicTripRow>
    ),
    PublicTripRow,
    PrefetchHooks Function()>;
typedef $$UserTripsTableCreateCompanionBuilder = UserTripsCompanion Function({
  required String id,
  required String userId,
  required String name,
  Value<String?> description,
  Value<String?> coverPhotoUrl,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<String> visibility,
  Value<int> placeCount,
  Value<String> status,
  Value<DateTime?> lastEditedAt,
  required DateTime localUpdatedAt,
  required DateTime serverUpdatedAt,
  required String syncStatus,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$UserTripsTableUpdateCompanionBuilder = UserTripsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<String?> description,
  Value<String?> coverPhotoUrl,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<String> visibility,
  Value<int> placeCount,
  Value<String> status,
  Value<DateTime?> lastEditedAt,
  Value<DateTime> localUpdatedAt,
  Value<DateTime> serverUpdatedAt,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$UserTripsTableFilterComposer
    extends Composer<_$AppDatabase, $UserTripsTable> {
  $$UserTripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverPhotoUrl => $composableBuilder(
      column: $table.coverPhotoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get visibility => $composableBuilder(
      column: $table.visibility, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get placeCount => $composableBuilder(
      column: $table.placeCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastEditedAt => $composableBuilder(
      column: $table.lastEditedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$UserTripsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserTripsTable> {
  $$UserTripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverPhotoUrl => $composableBuilder(
      column: $table.coverPhotoUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get visibility => $composableBuilder(
      column: $table.visibility, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get placeCount => $composableBuilder(
      column: $table.placeCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastEditedAt => $composableBuilder(
      column: $table.lastEditedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$UserTripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserTripsTable> {
  $$UserTripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get coverPhotoUrl => $composableBuilder(
      column: $table.coverPhotoUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get visibility => $composableBuilder(
      column: $table.visibility, builder: (column) => column);

  GeneratedColumn<int> get placeCount => $composableBuilder(
      column: $table.placeCount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get lastEditedAt => $composableBuilder(
      column: $table.lastEditedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserTripsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserTripsTable,
    UserTripRow,
    $$UserTripsTableFilterComposer,
    $$UserTripsTableOrderingComposer,
    $$UserTripsTableAnnotationComposer,
    $$UserTripsTableCreateCompanionBuilder,
    $$UserTripsTableUpdateCompanionBuilder,
    (UserTripRow, BaseReferences<_$AppDatabase, $UserTripsTable, UserTripRow>),
    UserTripRow,
    PrefetchHooks Function()> {
  $$UserTripsTableTableManager(_$AppDatabase db, $UserTripsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserTripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserTripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserTripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> coverPhotoUrl = const Value.absent(),
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<String> visibility = const Value.absent(),
            Value<int> placeCount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> lastEditedAt = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<DateTime> serverUpdatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserTripsCompanion(
            id: id,
            userId: userId,
            name: name,
            description: description,
            coverPhotoUrl: coverPhotoUrl,
            startDate: startDate,
            endDate: endDate,
            visibility: visibility,
            placeCount: placeCount,
            status: status,
            lastEditedAt: lastEditedAt,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String?> coverPhotoUrl = const Value.absent(),
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<String> visibility = const Value.absent(),
            Value<int> placeCount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> lastEditedAt = const Value.absent(),
            required DateTime localUpdatedAt,
            required DateTime serverUpdatedAt,
            required String syncStatus,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserTripsCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            description: description,
            coverPhotoUrl: coverPhotoUrl,
            startDate: startDate,
            endDate: endDate,
            visibility: visibility,
            placeCount: placeCount,
            status: status,
            lastEditedAt: lastEditedAt,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserTripsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserTripsTable,
    UserTripRow,
    $$UserTripsTableFilterComposer,
    $$UserTripsTableOrderingComposer,
    $$UserTripsTableAnnotationComposer,
    $$UserTripsTableCreateCompanionBuilder,
    $$UserTripsTableUpdateCompanionBuilder,
    (UserTripRow, BaseReferences<_$AppDatabase, $UserTripsTable, UserTripRow>),
    UserTripRow,
    PrefetchHooks Function()>;
typedef $$SyncTasksTableCreateCompanionBuilder = SyncTasksCompanion Function({
  required String id,
  required String entityType,
  required String entityId,
  required String operation,
  Value<String> status,
  Value<int> retryCount,
  Value<DateTime?> nextAttemptAt,
  Value<String?> dependsOnEntityType,
  Value<String?> dependsOnEntityId,
  Value<String?> errorCode,
  Value<String?> errorMessage,
  Value<String?> workerSessionId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$SyncTasksTableUpdateCompanionBuilder = SyncTasksCompanion Function({
  Value<String> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> operation,
  Value<String> status,
  Value<int> retryCount,
  Value<DateTime?> nextAttemptAt,
  Value<String?> dependsOnEntityType,
  Value<String?> dependsOnEntityId,
  Value<String?> errorCode,
  Value<String?> errorMessage,
  Value<String?> workerSessionId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SyncTasksTableFilterComposer
    extends Composer<_$AppDatabase, $SyncTasksTable> {
  $$SyncTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dependsOnEntityType => $composableBuilder(
      column: $table.dependsOnEntityType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dependsOnEntityId => $composableBuilder(
      column: $table.dependsOnEntityId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorCode => $composableBuilder(
      column: $table.errorCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get workerSessionId => $composableBuilder(
      column: $table.workerSessionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncTasksTable> {
  $$SyncTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dependsOnEntityType => $composableBuilder(
      column: $table.dependsOnEntityType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dependsOnEntityId => $composableBuilder(
      column: $table.dependsOnEntityId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorCode => $composableBuilder(
      column: $table.errorCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get workerSessionId => $composableBuilder(
      column: $table.workerSessionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncTasksTable> {
  $$SyncTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => column);

  GeneratedColumn<String> get dependsOnEntityType => $composableBuilder(
      column: $table.dependsOnEntityType, builder: (column) => column);

  GeneratedColumn<String> get dependsOnEntityId => $composableBuilder(
      column: $table.dependsOnEntityId, builder: (column) => column);

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<String> get workerSessionId => $composableBuilder(
      column: $table.workerSessionId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncTasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncTasksTable,
    SyncTaskRow,
    $$SyncTasksTableFilterComposer,
    $$SyncTasksTableOrderingComposer,
    $$SyncTasksTableAnnotationComposer,
    $$SyncTasksTableCreateCompanionBuilder,
    $$SyncTasksTableUpdateCompanionBuilder,
    (SyncTaskRow, BaseReferences<_$AppDatabase, $SyncTasksTable, SyncTaskRow>),
    SyncTaskRow,
    PrefetchHooks Function()> {
  $$SyncTasksTableTableManager(_$AppDatabase db, $SyncTasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime?> nextAttemptAt = const Value.absent(),
            Value<String?> dependsOnEntityType = const Value.absent(),
            Value<String?> dependsOnEntityId = const Value.absent(),
            Value<String?> errorCode = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<String?> workerSessionId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncTasksCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            status: status,
            retryCount: retryCount,
            nextAttemptAt: nextAttemptAt,
            dependsOnEntityType: dependsOnEntityType,
            dependsOnEntityId: dependsOnEntityId,
            errorCode: errorCode,
            errorMessage: errorMessage,
            workerSessionId: workerSessionId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityType,
            required String entityId,
            required String operation,
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime?> nextAttemptAt = const Value.absent(),
            Value<String?> dependsOnEntityType = const Value.absent(),
            Value<String?> dependsOnEntityId = const Value.absent(),
            Value<String?> errorCode = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<String?> workerSessionId = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncTasksCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            status: status,
            retryCount: retryCount,
            nextAttemptAt: nextAttemptAt,
            dependsOnEntityType: dependsOnEntityType,
            dependsOnEntityId: dependsOnEntityId,
            errorCode: errorCode,
            errorMessage: errorMessage,
            workerSessionId: workerSessionId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncTasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncTasksTable,
    SyncTaskRow,
    $$SyncTasksTableFilterComposer,
    $$SyncTasksTableOrderingComposer,
    $$SyncTasksTableAnnotationComposer,
    $$SyncTasksTableCreateCompanionBuilder,
    $$SyncTasksTableUpdateCompanionBuilder,
    (SyncTaskRow, BaseReferences<_$AppDatabase, $SyncTasksTable, SyncTaskRow>),
    SyncTaskRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
  $$PlacesTableTableManager get places =>
      $$PlacesTableTableManager(_db, _db.places);
  $$RoutesTableTableManager get routes =>
      $$RoutesTableTableManager(_db, _db.routes);
  $$MediaTableTableManager get media =>
      $$MediaTableTableManager(_db, _db.media);
  $$PublicTripsTableTableManager get publicTrips =>
      $$PublicTripsTableTableManager(_db, _db.publicTrips);
  $$UserTripsTableTableManager get userTrips =>
      $$UserTripsTableTableManager(_db, _db.userTrips);
  $$SyncTasksTableTableManager get syncTasks =>
      $$SyncTasksTableTableManager(_db, _db.syncTasks);
}
