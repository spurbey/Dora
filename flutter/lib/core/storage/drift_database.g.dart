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
  static const VerificationMeta _serverRouteIdMeta =
      const VerificationMeta('serverRouteId');
  @override
  late final GeneratedColumn<String> serverRouteId = GeneratedColumn<String>(
      'server_route_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        serverRouteId,
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
    if (data.containsKey('server_route_id')) {
      context.handle(
          _serverRouteIdMeta,
          serverRouteId.isAcceptableOrUnknown(
              data['server_route_id']!, _serverRouteIdMeta));
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
      serverRouteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_route_id']),
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
  final String? serverRouteId;
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
      this.serverRouteId,
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
    if (!nullToAbsent || serverRouteId != null) {
      map['server_route_id'] = Variable<String>(serverRouteId);
    }
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
      serverRouteId: serverRouteId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRouteId),
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
      serverRouteId: serializer.fromJson<String?>(json['serverRouteId']),
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
      'serverRouteId': serializer.toJson<String?>(serverRouteId),
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
          Value<String?> serverRouteId = const Value.absent(),
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
        serverRouteId:
            serverRouteId.present ? serverRouteId.value : this.serverRouteId,
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
      serverRouteId: data.serverRouteId.present
          ? data.serverRouteId.value
          : this.serverRouteId,
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
          ..write('serverRouteId: $serverRouteId, ')
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
      serverRouteId,
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
          other.serverRouteId == this.serverRouteId &&
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
  final Value<String?> serverRouteId;
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
    this.serverRouteId = const Value.absent(),
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
    this.serverRouteId = const Value.absent(),
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
    Expression<String>? serverRouteId,
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
      if (serverRouteId != null) 'server_route_id': serverRouteId,
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
      Value<String?>? serverRouteId,
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
      serverRouteId: serverRouteId ?? this.serverRouteId,
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
    if (serverRouteId.present) {
      map['server_route_id'] = Variable<String>(serverRouteId.value);
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
          ..write('serverRouteId: $serverRouteId, ')
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
  static const VerificationMeta _remoteEntityIdMeta =
      const VerificationMeta('remoteEntityId');
  @override
  late final GeneratedColumn<String> remoteEntityId = GeneratedColumn<String>(
      'remote_entity_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
  static const VerificationMeta _pendingRequeueMeta =
      const VerificationMeta('pendingRequeue');
  @override
  late final GeneratedColumn<bool> pendingRequeue = GeneratedColumn<bool>(
      'pending_requeue', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("pending_requeue" IN (0, 1))'),
      defaultValue: const Constant(false));
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
        remoteEntityId,
        operation,
        status,
        pendingRequeue,
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
    if (data.containsKey('remote_entity_id')) {
      context.handle(
          _remoteEntityIdMeta,
          remoteEntityId.isAcceptableOrUnknown(
              data['remote_entity_id']!, _remoteEntityIdMeta));
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
    if (data.containsKey('pending_requeue')) {
      context.handle(
          _pendingRequeueMeta,
          pendingRequeue.isAcceptableOrUnknown(
              data['pending_requeue']!, _pendingRequeueMeta));
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
      remoteEntityId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}remote_entity_id']),
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      pendingRequeue: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pending_requeue'])!,
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
  final String? remoteEntityId;
  final String operation;
  final String status;
  final bool pendingRequeue;
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
      this.remoteEntityId,
      required this.operation,
      required this.status,
      required this.pendingRequeue,
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
    if (!nullToAbsent || remoteEntityId != null) {
      map['remote_entity_id'] = Variable<String>(remoteEntityId);
    }
    map['operation'] = Variable<String>(operation);
    map['status'] = Variable<String>(status);
    map['pending_requeue'] = Variable<bool>(pendingRequeue);
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
      remoteEntityId: remoteEntityId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteEntityId),
      operation: Value(operation),
      status: Value(status),
      pendingRequeue: Value(pendingRequeue),
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
      remoteEntityId: serializer.fromJson<String?>(json['remoteEntityId']),
      operation: serializer.fromJson<String>(json['operation']),
      status: serializer.fromJson<String>(json['status']),
      pendingRequeue: serializer.fromJson<bool>(json['pendingRequeue']),
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
      'remoteEntityId': serializer.toJson<String?>(remoteEntityId),
      'operation': serializer.toJson<String>(operation),
      'status': serializer.toJson<String>(status),
      'pendingRequeue': serializer.toJson<bool>(pendingRequeue),
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
          Value<String?> remoteEntityId = const Value.absent(),
          String? operation,
          String? status,
          bool? pendingRequeue,
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
        remoteEntityId:
            remoteEntityId.present ? remoteEntityId.value : this.remoteEntityId,
        operation: operation ?? this.operation,
        status: status ?? this.status,
        pendingRequeue: pendingRequeue ?? this.pendingRequeue,
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
      remoteEntityId: data.remoteEntityId.present
          ? data.remoteEntityId.value
          : this.remoteEntityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      status: data.status.present ? data.status.value : this.status,
      pendingRequeue: data.pendingRequeue.present
          ? data.pendingRequeue.value
          : this.pendingRequeue,
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
          ..write('remoteEntityId: $remoteEntityId, ')
          ..write('operation: $operation, ')
          ..write('status: $status, ')
          ..write('pendingRequeue: $pendingRequeue, ')
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
      remoteEntityId,
      operation,
      status,
      pendingRequeue,
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
          other.remoteEntityId == this.remoteEntityId &&
          other.operation == this.operation &&
          other.status == this.status &&
          other.pendingRequeue == this.pendingRequeue &&
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
  final Value<String?> remoteEntityId;
  final Value<String> operation;
  final Value<String> status;
  final Value<bool> pendingRequeue;
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
    this.remoteEntityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.status = const Value.absent(),
    this.pendingRequeue = const Value.absent(),
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
    this.remoteEntityId = const Value.absent(),
    required String operation,
    this.status = const Value.absent(),
    this.pendingRequeue = const Value.absent(),
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
    Expression<String>? remoteEntityId,
    Expression<String>? operation,
    Expression<String>? status,
    Expression<bool>? pendingRequeue,
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
      if (remoteEntityId != null) 'remote_entity_id': remoteEntityId,
      if (operation != null) 'operation': operation,
      if (status != null) 'status': status,
      if (pendingRequeue != null) 'pending_requeue': pendingRequeue,
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
      Value<String?>? remoteEntityId,
      Value<String>? operation,
      Value<String>? status,
      Value<bool>? pendingRequeue,
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
      remoteEntityId: remoteEntityId ?? this.remoteEntityId,
      operation: operation ?? this.operation,
      status: status ?? this.status,
      pendingRequeue: pendingRequeue ?? this.pendingRequeue,
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
    if (remoteEntityId.present) {
      map['remote_entity_id'] = Variable<String>(remoteEntityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (pendingRequeue.present) {
      map['pending_requeue'] = Variable<bool>(pendingRequeue.value);
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
          ..write('remoteEntityId: $remoteEntityId, ')
          ..write('operation: $operation, ')
          ..write('status: $status, ')
          ..write('pendingRequeue: $pendingRequeue, ')
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

class $TrackingSessionsTable extends TrackingSessions
    with TableInfo<$TrackingSessionsTable, TrackingSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackingSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _remoteSessionIdMeta =
      const VerificationMeta('remoteSessionId');
  @override
  late final GeneratedColumn<String> remoteSessionId = GeneratedColumn<String>(
      'remote_session_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _clientSessionIdMeta =
      const VerificationMeta('clientSessionId');
  @override
  late final GeneratedColumn<String> clientSessionId = GeneratedColumn<String>(
      'client_session_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('planned'));
  static const VerificationMeta _timezoneMeta =
      const VerificationMeta('timezone');
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
      'timezone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceContextJsonMeta =
      const VerificationMeta('deviceContextJson');
  @override
  late final GeneratedColumn<String> deviceContextJson =
      GeneratedColumn<String>('device_context_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('{}'));
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _pausedAtMeta =
      const VerificationMeta('pausedAt');
  @override
  late final GeneratedColumn<DateTime> pausedAt = GeneratedColumn<DateTime>(
      'paused_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _resumedAtMeta =
      const VerificationMeta('resumedAt');
  @override
  late final GeneratedColumn<DateTime> resumedAt = GeneratedColumn<DateTime>(
      'resumed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _abandonedAtMeta =
      const VerificationMeta('abandonedAt');
  @override
  late final GeneratedColumn<DateTime> abandonedAt = GeneratedColumn<DateTime>(
      'abandoned_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastPointAtMeta =
      const VerificationMeta('lastPointAt');
  @override
  late final GeneratedColumn<DateTime> lastPointAt = GeneratedColumn<DateTime>(
      'last_point_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastFlushAtMeta =
      const VerificationMeta('lastFlushAt');
  @override
  late final GeneratedColumn<DateTime> lastFlushAt = GeneratedColumn<DateTime>(
      'last_flush_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
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
      GeneratedColumn<DateTime>('server_updated_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
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
        tripId,
        remoteSessionId,
        clientSessionId,
        state,
        timezone,
        deviceContextJson,
        startedAt,
        pausedAt,
        resumedAt,
        endedAt,
        abandonedAt,
        lastPointAt,
        lastFlushAt,
        syncStatus,
        localUpdatedAt,
        serverUpdatedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracking_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<TrackingSessionRow> instance,
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
    if (data.containsKey('remote_session_id')) {
      context.handle(
          _remoteSessionIdMeta,
          remoteSessionId.isAcceptableOrUnknown(
              data['remote_session_id']!, _remoteSessionIdMeta));
    }
    if (data.containsKey('client_session_id')) {
      context.handle(
          _clientSessionIdMeta,
          clientSessionId.isAcceptableOrUnknown(
              data['client_session_id']!, _clientSessionIdMeta));
    } else if (isInserting) {
      context.missing(_clientSessionIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    }
    if (data.containsKey('timezone')) {
      context.handle(_timezoneMeta,
          timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta));
    }
    if (data.containsKey('device_context_json')) {
      context.handle(
          _deviceContextJsonMeta,
          deviceContextJson.isAcceptableOrUnknown(
              data['device_context_json']!, _deviceContextJsonMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('paused_at')) {
      context.handle(_pausedAtMeta,
          pausedAt.isAcceptableOrUnknown(data['paused_at']!, _pausedAtMeta));
    }
    if (data.containsKey('resumed_at')) {
      context.handle(_resumedAtMeta,
          resumedAt.isAcceptableOrUnknown(data['resumed_at']!, _resumedAtMeta));
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('abandoned_at')) {
      context.handle(
          _abandonedAtMeta,
          abandonedAt.isAcceptableOrUnknown(
              data['abandoned_at']!, _abandonedAtMeta));
    }
    if (data.containsKey('last_point_at')) {
      context.handle(
          _lastPointAtMeta,
          lastPointAt.isAcceptableOrUnknown(
              data['last_point_at']!, _lastPointAtMeta));
    }
    if (data.containsKey('last_flush_at')) {
      context.handle(
          _lastFlushAtMeta,
          lastFlushAt.isAcceptableOrUnknown(
              data['last_flush_at']!, _lastFlushAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
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
        {tripId, clientSessionId},
      ];
  @override
  TrackingSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackingSessionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tripId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trip_id'])!,
      remoteSessionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}remote_session_id']),
      clientSessionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}client_session_id'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      timezone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timezone']),
      deviceContextJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}device_context_json'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at']),
      pausedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}paused_at']),
      resumedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}resumed_at']),
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ended_at']),
      abandonedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}abandoned_at']),
      lastPointAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_point_at']),
      lastFlushAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_flush_at']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}server_updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TrackingSessionsTable createAlias(String alias) {
    return $TrackingSessionsTable(attachedDatabase, alias);
  }
}

class TrackingSessionRow extends DataClass
    implements Insertable<TrackingSessionRow> {
  final String id;
  final String tripId;
  final String? remoteSessionId;
  final String clientSessionId;
  final String state;
  final String? timezone;
  final String deviceContextJson;
  final DateTime? startedAt;
  final DateTime? pausedAt;
  final DateTime? resumedAt;
  final DateTime? endedAt;
  final DateTime? abandonedAt;
  final DateTime? lastPointAt;
  final DateTime? lastFlushAt;
  final String syncStatus;
  final DateTime localUpdatedAt;
  final DateTime? serverUpdatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TrackingSessionRow(
      {required this.id,
      required this.tripId,
      this.remoteSessionId,
      required this.clientSessionId,
      required this.state,
      this.timezone,
      required this.deviceContextJson,
      this.startedAt,
      this.pausedAt,
      this.resumedAt,
      this.endedAt,
      this.abandonedAt,
      this.lastPointAt,
      this.lastFlushAt,
      required this.syncStatus,
      required this.localUpdatedAt,
      this.serverUpdatedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    if (!nullToAbsent || remoteSessionId != null) {
      map['remote_session_id'] = Variable<String>(remoteSessionId);
    }
    map['client_session_id'] = Variable<String>(clientSessionId);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || timezone != null) {
      map['timezone'] = Variable<String>(timezone);
    }
    map['device_context_json'] = Variable<String>(deviceContextJson);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || pausedAt != null) {
      map['paused_at'] = Variable<DateTime>(pausedAt);
    }
    if (!nullToAbsent || resumedAt != null) {
      map['resumed_at'] = Variable<DateTime>(resumedAt);
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || abandonedAt != null) {
      map['abandoned_at'] = Variable<DateTime>(abandonedAt);
    }
    if (!nullToAbsent || lastPointAt != null) {
      map['last_point_at'] = Variable<DateTime>(lastPointAt);
    }
    if (!nullToAbsent || lastFlushAt != null) {
      map['last_flush_at'] = Variable<DateTime>(lastFlushAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TrackingSessionsCompanion toCompanion(bool nullToAbsent) {
    return TrackingSessionsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      remoteSessionId: remoteSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteSessionId),
      clientSessionId: Value(clientSessionId),
      state: Value(state),
      timezone: timezone == null && nullToAbsent
          ? const Value.absent()
          : Value(timezone),
      deviceContextJson: Value(deviceContextJson),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      pausedAt: pausedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedAt),
      resumedAt: resumedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resumedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      abandonedAt: abandonedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(abandonedAt),
      lastPointAt: lastPointAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPointAt),
      lastFlushAt: lastFlushAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFlushAt),
      syncStatus: Value(syncStatus),
      localUpdatedAt: Value(localUpdatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TrackingSessionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackingSessionRow(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      remoteSessionId: serializer.fromJson<String?>(json['remoteSessionId']),
      clientSessionId: serializer.fromJson<String>(json['clientSessionId']),
      state: serializer.fromJson<String>(json['state']),
      timezone: serializer.fromJson<String?>(json['timezone']),
      deviceContextJson: serializer.fromJson<String>(json['deviceContextJson']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      pausedAt: serializer.fromJson<DateTime?>(json['pausedAt']),
      resumedAt: serializer.fromJson<DateTime?>(json['resumedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      abandonedAt: serializer.fromJson<DateTime?>(json['abandonedAt']),
      lastPointAt: serializer.fromJson<DateTime?>(json['lastPointAt']),
      lastFlushAt: serializer.fromJson<DateTime?>(json['lastFlushAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'remoteSessionId': serializer.toJson<String?>(remoteSessionId),
      'clientSessionId': serializer.toJson<String>(clientSessionId),
      'state': serializer.toJson<String>(state),
      'timezone': serializer.toJson<String?>(timezone),
      'deviceContextJson': serializer.toJson<String>(deviceContextJson),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'pausedAt': serializer.toJson<DateTime?>(pausedAt),
      'resumedAt': serializer.toJson<DateTime?>(resumedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'abandonedAt': serializer.toJson<DateTime?>(abandonedAt),
      'lastPointAt': serializer.toJson<DateTime?>(lastPointAt),
      'lastFlushAt': serializer.toJson<DateTime?>(lastFlushAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TrackingSessionRow copyWith(
          {String? id,
          String? tripId,
          Value<String?> remoteSessionId = const Value.absent(),
          String? clientSessionId,
          String? state,
          Value<String?> timezone = const Value.absent(),
          String? deviceContextJson,
          Value<DateTime?> startedAt = const Value.absent(),
          Value<DateTime?> pausedAt = const Value.absent(),
          Value<DateTime?> resumedAt = const Value.absent(),
          Value<DateTime?> endedAt = const Value.absent(),
          Value<DateTime?> abandonedAt = const Value.absent(),
          Value<DateTime?> lastPointAt = const Value.absent(),
          Value<DateTime?> lastFlushAt = const Value.absent(),
          String? syncStatus,
          DateTime? localUpdatedAt,
          Value<DateTime?> serverUpdatedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      TrackingSessionRow(
        id: id ?? this.id,
        tripId: tripId ?? this.tripId,
        remoteSessionId: remoteSessionId.present
            ? remoteSessionId.value
            : this.remoteSessionId,
        clientSessionId: clientSessionId ?? this.clientSessionId,
        state: state ?? this.state,
        timezone: timezone.present ? timezone.value : this.timezone,
        deviceContextJson: deviceContextJson ?? this.deviceContextJson,
        startedAt: startedAt.present ? startedAt.value : this.startedAt,
        pausedAt: pausedAt.present ? pausedAt.value : this.pausedAt,
        resumedAt: resumedAt.present ? resumedAt.value : this.resumedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        abandonedAt: abandonedAt.present ? abandonedAt.value : this.abandonedAt,
        lastPointAt: lastPointAt.present ? lastPointAt.value : this.lastPointAt,
        lastFlushAt: lastFlushAt.present ? lastFlushAt.value : this.lastFlushAt,
        syncStatus: syncStatus ?? this.syncStatus,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        serverUpdatedAt: serverUpdatedAt.present
            ? serverUpdatedAt.value
            : this.serverUpdatedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TrackingSessionRow copyWithCompanion(TrackingSessionsCompanion data) {
    return TrackingSessionRow(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      remoteSessionId: data.remoteSessionId.present
          ? data.remoteSessionId.value
          : this.remoteSessionId,
      clientSessionId: data.clientSessionId.present
          ? data.clientSessionId.value
          : this.clientSessionId,
      state: data.state.present ? data.state.value : this.state,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      deviceContextJson: data.deviceContextJson.present
          ? data.deviceContextJson.value
          : this.deviceContextJson,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      pausedAt: data.pausedAt.present ? data.pausedAt.value : this.pausedAt,
      resumedAt: data.resumedAt.present ? data.resumedAt.value : this.resumedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      abandonedAt:
          data.abandonedAt.present ? data.abandonedAt.value : this.abandonedAt,
      lastPointAt:
          data.lastPointAt.present ? data.lastPointAt.value : this.lastPointAt,
      lastFlushAt:
          data.lastFlushAt.present ? data.lastFlushAt.value : this.lastFlushAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackingSessionRow(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('remoteSessionId: $remoteSessionId, ')
          ..write('clientSessionId: $clientSessionId, ')
          ..write('state: $state, ')
          ..write('timezone: $timezone, ')
          ..write('deviceContextJson: $deviceContextJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('resumedAt: $resumedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('abandonedAt: $abandonedAt, ')
          ..write('lastPointAt: $lastPointAt, ')
          ..write('lastFlushAt: $lastFlushAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tripId,
      remoteSessionId,
      clientSessionId,
      state,
      timezone,
      deviceContextJson,
      startedAt,
      pausedAt,
      resumedAt,
      endedAt,
      abandonedAt,
      lastPointAt,
      lastFlushAt,
      syncStatus,
      localUpdatedAt,
      serverUpdatedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackingSessionRow &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.remoteSessionId == this.remoteSessionId &&
          other.clientSessionId == this.clientSessionId &&
          other.state == this.state &&
          other.timezone == this.timezone &&
          other.deviceContextJson == this.deviceContextJson &&
          other.startedAt == this.startedAt &&
          other.pausedAt == this.pausedAt &&
          other.resumedAt == this.resumedAt &&
          other.endedAt == this.endedAt &&
          other.abandonedAt == this.abandonedAt &&
          other.lastPointAt == this.lastPointAt &&
          other.lastFlushAt == this.lastFlushAt &&
          other.syncStatus == this.syncStatus &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TrackingSessionsCompanion extends UpdateCompanion<TrackingSessionRow> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String?> remoteSessionId;
  final Value<String> clientSessionId;
  final Value<String> state;
  final Value<String?> timezone;
  final Value<String> deviceContextJson;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> pausedAt;
  final Value<DateTime?> resumedAt;
  final Value<DateTime?> endedAt;
  final Value<DateTime?> abandonedAt;
  final Value<DateTime?> lastPointAt;
  final Value<DateTime?> lastFlushAt;
  final Value<String> syncStatus;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime?> serverUpdatedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TrackingSessionsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.remoteSessionId = const Value.absent(),
    this.clientSessionId = const Value.absent(),
    this.state = const Value.absent(),
    this.timezone = const Value.absent(),
    this.deviceContextJson = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.resumedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.abandonedAt = const Value.absent(),
    this.lastPointAt = const Value.absent(),
    this.lastFlushAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackingSessionsCompanion.insert({
    required String id,
    required String tripId,
    this.remoteSessionId = const Value.absent(),
    required String clientSessionId,
    this.state = const Value.absent(),
    this.timezone = const Value.absent(),
    this.deviceContextJson = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.resumedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.abandonedAt = const Value.absent(),
    this.lastPointAt = const Value.absent(),
    this.lastFlushAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime localUpdatedAt,
    this.serverUpdatedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tripId = Value(tripId),
        clientSessionId = Value(clientSessionId),
        localUpdatedAt = Value(localUpdatedAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TrackingSessionRow> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? remoteSessionId,
    Expression<String>? clientSessionId,
    Expression<String>? state,
    Expression<String>? timezone,
    Expression<String>? deviceContextJson,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? pausedAt,
    Expression<DateTime>? resumedAt,
    Expression<DateTime>? endedAt,
    Expression<DateTime>? abandonedAt,
    Expression<DateTime>? lastPointAt,
    Expression<DateTime>? lastFlushAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (remoteSessionId != null) 'remote_session_id': remoteSessionId,
      if (clientSessionId != null) 'client_session_id': clientSessionId,
      if (state != null) 'state': state,
      if (timezone != null) 'timezone': timezone,
      if (deviceContextJson != null) 'device_context_json': deviceContextJson,
      if (startedAt != null) 'started_at': startedAt,
      if (pausedAt != null) 'paused_at': pausedAt,
      if (resumedAt != null) 'resumed_at': resumedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (abandonedAt != null) 'abandoned_at': abandonedAt,
      if (lastPointAt != null) 'last_point_at': lastPointAt,
      if (lastFlushAt != null) 'last_flush_at': lastFlushAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackingSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tripId,
      Value<String?>? remoteSessionId,
      Value<String>? clientSessionId,
      Value<String>? state,
      Value<String?>? timezone,
      Value<String>? deviceContextJson,
      Value<DateTime?>? startedAt,
      Value<DateTime?>? pausedAt,
      Value<DateTime?>? resumedAt,
      Value<DateTime?>? endedAt,
      Value<DateTime?>? abandonedAt,
      Value<DateTime?>? lastPointAt,
      Value<DateTime?>? lastFlushAt,
      Value<String>? syncStatus,
      Value<DateTime>? localUpdatedAt,
      Value<DateTime?>? serverUpdatedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return TrackingSessionsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      remoteSessionId: remoteSessionId ?? this.remoteSessionId,
      clientSessionId: clientSessionId ?? this.clientSessionId,
      state: state ?? this.state,
      timezone: timezone ?? this.timezone,
      deviceContextJson: deviceContextJson ?? this.deviceContextJson,
      startedAt: startedAt ?? this.startedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      resumedAt: resumedAt ?? this.resumedAt,
      endedAt: endedAt ?? this.endedAt,
      abandonedAt: abandonedAt ?? this.abandonedAt,
      lastPointAt: lastPointAt ?? this.lastPointAt,
      lastFlushAt: lastFlushAt ?? this.lastFlushAt,
      syncStatus: syncStatus ?? this.syncStatus,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
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
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (remoteSessionId.present) {
      map['remote_session_id'] = Variable<String>(remoteSessionId.value);
    }
    if (clientSessionId.present) {
      map['client_session_id'] = Variable<String>(clientSessionId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (deviceContextJson.present) {
      map['device_context_json'] = Variable<String>(deviceContextJson.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (pausedAt.present) {
      map['paused_at'] = Variable<DateTime>(pausedAt.value);
    }
    if (resumedAt.present) {
      map['resumed_at'] = Variable<DateTime>(resumedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (abandonedAt.present) {
      map['abandoned_at'] = Variable<DateTime>(abandonedAt.value);
    }
    if (lastPointAt.present) {
      map['last_point_at'] = Variable<DateTime>(lastPointAt.value);
    }
    if (lastFlushAt.present) {
      map['last_flush_at'] = Variable<DateTime>(lastFlushAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
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
    return (StringBuffer('TrackingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('remoteSessionId: $remoteSessionId, ')
          ..write('clientSessionId: $clientSessionId, ')
          ..write('state: $state, ')
          ..write('timezone: $timezone, ')
          ..write('deviceContextJson: $deviceContextJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('resumedAt: $resumedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('abandonedAt: $abandonedAt, ')
          ..write('lastPointAt: $lastPointAt, ')
          ..write('lastFlushAt: $lastFlushAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackingPointBatchesTable extends TrackingPointBatches
    with TableInfo<$TrackingPointBatchesTable, TrackingPointBatchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackingPointBatchesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteSessionIdMeta =
      const VerificationMeta('remoteSessionId');
  @override
  late final GeneratedColumn<String> remoteSessionId = GeneratedColumn<String>(
      'remote_session_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _clientBatchIdMeta =
      const VerificationMeta('clientBatchId');
  @override
  late final GeneratedColumn<String> clientBatchId = GeneratedColumn<String>(
      'client_batch_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstRecordedAtMeta =
      const VerificationMeta('firstRecordedAt');
  @override
  late final GeneratedColumn<DateTime> firstRecordedAt =
      GeneratedColumn<DateTime>('first_recorded_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastRecordedAtMeta =
      const VerificationMeta('lastRecordedAt');
  @override
  late final GeneratedColumn<DateTime> lastRecordedAt =
      GeneratedColumn<DateTime>('last_recorded_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _pointCountMeta =
      const VerificationMeta('pointCount');
  @override
  late final GeneratedColumn<int> pointCount = GeneratedColumn<int>(
      'point_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _pointsJsonMeta =
      const VerificationMeta('pointsJson');
  @override
  late final GeneratedColumn<String> pointsJson = GeneratedColumn<String>(
      'points_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
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
  static const VerificationMeta _workerSessionIdMeta =
      const VerificationMeta('workerSessionId');
  @override
  late final GeneratedColumn<String> workerSessionId = GeneratedColumn<String>(
      'worker_session_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
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
      GeneratedColumn<DateTime>('server_updated_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
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
        tripId,
        sessionId,
        remoteSessionId,
        clientBatchId,
        firstRecordedAt,
        lastRecordedAt,
        pointCount,
        pointsJson,
        status,
        retryCount,
        nextAttemptAt,
        workerSessionId,
        lastError,
        syncStatus,
        localUpdatedAt,
        serverUpdatedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracking_point_batches';
  @override
  VerificationContext validateIntegrity(
      Insertable<TrackingPointBatchRow> instance,
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
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('remote_session_id')) {
      context.handle(
          _remoteSessionIdMeta,
          remoteSessionId.isAcceptableOrUnknown(
              data['remote_session_id']!, _remoteSessionIdMeta));
    }
    if (data.containsKey('client_batch_id')) {
      context.handle(
          _clientBatchIdMeta,
          clientBatchId.isAcceptableOrUnknown(
              data['client_batch_id']!, _clientBatchIdMeta));
    } else if (isInserting) {
      context.missing(_clientBatchIdMeta);
    }
    if (data.containsKey('first_recorded_at')) {
      context.handle(
          _firstRecordedAtMeta,
          firstRecordedAt.isAcceptableOrUnknown(
              data['first_recorded_at']!, _firstRecordedAtMeta));
    }
    if (data.containsKey('last_recorded_at')) {
      context.handle(
          _lastRecordedAtMeta,
          lastRecordedAt.isAcceptableOrUnknown(
              data['last_recorded_at']!, _lastRecordedAtMeta));
    }
    if (data.containsKey('point_count')) {
      context.handle(
          _pointCountMeta,
          pointCount.isAcceptableOrUnknown(
              data['point_count']!, _pointCountMeta));
    }
    if (data.containsKey('points_json')) {
      context.handle(
          _pointsJsonMeta,
          pointsJson.isAcceptableOrUnknown(
              data['points_json']!, _pointsJsonMeta));
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
    if (data.containsKey('worker_session_id')) {
      context.handle(
          _workerSessionIdMeta,
          workerSessionId.isAcceptableOrUnknown(
              data['worker_session_id']!, _workerSessionIdMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
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
        {clientBatchId},
      ];
  @override
  TrackingPointBatchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackingPointBatchRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tripId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trip_id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      remoteSessionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}remote_session_id']),
      clientBatchId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}client_batch_id'])!,
      firstRecordedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}first_recorded_at']),
      lastRecordedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_recorded_at']),
      pointCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}point_count'])!,
      pointsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}points_json'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_attempt_at']),
      workerSessionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}worker_session_id']),
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}server_updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TrackingPointBatchesTable createAlias(String alias) {
    return $TrackingPointBatchesTable(attachedDatabase, alias);
  }
}

class TrackingPointBatchRow extends DataClass
    implements Insertable<TrackingPointBatchRow> {
  final String id;
  final String tripId;
  final String sessionId;
  final String? remoteSessionId;
  final String clientBatchId;
  final DateTime? firstRecordedAt;
  final DateTime? lastRecordedAt;
  final int pointCount;
  final String pointsJson;
  final String status;
  final int retryCount;
  final DateTime? nextAttemptAt;
  final String? workerSessionId;
  final String? lastError;
  final String syncStatus;
  final DateTime localUpdatedAt;
  final DateTime? serverUpdatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TrackingPointBatchRow(
      {required this.id,
      required this.tripId,
      required this.sessionId,
      this.remoteSessionId,
      required this.clientBatchId,
      this.firstRecordedAt,
      this.lastRecordedAt,
      required this.pointCount,
      required this.pointsJson,
      required this.status,
      required this.retryCount,
      this.nextAttemptAt,
      this.workerSessionId,
      this.lastError,
      required this.syncStatus,
      required this.localUpdatedAt,
      this.serverUpdatedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || remoteSessionId != null) {
      map['remote_session_id'] = Variable<String>(remoteSessionId);
    }
    map['client_batch_id'] = Variable<String>(clientBatchId);
    if (!nullToAbsent || firstRecordedAt != null) {
      map['first_recorded_at'] = Variable<DateTime>(firstRecordedAt);
    }
    if (!nullToAbsent || lastRecordedAt != null) {
      map['last_recorded_at'] = Variable<DateTime>(lastRecordedAt);
    }
    map['point_count'] = Variable<int>(pointCount);
    map['points_json'] = Variable<String>(pointsJson);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || workerSessionId != null) {
      map['worker_session_id'] = Variable<String>(workerSessionId);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TrackingPointBatchesCompanion toCompanion(bool nullToAbsent) {
    return TrackingPointBatchesCompanion(
      id: Value(id),
      tripId: Value(tripId),
      sessionId: Value(sessionId),
      remoteSessionId: remoteSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteSessionId),
      clientBatchId: Value(clientBatchId),
      firstRecordedAt: firstRecordedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(firstRecordedAt),
      lastRecordedAt: lastRecordedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRecordedAt),
      pointCount: Value(pointCount),
      pointsJson: Value(pointsJson),
      status: Value(status),
      retryCount: Value(retryCount),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      workerSessionId: workerSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(workerSessionId),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      syncStatus: Value(syncStatus),
      localUpdatedAt: Value(localUpdatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TrackingPointBatchRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackingPointBatchRow(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      remoteSessionId: serializer.fromJson<String?>(json['remoteSessionId']),
      clientBatchId: serializer.fromJson<String>(json['clientBatchId']),
      firstRecordedAt: serializer.fromJson<DateTime?>(json['firstRecordedAt']),
      lastRecordedAt: serializer.fromJson<DateTime?>(json['lastRecordedAt']),
      pointCount: serializer.fromJson<int>(json['pointCount']),
      pointsJson: serializer.fromJson<String>(json['pointsJson']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      workerSessionId: serializer.fromJson<String?>(json['workerSessionId']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'sessionId': serializer.toJson<String>(sessionId),
      'remoteSessionId': serializer.toJson<String?>(remoteSessionId),
      'clientBatchId': serializer.toJson<String>(clientBatchId),
      'firstRecordedAt': serializer.toJson<DateTime?>(firstRecordedAt),
      'lastRecordedAt': serializer.toJson<DateTime?>(lastRecordedAt),
      'pointCount': serializer.toJson<int>(pointCount),
      'pointsJson': serializer.toJson<String>(pointsJson),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'workerSessionId': serializer.toJson<String?>(workerSessionId),
      'lastError': serializer.toJson<String?>(lastError),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TrackingPointBatchRow copyWith(
          {String? id,
          String? tripId,
          String? sessionId,
          Value<String?> remoteSessionId = const Value.absent(),
          String? clientBatchId,
          Value<DateTime?> firstRecordedAt = const Value.absent(),
          Value<DateTime?> lastRecordedAt = const Value.absent(),
          int? pointCount,
          String? pointsJson,
          String? status,
          int? retryCount,
          Value<DateTime?> nextAttemptAt = const Value.absent(),
          Value<String?> workerSessionId = const Value.absent(),
          Value<String?> lastError = const Value.absent(),
          String? syncStatus,
          DateTime? localUpdatedAt,
          Value<DateTime?> serverUpdatedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      TrackingPointBatchRow(
        id: id ?? this.id,
        tripId: tripId ?? this.tripId,
        sessionId: sessionId ?? this.sessionId,
        remoteSessionId: remoteSessionId.present
            ? remoteSessionId.value
            : this.remoteSessionId,
        clientBatchId: clientBatchId ?? this.clientBatchId,
        firstRecordedAt: firstRecordedAt.present
            ? firstRecordedAt.value
            : this.firstRecordedAt,
        lastRecordedAt:
            lastRecordedAt.present ? lastRecordedAt.value : this.lastRecordedAt,
        pointCount: pointCount ?? this.pointCount,
        pointsJson: pointsJson ?? this.pointsJson,
        status: status ?? this.status,
        retryCount: retryCount ?? this.retryCount,
        nextAttemptAt:
            nextAttemptAt.present ? nextAttemptAt.value : this.nextAttemptAt,
        workerSessionId: workerSessionId.present
            ? workerSessionId.value
            : this.workerSessionId,
        lastError: lastError.present ? lastError.value : this.lastError,
        syncStatus: syncStatus ?? this.syncStatus,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        serverUpdatedAt: serverUpdatedAt.present
            ? serverUpdatedAt.value
            : this.serverUpdatedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TrackingPointBatchRow copyWithCompanion(TrackingPointBatchesCompanion data) {
    return TrackingPointBatchRow(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      remoteSessionId: data.remoteSessionId.present
          ? data.remoteSessionId.value
          : this.remoteSessionId,
      clientBatchId: data.clientBatchId.present
          ? data.clientBatchId.value
          : this.clientBatchId,
      firstRecordedAt: data.firstRecordedAt.present
          ? data.firstRecordedAt.value
          : this.firstRecordedAt,
      lastRecordedAt: data.lastRecordedAt.present
          ? data.lastRecordedAt.value
          : this.lastRecordedAt,
      pointCount:
          data.pointCount.present ? data.pointCount.value : this.pointCount,
      pointsJson:
          data.pointsJson.present ? data.pointsJson.value : this.pointsJson,
      status: data.status.present ? data.status.value : this.status,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      workerSessionId: data.workerSessionId.present
          ? data.workerSessionId.value
          : this.workerSessionId,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackingPointBatchRow(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('sessionId: $sessionId, ')
          ..write('remoteSessionId: $remoteSessionId, ')
          ..write('clientBatchId: $clientBatchId, ')
          ..write('firstRecordedAt: $firstRecordedAt, ')
          ..write('lastRecordedAt: $lastRecordedAt, ')
          ..write('pointCount: $pointCount, ')
          ..write('pointsJson: $pointsJson, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('workerSessionId: $workerSessionId, ')
          ..write('lastError: $lastError, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tripId,
      sessionId,
      remoteSessionId,
      clientBatchId,
      firstRecordedAt,
      lastRecordedAt,
      pointCount,
      pointsJson,
      status,
      retryCount,
      nextAttemptAt,
      workerSessionId,
      lastError,
      syncStatus,
      localUpdatedAt,
      serverUpdatedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackingPointBatchRow &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.sessionId == this.sessionId &&
          other.remoteSessionId == this.remoteSessionId &&
          other.clientBatchId == this.clientBatchId &&
          other.firstRecordedAt == this.firstRecordedAt &&
          other.lastRecordedAt == this.lastRecordedAt &&
          other.pointCount == this.pointCount &&
          other.pointsJson == this.pointsJson &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.workerSessionId == this.workerSessionId &&
          other.lastError == this.lastError &&
          other.syncStatus == this.syncStatus &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TrackingPointBatchesCompanion
    extends UpdateCompanion<TrackingPointBatchRow> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> sessionId;
  final Value<String?> remoteSessionId;
  final Value<String> clientBatchId;
  final Value<DateTime?> firstRecordedAt;
  final Value<DateTime?> lastRecordedAt;
  final Value<int> pointCount;
  final Value<String> pointsJson;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> workerSessionId;
  final Value<String?> lastError;
  final Value<String> syncStatus;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime?> serverUpdatedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TrackingPointBatchesCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.remoteSessionId = const Value.absent(),
    this.clientBatchId = const Value.absent(),
    this.firstRecordedAt = const Value.absent(),
    this.lastRecordedAt = const Value.absent(),
    this.pointCount = const Value.absent(),
    this.pointsJson = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.workerSessionId = const Value.absent(),
    this.lastError = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackingPointBatchesCompanion.insert({
    required String id,
    required String tripId,
    required String sessionId,
    this.remoteSessionId = const Value.absent(),
    required String clientBatchId,
    this.firstRecordedAt = const Value.absent(),
    this.lastRecordedAt = const Value.absent(),
    this.pointCount = const Value.absent(),
    this.pointsJson = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.workerSessionId = const Value.absent(),
    this.lastError = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime localUpdatedAt,
    this.serverUpdatedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tripId = Value(tripId),
        sessionId = Value(sessionId),
        clientBatchId = Value(clientBatchId),
        localUpdatedAt = Value(localUpdatedAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TrackingPointBatchRow> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? sessionId,
    Expression<String>? remoteSessionId,
    Expression<String>? clientBatchId,
    Expression<DateTime>? firstRecordedAt,
    Expression<DateTime>? lastRecordedAt,
    Expression<int>? pointCount,
    Expression<String>? pointsJson,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? workerSessionId,
    Expression<String>? lastError,
    Expression<String>? syncStatus,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (sessionId != null) 'session_id': sessionId,
      if (remoteSessionId != null) 'remote_session_id': remoteSessionId,
      if (clientBatchId != null) 'client_batch_id': clientBatchId,
      if (firstRecordedAt != null) 'first_recorded_at': firstRecordedAt,
      if (lastRecordedAt != null) 'last_recorded_at': lastRecordedAt,
      if (pointCount != null) 'point_count': pointCount,
      if (pointsJson != null) 'points_json': pointsJson,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (workerSessionId != null) 'worker_session_id': workerSessionId,
      if (lastError != null) 'last_error': lastError,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackingPointBatchesCompanion copyWith(
      {Value<String>? id,
      Value<String>? tripId,
      Value<String>? sessionId,
      Value<String?>? remoteSessionId,
      Value<String>? clientBatchId,
      Value<DateTime?>? firstRecordedAt,
      Value<DateTime?>? lastRecordedAt,
      Value<int>? pointCount,
      Value<String>? pointsJson,
      Value<String>? status,
      Value<int>? retryCount,
      Value<DateTime?>? nextAttemptAt,
      Value<String?>? workerSessionId,
      Value<String?>? lastError,
      Value<String>? syncStatus,
      Value<DateTime>? localUpdatedAt,
      Value<DateTime?>? serverUpdatedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return TrackingPointBatchesCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      sessionId: sessionId ?? this.sessionId,
      remoteSessionId: remoteSessionId ?? this.remoteSessionId,
      clientBatchId: clientBatchId ?? this.clientBatchId,
      firstRecordedAt: firstRecordedAt ?? this.firstRecordedAt,
      lastRecordedAt: lastRecordedAt ?? this.lastRecordedAt,
      pointCount: pointCount ?? this.pointCount,
      pointsJson: pointsJson ?? this.pointsJson,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      workerSessionId: workerSessionId ?? this.workerSessionId,
      lastError: lastError ?? this.lastError,
      syncStatus: syncStatus ?? this.syncStatus,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
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
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (remoteSessionId.present) {
      map['remote_session_id'] = Variable<String>(remoteSessionId.value);
    }
    if (clientBatchId.present) {
      map['client_batch_id'] = Variable<String>(clientBatchId.value);
    }
    if (firstRecordedAt.present) {
      map['first_recorded_at'] = Variable<DateTime>(firstRecordedAt.value);
    }
    if (lastRecordedAt.present) {
      map['last_recorded_at'] = Variable<DateTime>(lastRecordedAt.value);
    }
    if (pointCount.present) {
      map['point_count'] = Variable<int>(pointCount.value);
    }
    if (pointsJson.present) {
      map['points_json'] = Variable<String>(pointsJson.value);
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
    if (workerSessionId.present) {
      map['worker_session_id'] = Variable<String>(workerSessionId.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
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
    return (StringBuffer('TrackingPointBatchesCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('sessionId: $sessionId, ')
          ..write('remoteSessionId: $remoteSessionId, ')
          ..write('clientBatchId: $clientBatchId, ')
          ..write('firstRecordedAt: $firstRecordedAt, ')
          ..write('lastRecordedAt: $lastRecordedAt, ')
          ..write('pointCount: $pointCount, ')
          ..write('pointsJson: $pointsJson, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('workerSessionId: $workerSessionId, ')
          ..write('lastError: $lastError, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackingCandidatesTable extends TrackingCandidates
    with TableInfo<$TrackingCandidatesTable, TrackingCandidateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackingCandidatesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fingerprintMeta =
      const VerificationMeta('fingerprint');
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
      'fingerprint', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _suggestedNameMeta =
      const VerificationMeta('suggestedName');
  @override
  late final GeneratedColumn<String> suggestedName = GeneratedColumn<String>(
      'suggested_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _suggestedLatitudeMeta =
      const VerificationMeta('suggestedLatitude');
  @override
  late final GeneratedColumn<double> suggestedLatitude =
      GeneratedColumn<double>('suggested_latitude', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _suggestedLongitudeMeta =
      const VerificationMeta('suggestedLongitude');
  @override
  late final GeneratedColumn<double> suggestedLongitude =
      GeneratedColumn<double>('suggested_longitude', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _confirmedTripPlaceIdMeta =
      const VerificationMeta('confirmedTripPlaceId');
  @override
  late final GeneratedColumn<String> confirmedTripPlaceId =
      GeneratedColumn<String>('confirmed_trip_place_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rejectedReasonMeta =
      const VerificationMeta('rejectedReason');
  @override
  late final GeneratedColumn<String> rejectedReason = GeneratedColumn<String>(
      'rejected_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _snoozedUntilMeta =
      const VerificationMeta('snoozedUntil');
  @override
  late final GeneratedColumn<DateTime> snoozedUntil = GeneratedColumn<DateTime>(
      'snoozed_until', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _cooldownUntilMeta =
      const VerificationMeta('cooldownUntil');
  @override
  late final GeneratedColumn<DateTime> cooldownUntil =
      GeneratedColumn<DateTime>('cooldown_until', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _notificationStateMeta =
      const VerificationMeta('notificationState');
  @override
  late final GeneratedColumn<String> notificationState =
      GeneratedColumn<String>('notification_state', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actionStateMeta =
      const VerificationMeta('actionState');
  @override
  late final GeneratedColumn<String> actionState = GeneratedColumn<String>(
      'action_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('none'));
  static const VerificationMeta _actionTypeMeta =
      const VerificationMeta('actionType');
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
      'action_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actionClientEventIdMeta =
      const VerificationMeta('actionClientEventId');
  @override
  late final GeneratedColumn<String> actionClientEventId =
      GeneratedColumn<String>('action_client_event_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actionQueuedAtMeta =
      const VerificationMeta('actionQueuedAt');
  @override
  late final GeneratedColumn<DateTime> actionQueuedAt =
      GeneratedColumn<DateTime>('action_queued_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _actionSyncedAtMeta =
      const VerificationMeta('actionSyncedAt');
  @override
  late final GeneratedColumn<DateTime> actionSyncedAt =
      GeneratedColumn<DateTime>('action_synced_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
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
      GeneratedColumn<DateTime>('server_updated_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
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
        tripId,
        sessionId,
        fingerprint,
        status,
        confidence,
        suggestedName,
        suggestedLatitude,
        suggestedLongitude,
        startedAt,
        endedAt,
        confirmedTripPlaceId,
        rejectedReason,
        snoozedUntil,
        cooldownUntil,
        payloadJson,
        notificationState,
        actionState,
        actionType,
        actionClientEventId,
        actionQueuedAt,
        actionSyncedAt,
        syncStatus,
        localUpdatedAt,
        serverUpdatedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracking_candidates';
  @override
  VerificationContext validateIntegrity(
      Insertable<TrackingCandidateRow> instance,
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
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
          _fingerprintMeta,
          fingerprint.isAcceptableOrUnknown(
              data['fingerprint']!, _fingerprintMeta));
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    }
    if (data.containsKey('suggested_name')) {
      context.handle(
          _suggestedNameMeta,
          suggestedName.isAcceptableOrUnknown(
              data['suggested_name']!, _suggestedNameMeta));
    }
    if (data.containsKey('suggested_latitude')) {
      context.handle(
          _suggestedLatitudeMeta,
          suggestedLatitude.isAcceptableOrUnknown(
              data['suggested_latitude']!, _suggestedLatitudeMeta));
    }
    if (data.containsKey('suggested_longitude')) {
      context.handle(
          _suggestedLongitudeMeta,
          suggestedLongitude.isAcceptableOrUnknown(
              data['suggested_longitude']!, _suggestedLongitudeMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('confirmed_trip_place_id')) {
      context.handle(
          _confirmedTripPlaceIdMeta,
          confirmedTripPlaceId.isAcceptableOrUnknown(
              data['confirmed_trip_place_id']!, _confirmedTripPlaceIdMeta));
    }
    if (data.containsKey('rejected_reason')) {
      context.handle(
          _rejectedReasonMeta,
          rejectedReason.isAcceptableOrUnknown(
              data['rejected_reason']!, _rejectedReasonMeta));
    }
    if (data.containsKey('snoozed_until')) {
      context.handle(
          _snoozedUntilMeta,
          snoozedUntil.isAcceptableOrUnknown(
              data['snoozed_until']!, _snoozedUntilMeta));
    }
    if (data.containsKey('cooldown_until')) {
      context.handle(
          _cooldownUntilMeta,
          cooldownUntil.isAcceptableOrUnknown(
              data['cooldown_until']!, _cooldownUntilMeta));
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    }
    if (data.containsKey('notification_state')) {
      context.handle(
          _notificationStateMeta,
          notificationState.isAcceptableOrUnknown(
              data['notification_state']!, _notificationStateMeta));
    }
    if (data.containsKey('action_state')) {
      context.handle(
          _actionStateMeta,
          actionState.isAcceptableOrUnknown(
              data['action_state']!, _actionStateMeta));
    }
    if (data.containsKey('action_type')) {
      context.handle(
          _actionTypeMeta,
          actionType.isAcceptableOrUnknown(
              data['action_type']!, _actionTypeMeta));
    }
    if (data.containsKey('action_client_event_id')) {
      context.handle(
          _actionClientEventIdMeta,
          actionClientEventId.isAcceptableOrUnknown(
              data['action_client_event_id']!, _actionClientEventIdMeta));
    }
    if (data.containsKey('action_queued_at')) {
      context.handle(
          _actionQueuedAtMeta,
          actionQueuedAt.isAcceptableOrUnknown(
              data['action_queued_at']!, _actionQueuedAtMeta));
    }
    if (data.containsKey('action_synced_at')) {
      context.handle(
          _actionSyncedAtMeta,
          actionSyncedAt.isAcceptableOrUnknown(
              data['action_synced_at']!, _actionSyncedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
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
  TrackingCandidateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackingCandidateRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tripId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trip_id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id']),
      fingerprint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fingerprint'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence']),
      suggestedName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}suggested_name']),
      suggestedLatitude: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}suggested_latitude']),
      suggestedLongitude: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}suggested_longitude']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at']),
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ended_at']),
      confirmedTripPlaceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}confirmed_trip_place_id']),
      rejectedReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rejected_reason']),
      snoozedUntil: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}snoozed_until']),
      cooldownUntil: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}cooldown_until']),
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      notificationState: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}notification_state']),
      actionState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_state'])!,
      actionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_type']),
      actionClientEventId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}action_client_event_id']),
      actionQueuedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}action_queued_at']),
      actionSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}action_synced_at']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}server_updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TrackingCandidatesTable createAlias(String alias) {
    return $TrackingCandidatesTable(attachedDatabase, alias);
  }
}

class TrackingCandidateRow extends DataClass
    implements Insertable<TrackingCandidateRow> {
  final String id;
  final String tripId;
  final String? sessionId;
  final String fingerprint;
  final String status;
  final double? confidence;
  final String? suggestedName;
  final double? suggestedLatitude;
  final double? suggestedLongitude;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? confirmedTripPlaceId;
  final String? rejectedReason;
  final DateTime? snoozedUntil;
  final DateTime? cooldownUntil;
  final String payloadJson;
  final String? notificationState;
  final String actionState;
  final String? actionType;
  final String? actionClientEventId;
  final DateTime? actionQueuedAt;
  final DateTime? actionSyncedAt;
  final String syncStatus;
  final DateTime localUpdatedAt;
  final DateTime? serverUpdatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TrackingCandidateRow(
      {required this.id,
      required this.tripId,
      this.sessionId,
      required this.fingerprint,
      required this.status,
      this.confidence,
      this.suggestedName,
      this.suggestedLatitude,
      this.suggestedLongitude,
      this.startedAt,
      this.endedAt,
      this.confirmedTripPlaceId,
      this.rejectedReason,
      this.snoozedUntil,
      this.cooldownUntil,
      required this.payloadJson,
      this.notificationState,
      required this.actionState,
      this.actionType,
      this.actionClientEventId,
      this.actionQueuedAt,
      this.actionSyncedAt,
      required this.syncStatus,
      required this.localUpdatedAt,
      this.serverUpdatedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    map['fingerprint'] = Variable<String>(fingerprint);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || suggestedName != null) {
      map['suggested_name'] = Variable<String>(suggestedName);
    }
    if (!nullToAbsent || suggestedLatitude != null) {
      map['suggested_latitude'] = Variable<double>(suggestedLatitude);
    }
    if (!nullToAbsent || suggestedLongitude != null) {
      map['suggested_longitude'] = Variable<double>(suggestedLongitude);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || confirmedTripPlaceId != null) {
      map['confirmed_trip_place_id'] = Variable<String>(confirmedTripPlaceId);
    }
    if (!nullToAbsent || rejectedReason != null) {
      map['rejected_reason'] = Variable<String>(rejectedReason);
    }
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil);
    }
    if (!nullToAbsent || cooldownUntil != null) {
      map['cooldown_until'] = Variable<DateTime>(cooldownUntil);
    }
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || notificationState != null) {
      map['notification_state'] = Variable<String>(notificationState);
    }
    map['action_state'] = Variable<String>(actionState);
    if (!nullToAbsent || actionType != null) {
      map['action_type'] = Variable<String>(actionType);
    }
    if (!nullToAbsent || actionClientEventId != null) {
      map['action_client_event_id'] = Variable<String>(actionClientEventId);
    }
    if (!nullToAbsent || actionQueuedAt != null) {
      map['action_queued_at'] = Variable<DateTime>(actionQueuedAt);
    }
    if (!nullToAbsent || actionSyncedAt != null) {
      map['action_synced_at'] = Variable<DateTime>(actionSyncedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TrackingCandidatesCompanion toCompanion(bool nullToAbsent) {
    return TrackingCandidatesCompanion(
      id: Value(id),
      tripId: Value(tripId),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      fingerprint: Value(fingerprint),
      status: Value(status),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      suggestedName: suggestedName == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedName),
      suggestedLatitude: suggestedLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedLatitude),
      suggestedLongitude: suggestedLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedLongitude),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      confirmedTripPlaceId: confirmedTripPlaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(confirmedTripPlaceId),
      rejectedReason: rejectedReason == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectedReason),
      snoozedUntil: snoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntil),
      cooldownUntil: cooldownUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(cooldownUntil),
      payloadJson: Value(payloadJson),
      notificationState: notificationState == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationState),
      actionState: Value(actionState),
      actionType: actionType == null && nullToAbsent
          ? const Value.absent()
          : Value(actionType),
      actionClientEventId: actionClientEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(actionClientEventId),
      actionQueuedAt: actionQueuedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(actionQueuedAt),
      actionSyncedAt: actionSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(actionSyncedAt),
      syncStatus: Value(syncStatus),
      localUpdatedAt: Value(localUpdatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TrackingCandidateRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackingCandidateRow(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      status: serializer.fromJson<String>(json['status']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      suggestedName: serializer.fromJson<String?>(json['suggestedName']),
      suggestedLatitude:
          serializer.fromJson<double?>(json['suggestedLatitude']),
      suggestedLongitude:
          serializer.fromJson<double?>(json['suggestedLongitude']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      confirmedTripPlaceId:
          serializer.fromJson<String?>(json['confirmedTripPlaceId']),
      rejectedReason: serializer.fromJson<String?>(json['rejectedReason']),
      snoozedUntil: serializer.fromJson<DateTime?>(json['snoozedUntil']),
      cooldownUntil: serializer.fromJson<DateTime?>(json['cooldownUntil']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      notificationState:
          serializer.fromJson<String?>(json['notificationState']),
      actionState: serializer.fromJson<String>(json['actionState']),
      actionType: serializer.fromJson<String?>(json['actionType']),
      actionClientEventId:
          serializer.fromJson<String?>(json['actionClientEventId']),
      actionQueuedAt: serializer.fromJson<DateTime?>(json['actionQueuedAt']),
      actionSyncedAt: serializer.fromJson<DateTime?>(json['actionSyncedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'sessionId': serializer.toJson<String?>(sessionId),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'status': serializer.toJson<String>(status),
      'confidence': serializer.toJson<double?>(confidence),
      'suggestedName': serializer.toJson<String?>(suggestedName),
      'suggestedLatitude': serializer.toJson<double?>(suggestedLatitude),
      'suggestedLongitude': serializer.toJson<double?>(suggestedLongitude),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'confirmedTripPlaceId': serializer.toJson<String?>(confirmedTripPlaceId),
      'rejectedReason': serializer.toJson<String?>(rejectedReason),
      'snoozedUntil': serializer.toJson<DateTime?>(snoozedUntil),
      'cooldownUntil': serializer.toJson<DateTime?>(cooldownUntil),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'notificationState': serializer.toJson<String?>(notificationState),
      'actionState': serializer.toJson<String>(actionState),
      'actionType': serializer.toJson<String?>(actionType),
      'actionClientEventId': serializer.toJson<String?>(actionClientEventId),
      'actionQueuedAt': serializer.toJson<DateTime?>(actionQueuedAt),
      'actionSyncedAt': serializer.toJson<DateTime?>(actionSyncedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TrackingCandidateRow copyWith(
          {String? id,
          String? tripId,
          Value<String?> sessionId = const Value.absent(),
          String? fingerprint,
          String? status,
          Value<double?> confidence = const Value.absent(),
          Value<String?> suggestedName = const Value.absent(),
          Value<double?> suggestedLatitude = const Value.absent(),
          Value<double?> suggestedLongitude = const Value.absent(),
          Value<DateTime?> startedAt = const Value.absent(),
          Value<DateTime?> endedAt = const Value.absent(),
          Value<String?> confirmedTripPlaceId = const Value.absent(),
          Value<String?> rejectedReason = const Value.absent(),
          Value<DateTime?> snoozedUntil = const Value.absent(),
          Value<DateTime?> cooldownUntil = const Value.absent(),
          String? payloadJson,
          Value<String?> notificationState = const Value.absent(),
          String? actionState,
          Value<String?> actionType = const Value.absent(),
          Value<String?> actionClientEventId = const Value.absent(),
          Value<DateTime?> actionQueuedAt = const Value.absent(),
          Value<DateTime?> actionSyncedAt = const Value.absent(),
          String? syncStatus,
          DateTime? localUpdatedAt,
          Value<DateTime?> serverUpdatedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      TrackingCandidateRow(
        id: id ?? this.id,
        tripId: tripId ?? this.tripId,
        sessionId: sessionId.present ? sessionId.value : this.sessionId,
        fingerprint: fingerprint ?? this.fingerprint,
        status: status ?? this.status,
        confidence: confidence.present ? confidence.value : this.confidence,
        suggestedName:
            suggestedName.present ? suggestedName.value : this.suggestedName,
        suggestedLatitude: suggestedLatitude.present
            ? suggestedLatitude.value
            : this.suggestedLatitude,
        suggestedLongitude: suggestedLongitude.present
            ? suggestedLongitude.value
            : this.suggestedLongitude,
        startedAt: startedAt.present ? startedAt.value : this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        confirmedTripPlaceId: confirmedTripPlaceId.present
            ? confirmedTripPlaceId.value
            : this.confirmedTripPlaceId,
        rejectedReason:
            rejectedReason.present ? rejectedReason.value : this.rejectedReason,
        snoozedUntil:
            snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
        cooldownUntil:
            cooldownUntil.present ? cooldownUntil.value : this.cooldownUntil,
        payloadJson: payloadJson ?? this.payloadJson,
        notificationState: notificationState.present
            ? notificationState.value
            : this.notificationState,
        actionState: actionState ?? this.actionState,
        actionType: actionType.present ? actionType.value : this.actionType,
        actionClientEventId: actionClientEventId.present
            ? actionClientEventId.value
            : this.actionClientEventId,
        actionQueuedAt:
            actionQueuedAt.present ? actionQueuedAt.value : this.actionQueuedAt,
        actionSyncedAt:
            actionSyncedAt.present ? actionSyncedAt.value : this.actionSyncedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        serverUpdatedAt: serverUpdatedAt.present
            ? serverUpdatedAt.value
            : this.serverUpdatedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TrackingCandidateRow copyWithCompanion(TrackingCandidatesCompanion data) {
    return TrackingCandidateRow(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      fingerprint:
          data.fingerprint.present ? data.fingerprint.value : this.fingerprint,
      status: data.status.present ? data.status.value : this.status,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      suggestedName: data.suggestedName.present
          ? data.suggestedName.value
          : this.suggestedName,
      suggestedLatitude: data.suggestedLatitude.present
          ? data.suggestedLatitude.value
          : this.suggestedLatitude,
      suggestedLongitude: data.suggestedLongitude.present
          ? data.suggestedLongitude.value
          : this.suggestedLongitude,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      confirmedTripPlaceId: data.confirmedTripPlaceId.present
          ? data.confirmedTripPlaceId.value
          : this.confirmedTripPlaceId,
      rejectedReason: data.rejectedReason.present
          ? data.rejectedReason.value
          : this.rejectedReason,
      snoozedUntil: data.snoozedUntil.present
          ? data.snoozedUntil.value
          : this.snoozedUntil,
      cooldownUntil: data.cooldownUntil.present
          ? data.cooldownUntil.value
          : this.cooldownUntil,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      notificationState: data.notificationState.present
          ? data.notificationState.value
          : this.notificationState,
      actionState:
          data.actionState.present ? data.actionState.value : this.actionState,
      actionType:
          data.actionType.present ? data.actionType.value : this.actionType,
      actionClientEventId: data.actionClientEventId.present
          ? data.actionClientEventId.value
          : this.actionClientEventId,
      actionQueuedAt: data.actionQueuedAt.present
          ? data.actionQueuedAt.value
          : this.actionQueuedAt,
      actionSyncedAt: data.actionSyncedAt.present
          ? data.actionSyncedAt.value
          : this.actionSyncedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackingCandidateRow(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('sessionId: $sessionId, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('status: $status, ')
          ..write('confidence: $confidence, ')
          ..write('suggestedName: $suggestedName, ')
          ..write('suggestedLatitude: $suggestedLatitude, ')
          ..write('suggestedLongitude: $suggestedLongitude, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('confirmedTripPlaceId: $confirmedTripPlaceId, ')
          ..write('rejectedReason: $rejectedReason, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('cooldownUntil: $cooldownUntil, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('notificationState: $notificationState, ')
          ..write('actionState: $actionState, ')
          ..write('actionType: $actionType, ')
          ..write('actionClientEventId: $actionClientEventId, ')
          ..write('actionQueuedAt: $actionQueuedAt, ')
          ..write('actionSyncedAt: $actionSyncedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        tripId,
        sessionId,
        fingerprint,
        status,
        confidence,
        suggestedName,
        suggestedLatitude,
        suggestedLongitude,
        startedAt,
        endedAt,
        confirmedTripPlaceId,
        rejectedReason,
        snoozedUntil,
        cooldownUntil,
        payloadJson,
        notificationState,
        actionState,
        actionType,
        actionClientEventId,
        actionQueuedAt,
        actionSyncedAt,
        syncStatus,
        localUpdatedAt,
        serverUpdatedAt,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackingCandidateRow &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.sessionId == this.sessionId &&
          other.fingerprint == this.fingerprint &&
          other.status == this.status &&
          other.confidence == this.confidence &&
          other.suggestedName == this.suggestedName &&
          other.suggestedLatitude == this.suggestedLatitude &&
          other.suggestedLongitude == this.suggestedLongitude &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.confirmedTripPlaceId == this.confirmedTripPlaceId &&
          other.rejectedReason == this.rejectedReason &&
          other.snoozedUntil == this.snoozedUntil &&
          other.cooldownUntil == this.cooldownUntil &&
          other.payloadJson == this.payloadJson &&
          other.notificationState == this.notificationState &&
          other.actionState == this.actionState &&
          other.actionType == this.actionType &&
          other.actionClientEventId == this.actionClientEventId &&
          other.actionQueuedAt == this.actionQueuedAt &&
          other.actionSyncedAt == this.actionSyncedAt &&
          other.syncStatus == this.syncStatus &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TrackingCandidatesCompanion
    extends UpdateCompanion<TrackingCandidateRow> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String?> sessionId;
  final Value<String> fingerprint;
  final Value<String> status;
  final Value<double?> confidence;
  final Value<String?> suggestedName;
  final Value<double?> suggestedLatitude;
  final Value<double?> suggestedLongitude;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String?> confirmedTripPlaceId;
  final Value<String?> rejectedReason;
  final Value<DateTime?> snoozedUntil;
  final Value<DateTime?> cooldownUntil;
  final Value<String> payloadJson;
  final Value<String?> notificationState;
  final Value<String> actionState;
  final Value<String?> actionType;
  final Value<String?> actionClientEventId;
  final Value<DateTime?> actionQueuedAt;
  final Value<DateTime?> actionSyncedAt;
  final Value<String> syncStatus;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime?> serverUpdatedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TrackingCandidatesCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.status = const Value.absent(),
    this.confidence = const Value.absent(),
    this.suggestedName = const Value.absent(),
    this.suggestedLatitude = const Value.absent(),
    this.suggestedLongitude = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.confirmedTripPlaceId = const Value.absent(),
    this.rejectedReason = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.cooldownUntil = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.notificationState = const Value.absent(),
    this.actionState = const Value.absent(),
    this.actionType = const Value.absent(),
    this.actionClientEventId = const Value.absent(),
    this.actionQueuedAt = const Value.absent(),
    this.actionSyncedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackingCandidatesCompanion.insert({
    required String id,
    required String tripId,
    this.sessionId = const Value.absent(),
    required String fingerprint,
    this.status = const Value.absent(),
    this.confidence = const Value.absent(),
    this.suggestedName = const Value.absent(),
    this.suggestedLatitude = const Value.absent(),
    this.suggestedLongitude = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.confirmedTripPlaceId = const Value.absent(),
    this.rejectedReason = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.cooldownUntil = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.notificationState = const Value.absent(),
    this.actionState = const Value.absent(),
    this.actionType = const Value.absent(),
    this.actionClientEventId = const Value.absent(),
    this.actionQueuedAt = const Value.absent(),
    this.actionSyncedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime localUpdatedAt,
    this.serverUpdatedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tripId = Value(tripId),
        fingerprint = Value(fingerprint),
        localUpdatedAt = Value(localUpdatedAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TrackingCandidateRow> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? sessionId,
    Expression<String>? fingerprint,
    Expression<String>? status,
    Expression<double>? confidence,
    Expression<String>? suggestedName,
    Expression<double>? suggestedLatitude,
    Expression<double>? suggestedLongitude,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? confirmedTripPlaceId,
    Expression<String>? rejectedReason,
    Expression<DateTime>? snoozedUntil,
    Expression<DateTime>? cooldownUntil,
    Expression<String>? payloadJson,
    Expression<String>? notificationState,
    Expression<String>? actionState,
    Expression<String>? actionType,
    Expression<String>? actionClientEventId,
    Expression<DateTime>? actionQueuedAt,
    Expression<DateTime>? actionSyncedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (sessionId != null) 'session_id': sessionId,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (status != null) 'status': status,
      if (confidence != null) 'confidence': confidence,
      if (suggestedName != null) 'suggested_name': suggestedName,
      if (suggestedLatitude != null) 'suggested_latitude': suggestedLatitude,
      if (suggestedLongitude != null) 'suggested_longitude': suggestedLongitude,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (confirmedTripPlaceId != null)
        'confirmed_trip_place_id': confirmedTripPlaceId,
      if (rejectedReason != null) 'rejected_reason': rejectedReason,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (cooldownUntil != null) 'cooldown_until': cooldownUntil,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (notificationState != null) 'notification_state': notificationState,
      if (actionState != null) 'action_state': actionState,
      if (actionType != null) 'action_type': actionType,
      if (actionClientEventId != null)
        'action_client_event_id': actionClientEventId,
      if (actionQueuedAt != null) 'action_queued_at': actionQueuedAt,
      if (actionSyncedAt != null) 'action_synced_at': actionSyncedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackingCandidatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? tripId,
      Value<String?>? sessionId,
      Value<String>? fingerprint,
      Value<String>? status,
      Value<double?>? confidence,
      Value<String?>? suggestedName,
      Value<double?>? suggestedLatitude,
      Value<double?>? suggestedLongitude,
      Value<DateTime?>? startedAt,
      Value<DateTime?>? endedAt,
      Value<String?>? confirmedTripPlaceId,
      Value<String?>? rejectedReason,
      Value<DateTime?>? snoozedUntil,
      Value<DateTime?>? cooldownUntil,
      Value<String>? payloadJson,
      Value<String?>? notificationState,
      Value<String>? actionState,
      Value<String?>? actionType,
      Value<String?>? actionClientEventId,
      Value<DateTime?>? actionQueuedAt,
      Value<DateTime?>? actionSyncedAt,
      Value<String>? syncStatus,
      Value<DateTime>? localUpdatedAt,
      Value<DateTime?>? serverUpdatedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return TrackingCandidatesCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      sessionId: sessionId ?? this.sessionId,
      fingerprint: fingerprint ?? this.fingerprint,
      status: status ?? this.status,
      confidence: confidence ?? this.confidence,
      suggestedName: suggestedName ?? this.suggestedName,
      suggestedLatitude: suggestedLatitude ?? this.suggestedLatitude,
      suggestedLongitude: suggestedLongitude ?? this.suggestedLongitude,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      confirmedTripPlaceId: confirmedTripPlaceId ?? this.confirmedTripPlaceId,
      rejectedReason: rejectedReason ?? this.rejectedReason,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      cooldownUntil: cooldownUntil ?? this.cooldownUntil,
      payloadJson: payloadJson ?? this.payloadJson,
      notificationState: notificationState ?? this.notificationState,
      actionState: actionState ?? this.actionState,
      actionType: actionType ?? this.actionType,
      actionClientEventId: actionClientEventId ?? this.actionClientEventId,
      actionQueuedAt: actionQueuedAt ?? this.actionQueuedAt,
      actionSyncedAt: actionSyncedAt ?? this.actionSyncedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
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
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (suggestedName.present) {
      map['suggested_name'] = Variable<String>(suggestedName.value);
    }
    if (suggestedLatitude.present) {
      map['suggested_latitude'] = Variable<double>(suggestedLatitude.value);
    }
    if (suggestedLongitude.present) {
      map['suggested_longitude'] = Variable<double>(suggestedLongitude.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (confirmedTripPlaceId.present) {
      map['confirmed_trip_place_id'] =
          Variable<String>(confirmedTripPlaceId.value);
    }
    if (rejectedReason.present) {
      map['rejected_reason'] = Variable<String>(rejectedReason.value);
    }
    if (snoozedUntil.present) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil.value);
    }
    if (cooldownUntil.present) {
      map['cooldown_until'] = Variable<DateTime>(cooldownUntil.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (notificationState.present) {
      map['notification_state'] = Variable<String>(notificationState.value);
    }
    if (actionState.present) {
      map['action_state'] = Variable<String>(actionState.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (actionClientEventId.present) {
      map['action_client_event_id'] =
          Variable<String>(actionClientEventId.value);
    }
    if (actionQueuedAt.present) {
      map['action_queued_at'] = Variable<DateTime>(actionQueuedAt.value);
    }
    if (actionSyncedAt.present) {
      map['action_synced_at'] = Variable<DateTime>(actionSyncedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
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
    return (StringBuffer('TrackingCandidatesCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('sessionId: $sessionId, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('status: $status, ')
          ..write('confidence: $confidence, ')
          ..write('suggestedName: $suggestedName, ')
          ..write('suggestedLatitude: $suggestedLatitude, ')
          ..write('suggestedLongitude: $suggestedLongitude, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('confirmedTripPlaceId: $confirmedTripPlaceId, ')
          ..write('rejectedReason: $rejectedReason, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('cooldownUntil: $cooldownUntil, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('notificationState: $notificationState, ')
          ..write('actionState: $actionState, ')
          ..write('actionType: $actionType, ')
          ..write('actionClientEventId: $actionClientEventId, ')
          ..write('actionQueuedAt: $actionQueuedAt, ')
          ..write('actionSyncedAt: $actionSyncedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackingMomentsTable extends TrackingMoments
    with TableInfo<$TrackingMomentsTable, TrackingMomentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackingMomentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _candidateIdMeta =
      const VerificationMeta('candidateId');
  @override
  late final GeneratedColumn<String> candidateId = GeneratedColumn<String>(
      'candidate_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _linkedTripPlaceIdMeta =
      const VerificationMeta('linkedTripPlaceId');
  @override
  late final GeneratedColumn<String> linkedTripPlaceId =
      GeneratedColumn<String>('linked_trip_place_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('manual'));
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _capturedAtMeta =
      const VerificationMeta('capturedAt');
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
      'captured_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mediaRefsJsonMeta =
      const VerificationMeta('mediaRefsJson');
  @override
  late final GeneratedColumn<String> mediaRefsJson = GeneratedColumn<String>(
      'media_refs_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _extraPayloadJsonMeta =
      const VerificationMeta('extraPayloadJson');
  @override
  late final GeneratedColumn<String> extraPayloadJson = GeneratedColumn<String>(
      'extra_payload_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _lockedFieldsJsonMeta =
      const VerificationMeta('lockedFieldsJson');
  @override
  late final GeneratedColumn<String> lockedFieldsJson = GeneratedColumn<String>(
      'locked_fields_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _pendingOperationMeta =
      const VerificationMeta('pendingOperation');
  @override
  late final GeneratedColumn<String> pendingOperation = GeneratedColumn<String>(
      'pending_operation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _clientEventIdMeta =
      const VerificationMeta('clientEventId');
  @override
  late final GeneratedColumn<String> clientEventId = GeneratedColumn<String>(
      'client_event_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
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
      GeneratedColumn<DateTime>('server_updated_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
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
        tripId,
        candidateId,
        linkedTripPlaceId,
        source,
        confidence,
        capturedAt,
        latitude,
        longitude,
        note,
        mediaRefsJson,
        extraPayloadJson,
        lockedFieldsJson,
        pendingOperation,
        clientEventId,
        syncStatus,
        localUpdatedAt,
        serverUpdatedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracking_moments';
  @override
  VerificationContext validateIntegrity(Insertable<TrackingMomentRow> instance,
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
    if (data.containsKey('candidate_id')) {
      context.handle(
          _candidateIdMeta,
          candidateId.isAcceptableOrUnknown(
              data['candidate_id']!, _candidateIdMeta));
    }
    if (data.containsKey('linked_trip_place_id')) {
      context.handle(
          _linkedTripPlaceIdMeta,
          linkedTripPlaceId.isAcceptableOrUnknown(
              data['linked_trip_place_id']!, _linkedTripPlaceIdMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    }
    if (data.containsKey('captured_at')) {
      context.handle(
          _capturedAtMeta,
          capturedAt.isAcceptableOrUnknown(
              data['captured_at']!, _capturedAtMeta));
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('media_refs_json')) {
      context.handle(
          _mediaRefsJsonMeta,
          mediaRefsJson.isAcceptableOrUnknown(
              data['media_refs_json']!, _mediaRefsJsonMeta));
    }
    if (data.containsKey('extra_payload_json')) {
      context.handle(
          _extraPayloadJsonMeta,
          extraPayloadJson.isAcceptableOrUnknown(
              data['extra_payload_json']!, _extraPayloadJsonMeta));
    }
    if (data.containsKey('locked_fields_json')) {
      context.handle(
          _lockedFieldsJsonMeta,
          lockedFieldsJson.isAcceptableOrUnknown(
              data['locked_fields_json']!, _lockedFieldsJsonMeta));
    }
    if (data.containsKey('pending_operation')) {
      context.handle(
          _pendingOperationMeta,
          pendingOperation.isAcceptableOrUnknown(
              data['pending_operation']!, _pendingOperationMeta));
    }
    if (data.containsKey('client_event_id')) {
      context.handle(
          _clientEventIdMeta,
          clientEventId.isAcceptableOrUnknown(
              data['client_event_id']!, _clientEventIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
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
  TrackingMomentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackingMomentRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tripId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trip_id'])!,
      candidateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}candidate_id']),
      linkedTripPlaceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}linked_trip_place_id']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence']),
      capturedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}captured_at'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      mediaRefsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}media_refs_json'])!,
      extraPayloadJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}extra_payload_json'])!,
      lockedFieldsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}locked_fields_json'])!,
      pendingOperation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}pending_operation']),
      clientEventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_event_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}server_updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TrackingMomentsTable createAlias(String alias) {
    return $TrackingMomentsTable(attachedDatabase, alias);
  }
}

class TrackingMomentRow extends DataClass
    implements Insertable<TrackingMomentRow> {
  final String id;
  final String tripId;
  final String? candidateId;
  final String? linkedTripPlaceId;
  final String source;
  final double? confidence;
  final DateTime capturedAt;
  final double? latitude;
  final double? longitude;
  final String? note;
  final String mediaRefsJson;
  final String extraPayloadJson;
  final String lockedFieldsJson;
  final String? pendingOperation;
  final String? clientEventId;
  final String syncStatus;
  final DateTime localUpdatedAt;
  final DateTime? serverUpdatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TrackingMomentRow(
      {required this.id,
      required this.tripId,
      this.candidateId,
      this.linkedTripPlaceId,
      required this.source,
      this.confidence,
      required this.capturedAt,
      this.latitude,
      this.longitude,
      this.note,
      required this.mediaRefsJson,
      required this.extraPayloadJson,
      required this.lockedFieldsJson,
      this.pendingOperation,
      this.clientEventId,
      required this.syncStatus,
      required this.localUpdatedAt,
      this.serverUpdatedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    if (!nullToAbsent || candidateId != null) {
      map['candidate_id'] = Variable<String>(candidateId);
    }
    if (!nullToAbsent || linkedTripPlaceId != null) {
      map['linked_trip_place_id'] = Variable<String>(linkedTripPlaceId);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['captured_at'] = Variable<DateTime>(capturedAt);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['media_refs_json'] = Variable<String>(mediaRefsJson);
    map['extra_payload_json'] = Variable<String>(extraPayloadJson);
    map['locked_fields_json'] = Variable<String>(lockedFieldsJson);
    if (!nullToAbsent || pendingOperation != null) {
      map['pending_operation'] = Variable<String>(pendingOperation);
    }
    if (!nullToAbsent || clientEventId != null) {
      map['client_event_id'] = Variable<String>(clientEventId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TrackingMomentsCompanion toCompanion(bool nullToAbsent) {
    return TrackingMomentsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      candidateId: candidateId == null && nullToAbsent
          ? const Value.absent()
          : Value(candidateId),
      linkedTripPlaceId: linkedTripPlaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedTripPlaceId),
      source: Value(source),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      capturedAt: Value(capturedAt),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      mediaRefsJson: Value(mediaRefsJson),
      extraPayloadJson: Value(extraPayloadJson),
      lockedFieldsJson: Value(lockedFieldsJson),
      pendingOperation: pendingOperation == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingOperation),
      clientEventId: clientEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientEventId),
      syncStatus: Value(syncStatus),
      localUpdatedAt: Value(localUpdatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TrackingMomentRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackingMomentRow(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      candidateId: serializer.fromJson<String?>(json['candidateId']),
      linkedTripPlaceId:
          serializer.fromJson<String?>(json['linkedTripPlaceId']),
      source: serializer.fromJson<String>(json['source']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      note: serializer.fromJson<String?>(json['note']),
      mediaRefsJson: serializer.fromJson<String>(json['mediaRefsJson']),
      extraPayloadJson: serializer.fromJson<String>(json['extraPayloadJson']),
      lockedFieldsJson: serializer.fromJson<String>(json['lockedFieldsJson']),
      pendingOperation: serializer.fromJson<String?>(json['pendingOperation']),
      clientEventId: serializer.fromJson<String?>(json['clientEventId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'candidateId': serializer.toJson<String?>(candidateId),
      'linkedTripPlaceId': serializer.toJson<String?>(linkedTripPlaceId),
      'source': serializer.toJson<String>(source),
      'confidence': serializer.toJson<double?>(confidence),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'note': serializer.toJson<String?>(note),
      'mediaRefsJson': serializer.toJson<String>(mediaRefsJson),
      'extraPayloadJson': serializer.toJson<String>(extraPayloadJson),
      'lockedFieldsJson': serializer.toJson<String>(lockedFieldsJson),
      'pendingOperation': serializer.toJson<String?>(pendingOperation),
      'clientEventId': serializer.toJson<String?>(clientEventId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TrackingMomentRow copyWith(
          {String? id,
          String? tripId,
          Value<String?> candidateId = const Value.absent(),
          Value<String?> linkedTripPlaceId = const Value.absent(),
          String? source,
          Value<double?> confidence = const Value.absent(),
          DateTime? capturedAt,
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          Value<String?> note = const Value.absent(),
          String? mediaRefsJson,
          String? extraPayloadJson,
          String? lockedFieldsJson,
          Value<String?> pendingOperation = const Value.absent(),
          Value<String?> clientEventId = const Value.absent(),
          String? syncStatus,
          DateTime? localUpdatedAt,
          Value<DateTime?> serverUpdatedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      TrackingMomentRow(
        id: id ?? this.id,
        tripId: tripId ?? this.tripId,
        candidateId: candidateId.present ? candidateId.value : this.candidateId,
        linkedTripPlaceId: linkedTripPlaceId.present
            ? linkedTripPlaceId.value
            : this.linkedTripPlaceId,
        source: source ?? this.source,
        confidence: confidence.present ? confidence.value : this.confidence,
        capturedAt: capturedAt ?? this.capturedAt,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        note: note.present ? note.value : this.note,
        mediaRefsJson: mediaRefsJson ?? this.mediaRefsJson,
        extraPayloadJson: extraPayloadJson ?? this.extraPayloadJson,
        lockedFieldsJson: lockedFieldsJson ?? this.lockedFieldsJson,
        pendingOperation: pendingOperation.present
            ? pendingOperation.value
            : this.pendingOperation,
        clientEventId:
            clientEventId.present ? clientEventId.value : this.clientEventId,
        syncStatus: syncStatus ?? this.syncStatus,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        serverUpdatedAt: serverUpdatedAt.present
            ? serverUpdatedAt.value
            : this.serverUpdatedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TrackingMomentRow copyWithCompanion(TrackingMomentsCompanion data) {
    return TrackingMomentRow(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      candidateId:
          data.candidateId.present ? data.candidateId.value : this.candidateId,
      linkedTripPlaceId: data.linkedTripPlaceId.present
          ? data.linkedTripPlaceId.value
          : this.linkedTripPlaceId,
      source: data.source.present ? data.source.value : this.source,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      capturedAt:
          data.capturedAt.present ? data.capturedAt.value : this.capturedAt,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      note: data.note.present ? data.note.value : this.note,
      mediaRefsJson: data.mediaRefsJson.present
          ? data.mediaRefsJson.value
          : this.mediaRefsJson,
      extraPayloadJson: data.extraPayloadJson.present
          ? data.extraPayloadJson.value
          : this.extraPayloadJson,
      lockedFieldsJson: data.lockedFieldsJson.present
          ? data.lockedFieldsJson.value
          : this.lockedFieldsJson,
      pendingOperation: data.pendingOperation.present
          ? data.pendingOperation.value
          : this.pendingOperation,
      clientEventId: data.clientEventId.present
          ? data.clientEventId.value
          : this.clientEventId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackingMomentRow(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('candidateId: $candidateId, ')
          ..write('linkedTripPlaceId: $linkedTripPlaceId, ')
          ..write('source: $source, ')
          ..write('confidence: $confidence, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('note: $note, ')
          ..write('mediaRefsJson: $mediaRefsJson, ')
          ..write('extraPayloadJson: $extraPayloadJson, ')
          ..write('lockedFieldsJson: $lockedFieldsJson, ')
          ..write('pendingOperation: $pendingOperation, ')
          ..write('clientEventId: $clientEventId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tripId,
      candidateId,
      linkedTripPlaceId,
      source,
      confidence,
      capturedAt,
      latitude,
      longitude,
      note,
      mediaRefsJson,
      extraPayloadJson,
      lockedFieldsJson,
      pendingOperation,
      clientEventId,
      syncStatus,
      localUpdatedAt,
      serverUpdatedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackingMomentRow &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.candidateId == this.candidateId &&
          other.linkedTripPlaceId == this.linkedTripPlaceId &&
          other.source == this.source &&
          other.confidence == this.confidence &&
          other.capturedAt == this.capturedAt &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.note == this.note &&
          other.mediaRefsJson == this.mediaRefsJson &&
          other.extraPayloadJson == this.extraPayloadJson &&
          other.lockedFieldsJson == this.lockedFieldsJson &&
          other.pendingOperation == this.pendingOperation &&
          other.clientEventId == this.clientEventId &&
          other.syncStatus == this.syncStatus &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TrackingMomentsCompanion extends UpdateCompanion<TrackingMomentRow> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String?> candidateId;
  final Value<String?> linkedTripPlaceId;
  final Value<String> source;
  final Value<double?> confidence;
  final Value<DateTime> capturedAt;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> note;
  final Value<String> mediaRefsJson;
  final Value<String> extraPayloadJson;
  final Value<String> lockedFieldsJson;
  final Value<String?> pendingOperation;
  final Value<String?> clientEventId;
  final Value<String> syncStatus;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime?> serverUpdatedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TrackingMomentsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.candidateId = const Value.absent(),
    this.linkedTripPlaceId = const Value.absent(),
    this.source = const Value.absent(),
    this.confidence = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.note = const Value.absent(),
    this.mediaRefsJson = const Value.absent(),
    this.extraPayloadJson = const Value.absent(),
    this.lockedFieldsJson = const Value.absent(),
    this.pendingOperation = const Value.absent(),
    this.clientEventId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackingMomentsCompanion.insert({
    required String id,
    required String tripId,
    this.candidateId = const Value.absent(),
    this.linkedTripPlaceId = const Value.absent(),
    this.source = const Value.absent(),
    this.confidence = const Value.absent(),
    required DateTime capturedAt,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.note = const Value.absent(),
    this.mediaRefsJson = const Value.absent(),
    this.extraPayloadJson = const Value.absent(),
    this.lockedFieldsJson = const Value.absent(),
    this.pendingOperation = const Value.absent(),
    this.clientEventId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime localUpdatedAt,
    this.serverUpdatedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tripId = Value(tripId),
        capturedAt = Value(capturedAt),
        localUpdatedAt = Value(localUpdatedAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TrackingMomentRow> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? candidateId,
    Expression<String>? linkedTripPlaceId,
    Expression<String>? source,
    Expression<double>? confidence,
    Expression<DateTime>? capturedAt,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? note,
    Expression<String>? mediaRefsJson,
    Expression<String>? extraPayloadJson,
    Expression<String>? lockedFieldsJson,
    Expression<String>? pendingOperation,
    Expression<String>? clientEventId,
    Expression<String>? syncStatus,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (candidateId != null) 'candidate_id': candidateId,
      if (linkedTripPlaceId != null) 'linked_trip_place_id': linkedTripPlaceId,
      if (source != null) 'source': source,
      if (confidence != null) 'confidence': confidence,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (note != null) 'note': note,
      if (mediaRefsJson != null) 'media_refs_json': mediaRefsJson,
      if (extraPayloadJson != null) 'extra_payload_json': extraPayloadJson,
      if (lockedFieldsJson != null) 'locked_fields_json': lockedFieldsJson,
      if (pendingOperation != null) 'pending_operation': pendingOperation,
      if (clientEventId != null) 'client_event_id': clientEventId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackingMomentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tripId,
      Value<String?>? candidateId,
      Value<String?>? linkedTripPlaceId,
      Value<String>? source,
      Value<double?>? confidence,
      Value<DateTime>? capturedAt,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<String?>? note,
      Value<String>? mediaRefsJson,
      Value<String>? extraPayloadJson,
      Value<String>? lockedFieldsJson,
      Value<String?>? pendingOperation,
      Value<String?>? clientEventId,
      Value<String>? syncStatus,
      Value<DateTime>? localUpdatedAt,
      Value<DateTime?>? serverUpdatedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return TrackingMomentsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      candidateId: candidateId ?? this.candidateId,
      linkedTripPlaceId: linkedTripPlaceId ?? this.linkedTripPlaceId,
      source: source ?? this.source,
      confidence: confidence ?? this.confidence,
      capturedAt: capturedAt ?? this.capturedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      note: note ?? this.note,
      mediaRefsJson: mediaRefsJson ?? this.mediaRefsJson,
      extraPayloadJson: extraPayloadJson ?? this.extraPayloadJson,
      lockedFieldsJson: lockedFieldsJson ?? this.lockedFieldsJson,
      pendingOperation: pendingOperation ?? this.pendingOperation,
      clientEventId: clientEventId ?? this.clientEventId,
      syncStatus: syncStatus ?? this.syncStatus,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
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
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (candidateId.present) {
      map['candidate_id'] = Variable<String>(candidateId.value);
    }
    if (linkedTripPlaceId.present) {
      map['linked_trip_place_id'] = Variable<String>(linkedTripPlaceId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (mediaRefsJson.present) {
      map['media_refs_json'] = Variable<String>(mediaRefsJson.value);
    }
    if (extraPayloadJson.present) {
      map['extra_payload_json'] = Variable<String>(extraPayloadJson.value);
    }
    if (lockedFieldsJson.present) {
      map['locked_fields_json'] = Variable<String>(lockedFieldsJson.value);
    }
    if (pendingOperation.present) {
      map['pending_operation'] = Variable<String>(pendingOperation.value);
    }
    if (clientEventId.present) {
      map['client_event_id'] = Variable<String>(clientEventId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
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
    return (StringBuffer('TrackingMomentsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('candidateId: $candidateId, ')
          ..write('linkedTripPlaceId: $linkedTripPlaceId, ')
          ..write('source: $source, ')
          ..write('confidence: $confidence, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('note: $note, ')
          ..write('mediaRefsJson: $mediaRefsJson, ')
          ..write('extraPayloadJson: $extraPayloadJson, ')
          ..write('lockedFieldsJson: $lockedFieldsJson, ')
          ..write('pendingOperation: $pendingOperation, ')
          ..write('clientEventId: $clientEventId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackingEventsTable extends TrackingEvents
    with TableInfo<$TrackingEventsTable, TrackingEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackingEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _clientEventIdMeta =
      const VerificationMeta('clientEventId');
  @override
  late final GeneratedColumn<String> clientEventId = GeneratedColumn<String>(
      'client_event_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resolvedPlaceIdMeta =
      const VerificationMeta('resolvedPlaceId');
  @override
  late final GeneratedColumn<String> resolvedPlaceId = GeneratedColumn<String>(
      'resolved_place_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bindConfidenceMeta =
      const VerificationMeta('bindConfidence');
  @override
  late final GeneratedColumn<double> bindConfidence = GeneratedColumn<double>(
      'bind_confidence', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _resolverReasonCodeMeta =
      const VerificationMeta('resolverReasonCode');
  @override
  late final GeneratedColumn<String> resolverReasonCode =
      GeneratedColumn<String>('resolver_reason_code', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resolverStateMeta =
      const VerificationMeta('resolverState');
  @override
  late final GeneratedColumn<String> resolverState = GeneratedColumn<String>(
      'resolver_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('on_route_unresolved'));
  static const VerificationMeta _resolverVersionMeta =
      const VerificationMeta('resolverVersion');
  @override
  late final GeneratedColumn<int> resolverVersion = GeneratedColumn<int>(
      'resolver_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _resolvedAtMeta =
      const VerificationMeta('resolvedAt');
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
      'resolved_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _resolutionHintJsonMeta =
      const VerificationMeta('resolutionHintJson');
  @override
  late final GeneratedColumn<String> resolutionHintJson =
      GeneratedColumn<String>('resolution_hint_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local_only'));
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
      GeneratedColumn<DateTime>('server_updated_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
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
        tripId,
        eventType,
        note,
        latitude,
        longitude,
        payloadJson,
        clientEventId,
        resolvedPlaceId,
        bindConfidence,
        resolverReasonCode,
        resolverState,
        resolverVersion,
        resolvedAt,
        resolutionHintJson,
        syncStatus,
        localUpdatedAt,
        serverUpdatedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracking_events';
  @override
  VerificationContext validateIntegrity(Insertable<TrackingEventRow> instance,
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
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    }
    if (data.containsKey('client_event_id')) {
      context.handle(
          _clientEventIdMeta,
          clientEventId.isAcceptableOrUnknown(
              data['client_event_id']!, _clientEventIdMeta));
    }
    if (data.containsKey('resolved_place_id')) {
      context.handle(
          _resolvedPlaceIdMeta,
          resolvedPlaceId.isAcceptableOrUnknown(
              data['resolved_place_id']!, _resolvedPlaceIdMeta));
    }
    if (data.containsKey('bind_confidence')) {
      context.handle(
          _bindConfidenceMeta,
          bindConfidence.isAcceptableOrUnknown(
              data['bind_confidence']!, _bindConfidenceMeta));
    }
    if (data.containsKey('resolver_reason_code')) {
      context.handle(
          _resolverReasonCodeMeta,
          resolverReasonCode.isAcceptableOrUnknown(
              data['resolver_reason_code']!, _resolverReasonCodeMeta));
    }
    if (data.containsKey('resolver_state')) {
      context.handle(
          _resolverStateMeta,
          resolverState.isAcceptableOrUnknown(
              data['resolver_state']!, _resolverStateMeta));
    }
    if (data.containsKey('resolver_version')) {
      context.handle(
          _resolverVersionMeta,
          resolverVersion.isAcceptableOrUnknown(
              data['resolver_version']!, _resolverVersionMeta));
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
          _resolvedAtMeta,
          resolvedAt.isAcceptableOrUnknown(
              data['resolved_at']!, _resolvedAtMeta));
    }
    if (data.containsKey('resolution_hint_json')) {
      context.handle(
          _resolutionHintJsonMeta,
          resolutionHintJson.isAcceptableOrUnknown(
              data['resolution_hint_json']!, _resolutionHintJsonMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
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
  TrackingEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackingEventRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tripId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trip_id'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      clientEventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_event_id']),
      resolvedPlaceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}resolved_place_id']),
      bindConfidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bind_confidence']),
      resolverReasonCode: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}resolver_reason_code']),
      resolverState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}resolver_state'])!,
      resolverVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}resolver_version'])!,
      resolvedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}resolved_at']),
      resolutionHintJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}resolution_hint_json']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}server_updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TrackingEventsTable createAlias(String alias) {
    return $TrackingEventsTable(attachedDatabase, alias);
  }
}

class TrackingEventRow extends DataClass
    implements Insertable<TrackingEventRow> {
  final String id;
  final String tripId;
  final String eventType;
  final String? note;
  final double? latitude;
  final double? longitude;
  final String payloadJson;
  final String? clientEventId;
  final String? resolvedPlaceId;
  final double? bindConfidence;
  final String? resolverReasonCode;
  final String resolverState;
  final int resolverVersion;
  final DateTime? resolvedAt;
  final String? resolutionHintJson;
  final String syncStatus;
  final DateTime localUpdatedAt;
  final DateTime? serverUpdatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TrackingEventRow(
      {required this.id,
      required this.tripId,
      required this.eventType,
      this.note,
      this.latitude,
      this.longitude,
      required this.payloadJson,
      this.clientEventId,
      this.resolvedPlaceId,
      this.bindConfidence,
      this.resolverReasonCode,
      required this.resolverState,
      required this.resolverVersion,
      this.resolvedAt,
      this.resolutionHintJson,
      required this.syncStatus,
      required this.localUpdatedAt,
      this.serverUpdatedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || clientEventId != null) {
      map['client_event_id'] = Variable<String>(clientEventId);
    }
    if (!nullToAbsent || resolvedPlaceId != null) {
      map['resolved_place_id'] = Variable<String>(resolvedPlaceId);
    }
    if (!nullToAbsent || bindConfidence != null) {
      map['bind_confidence'] = Variable<double>(bindConfidence);
    }
    if (!nullToAbsent || resolverReasonCode != null) {
      map['resolver_reason_code'] = Variable<String>(resolverReasonCode);
    }
    map['resolver_state'] = Variable<String>(resolverState);
    map['resolver_version'] = Variable<int>(resolverVersion);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    if (!nullToAbsent || resolutionHintJson != null) {
      map['resolution_hint_json'] = Variable<String>(resolutionHintJson);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TrackingEventsCompanion toCompanion(bool nullToAbsent) {
    return TrackingEventsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      eventType: Value(eventType),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      payloadJson: Value(payloadJson),
      clientEventId: clientEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientEventId),
      resolvedPlaceId: resolvedPlaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedPlaceId),
      bindConfidence: bindConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(bindConfidence),
      resolverReasonCode: resolverReasonCode == null && nullToAbsent
          ? const Value.absent()
          : Value(resolverReasonCode),
      resolverState: Value(resolverState),
      resolverVersion: Value(resolverVersion),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      resolutionHintJson: resolutionHintJson == null && nullToAbsent
          ? const Value.absent()
          : Value(resolutionHintJson),
      syncStatus: Value(syncStatus),
      localUpdatedAt: Value(localUpdatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TrackingEventRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackingEventRow(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      note: serializer.fromJson<String?>(json['note']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      clientEventId: serializer.fromJson<String?>(json['clientEventId']),
      resolvedPlaceId: serializer.fromJson<String?>(json['resolvedPlaceId']),
      bindConfidence: serializer.fromJson<double?>(json['bindConfidence']),
      resolverReasonCode:
          serializer.fromJson<String?>(json['resolverReasonCode']),
      resolverState: serializer.fromJson<String>(json['resolverState']),
      resolverVersion: serializer.fromJson<int>(json['resolverVersion']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      resolutionHintJson:
          serializer.fromJson<String?>(json['resolutionHintJson']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'eventType': serializer.toJson<String>(eventType),
      'note': serializer.toJson<String?>(note),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'clientEventId': serializer.toJson<String?>(clientEventId),
      'resolvedPlaceId': serializer.toJson<String?>(resolvedPlaceId),
      'bindConfidence': serializer.toJson<double?>(bindConfidence),
      'resolverReasonCode': serializer.toJson<String?>(resolverReasonCode),
      'resolverState': serializer.toJson<String>(resolverState),
      'resolverVersion': serializer.toJson<int>(resolverVersion),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'resolutionHintJson': serializer.toJson<String?>(resolutionHintJson),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TrackingEventRow copyWith(
          {String? id,
          String? tripId,
          String? eventType,
          Value<String?> note = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          String? payloadJson,
          Value<String?> clientEventId = const Value.absent(),
          Value<String?> resolvedPlaceId = const Value.absent(),
          Value<double?> bindConfidence = const Value.absent(),
          Value<String?> resolverReasonCode = const Value.absent(),
          String? resolverState,
          int? resolverVersion,
          Value<DateTime?> resolvedAt = const Value.absent(),
          Value<String?> resolutionHintJson = const Value.absent(),
          String? syncStatus,
          DateTime? localUpdatedAt,
          Value<DateTime?> serverUpdatedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      TrackingEventRow(
        id: id ?? this.id,
        tripId: tripId ?? this.tripId,
        eventType: eventType ?? this.eventType,
        note: note.present ? note.value : this.note,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        payloadJson: payloadJson ?? this.payloadJson,
        clientEventId:
            clientEventId.present ? clientEventId.value : this.clientEventId,
        resolvedPlaceId: resolvedPlaceId.present
            ? resolvedPlaceId.value
            : this.resolvedPlaceId,
        bindConfidence:
            bindConfidence.present ? bindConfidence.value : this.bindConfidence,
        resolverReasonCode: resolverReasonCode.present
            ? resolverReasonCode.value
            : this.resolverReasonCode,
        resolverState: resolverState ?? this.resolverState,
        resolverVersion: resolverVersion ?? this.resolverVersion,
        resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
        resolutionHintJson: resolutionHintJson.present
            ? resolutionHintJson.value
            : this.resolutionHintJson,
        syncStatus: syncStatus ?? this.syncStatus,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        serverUpdatedAt: serverUpdatedAt.present
            ? serverUpdatedAt.value
            : this.serverUpdatedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TrackingEventRow copyWithCompanion(TrackingEventsCompanion data) {
    return TrackingEventRow(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      note: data.note.present ? data.note.value : this.note,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      clientEventId: data.clientEventId.present
          ? data.clientEventId.value
          : this.clientEventId,
      resolvedPlaceId: data.resolvedPlaceId.present
          ? data.resolvedPlaceId.value
          : this.resolvedPlaceId,
      bindConfidence: data.bindConfidence.present
          ? data.bindConfidence.value
          : this.bindConfidence,
      resolverReasonCode: data.resolverReasonCode.present
          ? data.resolverReasonCode.value
          : this.resolverReasonCode,
      resolverState: data.resolverState.present
          ? data.resolverState.value
          : this.resolverState,
      resolverVersion: data.resolverVersion.present
          ? data.resolverVersion.value
          : this.resolverVersion,
      resolvedAt:
          data.resolvedAt.present ? data.resolvedAt.value : this.resolvedAt,
      resolutionHintJson: data.resolutionHintJson.present
          ? data.resolutionHintJson.value
          : this.resolutionHintJson,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackingEventRow(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('eventType: $eventType, ')
          ..write('note: $note, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('clientEventId: $clientEventId, ')
          ..write('resolvedPlaceId: $resolvedPlaceId, ')
          ..write('bindConfidence: $bindConfidence, ')
          ..write('resolverReasonCode: $resolverReasonCode, ')
          ..write('resolverState: $resolverState, ')
          ..write('resolverVersion: $resolverVersion, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolutionHintJson: $resolutionHintJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tripId,
      eventType,
      note,
      latitude,
      longitude,
      payloadJson,
      clientEventId,
      resolvedPlaceId,
      bindConfidence,
      resolverReasonCode,
      resolverState,
      resolverVersion,
      resolvedAt,
      resolutionHintJson,
      syncStatus,
      localUpdatedAt,
      serverUpdatedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackingEventRow &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.eventType == this.eventType &&
          other.note == this.note &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.payloadJson == this.payloadJson &&
          other.clientEventId == this.clientEventId &&
          other.resolvedPlaceId == this.resolvedPlaceId &&
          other.bindConfidence == this.bindConfidence &&
          other.resolverReasonCode == this.resolverReasonCode &&
          other.resolverState == this.resolverState &&
          other.resolverVersion == this.resolverVersion &&
          other.resolvedAt == this.resolvedAt &&
          other.resolutionHintJson == this.resolutionHintJson &&
          other.syncStatus == this.syncStatus &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TrackingEventsCompanion extends UpdateCompanion<TrackingEventRow> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> eventType;
  final Value<String?> note;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String> payloadJson;
  final Value<String?> clientEventId;
  final Value<String?> resolvedPlaceId;
  final Value<double?> bindConfidence;
  final Value<String?> resolverReasonCode;
  final Value<String> resolverState;
  final Value<int> resolverVersion;
  final Value<DateTime?> resolvedAt;
  final Value<String?> resolutionHintJson;
  final Value<String> syncStatus;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime?> serverUpdatedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TrackingEventsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.note = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.clientEventId = const Value.absent(),
    this.resolvedPlaceId = const Value.absent(),
    this.bindConfidence = const Value.absent(),
    this.resolverReasonCode = const Value.absent(),
    this.resolverState = const Value.absent(),
    this.resolverVersion = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.resolutionHintJson = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackingEventsCompanion.insert({
    required String id,
    required String tripId,
    required String eventType,
    this.note = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.clientEventId = const Value.absent(),
    this.resolvedPlaceId = const Value.absent(),
    this.bindConfidence = const Value.absent(),
    this.resolverReasonCode = const Value.absent(),
    this.resolverState = const Value.absent(),
    this.resolverVersion = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.resolutionHintJson = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime localUpdatedAt,
    this.serverUpdatedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tripId = Value(tripId),
        eventType = Value(eventType),
        localUpdatedAt = Value(localUpdatedAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TrackingEventRow> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? eventType,
    Expression<String>? note,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? payloadJson,
    Expression<String>? clientEventId,
    Expression<String>? resolvedPlaceId,
    Expression<double>? bindConfidence,
    Expression<String>? resolverReasonCode,
    Expression<String>? resolverState,
    Expression<int>? resolverVersion,
    Expression<DateTime>? resolvedAt,
    Expression<String>? resolutionHintJson,
    Expression<String>? syncStatus,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (eventType != null) 'event_type': eventType,
      if (note != null) 'note': note,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (clientEventId != null) 'client_event_id': clientEventId,
      if (resolvedPlaceId != null) 'resolved_place_id': resolvedPlaceId,
      if (bindConfidence != null) 'bind_confidence': bindConfidence,
      if (resolverReasonCode != null)
        'resolver_reason_code': resolverReasonCode,
      if (resolverState != null) 'resolver_state': resolverState,
      if (resolverVersion != null) 'resolver_version': resolverVersion,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (resolutionHintJson != null)
        'resolution_hint_json': resolutionHintJson,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackingEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tripId,
      Value<String>? eventType,
      Value<String?>? note,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<String>? payloadJson,
      Value<String?>? clientEventId,
      Value<String?>? resolvedPlaceId,
      Value<double?>? bindConfidence,
      Value<String?>? resolverReasonCode,
      Value<String>? resolverState,
      Value<int>? resolverVersion,
      Value<DateTime?>? resolvedAt,
      Value<String?>? resolutionHintJson,
      Value<String>? syncStatus,
      Value<DateTime>? localUpdatedAt,
      Value<DateTime?>? serverUpdatedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return TrackingEventsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      eventType: eventType ?? this.eventType,
      note: note ?? this.note,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      payloadJson: payloadJson ?? this.payloadJson,
      clientEventId: clientEventId ?? this.clientEventId,
      resolvedPlaceId: resolvedPlaceId ?? this.resolvedPlaceId,
      bindConfidence: bindConfidence ?? this.bindConfidence,
      resolverReasonCode: resolverReasonCode ?? this.resolverReasonCode,
      resolverState: resolverState ?? this.resolverState,
      resolverVersion: resolverVersion ?? this.resolverVersion,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionHintJson: resolutionHintJson ?? this.resolutionHintJson,
      syncStatus: syncStatus ?? this.syncStatus,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
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
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (clientEventId.present) {
      map['client_event_id'] = Variable<String>(clientEventId.value);
    }
    if (resolvedPlaceId.present) {
      map['resolved_place_id'] = Variable<String>(resolvedPlaceId.value);
    }
    if (bindConfidence.present) {
      map['bind_confidence'] = Variable<double>(bindConfidence.value);
    }
    if (resolverReasonCode.present) {
      map['resolver_reason_code'] = Variable<String>(resolverReasonCode.value);
    }
    if (resolverState.present) {
      map['resolver_state'] = Variable<String>(resolverState.value);
    }
    if (resolverVersion.present) {
      map['resolver_version'] = Variable<int>(resolverVersion.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (resolutionHintJson.present) {
      map['resolution_hint_json'] = Variable<String>(resolutionHintJson.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
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
    return (StringBuffer('TrackingEventsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('eventType: $eventType, ')
          ..write('note: $note, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('clientEventId: $clientEventId, ')
          ..write('resolvedPlaceId: $resolvedPlaceId, ')
          ..write('bindConfidence: $bindConfidence, ')
          ..write('resolverReasonCode: $resolverReasonCode, ')
          ..write('resolverState: $resolverState, ')
          ..write('resolverVersion: $resolverVersion, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolutionHintJson: $resolutionHintJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackingEventMediaTable extends TrackingEventMedia
    with TableInfo<$TrackingEventMediaTable, TrackingEventMediaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackingEventMediaTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
      'event_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bindModeMeta =
      const VerificationMeta('bindMode');
  @override
  late final GeneratedColumn<String> bindMode = GeneratedColumn<String>(
      'bind_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('route'));
  static const VerificationMeta _bindStateMeta =
      const VerificationMeta('bindState');
  @override
  late final GeneratedColumn<String> bindState = GeneratedColumn<String>(
      'bind_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('awaiting_bind_choice'));
  static const VerificationMeta _tripPlaceIdMeta =
      const VerificationMeta('tripPlaceId');
  @override
  late final GeneratedColumn<String> tripPlaceId = GeneratedColumn<String>(
      'trip_place_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _anchorLatitudeMeta =
      const VerificationMeta('anchorLatitude');
  @override
  late final GeneratedColumn<double> anchorLatitude = GeneratedColumn<double>(
      'anchor_latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _anchorLongitudeMeta =
      const VerificationMeta('anchorLongitude');
  @override
  late final GeneratedColumn<double> anchorLongitude = GeneratedColumn<double>(
      'anchor_longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _capturedAtMeta =
      const VerificationMeta('capturedAt');
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
      'captured_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _uploadRefMeta =
      const VerificationMeta('uploadRef');
  @override
  late final GeneratedColumn<String> uploadRef = GeneratedColumn<String>(
      'upload_ref', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _remoteMediaIdMeta =
      const VerificationMeta('remoteMediaId');
  @override
  late final GeneratedColumn<String> remoteMediaId = GeneratedColumn<String>(
      'remote_media_id', aliasedName, true,
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
  static const VerificationMeta _uploadStatusMeta =
      const VerificationMeta('uploadStatus');
  @override
  late final GeneratedColumn<String> uploadStatus = GeneratedColumn<String>(
      'upload_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('awaiting_bind_choice'));
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
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
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
        tripId,
        eventId,
        bindMode,
        bindState,
        tripPlaceId,
        anchorLatitude,
        anchorLongitude,
        capturedAt,
        localPath,
        uploadRef,
        remoteMediaId,
        mimeType,
        fileSizeBytes,
        width,
        height,
        uploadStatus,
        uploadProgress,
        retryCount,
        errorMessage,
        nextAttemptAt,
        workerSessionId,
        payloadJson,
        syncStatus,
        localUpdatedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracking_event_media';
  @override
  VerificationContext validateIntegrity(
      Insertable<TrackingEventMediaRow> instance,
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
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('bind_mode')) {
      context.handle(_bindModeMeta,
          bindMode.isAcceptableOrUnknown(data['bind_mode']!, _bindModeMeta));
    }
    if (data.containsKey('bind_state')) {
      context.handle(_bindStateMeta,
          bindState.isAcceptableOrUnknown(data['bind_state']!, _bindStateMeta));
    }
    if (data.containsKey('trip_place_id')) {
      context.handle(
          _tripPlaceIdMeta,
          tripPlaceId.isAcceptableOrUnknown(
              data['trip_place_id']!, _tripPlaceIdMeta));
    }
    if (data.containsKey('anchor_latitude')) {
      context.handle(
          _anchorLatitudeMeta,
          anchorLatitude.isAcceptableOrUnknown(
              data['anchor_latitude']!, _anchorLatitudeMeta));
    }
    if (data.containsKey('anchor_longitude')) {
      context.handle(
          _anchorLongitudeMeta,
          anchorLongitude.isAcceptableOrUnknown(
              data['anchor_longitude']!, _anchorLongitudeMeta));
    }
    if (data.containsKey('captured_at')) {
      context.handle(
          _capturedAtMeta,
          capturedAt.isAcceptableOrUnknown(
              data['captured_at']!, _capturedAtMeta));
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('upload_ref')) {
      context.handle(_uploadRefMeta,
          uploadRef.isAcceptableOrUnknown(data['upload_ref']!, _uploadRefMeta));
    }
    if (data.containsKey('remote_media_id')) {
      context.handle(
          _remoteMediaIdMeta,
          remoteMediaId.isAcceptableOrUnknown(
              data['remote_media_id']!, _remoteMediaIdMeta));
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
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
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
  TrackingEventMediaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackingEventMediaRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tripId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trip_id'])!,
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_id'])!,
      bindMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bind_mode'])!,
      bindState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bind_state'])!,
      tripPlaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trip_place_id']),
      anchorLatitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}anchor_latitude']),
      anchorLongitude: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}anchor_longitude']),
      capturedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}captured_at'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path'])!,
      uploadRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}upload_ref']),
      remoteMediaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_media_id']),
      mimeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime_type']),
      fileSizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size_bytes']),
      width: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}width']),
      height: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}height']),
      uploadStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}upload_status'])!,
      uploadProgress: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}upload_progress'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      nextAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_attempt_at']),
      workerSessionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}worker_session_id']),
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TrackingEventMediaTable createAlias(String alias) {
    return $TrackingEventMediaTable(attachedDatabase, alias);
  }
}

class TrackingEventMediaRow extends DataClass
    implements Insertable<TrackingEventMediaRow> {
  final String id;
  final String tripId;
  final String eventId;
  final String bindMode;
  final String bindState;
  final String? tripPlaceId;
  final double? anchorLatitude;
  final double? anchorLongitude;
  final DateTime capturedAt;
  final String localPath;
  final String? uploadRef;
  final String? remoteMediaId;
  final String? mimeType;
  final int? fileSizeBytes;
  final int? width;
  final int? height;
  final String uploadStatus;
  final double uploadProgress;
  final int retryCount;
  final String? errorMessage;
  final DateTime? nextAttemptAt;
  final String? workerSessionId;
  final String payloadJson;
  final String syncStatus;
  final DateTime localUpdatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TrackingEventMediaRow(
      {required this.id,
      required this.tripId,
      required this.eventId,
      required this.bindMode,
      required this.bindState,
      this.tripPlaceId,
      this.anchorLatitude,
      this.anchorLongitude,
      required this.capturedAt,
      required this.localPath,
      this.uploadRef,
      this.remoteMediaId,
      this.mimeType,
      this.fileSizeBytes,
      this.width,
      this.height,
      required this.uploadStatus,
      required this.uploadProgress,
      required this.retryCount,
      this.errorMessage,
      this.nextAttemptAt,
      this.workerSessionId,
      required this.payloadJson,
      required this.syncStatus,
      required this.localUpdatedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['event_id'] = Variable<String>(eventId);
    map['bind_mode'] = Variable<String>(bindMode);
    map['bind_state'] = Variable<String>(bindState);
    if (!nullToAbsent || tripPlaceId != null) {
      map['trip_place_id'] = Variable<String>(tripPlaceId);
    }
    if (!nullToAbsent || anchorLatitude != null) {
      map['anchor_latitude'] = Variable<double>(anchorLatitude);
    }
    if (!nullToAbsent || anchorLongitude != null) {
      map['anchor_longitude'] = Variable<double>(anchorLongitude);
    }
    map['captured_at'] = Variable<DateTime>(capturedAt);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || uploadRef != null) {
      map['upload_ref'] = Variable<String>(uploadRef);
    }
    if (!nullToAbsent || remoteMediaId != null) {
      map['remote_media_id'] = Variable<String>(remoteMediaId);
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
    map['upload_status'] = Variable<String>(uploadStatus);
    map['upload_progress'] = Variable<double>(uploadProgress);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || workerSessionId != null) {
      map['worker_session_id'] = Variable<String>(workerSessionId);
    }
    map['payload_json'] = Variable<String>(payloadJson);
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TrackingEventMediaCompanion toCompanion(bool nullToAbsent) {
    return TrackingEventMediaCompanion(
      id: Value(id),
      tripId: Value(tripId),
      eventId: Value(eventId),
      bindMode: Value(bindMode),
      bindState: Value(bindState),
      tripPlaceId: tripPlaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(tripPlaceId),
      anchorLatitude: anchorLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(anchorLatitude),
      anchorLongitude: anchorLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(anchorLongitude),
      capturedAt: Value(capturedAt),
      localPath: Value(localPath),
      uploadRef: uploadRef == null && nullToAbsent
          ? const Value.absent()
          : Value(uploadRef),
      remoteMediaId: remoteMediaId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteMediaId),
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
      uploadStatus: Value(uploadStatus),
      uploadProgress: Value(uploadProgress),
      retryCount: Value(retryCount),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      workerSessionId: workerSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(workerSessionId),
      payloadJson: Value(payloadJson),
      syncStatus: Value(syncStatus),
      localUpdatedAt: Value(localUpdatedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TrackingEventMediaRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackingEventMediaRow(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      eventId: serializer.fromJson<String>(json['eventId']),
      bindMode: serializer.fromJson<String>(json['bindMode']),
      bindState: serializer.fromJson<String>(json['bindState']),
      tripPlaceId: serializer.fromJson<String?>(json['tripPlaceId']),
      anchorLatitude: serializer.fromJson<double?>(json['anchorLatitude']),
      anchorLongitude: serializer.fromJson<double?>(json['anchorLongitude']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      localPath: serializer.fromJson<String>(json['localPath']),
      uploadRef: serializer.fromJson<String?>(json['uploadRef']),
      remoteMediaId: serializer.fromJson<String?>(json['remoteMediaId']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      fileSizeBytes: serializer.fromJson<int?>(json['fileSizeBytes']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      uploadStatus: serializer.fromJson<String>(json['uploadStatus']),
      uploadProgress: serializer.fromJson<double>(json['uploadProgress']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      workerSessionId: serializer.fromJson<String?>(json['workerSessionId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'eventId': serializer.toJson<String>(eventId),
      'bindMode': serializer.toJson<String>(bindMode),
      'bindState': serializer.toJson<String>(bindState),
      'tripPlaceId': serializer.toJson<String?>(tripPlaceId),
      'anchorLatitude': serializer.toJson<double?>(anchorLatitude),
      'anchorLongitude': serializer.toJson<double?>(anchorLongitude),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'localPath': serializer.toJson<String>(localPath),
      'uploadRef': serializer.toJson<String?>(uploadRef),
      'remoteMediaId': serializer.toJson<String?>(remoteMediaId),
      'mimeType': serializer.toJson<String?>(mimeType),
      'fileSizeBytes': serializer.toJson<int?>(fileSizeBytes),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'uploadStatus': serializer.toJson<String>(uploadStatus),
      'uploadProgress': serializer.toJson<double>(uploadProgress),
      'retryCount': serializer.toJson<int>(retryCount),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'workerSessionId': serializer.toJson<String?>(workerSessionId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TrackingEventMediaRow copyWith(
          {String? id,
          String? tripId,
          String? eventId,
          String? bindMode,
          String? bindState,
          Value<String?> tripPlaceId = const Value.absent(),
          Value<double?> anchorLatitude = const Value.absent(),
          Value<double?> anchorLongitude = const Value.absent(),
          DateTime? capturedAt,
          String? localPath,
          Value<String?> uploadRef = const Value.absent(),
          Value<String?> remoteMediaId = const Value.absent(),
          Value<String?> mimeType = const Value.absent(),
          Value<int?> fileSizeBytes = const Value.absent(),
          Value<int?> width = const Value.absent(),
          Value<int?> height = const Value.absent(),
          String? uploadStatus,
          double? uploadProgress,
          int? retryCount,
          Value<String?> errorMessage = const Value.absent(),
          Value<DateTime?> nextAttemptAt = const Value.absent(),
          Value<String?> workerSessionId = const Value.absent(),
          String? payloadJson,
          String? syncStatus,
          DateTime? localUpdatedAt,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      TrackingEventMediaRow(
        id: id ?? this.id,
        tripId: tripId ?? this.tripId,
        eventId: eventId ?? this.eventId,
        bindMode: bindMode ?? this.bindMode,
        bindState: bindState ?? this.bindState,
        tripPlaceId: tripPlaceId.present ? tripPlaceId.value : this.tripPlaceId,
        anchorLatitude:
            anchorLatitude.present ? anchorLatitude.value : this.anchorLatitude,
        anchorLongitude: anchorLongitude.present
            ? anchorLongitude.value
            : this.anchorLongitude,
        capturedAt: capturedAt ?? this.capturedAt,
        localPath: localPath ?? this.localPath,
        uploadRef: uploadRef.present ? uploadRef.value : this.uploadRef,
        remoteMediaId:
            remoteMediaId.present ? remoteMediaId.value : this.remoteMediaId,
        mimeType: mimeType.present ? mimeType.value : this.mimeType,
        fileSizeBytes:
            fileSizeBytes.present ? fileSizeBytes.value : this.fileSizeBytes,
        width: width.present ? width.value : this.width,
        height: height.present ? height.value : this.height,
        uploadStatus: uploadStatus ?? this.uploadStatus,
        uploadProgress: uploadProgress ?? this.uploadProgress,
        retryCount: retryCount ?? this.retryCount,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        nextAttemptAt:
            nextAttemptAt.present ? nextAttemptAt.value : this.nextAttemptAt,
        workerSessionId: workerSessionId.present
            ? workerSessionId.value
            : this.workerSessionId,
        payloadJson: payloadJson ?? this.payloadJson,
        syncStatus: syncStatus ?? this.syncStatus,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TrackingEventMediaRow copyWithCompanion(TrackingEventMediaCompanion data) {
    return TrackingEventMediaRow(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      bindMode: data.bindMode.present ? data.bindMode.value : this.bindMode,
      bindState: data.bindState.present ? data.bindState.value : this.bindState,
      tripPlaceId:
          data.tripPlaceId.present ? data.tripPlaceId.value : this.tripPlaceId,
      anchorLatitude: data.anchorLatitude.present
          ? data.anchorLatitude.value
          : this.anchorLatitude,
      anchorLongitude: data.anchorLongitude.present
          ? data.anchorLongitude.value
          : this.anchorLongitude,
      capturedAt:
          data.capturedAt.present ? data.capturedAt.value : this.capturedAt,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      uploadRef: data.uploadRef.present ? data.uploadRef.value : this.uploadRef,
      remoteMediaId: data.remoteMediaId.present
          ? data.remoteMediaId.value
          : this.remoteMediaId,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
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
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      workerSessionId: data.workerSessionId.present
          ? data.workerSessionId.value
          : this.workerSessionId,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackingEventMediaRow(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('eventId: $eventId, ')
          ..write('bindMode: $bindMode, ')
          ..write('bindState: $bindState, ')
          ..write('tripPlaceId: $tripPlaceId, ')
          ..write('anchorLatitude: $anchorLatitude, ')
          ..write('anchorLongitude: $anchorLongitude, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('localPath: $localPath, ')
          ..write('uploadRef: $uploadRef, ')
          ..write('remoteMediaId: $remoteMediaId, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('uploadProgress: $uploadProgress, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('workerSessionId: $workerSessionId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        tripId,
        eventId,
        bindMode,
        bindState,
        tripPlaceId,
        anchorLatitude,
        anchorLongitude,
        capturedAt,
        localPath,
        uploadRef,
        remoteMediaId,
        mimeType,
        fileSizeBytes,
        width,
        height,
        uploadStatus,
        uploadProgress,
        retryCount,
        errorMessage,
        nextAttemptAt,
        workerSessionId,
        payloadJson,
        syncStatus,
        localUpdatedAt,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackingEventMediaRow &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.eventId == this.eventId &&
          other.bindMode == this.bindMode &&
          other.bindState == this.bindState &&
          other.tripPlaceId == this.tripPlaceId &&
          other.anchorLatitude == this.anchorLatitude &&
          other.anchorLongitude == this.anchorLongitude &&
          other.capturedAt == this.capturedAt &&
          other.localPath == this.localPath &&
          other.uploadRef == this.uploadRef &&
          other.remoteMediaId == this.remoteMediaId &&
          other.mimeType == this.mimeType &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.width == this.width &&
          other.height == this.height &&
          other.uploadStatus == this.uploadStatus &&
          other.uploadProgress == this.uploadProgress &&
          other.retryCount == this.retryCount &&
          other.errorMessage == this.errorMessage &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.workerSessionId == this.workerSessionId &&
          other.payloadJson == this.payloadJson &&
          other.syncStatus == this.syncStatus &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TrackingEventMediaCompanion
    extends UpdateCompanion<TrackingEventMediaRow> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> eventId;
  final Value<String> bindMode;
  final Value<String> bindState;
  final Value<String?> tripPlaceId;
  final Value<double?> anchorLatitude;
  final Value<double?> anchorLongitude;
  final Value<DateTime> capturedAt;
  final Value<String> localPath;
  final Value<String?> uploadRef;
  final Value<String?> remoteMediaId;
  final Value<String?> mimeType;
  final Value<int?> fileSizeBytes;
  final Value<int?> width;
  final Value<int?> height;
  final Value<String> uploadStatus;
  final Value<double> uploadProgress;
  final Value<int> retryCount;
  final Value<String?> errorMessage;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> workerSessionId;
  final Value<String> payloadJson;
  final Value<String> syncStatus;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TrackingEventMediaCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.bindMode = const Value.absent(),
    this.bindState = const Value.absent(),
    this.tripPlaceId = const Value.absent(),
    this.anchorLatitude = const Value.absent(),
    this.anchorLongitude = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.localPath = const Value.absent(),
    this.uploadRef = const Value.absent(),
    this.remoteMediaId = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.uploadStatus = const Value.absent(),
    this.uploadProgress = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.workerSessionId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackingEventMediaCompanion.insert({
    required String id,
    required String tripId,
    required String eventId,
    this.bindMode = const Value.absent(),
    this.bindState = const Value.absent(),
    this.tripPlaceId = const Value.absent(),
    this.anchorLatitude = const Value.absent(),
    this.anchorLongitude = const Value.absent(),
    required DateTime capturedAt,
    required String localPath,
    this.uploadRef = const Value.absent(),
    this.remoteMediaId = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.uploadStatus = const Value.absent(),
    this.uploadProgress = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.workerSessionId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime localUpdatedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tripId = Value(tripId),
        eventId = Value(eventId),
        capturedAt = Value(capturedAt),
        localPath = Value(localPath),
        localUpdatedAt = Value(localUpdatedAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TrackingEventMediaRow> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? eventId,
    Expression<String>? bindMode,
    Expression<String>? bindState,
    Expression<String>? tripPlaceId,
    Expression<double>? anchorLatitude,
    Expression<double>? anchorLongitude,
    Expression<DateTime>? capturedAt,
    Expression<String>? localPath,
    Expression<String>? uploadRef,
    Expression<String>? remoteMediaId,
    Expression<String>? mimeType,
    Expression<int>? fileSizeBytes,
    Expression<int>? width,
    Expression<int>? height,
    Expression<String>? uploadStatus,
    Expression<double>? uploadProgress,
    Expression<int>? retryCount,
    Expression<String>? errorMessage,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? workerSessionId,
    Expression<String>? payloadJson,
    Expression<String>? syncStatus,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (eventId != null) 'event_id': eventId,
      if (bindMode != null) 'bind_mode': bindMode,
      if (bindState != null) 'bind_state': bindState,
      if (tripPlaceId != null) 'trip_place_id': tripPlaceId,
      if (anchorLatitude != null) 'anchor_latitude': anchorLatitude,
      if (anchorLongitude != null) 'anchor_longitude': anchorLongitude,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (localPath != null) 'local_path': localPath,
      if (uploadRef != null) 'upload_ref': uploadRef,
      if (remoteMediaId != null) 'remote_media_id': remoteMediaId,
      if (mimeType != null) 'mime_type': mimeType,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (uploadStatus != null) 'upload_status': uploadStatus,
      if (uploadProgress != null) 'upload_progress': uploadProgress,
      if (retryCount != null) 'retry_count': retryCount,
      if (errorMessage != null) 'error_message': errorMessage,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (workerSessionId != null) 'worker_session_id': workerSessionId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackingEventMediaCompanion copyWith(
      {Value<String>? id,
      Value<String>? tripId,
      Value<String>? eventId,
      Value<String>? bindMode,
      Value<String>? bindState,
      Value<String?>? tripPlaceId,
      Value<double?>? anchorLatitude,
      Value<double?>? anchorLongitude,
      Value<DateTime>? capturedAt,
      Value<String>? localPath,
      Value<String?>? uploadRef,
      Value<String?>? remoteMediaId,
      Value<String?>? mimeType,
      Value<int?>? fileSizeBytes,
      Value<int?>? width,
      Value<int?>? height,
      Value<String>? uploadStatus,
      Value<double>? uploadProgress,
      Value<int>? retryCount,
      Value<String?>? errorMessage,
      Value<DateTime?>? nextAttemptAt,
      Value<String?>? workerSessionId,
      Value<String>? payloadJson,
      Value<String>? syncStatus,
      Value<DateTime>? localUpdatedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return TrackingEventMediaCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      eventId: eventId ?? this.eventId,
      bindMode: bindMode ?? this.bindMode,
      bindState: bindState ?? this.bindState,
      tripPlaceId: tripPlaceId ?? this.tripPlaceId,
      anchorLatitude: anchorLatitude ?? this.anchorLatitude,
      anchorLongitude: anchorLongitude ?? this.anchorLongitude,
      capturedAt: capturedAt ?? this.capturedAt,
      localPath: localPath ?? this.localPath,
      uploadRef: uploadRef ?? this.uploadRef,
      remoteMediaId: remoteMediaId ?? this.remoteMediaId,
      mimeType: mimeType ?? this.mimeType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      width: width ?? this.width,
      height: height ?? this.height,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      workerSessionId: workerSessionId ?? this.workerSessionId,
      payloadJson: payloadJson ?? this.payloadJson,
      syncStatus: syncStatus ?? this.syncStatus,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
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
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (bindMode.present) {
      map['bind_mode'] = Variable<String>(bindMode.value);
    }
    if (bindState.present) {
      map['bind_state'] = Variable<String>(bindState.value);
    }
    if (tripPlaceId.present) {
      map['trip_place_id'] = Variable<String>(tripPlaceId.value);
    }
    if (anchorLatitude.present) {
      map['anchor_latitude'] = Variable<double>(anchorLatitude.value);
    }
    if (anchorLongitude.present) {
      map['anchor_longitude'] = Variable<double>(anchorLongitude.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (uploadRef.present) {
      map['upload_ref'] = Variable<String>(uploadRef.value);
    }
    if (remoteMediaId.present) {
      map['remote_media_id'] = Variable<String>(remoteMediaId.value);
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
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (workerSessionId.present) {
      map['worker_session_id'] = Variable<String>(workerSessionId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
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
    return (StringBuffer('TrackingEventMediaCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('eventId: $eventId, ')
          ..write('bindMode: $bindMode, ')
          ..write('bindState: $bindState, ')
          ..write('tripPlaceId: $tripPlaceId, ')
          ..write('anchorLatitude: $anchorLatitude, ')
          ..write('anchorLongitude: $anchorLongitude, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('localPath: $localPath, ')
          ..write('uploadRef: $uploadRef, ')
          ..write('remoteMediaId: $remoteMediaId, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('uploadProgress: $uploadProgress, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('workerSessionId: $workerSessionId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
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
  late final $TrackingSessionsTable trackingSessions =
      $TrackingSessionsTable(this);
  late final $TrackingPointBatchesTable trackingPointBatches =
      $TrackingPointBatchesTable(this);
  late final $TrackingCandidatesTable trackingCandidates =
      $TrackingCandidatesTable(this);
  late final $TrackingMomentsTable trackingMoments =
      $TrackingMomentsTable(this);
  late final $TrackingEventsTable trackingEvents = $TrackingEventsTable(this);
  late final $TrackingEventMediaTable trackingEventMedia =
      $TrackingEventMediaTable(this);
  late final Index trackingSessionsTripStateUpdatedIdx = Index(
      'tracking_sessions_trip_state_updated_idx',
      'CREATE INDEX tracking_sessions_trip_state_updated_idx ON tracking_sessions (trip_id, state, local_updated_at)');
  late final Index trackingSessionsTripUpdatedIdx = Index(
      'tracking_sessions_trip_updated_idx',
      'CREATE INDEX tracking_sessions_trip_updated_idx ON tracking_sessions (trip_id, updated_at)');
  late final Index trackingPointBatchesClaimIdx = Index(
      'tracking_point_batches_claim_idx',
      'CREATE INDEX tracking_point_batches_claim_idx ON tracking_point_batches (status, next_attempt_at, worker_session_id, created_at)');
  late final Index trackingPointBatchesTripCreatedIdx = Index(
      'tracking_point_batches_trip_created_idx',
      'CREATE INDEX tracking_point_batches_trip_created_idx ON tracking_point_batches (trip_id, created_at)');
  late final Index trackingPointBatchesSessionCreatedIdx = Index(
      'tracking_point_batches_session_created_idx',
      'CREATE INDEX tracking_point_batches_session_created_idx ON tracking_point_batches (session_id, created_at)');
  late final Index trackingCandidatesTripCreatedIdx = Index(
      'tracking_candidates_trip_created_idx',
      'CREATE INDEX tracking_candidates_trip_created_idx ON tracking_candidates (trip_id, created_at)');
  late final Index trackingCandidatesTripStatusUpdatedIdx = Index(
      'tracking_candidates_trip_status_updated_idx',
      'CREATE INDEX tracking_candidates_trip_status_updated_idx ON tracking_candidates (trip_id, status, updated_at)');
  late final Index trackingCandidatesActionQueueIdx = Index(
      'tracking_candidates_action_queue_idx',
      'CREATE INDEX tracking_candidates_action_queue_idx ON tracking_candidates (action_state, sync_status, action_queued_at)');
  late final Index trackingMomentsTripCapturedIdx = Index(
      'tracking_moments_trip_captured_idx',
      'CREATE INDEX tracking_moments_trip_captured_idx ON tracking_moments (trip_id, captured_at)');
  late final Index trackingMomentsSyncPendingIdx = Index(
      'tracking_moments_sync_pending_idx',
      'CREATE INDEX tracking_moments_sync_pending_idx ON tracking_moments (sync_status, pending_operation, updated_at)');
  late final Index trackingEventsTripCreatedIdx = Index(
      'tracking_events_trip_created_idx',
      'CREATE INDEX tracking_events_trip_created_idx ON tracking_events (trip_id, created_at)');
  late final Index trackingEventsSyncUpdatedIdx = Index(
      'tracking_events_sync_updated_idx',
      'CREATE INDEX tracking_events_sync_updated_idx ON tracking_events (sync_status, updated_at)');
  late final Index trackingEventsTripResolverCreatedIdx = Index(
      'tracking_events_trip_resolver_created_idx',
      'CREATE INDEX tracking_events_trip_resolver_created_idx ON tracking_events (trip_id, resolver_state, created_at)');
  late final Index trackingEventsTripResolvedPlaceCreatedIdx = Index(
      'tracking_events_trip_resolved_place_created_idx',
      'CREATE INDEX tracking_events_trip_resolved_place_created_idx ON tracking_events (trip_id, resolved_place_id, created_at)');
  late final Index trackingEventMediaEventCreatedIdx = Index(
      'tracking_event_media_event_created_idx',
      'CREATE INDEX tracking_event_media_event_created_idx ON tracking_event_media (event_id, created_at)');
  late final Index trackingEventMediaStatusUpdatedIdx = Index(
      'tracking_event_media_status_updated_idx',
      'CREATE INDEX tracking_event_media_status_updated_idx ON tracking_event_media (upload_status, updated_at)');
  late final Index trackingEventMediaTripBindStateCreatedIdx = Index(
      'tracking_event_media_trip_bind_state_created_idx',
      'CREATE INDEX tracking_event_media_trip_bind_state_created_idx ON tracking_event_media (trip_id, bind_state, created_at)');
  late final Index trackingEventMediaSyncUpdatedIdx = Index(
      'tracking_event_media_sync_updated_idx',
      'CREATE INDEX tracking_event_media_sync_updated_idx ON tracking_event_media (sync_status, updated_at)');
  late final TripDao tripDao = TripDao(this as AppDatabase);
  late final PlaceDao placeDao = PlaceDao(this as AppDatabase);
  late final RouteDao routeDao = RouteDao(this as AppDatabase);
  late final MediaDao mediaDao = MediaDao(this as AppDatabase);
  late final PublicTripsDao publicTripsDao =
      PublicTripsDao(this as AppDatabase);
  late final UserTripsDao userTripsDao = UserTripsDao(this as AppDatabase);
  late final SyncTaskDao syncTaskDao = SyncTaskDao(this as AppDatabase);
  late final TrackingSessionDao trackingSessionDao =
      TrackingSessionDao(this as AppDatabase);
  late final TrackingPointBatchDao trackingPointBatchDao =
      TrackingPointBatchDao(this as AppDatabase);
  late final TrackingCandidateDao trackingCandidateDao =
      TrackingCandidateDao(this as AppDatabase);
  late final TrackingMomentDao trackingMomentDao =
      TrackingMomentDao(this as AppDatabase);
  late final TrackingEventDao trackingEventDao =
      TrackingEventDao(this as AppDatabase);
  late final TrackingEventMediaDao trackingEventMediaDao =
      TrackingEventMediaDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        trips,
        places,
        routes,
        media,
        publicTrips,
        userTrips,
        syncTasks,
        trackingSessions,
        trackingPointBatches,
        trackingCandidates,
        trackingMoments,
        trackingEvents,
        trackingEventMedia,
        trackingSessionsTripStateUpdatedIdx,
        trackingSessionsTripUpdatedIdx,
        trackingPointBatchesClaimIdx,
        trackingPointBatchesTripCreatedIdx,
        trackingPointBatchesSessionCreatedIdx,
        trackingCandidatesTripCreatedIdx,
        trackingCandidatesTripStatusUpdatedIdx,
        trackingCandidatesActionQueueIdx,
        trackingMomentsTripCapturedIdx,
        trackingMomentsSyncPendingIdx,
        trackingEventsTripCreatedIdx,
        trackingEventsSyncUpdatedIdx,
        trackingEventsTripResolverCreatedIdx,
        trackingEventsTripResolvedPlaceCreatedIdx,
        trackingEventMediaEventCreatedIdx,
        trackingEventMediaStatusUpdatedIdx,
        trackingEventMediaTripBindStateCreatedIdx,
        trackingEventMediaSyncUpdatedIdx
      ];
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
  Value<String?> serverRouteId,
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
  Value<String?> serverRouteId,
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

  ColumnFilters<String> get serverRouteId => $composableBuilder(
      column: $table.serverRouteId, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get serverRouteId => $composableBuilder(
      column: $table.serverRouteId,
      builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get serverRouteId => $composableBuilder(
      column: $table.serverRouteId, builder: (column) => column);

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
            Value<String?> serverRouteId = const Value.absent(),
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
            serverRouteId: serverRouteId,
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
            Value<String?> serverRouteId = const Value.absent(),
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
            serverRouteId: serverRouteId,
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
  Value<String?> remoteEntityId,
  required String operation,
  Value<String> status,
  Value<bool> pendingRequeue,
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
  Value<String?> remoteEntityId,
  Value<String> operation,
  Value<String> status,
  Value<bool> pendingRequeue,
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

  ColumnFilters<String> get remoteEntityId => $composableBuilder(
      column: $table.remoteEntityId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pendingRequeue => $composableBuilder(
      column: $table.pendingRequeue,
      builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get remoteEntityId => $composableBuilder(
      column: $table.remoteEntityId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pendingRequeue => $composableBuilder(
      column: $table.pendingRequeue,
      builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get remoteEntityId => $composableBuilder(
      column: $table.remoteEntityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get pendingRequeue => $composableBuilder(
      column: $table.pendingRequeue, builder: (column) => column);

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
            Value<String?> remoteEntityId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> pendingRequeue = const Value.absent(),
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
            remoteEntityId: remoteEntityId,
            operation: operation,
            status: status,
            pendingRequeue: pendingRequeue,
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
            Value<String?> remoteEntityId = const Value.absent(),
            required String operation,
            Value<String> status = const Value.absent(),
            Value<bool> pendingRequeue = const Value.absent(),
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
            remoteEntityId: remoteEntityId,
            operation: operation,
            status: status,
            pendingRequeue: pendingRequeue,
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
typedef $$TrackingSessionsTableCreateCompanionBuilder
    = TrackingSessionsCompanion Function({
  required String id,
  required String tripId,
  Value<String?> remoteSessionId,
  required String clientSessionId,
  Value<String> state,
  Value<String?> timezone,
  Value<String> deviceContextJson,
  Value<DateTime?> startedAt,
  Value<DateTime?> pausedAt,
  Value<DateTime?> resumedAt,
  Value<DateTime?> endedAt,
  Value<DateTime?> abandonedAt,
  Value<DateTime?> lastPointAt,
  Value<DateTime?> lastFlushAt,
  Value<String> syncStatus,
  required DateTime localUpdatedAt,
  Value<DateTime?> serverUpdatedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TrackingSessionsTableUpdateCompanionBuilder
    = TrackingSessionsCompanion Function({
  Value<String> id,
  Value<String> tripId,
  Value<String?> remoteSessionId,
  Value<String> clientSessionId,
  Value<String> state,
  Value<String?> timezone,
  Value<String> deviceContextJson,
  Value<DateTime?> startedAt,
  Value<DateTime?> pausedAt,
  Value<DateTime?> resumedAt,
  Value<DateTime?> endedAt,
  Value<DateTime?> abandonedAt,
  Value<DateTime?> lastPointAt,
  Value<DateTime?> lastFlushAt,
  Value<String> syncStatus,
  Value<DateTime> localUpdatedAt,
  Value<DateTime?> serverUpdatedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$TrackingSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $TrackingSessionsTable> {
  $$TrackingSessionsTableFilterComposer({
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

  ColumnFilters<String> get remoteSessionId => $composableBuilder(
      column: $table.remoteSessionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientSessionId => $composableBuilder(
      column: $table.clientSessionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceContextJson => $composableBuilder(
      column: $table.deviceContextJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get pausedAt => $composableBuilder(
      column: $table.pausedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get resumedAt => $composableBuilder(
      column: $table.resumedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get abandonedAt => $composableBuilder(
      column: $table.abandonedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastPointAt => $composableBuilder(
      column: $table.lastPointAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastFlushAt => $composableBuilder(
      column: $table.lastFlushAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TrackingSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackingSessionsTable> {
  $$TrackingSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get remoteSessionId => $composableBuilder(
      column: $table.remoteSessionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientSessionId => $composableBuilder(
      column: $table.clientSessionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceContextJson => $composableBuilder(
      column: $table.deviceContextJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get pausedAt => $composableBuilder(
      column: $table.pausedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get resumedAt => $composableBuilder(
      column: $table.resumedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get abandonedAt => $composableBuilder(
      column: $table.abandonedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastPointAt => $composableBuilder(
      column: $table.lastPointAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastFlushAt => $composableBuilder(
      column: $table.lastFlushAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TrackingSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackingSessionsTable> {
  $$TrackingSessionsTableAnnotationComposer({
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

  GeneratedColumn<String> get remoteSessionId => $composableBuilder(
      column: $table.remoteSessionId, builder: (column) => column);

  GeneratedColumn<String> get clientSessionId => $composableBuilder(
      column: $table.clientSessionId, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get deviceContextJson => $composableBuilder(
      column: $table.deviceContextJson, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get pausedAt =>
      $composableBuilder(column: $table.pausedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get resumedAt =>
      $composableBuilder(column: $table.resumedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get abandonedAt => $composableBuilder(
      column: $table.abandonedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPointAt => $composableBuilder(
      column: $table.lastPointAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastFlushAt => $composableBuilder(
      column: $table.lastFlushAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TrackingSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrackingSessionsTable,
    TrackingSessionRow,
    $$TrackingSessionsTableFilterComposer,
    $$TrackingSessionsTableOrderingComposer,
    $$TrackingSessionsTableAnnotationComposer,
    $$TrackingSessionsTableCreateCompanionBuilder,
    $$TrackingSessionsTableUpdateCompanionBuilder,
    (
      TrackingSessionRow,
      BaseReferences<_$AppDatabase, $TrackingSessionsTable, TrackingSessionRow>
    ),
    TrackingSessionRow,
    PrefetchHooks Function()> {
  $$TrackingSessionsTableTableManager(
      _$AppDatabase db, $TrackingSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tripId = const Value.absent(),
            Value<String?> remoteSessionId = const Value.absent(),
            Value<String> clientSessionId = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<String?> timezone = const Value.absent(),
            Value<String> deviceContextJson = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> pausedAt = const Value.absent(),
            Value<DateTime?> resumedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<DateTime?> abandonedAt = const Value.absent(),
            Value<DateTime?> lastPointAt = const Value.absent(),
            Value<DateTime?> lastFlushAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackingSessionsCompanion(
            id: id,
            tripId: tripId,
            remoteSessionId: remoteSessionId,
            clientSessionId: clientSessionId,
            state: state,
            timezone: timezone,
            deviceContextJson: deviceContextJson,
            startedAt: startedAt,
            pausedAt: pausedAt,
            resumedAt: resumedAt,
            endedAt: endedAt,
            abandonedAt: abandonedAt,
            lastPointAt: lastPointAt,
            lastFlushAt: lastFlushAt,
            syncStatus: syncStatus,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tripId,
            Value<String?> remoteSessionId = const Value.absent(),
            required String clientSessionId,
            Value<String> state = const Value.absent(),
            Value<String?> timezone = const Value.absent(),
            Value<String> deviceContextJson = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> pausedAt = const Value.absent(),
            Value<DateTime?> resumedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<DateTime?> abandonedAt = const Value.absent(),
            Value<DateTime?> lastPointAt = const Value.absent(),
            Value<DateTime?> lastFlushAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required DateTime localUpdatedAt,
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackingSessionsCompanion.insert(
            id: id,
            tripId: tripId,
            remoteSessionId: remoteSessionId,
            clientSessionId: clientSessionId,
            state: state,
            timezone: timezone,
            deviceContextJson: deviceContextJson,
            startedAt: startedAt,
            pausedAt: pausedAt,
            resumedAt: resumedAt,
            endedAt: endedAt,
            abandonedAt: abandonedAt,
            lastPointAt: lastPointAt,
            lastFlushAt: lastFlushAt,
            syncStatus: syncStatus,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
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

typedef $$TrackingSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TrackingSessionsTable,
    TrackingSessionRow,
    $$TrackingSessionsTableFilterComposer,
    $$TrackingSessionsTableOrderingComposer,
    $$TrackingSessionsTableAnnotationComposer,
    $$TrackingSessionsTableCreateCompanionBuilder,
    $$TrackingSessionsTableUpdateCompanionBuilder,
    (
      TrackingSessionRow,
      BaseReferences<_$AppDatabase, $TrackingSessionsTable, TrackingSessionRow>
    ),
    TrackingSessionRow,
    PrefetchHooks Function()>;
typedef $$TrackingPointBatchesTableCreateCompanionBuilder
    = TrackingPointBatchesCompanion Function({
  required String id,
  required String tripId,
  required String sessionId,
  Value<String?> remoteSessionId,
  required String clientBatchId,
  Value<DateTime?> firstRecordedAt,
  Value<DateTime?> lastRecordedAt,
  Value<int> pointCount,
  Value<String> pointsJson,
  Value<String> status,
  Value<int> retryCount,
  Value<DateTime?> nextAttemptAt,
  Value<String?> workerSessionId,
  Value<String?> lastError,
  Value<String> syncStatus,
  required DateTime localUpdatedAt,
  Value<DateTime?> serverUpdatedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TrackingPointBatchesTableUpdateCompanionBuilder
    = TrackingPointBatchesCompanion Function({
  Value<String> id,
  Value<String> tripId,
  Value<String> sessionId,
  Value<String?> remoteSessionId,
  Value<String> clientBatchId,
  Value<DateTime?> firstRecordedAt,
  Value<DateTime?> lastRecordedAt,
  Value<int> pointCount,
  Value<String> pointsJson,
  Value<String> status,
  Value<int> retryCount,
  Value<DateTime?> nextAttemptAt,
  Value<String?> workerSessionId,
  Value<String?> lastError,
  Value<String> syncStatus,
  Value<DateTime> localUpdatedAt,
  Value<DateTime?> serverUpdatedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$TrackingPointBatchesTableFilterComposer
    extends Composer<_$AppDatabase, $TrackingPointBatchesTable> {
  $$TrackingPointBatchesTableFilterComposer({
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

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteSessionId => $composableBuilder(
      column: $table.remoteSessionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientBatchId => $composableBuilder(
      column: $table.clientBatchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get firstRecordedAt => $composableBuilder(
      column: $table.firstRecordedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastRecordedAt => $composableBuilder(
      column: $table.lastRecordedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pointCount => $composableBuilder(
      column: $table.pointCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pointsJson => $composableBuilder(
      column: $table.pointsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get workerSessionId => $composableBuilder(
      column: $table.workerSessionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TrackingPointBatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackingPointBatchesTable> {
  $$TrackingPointBatchesTableOrderingComposer({
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

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteSessionId => $composableBuilder(
      column: $table.remoteSessionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientBatchId => $composableBuilder(
      column: $table.clientBatchId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get firstRecordedAt => $composableBuilder(
      column: $table.firstRecordedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastRecordedAt => $composableBuilder(
      column: $table.lastRecordedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pointCount => $composableBuilder(
      column: $table.pointCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pointsJson => $composableBuilder(
      column: $table.pointsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get workerSessionId => $composableBuilder(
      column: $table.workerSessionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TrackingPointBatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackingPointBatchesTable> {
  $$TrackingPointBatchesTableAnnotationComposer({
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

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get remoteSessionId => $composableBuilder(
      column: $table.remoteSessionId, builder: (column) => column);

  GeneratedColumn<String> get clientBatchId => $composableBuilder(
      column: $table.clientBatchId, builder: (column) => column);

  GeneratedColumn<DateTime> get firstRecordedAt => $composableBuilder(
      column: $table.firstRecordedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastRecordedAt => $composableBuilder(
      column: $table.lastRecordedAt, builder: (column) => column);

  GeneratedColumn<int> get pointCount => $composableBuilder(
      column: $table.pointCount, builder: (column) => column);

  GeneratedColumn<String> get pointsJson => $composableBuilder(
      column: $table.pointsJson, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => column);

  GeneratedColumn<String> get workerSessionId => $composableBuilder(
      column: $table.workerSessionId, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TrackingPointBatchesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrackingPointBatchesTable,
    TrackingPointBatchRow,
    $$TrackingPointBatchesTableFilterComposer,
    $$TrackingPointBatchesTableOrderingComposer,
    $$TrackingPointBatchesTableAnnotationComposer,
    $$TrackingPointBatchesTableCreateCompanionBuilder,
    $$TrackingPointBatchesTableUpdateCompanionBuilder,
    (
      TrackingPointBatchRow,
      BaseReferences<_$AppDatabase, $TrackingPointBatchesTable,
          TrackingPointBatchRow>
    ),
    TrackingPointBatchRow,
    PrefetchHooks Function()> {
  $$TrackingPointBatchesTableTableManager(
      _$AppDatabase db, $TrackingPointBatchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackingPointBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackingPointBatchesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackingPointBatchesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tripId = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String?> remoteSessionId = const Value.absent(),
            Value<String> clientBatchId = const Value.absent(),
            Value<DateTime?> firstRecordedAt = const Value.absent(),
            Value<DateTime?> lastRecordedAt = const Value.absent(),
            Value<int> pointCount = const Value.absent(),
            Value<String> pointsJson = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime?> nextAttemptAt = const Value.absent(),
            Value<String?> workerSessionId = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackingPointBatchesCompanion(
            id: id,
            tripId: tripId,
            sessionId: sessionId,
            remoteSessionId: remoteSessionId,
            clientBatchId: clientBatchId,
            firstRecordedAt: firstRecordedAt,
            lastRecordedAt: lastRecordedAt,
            pointCount: pointCount,
            pointsJson: pointsJson,
            status: status,
            retryCount: retryCount,
            nextAttemptAt: nextAttemptAt,
            workerSessionId: workerSessionId,
            lastError: lastError,
            syncStatus: syncStatus,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tripId,
            required String sessionId,
            Value<String?> remoteSessionId = const Value.absent(),
            required String clientBatchId,
            Value<DateTime?> firstRecordedAt = const Value.absent(),
            Value<DateTime?> lastRecordedAt = const Value.absent(),
            Value<int> pointCount = const Value.absent(),
            Value<String> pointsJson = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime?> nextAttemptAt = const Value.absent(),
            Value<String?> workerSessionId = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required DateTime localUpdatedAt,
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackingPointBatchesCompanion.insert(
            id: id,
            tripId: tripId,
            sessionId: sessionId,
            remoteSessionId: remoteSessionId,
            clientBatchId: clientBatchId,
            firstRecordedAt: firstRecordedAt,
            lastRecordedAt: lastRecordedAt,
            pointCount: pointCount,
            pointsJson: pointsJson,
            status: status,
            retryCount: retryCount,
            nextAttemptAt: nextAttemptAt,
            workerSessionId: workerSessionId,
            lastError: lastError,
            syncStatus: syncStatus,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
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

typedef $$TrackingPointBatchesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $TrackingPointBatchesTable,
        TrackingPointBatchRow,
        $$TrackingPointBatchesTableFilterComposer,
        $$TrackingPointBatchesTableOrderingComposer,
        $$TrackingPointBatchesTableAnnotationComposer,
        $$TrackingPointBatchesTableCreateCompanionBuilder,
        $$TrackingPointBatchesTableUpdateCompanionBuilder,
        (
          TrackingPointBatchRow,
          BaseReferences<_$AppDatabase, $TrackingPointBatchesTable,
              TrackingPointBatchRow>
        ),
        TrackingPointBatchRow,
        PrefetchHooks Function()>;
typedef $$TrackingCandidatesTableCreateCompanionBuilder
    = TrackingCandidatesCompanion Function({
  required String id,
  required String tripId,
  Value<String?> sessionId,
  required String fingerprint,
  Value<String> status,
  Value<double?> confidence,
  Value<String?> suggestedName,
  Value<double?> suggestedLatitude,
  Value<double?> suggestedLongitude,
  Value<DateTime?> startedAt,
  Value<DateTime?> endedAt,
  Value<String?> confirmedTripPlaceId,
  Value<String?> rejectedReason,
  Value<DateTime?> snoozedUntil,
  Value<DateTime?> cooldownUntil,
  Value<String> payloadJson,
  Value<String?> notificationState,
  Value<String> actionState,
  Value<String?> actionType,
  Value<String?> actionClientEventId,
  Value<DateTime?> actionQueuedAt,
  Value<DateTime?> actionSyncedAt,
  Value<String> syncStatus,
  required DateTime localUpdatedAt,
  Value<DateTime?> serverUpdatedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TrackingCandidatesTableUpdateCompanionBuilder
    = TrackingCandidatesCompanion Function({
  Value<String> id,
  Value<String> tripId,
  Value<String?> sessionId,
  Value<String> fingerprint,
  Value<String> status,
  Value<double?> confidence,
  Value<String?> suggestedName,
  Value<double?> suggestedLatitude,
  Value<double?> suggestedLongitude,
  Value<DateTime?> startedAt,
  Value<DateTime?> endedAt,
  Value<String?> confirmedTripPlaceId,
  Value<String?> rejectedReason,
  Value<DateTime?> snoozedUntil,
  Value<DateTime?> cooldownUntil,
  Value<String> payloadJson,
  Value<String?> notificationState,
  Value<String> actionState,
  Value<String?> actionType,
  Value<String?> actionClientEventId,
  Value<DateTime?> actionQueuedAt,
  Value<DateTime?> actionSyncedAt,
  Value<String> syncStatus,
  Value<DateTime> localUpdatedAt,
  Value<DateTime?> serverUpdatedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$TrackingCandidatesTableFilterComposer
    extends Composer<_$AppDatabase, $TrackingCandidatesTable> {
  $$TrackingCandidatesTableFilterComposer({
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

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fingerprint => $composableBuilder(
      column: $table.fingerprint, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get suggestedName => $composableBuilder(
      column: $table.suggestedName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get suggestedLatitude => $composableBuilder(
      column: $table.suggestedLatitude,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get suggestedLongitude => $composableBuilder(
      column: $table.suggestedLongitude,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get confirmedTripPlaceId => $composableBuilder(
      column: $table.confirmedTripPlaceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rejectedReason => $composableBuilder(
      column: $table.rejectedReason,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get snoozedUntil => $composableBuilder(
      column: $table.snoozedUntil, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cooldownUntil => $composableBuilder(
      column: $table.cooldownUntil, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notificationState => $composableBuilder(
      column: $table.notificationState,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionState => $composableBuilder(
      column: $table.actionState, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionClientEventId => $composableBuilder(
      column: $table.actionClientEventId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get actionQueuedAt => $composableBuilder(
      column: $table.actionQueuedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get actionSyncedAt => $composableBuilder(
      column: $table.actionSyncedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TrackingCandidatesTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackingCandidatesTable> {
  $$TrackingCandidatesTableOrderingComposer({
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

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fingerprint => $composableBuilder(
      column: $table.fingerprint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get suggestedName => $composableBuilder(
      column: $table.suggestedName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get suggestedLatitude => $composableBuilder(
      column: $table.suggestedLatitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get suggestedLongitude => $composableBuilder(
      column: $table.suggestedLongitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get confirmedTripPlaceId => $composableBuilder(
      column: $table.confirmedTripPlaceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rejectedReason => $composableBuilder(
      column: $table.rejectedReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get snoozedUntil => $composableBuilder(
      column: $table.snoozedUntil,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cooldownUntil => $composableBuilder(
      column: $table.cooldownUntil,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notificationState => $composableBuilder(
      column: $table.notificationState,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionState => $composableBuilder(
      column: $table.actionState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionClientEventId => $composableBuilder(
      column: $table.actionClientEventId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get actionQueuedAt => $composableBuilder(
      column: $table.actionQueuedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get actionSyncedAt => $composableBuilder(
      column: $table.actionSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TrackingCandidatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackingCandidatesTable> {
  $$TrackingCandidatesTableAnnotationComposer({
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

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get fingerprint => $composableBuilder(
      column: $table.fingerprint, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<String> get suggestedName => $composableBuilder(
      column: $table.suggestedName, builder: (column) => column);

  GeneratedColumn<double> get suggestedLatitude => $composableBuilder(
      column: $table.suggestedLatitude, builder: (column) => column);

  GeneratedColumn<double> get suggestedLongitude => $composableBuilder(
      column: $table.suggestedLongitude, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get confirmedTripPlaceId => $composableBuilder(
      column: $table.confirmedTripPlaceId, builder: (column) => column);

  GeneratedColumn<String> get rejectedReason => $composableBuilder(
      column: $table.rejectedReason, builder: (column) => column);

  GeneratedColumn<DateTime> get snoozedUntil => $composableBuilder(
      column: $table.snoozedUntil, builder: (column) => column);

  GeneratedColumn<DateTime> get cooldownUntil => $composableBuilder(
      column: $table.cooldownUntil, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get notificationState => $composableBuilder(
      column: $table.notificationState, builder: (column) => column);

  GeneratedColumn<String> get actionState => $composableBuilder(
      column: $table.actionState, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => column);

  GeneratedColumn<String> get actionClientEventId => $composableBuilder(
      column: $table.actionClientEventId, builder: (column) => column);

  GeneratedColumn<DateTime> get actionQueuedAt => $composableBuilder(
      column: $table.actionQueuedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get actionSyncedAt => $composableBuilder(
      column: $table.actionSyncedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TrackingCandidatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrackingCandidatesTable,
    TrackingCandidateRow,
    $$TrackingCandidatesTableFilterComposer,
    $$TrackingCandidatesTableOrderingComposer,
    $$TrackingCandidatesTableAnnotationComposer,
    $$TrackingCandidatesTableCreateCompanionBuilder,
    $$TrackingCandidatesTableUpdateCompanionBuilder,
    (
      TrackingCandidateRow,
      BaseReferences<_$AppDatabase, $TrackingCandidatesTable,
          TrackingCandidateRow>
    ),
    TrackingCandidateRow,
    PrefetchHooks Function()> {
  $$TrackingCandidatesTableTableManager(
      _$AppDatabase db, $TrackingCandidatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackingCandidatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackingCandidatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackingCandidatesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tripId = const Value.absent(),
            Value<String?> sessionId = const Value.absent(),
            Value<String> fingerprint = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<double?> confidence = const Value.absent(),
            Value<String?> suggestedName = const Value.absent(),
            Value<double?> suggestedLatitude = const Value.absent(),
            Value<double?> suggestedLongitude = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<String?> confirmedTripPlaceId = const Value.absent(),
            Value<String?> rejectedReason = const Value.absent(),
            Value<DateTime?> snoozedUntil = const Value.absent(),
            Value<DateTime?> cooldownUntil = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String?> notificationState = const Value.absent(),
            Value<String> actionState = const Value.absent(),
            Value<String?> actionType = const Value.absent(),
            Value<String?> actionClientEventId = const Value.absent(),
            Value<DateTime?> actionQueuedAt = const Value.absent(),
            Value<DateTime?> actionSyncedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackingCandidatesCompanion(
            id: id,
            tripId: tripId,
            sessionId: sessionId,
            fingerprint: fingerprint,
            status: status,
            confidence: confidence,
            suggestedName: suggestedName,
            suggestedLatitude: suggestedLatitude,
            suggestedLongitude: suggestedLongitude,
            startedAt: startedAt,
            endedAt: endedAt,
            confirmedTripPlaceId: confirmedTripPlaceId,
            rejectedReason: rejectedReason,
            snoozedUntil: snoozedUntil,
            cooldownUntil: cooldownUntil,
            payloadJson: payloadJson,
            notificationState: notificationState,
            actionState: actionState,
            actionType: actionType,
            actionClientEventId: actionClientEventId,
            actionQueuedAt: actionQueuedAt,
            actionSyncedAt: actionSyncedAt,
            syncStatus: syncStatus,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tripId,
            Value<String?> sessionId = const Value.absent(),
            required String fingerprint,
            Value<String> status = const Value.absent(),
            Value<double?> confidence = const Value.absent(),
            Value<String?> suggestedName = const Value.absent(),
            Value<double?> suggestedLatitude = const Value.absent(),
            Value<double?> suggestedLongitude = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<String?> confirmedTripPlaceId = const Value.absent(),
            Value<String?> rejectedReason = const Value.absent(),
            Value<DateTime?> snoozedUntil = const Value.absent(),
            Value<DateTime?> cooldownUntil = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String?> notificationState = const Value.absent(),
            Value<String> actionState = const Value.absent(),
            Value<String?> actionType = const Value.absent(),
            Value<String?> actionClientEventId = const Value.absent(),
            Value<DateTime?> actionQueuedAt = const Value.absent(),
            Value<DateTime?> actionSyncedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required DateTime localUpdatedAt,
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackingCandidatesCompanion.insert(
            id: id,
            tripId: tripId,
            sessionId: sessionId,
            fingerprint: fingerprint,
            status: status,
            confidence: confidence,
            suggestedName: suggestedName,
            suggestedLatitude: suggestedLatitude,
            suggestedLongitude: suggestedLongitude,
            startedAt: startedAt,
            endedAt: endedAt,
            confirmedTripPlaceId: confirmedTripPlaceId,
            rejectedReason: rejectedReason,
            snoozedUntil: snoozedUntil,
            cooldownUntil: cooldownUntil,
            payloadJson: payloadJson,
            notificationState: notificationState,
            actionState: actionState,
            actionType: actionType,
            actionClientEventId: actionClientEventId,
            actionQueuedAt: actionQueuedAt,
            actionSyncedAt: actionSyncedAt,
            syncStatus: syncStatus,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
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

typedef $$TrackingCandidatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TrackingCandidatesTable,
    TrackingCandidateRow,
    $$TrackingCandidatesTableFilterComposer,
    $$TrackingCandidatesTableOrderingComposer,
    $$TrackingCandidatesTableAnnotationComposer,
    $$TrackingCandidatesTableCreateCompanionBuilder,
    $$TrackingCandidatesTableUpdateCompanionBuilder,
    (
      TrackingCandidateRow,
      BaseReferences<_$AppDatabase, $TrackingCandidatesTable,
          TrackingCandidateRow>
    ),
    TrackingCandidateRow,
    PrefetchHooks Function()>;
typedef $$TrackingMomentsTableCreateCompanionBuilder = TrackingMomentsCompanion
    Function({
  required String id,
  required String tripId,
  Value<String?> candidateId,
  Value<String?> linkedTripPlaceId,
  Value<String> source,
  Value<double?> confidence,
  required DateTime capturedAt,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> note,
  Value<String> mediaRefsJson,
  Value<String> extraPayloadJson,
  Value<String> lockedFieldsJson,
  Value<String?> pendingOperation,
  Value<String?> clientEventId,
  Value<String> syncStatus,
  required DateTime localUpdatedAt,
  Value<DateTime?> serverUpdatedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TrackingMomentsTableUpdateCompanionBuilder = TrackingMomentsCompanion
    Function({
  Value<String> id,
  Value<String> tripId,
  Value<String?> candidateId,
  Value<String?> linkedTripPlaceId,
  Value<String> source,
  Value<double?> confidence,
  Value<DateTime> capturedAt,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> note,
  Value<String> mediaRefsJson,
  Value<String> extraPayloadJson,
  Value<String> lockedFieldsJson,
  Value<String?> pendingOperation,
  Value<String?> clientEventId,
  Value<String> syncStatus,
  Value<DateTime> localUpdatedAt,
  Value<DateTime?> serverUpdatedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$TrackingMomentsTableFilterComposer
    extends Composer<_$AppDatabase, $TrackingMomentsTable> {
  $$TrackingMomentsTableFilterComposer({
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

  ColumnFilters<String> get candidateId => $composableBuilder(
      column: $table.candidateId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkedTripPlaceId => $composableBuilder(
      column: $table.linkedTripPlaceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaRefsJson => $composableBuilder(
      column: $table.mediaRefsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extraPayloadJson => $composableBuilder(
      column: $table.extraPayloadJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lockedFieldsJson => $composableBuilder(
      column: $table.lockedFieldsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pendingOperation => $composableBuilder(
      column: $table.pendingOperation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientEventId => $composableBuilder(
      column: $table.clientEventId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TrackingMomentsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackingMomentsTable> {
  $$TrackingMomentsTableOrderingComposer({
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

  ColumnOrderings<String> get candidateId => $composableBuilder(
      column: $table.candidateId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkedTripPlaceId => $composableBuilder(
      column: $table.linkedTripPlaceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaRefsJson => $composableBuilder(
      column: $table.mediaRefsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extraPayloadJson => $composableBuilder(
      column: $table.extraPayloadJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lockedFieldsJson => $composableBuilder(
      column: $table.lockedFieldsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pendingOperation => $composableBuilder(
      column: $table.pendingOperation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientEventId => $composableBuilder(
      column: $table.clientEventId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TrackingMomentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackingMomentsTable> {
  $$TrackingMomentsTableAnnotationComposer({
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

  GeneratedColumn<String> get candidateId => $composableBuilder(
      column: $table.candidateId, builder: (column) => column);

  GeneratedColumn<String> get linkedTripPlaceId => $composableBuilder(
      column: $table.linkedTripPlaceId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get mediaRefsJson => $composableBuilder(
      column: $table.mediaRefsJson, builder: (column) => column);

  GeneratedColumn<String> get extraPayloadJson => $composableBuilder(
      column: $table.extraPayloadJson, builder: (column) => column);

  GeneratedColumn<String> get lockedFieldsJson => $composableBuilder(
      column: $table.lockedFieldsJson, builder: (column) => column);

  GeneratedColumn<String> get pendingOperation => $composableBuilder(
      column: $table.pendingOperation, builder: (column) => column);

  GeneratedColumn<String> get clientEventId => $composableBuilder(
      column: $table.clientEventId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TrackingMomentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrackingMomentsTable,
    TrackingMomentRow,
    $$TrackingMomentsTableFilterComposer,
    $$TrackingMomentsTableOrderingComposer,
    $$TrackingMomentsTableAnnotationComposer,
    $$TrackingMomentsTableCreateCompanionBuilder,
    $$TrackingMomentsTableUpdateCompanionBuilder,
    (
      TrackingMomentRow,
      BaseReferences<_$AppDatabase, $TrackingMomentsTable, TrackingMomentRow>
    ),
    TrackingMomentRow,
    PrefetchHooks Function()> {
  $$TrackingMomentsTableTableManager(
      _$AppDatabase db, $TrackingMomentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackingMomentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackingMomentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackingMomentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tripId = const Value.absent(),
            Value<String?> candidateId = const Value.absent(),
            Value<String?> linkedTripPlaceId = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<double?> confidence = const Value.absent(),
            Value<DateTime> capturedAt = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String> mediaRefsJson = const Value.absent(),
            Value<String> extraPayloadJson = const Value.absent(),
            Value<String> lockedFieldsJson = const Value.absent(),
            Value<String?> pendingOperation = const Value.absent(),
            Value<String?> clientEventId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackingMomentsCompanion(
            id: id,
            tripId: tripId,
            candidateId: candidateId,
            linkedTripPlaceId: linkedTripPlaceId,
            source: source,
            confidence: confidence,
            capturedAt: capturedAt,
            latitude: latitude,
            longitude: longitude,
            note: note,
            mediaRefsJson: mediaRefsJson,
            extraPayloadJson: extraPayloadJson,
            lockedFieldsJson: lockedFieldsJson,
            pendingOperation: pendingOperation,
            clientEventId: clientEventId,
            syncStatus: syncStatus,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tripId,
            Value<String?> candidateId = const Value.absent(),
            Value<String?> linkedTripPlaceId = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<double?> confidence = const Value.absent(),
            required DateTime capturedAt,
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String> mediaRefsJson = const Value.absent(),
            Value<String> extraPayloadJson = const Value.absent(),
            Value<String> lockedFieldsJson = const Value.absent(),
            Value<String?> pendingOperation = const Value.absent(),
            Value<String?> clientEventId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required DateTime localUpdatedAt,
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackingMomentsCompanion.insert(
            id: id,
            tripId: tripId,
            candidateId: candidateId,
            linkedTripPlaceId: linkedTripPlaceId,
            source: source,
            confidence: confidence,
            capturedAt: capturedAt,
            latitude: latitude,
            longitude: longitude,
            note: note,
            mediaRefsJson: mediaRefsJson,
            extraPayloadJson: extraPayloadJson,
            lockedFieldsJson: lockedFieldsJson,
            pendingOperation: pendingOperation,
            clientEventId: clientEventId,
            syncStatus: syncStatus,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
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

typedef $$TrackingMomentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TrackingMomentsTable,
    TrackingMomentRow,
    $$TrackingMomentsTableFilterComposer,
    $$TrackingMomentsTableOrderingComposer,
    $$TrackingMomentsTableAnnotationComposer,
    $$TrackingMomentsTableCreateCompanionBuilder,
    $$TrackingMomentsTableUpdateCompanionBuilder,
    (
      TrackingMomentRow,
      BaseReferences<_$AppDatabase, $TrackingMomentsTable, TrackingMomentRow>
    ),
    TrackingMomentRow,
    PrefetchHooks Function()>;
typedef $$TrackingEventsTableCreateCompanionBuilder = TrackingEventsCompanion
    Function({
  required String id,
  required String tripId,
  required String eventType,
  Value<String?> note,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String> payloadJson,
  Value<String?> clientEventId,
  Value<String?> resolvedPlaceId,
  Value<double?> bindConfidence,
  Value<String?> resolverReasonCode,
  Value<String> resolverState,
  Value<int> resolverVersion,
  Value<DateTime?> resolvedAt,
  Value<String?> resolutionHintJson,
  Value<String> syncStatus,
  required DateTime localUpdatedAt,
  Value<DateTime?> serverUpdatedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TrackingEventsTableUpdateCompanionBuilder = TrackingEventsCompanion
    Function({
  Value<String> id,
  Value<String> tripId,
  Value<String> eventType,
  Value<String?> note,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String> payloadJson,
  Value<String?> clientEventId,
  Value<String?> resolvedPlaceId,
  Value<double?> bindConfidence,
  Value<String?> resolverReasonCode,
  Value<String> resolverState,
  Value<int> resolverVersion,
  Value<DateTime?> resolvedAt,
  Value<String?> resolutionHintJson,
  Value<String> syncStatus,
  Value<DateTime> localUpdatedAt,
  Value<DateTime?> serverUpdatedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$TrackingEventsTableFilterComposer
    extends Composer<_$AppDatabase, $TrackingEventsTable> {
  $$TrackingEventsTableFilterComposer({
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

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientEventId => $composableBuilder(
      column: $table.clientEventId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resolvedPlaceId => $composableBuilder(
      column: $table.resolvedPlaceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get bindConfidence => $composableBuilder(
      column: $table.bindConfidence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resolverReasonCode => $composableBuilder(
      column: $table.resolverReasonCode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resolverState => $composableBuilder(
      column: $table.resolverState, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get resolverVersion => $composableBuilder(
      column: $table.resolverVersion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
      column: $table.resolvedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resolutionHintJson => $composableBuilder(
      column: $table.resolutionHintJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TrackingEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackingEventsTable> {
  $$TrackingEventsTableOrderingComposer({
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

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientEventId => $composableBuilder(
      column: $table.clientEventId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resolvedPlaceId => $composableBuilder(
      column: $table.resolvedPlaceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get bindConfidence => $composableBuilder(
      column: $table.bindConfidence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resolverReasonCode => $composableBuilder(
      column: $table.resolverReasonCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resolverState => $composableBuilder(
      column: $table.resolverState,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get resolverVersion => $composableBuilder(
      column: $table.resolverVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
      column: $table.resolvedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resolutionHintJson => $composableBuilder(
      column: $table.resolutionHintJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TrackingEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackingEventsTable> {
  $$TrackingEventsTableAnnotationComposer({
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

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get clientEventId => $composableBuilder(
      column: $table.clientEventId, builder: (column) => column);

  GeneratedColumn<String> get resolvedPlaceId => $composableBuilder(
      column: $table.resolvedPlaceId, builder: (column) => column);

  GeneratedColumn<double> get bindConfidence => $composableBuilder(
      column: $table.bindConfidence, builder: (column) => column);

  GeneratedColumn<String> get resolverReasonCode => $composableBuilder(
      column: $table.resolverReasonCode, builder: (column) => column);

  GeneratedColumn<String> get resolverState => $composableBuilder(
      column: $table.resolverState, builder: (column) => column);

  GeneratedColumn<int> get resolverVersion => $composableBuilder(
      column: $table.resolverVersion, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
      column: $table.resolvedAt, builder: (column) => column);

  GeneratedColumn<String> get resolutionHintJson => $composableBuilder(
      column: $table.resolutionHintJson, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TrackingEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrackingEventsTable,
    TrackingEventRow,
    $$TrackingEventsTableFilterComposer,
    $$TrackingEventsTableOrderingComposer,
    $$TrackingEventsTableAnnotationComposer,
    $$TrackingEventsTableCreateCompanionBuilder,
    $$TrackingEventsTableUpdateCompanionBuilder,
    (
      TrackingEventRow,
      BaseReferences<_$AppDatabase, $TrackingEventsTable, TrackingEventRow>
    ),
    TrackingEventRow,
    PrefetchHooks Function()> {
  $$TrackingEventsTableTableManager(
      _$AppDatabase db, $TrackingEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackingEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackingEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackingEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tripId = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String?> clientEventId = const Value.absent(),
            Value<String?> resolvedPlaceId = const Value.absent(),
            Value<double?> bindConfidence = const Value.absent(),
            Value<String?> resolverReasonCode = const Value.absent(),
            Value<String> resolverState = const Value.absent(),
            Value<int> resolverVersion = const Value.absent(),
            Value<DateTime?> resolvedAt = const Value.absent(),
            Value<String?> resolutionHintJson = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackingEventsCompanion(
            id: id,
            tripId: tripId,
            eventType: eventType,
            note: note,
            latitude: latitude,
            longitude: longitude,
            payloadJson: payloadJson,
            clientEventId: clientEventId,
            resolvedPlaceId: resolvedPlaceId,
            bindConfidence: bindConfidence,
            resolverReasonCode: resolverReasonCode,
            resolverState: resolverState,
            resolverVersion: resolverVersion,
            resolvedAt: resolvedAt,
            resolutionHintJson: resolutionHintJson,
            syncStatus: syncStatus,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tripId,
            required String eventType,
            Value<String?> note = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String?> clientEventId = const Value.absent(),
            Value<String?> resolvedPlaceId = const Value.absent(),
            Value<double?> bindConfidence = const Value.absent(),
            Value<String?> resolverReasonCode = const Value.absent(),
            Value<String> resolverState = const Value.absent(),
            Value<int> resolverVersion = const Value.absent(),
            Value<DateTime?> resolvedAt = const Value.absent(),
            Value<String?> resolutionHintJson = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required DateTime localUpdatedAt,
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackingEventsCompanion.insert(
            id: id,
            tripId: tripId,
            eventType: eventType,
            note: note,
            latitude: latitude,
            longitude: longitude,
            payloadJson: payloadJson,
            clientEventId: clientEventId,
            resolvedPlaceId: resolvedPlaceId,
            bindConfidence: bindConfidence,
            resolverReasonCode: resolverReasonCode,
            resolverState: resolverState,
            resolverVersion: resolverVersion,
            resolvedAt: resolvedAt,
            resolutionHintJson: resolutionHintJson,
            syncStatus: syncStatus,
            localUpdatedAt: localUpdatedAt,
            serverUpdatedAt: serverUpdatedAt,
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

typedef $$TrackingEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TrackingEventsTable,
    TrackingEventRow,
    $$TrackingEventsTableFilterComposer,
    $$TrackingEventsTableOrderingComposer,
    $$TrackingEventsTableAnnotationComposer,
    $$TrackingEventsTableCreateCompanionBuilder,
    $$TrackingEventsTableUpdateCompanionBuilder,
    (
      TrackingEventRow,
      BaseReferences<_$AppDatabase, $TrackingEventsTable, TrackingEventRow>
    ),
    TrackingEventRow,
    PrefetchHooks Function()>;
typedef $$TrackingEventMediaTableCreateCompanionBuilder
    = TrackingEventMediaCompanion Function({
  required String id,
  required String tripId,
  required String eventId,
  Value<String> bindMode,
  Value<String> bindState,
  Value<String?> tripPlaceId,
  Value<double?> anchorLatitude,
  Value<double?> anchorLongitude,
  required DateTime capturedAt,
  required String localPath,
  Value<String?> uploadRef,
  Value<String?> remoteMediaId,
  Value<String?> mimeType,
  Value<int?> fileSizeBytes,
  Value<int?> width,
  Value<int?> height,
  Value<String> uploadStatus,
  Value<double> uploadProgress,
  Value<int> retryCount,
  Value<String?> errorMessage,
  Value<DateTime?> nextAttemptAt,
  Value<String?> workerSessionId,
  Value<String> payloadJson,
  Value<String> syncStatus,
  required DateTime localUpdatedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TrackingEventMediaTableUpdateCompanionBuilder
    = TrackingEventMediaCompanion Function({
  Value<String> id,
  Value<String> tripId,
  Value<String> eventId,
  Value<String> bindMode,
  Value<String> bindState,
  Value<String?> tripPlaceId,
  Value<double?> anchorLatitude,
  Value<double?> anchorLongitude,
  Value<DateTime> capturedAt,
  Value<String> localPath,
  Value<String?> uploadRef,
  Value<String?> remoteMediaId,
  Value<String?> mimeType,
  Value<int?> fileSizeBytes,
  Value<int?> width,
  Value<int?> height,
  Value<String> uploadStatus,
  Value<double> uploadProgress,
  Value<int> retryCount,
  Value<String?> errorMessage,
  Value<DateTime?> nextAttemptAt,
  Value<String?> workerSessionId,
  Value<String> payloadJson,
  Value<String> syncStatus,
  Value<DateTime> localUpdatedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$TrackingEventMediaTableFilterComposer
    extends Composer<_$AppDatabase, $TrackingEventMediaTable> {
  $$TrackingEventMediaTableFilterComposer({
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

  ColumnFilters<String> get eventId => $composableBuilder(
      column: $table.eventId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bindMode => $composableBuilder(
      column: $table.bindMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bindState => $composableBuilder(
      column: $table.bindState, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tripPlaceId => $composableBuilder(
      column: $table.tripPlaceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get anchorLatitude => $composableBuilder(
      column: $table.anchorLatitude,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get anchorLongitude => $composableBuilder(
      column: $table.anchorLongitude,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uploadRef => $composableBuilder(
      column: $table.uploadRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteMediaId => $composableBuilder(
      column: $table.remoteMediaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get width => $composableBuilder(
      column: $table.width, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uploadStatus => $composableBuilder(
      column: $table.uploadStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get uploadProgress => $composableBuilder(
      column: $table.uploadProgress,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get workerSessionId => $composableBuilder(
      column: $table.workerSessionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TrackingEventMediaTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackingEventMediaTable> {
  $$TrackingEventMediaTableOrderingComposer({
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

  ColumnOrderings<String> get eventId => $composableBuilder(
      column: $table.eventId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bindMode => $composableBuilder(
      column: $table.bindMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bindState => $composableBuilder(
      column: $table.bindState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tripPlaceId => $composableBuilder(
      column: $table.tripPlaceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get anchorLatitude => $composableBuilder(
      column: $table.anchorLatitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get anchorLongitude => $composableBuilder(
      column: $table.anchorLongitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uploadRef => $composableBuilder(
      column: $table.uploadRef, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteMediaId => $composableBuilder(
      column: $table.remoteMediaId,
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

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get workerSessionId => $composableBuilder(
      column: $table.workerSessionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TrackingEventMediaTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackingEventMediaTable> {
  $$TrackingEventMediaTableAnnotationComposer({
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

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get bindMode =>
      $composableBuilder(column: $table.bindMode, builder: (column) => column);

  GeneratedColumn<String> get bindState =>
      $composableBuilder(column: $table.bindState, builder: (column) => column);

  GeneratedColumn<String> get tripPlaceId => $composableBuilder(
      column: $table.tripPlaceId, builder: (column) => column);

  GeneratedColumn<double> get anchorLatitude => $composableBuilder(
      column: $table.anchorLatitude, builder: (column) => column);

  GeneratedColumn<double> get anchorLongitude => $composableBuilder(
      column: $table.anchorLongitude, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get uploadRef =>
      $composableBuilder(column: $table.uploadRef, builder: (column) => column);

  GeneratedColumn<String> get remoteMediaId => $composableBuilder(
      column: $table.remoteMediaId, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get uploadStatus => $composableBuilder(
      column: $table.uploadStatus, builder: (column) => column);

  GeneratedColumn<double> get uploadProgress => $composableBuilder(
      column: $table.uploadProgress, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => column);

  GeneratedColumn<String> get workerSessionId => $composableBuilder(
      column: $table.workerSessionId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TrackingEventMediaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrackingEventMediaTable,
    TrackingEventMediaRow,
    $$TrackingEventMediaTableFilterComposer,
    $$TrackingEventMediaTableOrderingComposer,
    $$TrackingEventMediaTableAnnotationComposer,
    $$TrackingEventMediaTableCreateCompanionBuilder,
    $$TrackingEventMediaTableUpdateCompanionBuilder,
    (
      TrackingEventMediaRow,
      BaseReferences<_$AppDatabase, $TrackingEventMediaTable,
          TrackingEventMediaRow>
    ),
    TrackingEventMediaRow,
    PrefetchHooks Function()> {
  $$TrackingEventMediaTableTableManager(
      _$AppDatabase db, $TrackingEventMediaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackingEventMediaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackingEventMediaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackingEventMediaTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tripId = const Value.absent(),
            Value<String> eventId = const Value.absent(),
            Value<String> bindMode = const Value.absent(),
            Value<String> bindState = const Value.absent(),
            Value<String?> tripPlaceId = const Value.absent(),
            Value<double?> anchorLatitude = const Value.absent(),
            Value<double?> anchorLongitude = const Value.absent(),
            Value<DateTime> capturedAt = const Value.absent(),
            Value<String> localPath = const Value.absent(),
            Value<String?> uploadRef = const Value.absent(),
            Value<String?> remoteMediaId = const Value.absent(),
            Value<String?> mimeType = const Value.absent(),
            Value<int?> fileSizeBytes = const Value.absent(),
            Value<int?> width = const Value.absent(),
            Value<int?> height = const Value.absent(),
            Value<String> uploadStatus = const Value.absent(),
            Value<double> uploadProgress = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<DateTime?> nextAttemptAt = const Value.absent(),
            Value<String?> workerSessionId = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackingEventMediaCompanion(
            id: id,
            tripId: tripId,
            eventId: eventId,
            bindMode: bindMode,
            bindState: bindState,
            tripPlaceId: tripPlaceId,
            anchorLatitude: anchorLatitude,
            anchorLongitude: anchorLongitude,
            capturedAt: capturedAt,
            localPath: localPath,
            uploadRef: uploadRef,
            remoteMediaId: remoteMediaId,
            mimeType: mimeType,
            fileSizeBytes: fileSizeBytes,
            width: width,
            height: height,
            uploadStatus: uploadStatus,
            uploadProgress: uploadProgress,
            retryCount: retryCount,
            errorMessage: errorMessage,
            nextAttemptAt: nextAttemptAt,
            workerSessionId: workerSessionId,
            payloadJson: payloadJson,
            syncStatus: syncStatus,
            localUpdatedAt: localUpdatedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tripId,
            required String eventId,
            Value<String> bindMode = const Value.absent(),
            Value<String> bindState = const Value.absent(),
            Value<String?> tripPlaceId = const Value.absent(),
            Value<double?> anchorLatitude = const Value.absent(),
            Value<double?> anchorLongitude = const Value.absent(),
            required DateTime capturedAt,
            required String localPath,
            Value<String?> uploadRef = const Value.absent(),
            Value<String?> remoteMediaId = const Value.absent(),
            Value<String?> mimeType = const Value.absent(),
            Value<int?> fileSizeBytes = const Value.absent(),
            Value<int?> width = const Value.absent(),
            Value<int?> height = const Value.absent(),
            Value<String> uploadStatus = const Value.absent(),
            Value<double> uploadProgress = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<DateTime?> nextAttemptAt = const Value.absent(),
            Value<String?> workerSessionId = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required DateTime localUpdatedAt,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackingEventMediaCompanion.insert(
            id: id,
            tripId: tripId,
            eventId: eventId,
            bindMode: bindMode,
            bindState: bindState,
            tripPlaceId: tripPlaceId,
            anchorLatitude: anchorLatitude,
            anchorLongitude: anchorLongitude,
            capturedAt: capturedAt,
            localPath: localPath,
            uploadRef: uploadRef,
            remoteMediaId: remoteMediaId,
            mimeType: mimeType,
            fileSizeBytes: fileSizeBytes,
            width: width,
            height: height,
            uploadStatus: uploadStatus,
            uploadProgress: uploadProgress,
            retryCount: retryCount,
            errorMessage: errorMessage,
            nextAttemptAt: nextAttemptAt,
            workerSessionId: workerSessionId,
            payloadJson: payloadJson,
            syncStatus: syncStatus,
            localUpdatedAt: localUpdatedAt,
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

typedef $$TrackingEventMediaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TrackingEventMediaTable,
    TrackingEventMediaRow,
    $$TrackingEventMediaTableFilterComposer,
    $$TrackingEventMediaTableOrderingComposer,
    $$TrackingEventMediaTableAnnotationComposer,
    $$TrackingEventMediaTableCreateCompanionBuilder,
    $$TrackingEventMediaTableUpdateCompanionBuilder,
    (
      TrackingEventMediaRow,
      BaseReferences<_$AppDatabase, $TrackingEventMediaTable,
          TrackingEventMediaRow>
    ),
    TrackingEventMediaRow,
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
  $$TrackingSessionsTableTableManager get trackingSessions =>
      $$TrackingSessionsTableTableManager(_db, _db.trackingSessions);
  $$TrackingPointBatchesTableTableManager get trackingPointBatches =>
      $$TrackingPointBatchesTableTableManager(_db, _db.trackingPointBatches);
  $$TrackingCandidatesTableTableManager get trackingCandidates =>
      $$TrackingCandidatesTableTableManager(_db, _db.trackingCandidates);
  $$TrackingMomentsTableTableManager get trackingMoments =>
      $$TrackingMomentsTableTableManager(_db, _db.trackingMoments);
  $$TrackingEventsTableTableManager get trackingEvents =>
      $$TrackingEventsTableTableManager(_db, _db.trackingEvents);
  $$TrackingEventMediaTableTableManager get trackingEventMedia =>
      $$TrackingEventMediaTableTableManager(_db, _db.trackingEventMedia);
}
