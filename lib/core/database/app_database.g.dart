// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WheelsTable extends Wheels with TableInfo<$WheelsTable, WheelRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WheelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 8,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, code, name, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wheels';
  @override
  VerificationContext validateIntegrity(
    Insertable<WheelRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WheelRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WheelRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $WheelsTable createAlias(String alias) {
    return $WheelsTable(attachedDatabase, alias);
  }
}

class WheelRow extends DataClass implements Insertable<WheelRow> {
  final int id;
  final String code;
  final String name;
  final int sortOrder;
  const WheelRow({
    required this.id,
    required this.code,
    required this.name,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  WheelsCompanion toCompanion(bool nullToAbsent) {
    return WheelsCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      sortOrder: Value(sortOrder),
    );
  }

  factory WheelRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WheelRow(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  WheelRow copyWith({int? id, String? code, String? name, int? sortOrder}) =>
      WheelRow(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  WheelRow copyWithCompanion(WheelsCompanion data) {
    return WheelRow(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WheelRow(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, name, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WheelRow &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder);
}

class WheelsCompanion extends UpdateCompanion<WheelRow> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> name;
  final Value<int> sortOrder;
  const WheelsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  WheelsCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String name,
    required int sortOrder,
  }) : code = Value(code),
       name = Value(name),
       sortOrder = Value(sortOrder);
  static Insertable<WheelRow> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  WheelsCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<String>? name,
    Value<int>? sortOrder,
  }) {
    return WheelsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WheelsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $DataSourcesTable extends DataSources
    with TableInfo<$DataSourcesTable, DataSourceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DataSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageUrlMeta = const VerificationMeta(
    'pageUrl',
  );
  @override
  late final GeneratedColumn<String> pageUrl = GeneratedColumn<String>(
    'page_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archiveUrlMeta = const VerificationMeta(
    'archiveUrl',
  );
  @override
  late final GeneratedColumn<String> archiveUrl = GeneratedColumn<String>(
    'archive_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastCheckedAtMeta = const VerificationMeta(
    'lastCheckedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastCheckedAt =
      GeneratedColumn<DateTime>(
        'last_checked_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastSuccessAtMeta = const VerificationMeta(
    'lastSuccessAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSuccessAt =
      GeneratedColumn<DateTime>(
        'last_success_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _httpLastModifiedMeta = const VerificationMeta(
    'httpLastModified',
  );
  @override
  late final GeneratedColumn<String> httpLastModified = GeneratedColumn<String>(
    'http_last_modified',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    name,
    kind,
    pageUrl,
    archiveUrl,
    status,
    lastCheckedAt,
    lastSuccessAt,
    lastError,
    httpLastModified,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'data_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<DataSourceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('page_url')) {
      context.handle(
        _pageUrlMeta,
        pageUrl.isAcceptableOrUnknown(data['page_url']!, _pageUrlMeta),
      );
    }
    if (data.containsKey('archive_url')) {
      context.handle(
        _archiveUrlMeta,
        archiveUrl.isAcceptableOrUnknown(data['archive_url']!, _archiveUrlMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('last_checked_at')) {
      context.handle(
        _lastCheckedAtMeta,
        lastCheckedAt.isAcceptableOrUnknown(
          data['last_checked_at']!,
          _lastCheckedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_success_at')) {
      context.handle(
        _lastSuccessAtMeta,
        lastSuccessAt.isAcceptableOrUnknown(
          data['last_success_at']!,
          _lastSuccessAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('http_last_modified')) {
      context.handle(
        _httpLastModifiedMeta,
        httpLastModified.isAcceptableOrUnknown(
          data['http_last_modified']!,
          _httpLastModifiedMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DataSourceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DataSourceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      pageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_url'],
      ),
      archiveUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archive_url'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lastCheckedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_checked_at'],
      ),
      lastSuccessAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_success_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      httpLastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}http_last_modified'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $DataSourcesTable createAlias(String alias) {
    return $DataSourcesTable(attachedDatabase, alias);
  }
}

class DataSourceRow extends DataClass implements Insertable<DataSourceRow> {
  final int id;
  final String code;
  final String name;
  final String kind;
  final String? pageUrl;
  final String? archiveUrl;
  final String status;
  final DateTime? lastCheckedAt;
  final DateTime? lastSuccessAt;
  final String? lastError;
  final String? httpLastModified;
  final String? notes;
  const DataSourceRow({
    required this.id,
    required this.code,
    required this.name,
    required this.kind,
    this.pageUrl,
    this.archiveUrl,
    required this.status,
    this.lastCheckedAt,
    this.lastSuccessAt,
    this.lastError,
    this.httpLastModified,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || pageUrl != null) {
      map['page_url'] = Variable<String>(pageUrl);
    }
    if (!nullToAbsent || archiveUrl != null) {
      map['archive_url'] = Variable<String>(archiveUrl);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastCheckedAt != null) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt);
    }
    if (!nullToAbsent || lastSuccessAt != null) {
      map['last_success_at'] = Variable<DateTime>(lastSuccessAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || httpLastModified != null) {
      map['http_last_modified'] = Variable<String>(httpLastModified);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  DataSourcesCompanion toCompanion(bool nullToAbsent) {
    return DataSourcesCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      kind: Value(kind),
      pageUrl: pageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(pageUrl),
      archiveUrl: archiveUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(archiveUrl),
      status: Value(status),
      lastCheckedAt: lastCheckedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheckedAt),
      lastSuccessAt: lastSuccessAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      httpLastModified: httpLastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(httpLastModified),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory DataSourceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DataSourceRow(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      pageUrl: serializer.fromJson<String?>(json['pageUrl']),
      archiveUrl: serializer.fromJson<String?>(json['archiveUrl']),
      status: serializer.fromJson<String>(json['status']),
      lastCheckedAt: serializer.fromJson<DateTime?>(json['lastCheckedAt']),
      lastSuccessAt: serializer.fromJson<DateTime?>(json['lastSuccessAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      httpLastModified: serializer.fromJson<String?>(json['httpLastModified']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'pageUrl': serializer.toJson<String?>(pageUrl),
      'archiveUrl': serializer.toJson<String?>(archiveUrl),
      'status': serializer.toJson<String>(status),
      'lastCheckedAt': serializer.toJson<DateTime?>(lastCheckedAt),
      'lastSuccessAt': serializer.toJson<DateTime?>(lastSuccessAt),
      'lastError': serializer.toJson<String?>(lastError),
      'httpLastModified': serializer.toJson<String?>(httpLastModified),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  DataSourceRow copyWith({
    int? id,
    String? code,
    String? name,
    String? kind,
    Value<String?> pageUrl = const Value.absent(),
    Value<String?> archiveUrl = const Value.absent(),
    String? status,
    Value<DateTime?> lastCheckedAt = const Value.absent(),
    Value<DateTime?> lastSuccessAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    Value<String?> httpLastModified = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => DataSourceRow(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    pageUrl: pageUrl.present ? pageUrl.value : this.pageUrl,
    archiveUrl: archiveUrl.present ? archiveUrl.value : this.archiveUrl,
    status: status ?? this.status,
    lastCheckedAt: lastCheckedAt.present
        ? lastCheckedAt.value
        : this.lastCheckedAt,
    lastSuccessAt: lastSuccessAt.present
        ? lastSuccessAt.value
        : this.lastSuccessAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    httpLastModified: httpLastModified.present
        ? httpLastModified.value
        : this.httpLastModified,
    notes: notes.present ? notes.value : this.notes,
  );
  DataSourceRow copyWithCompanion(DataSourcesCompanion data) {
    return DataSourceRow(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      pageUrl: data.pageUrl.present ? data.pageUrl.value : this.pageUrl,
      archiveUrl: data.archiveUrl.present
          ? data.archiveUrl.value
          : this.archiveUrl,
      status: data.status.present ? data.status.value : this.status,
      lastCheckedAt: data.lastCheckedAt.present
          ? data.lastCheckedAt.value
          : this.lastCheckedAt,
      lastSuccessAt: data.lastSuccessAt.present
          ? data.lastSuccessAt.value
          : this.lastSuccessAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      httpLastModified: data.httpLastModified.present
          ? data.httpLastModified.value
          : this.httpLastModified,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DataSourceRow(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('pageUrl: $pageUrl, ')
          ..write('archiveUrl: $archiveUrl, ')
          ..write('status: $status, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('lastError: $lastError, ')
          ..write('httpLastModified: $httpLastModified, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    name,
    kind,
    pageUrl,
    archiveUrl,
    status,
    lastCheckedAt,
    lastSuccessAt,
    lastError,
    httpLastModified,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DataSourceRow &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.pageUrl == this.pageUrl &&
          other.archiveUrl == this.archiveUrl &&
          other.status == this.status &&
          other.lastCheckedAt == this.lastCheckedAt &&
          other.lastSuccessAt == this.lastSuccessAt &&
          other.lastError == this.lastError &&
          other.httpLastModified == this.httpLastModified &&
          other.notes == this.notes);
}

class DataSourcesCompanion extends UpdateCompanion<DataSourceRow> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String> kind;
  final Value<String?> pageUrl;
  final Value<String?> archiveUrl;
  final Value<String> status;
  final Value<DateTime?> lastCheckedAt;
  final Value<DateTime?> lastSuccessAt;
  final Value<String?> lastError;
  final Value<String?> httpLastModified;
  final Value<String?> notes;
  const DataSourcesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.pageUrl = const Value.absent(),
    this.archiveUrl = const Value.absent(),
    this.status = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.httpLastModified = const Value.absent(),
    this.notes = const Value.absent(),
  });
  DataSourcesCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String name,
    required String kind,
    this.pageUrl = const Value.absent(),
    this.archiveUrl = const Value.absent(),
    required String status,
    this.lastCheckedAt = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.httpLastModified = const Value.absent(),
    this.notes = const Value.absent(),
  }) : code = Value(code),
       name = Value(name),
       kind = Value(kind),
       status = Value(status);
  static Insertable<DataSourceRow> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? pageUrl,
    Expression<String>? archiveUrl,
    Expression<String>? status,
    Expression<DateTime>? lastCheckedAt,
    Expression<DateTime>? lastSuccessAt,
    Expression<String>? lastError,
    Expression<String>? httpLastModified,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (pageUrl != null) 'page_url': pageUrl,
      if (archiveUrl != null) 'archive_url': archiveUrl,
      if (status != null) 'status': status,
      if (lastCheckedAt != null) 'last_checked_at': lastCheckedAt,
      if (lastSuccessAt != null) 'last_success_at': lastSuccessAt,
      if (lastError != null) 'last_error': lastError,
      if (httpLastModified != null) 'http_last_modified': httpLastModified,
      if (notes != null) 'notes': notes,
    });
  }

  DataSourcesCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<String>? name,
    Value<String>? kind,
    Value<String?>? pageUrl,
    Value<String?>? archiveUrl,
    Value<String>? status,
    Value<DateTime?>? lastCheckedAt,
    Value<DateTime?>? lastSuccessAt,
    Value<String?>? lastError,
    Value<String?>? httpLastModified,
    Value<String?>? notes,
  }) {
    return DataSourcesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      pageUrl: pageUrl ?? this.pageUrl,
      archiveUrl: archiveUrl ?? this.archiveUrl,
      status: status ?? this.status,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      lastError: lastError ?? this.lastError,
      httpLastModified: httpLastModified ?? this.httpLastModified,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (pageUrl.present) {
      map['page_url'] = Variable<String>(pageUrl.value);
    }
    if (archiveUrl.present) {
      map['archive_url'] = Variable<String>(archiveUrl.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastCheckedAt.present) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt.value);
    }
    if (lastSuccessAt.present) {
      map['last_success_at'] = Variable<DateTime>(lastSuccessAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (httpLastModified.present) {
      map['http_last_modified'] = Variable<String>(httpLastModified.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DataSourcesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('pageUrl: $pageUrl, ')
          ..write('archiveUrl: $archiveUrl, ')
          ..write('status: $status, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('lastError: $lastError, ')
          ..write('httpLastModified: $httpLastModified, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $DrawsTable extends Draws with TableInfo<$DrawsTable, DrawRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DrawsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _drawDateMeta = const VerificationMeta(
    'drawDate',
  );
  @override
  late final GeneratedColumn<DateTime> drawDate = GeneratedColumn<DateTime>(
    'draw_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contestNumberMeta = const VerificationMeta(
    'contestNumber',
  );
  @override
  late final GeneratedColumn<int> contestNumber = GeneratedColumn<int>(
    'contest_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wheelIdMeta = const VerificationMeta(
    'wheelId',
  );
  @override
  late final GeneratedColumn<int> wheelId = GeneratedColumn<int>(
    'wheel_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wheels (id)',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES data_sources (id)',
    ),
  );
  static const VerificationMeta _structuralIntegrityOkMeta =
      const VerificationMeta('structuralIntegrityOk');
  @override
  late final GeneratedColumn<bool> structuralIntegrityOk =
      GeneratedColumn<bool>(
        'structural_integrity_ok',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("structural_integrity_ok" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _officiallyVerifiedMeta =
      const VerificationMeta('officiallyVerified');
  @override
  late final GeneratedColumn<bool> officiallyVerified = GeneratedColumn<bool>(
    'officially_verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("officially_verified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _provenanceMeta = const VerificationMeta(
    'provenance',
  );
  @override
  late final GeneratedColumn<String> provenance = GeneratedColumn<String>(
    'provenance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    drawDate,
    contestNumber,
    wheelId,
    sourceId,
    structuralIntegrityOk,
    officiallyVerified,
    provenance,
    contentHash,
    importedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'draws';
  @override
  VerificationContext validateIntegrity(
    Insertable<DrawRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('draw_date')) {
      context.handle(
        _drawDateMeta,
        drawDate.isAcceptableOrUnknown(data['draw_date']!, _drawDateMeta),
      );
    } else if (isInserting) {
      context.missing(_drawDateMeta);
    }
    if (data.containsKey('contest_number')) {
      context.handle(
        _contestNumberMeta,
        contestNumber.isAcceptableOrUnknown(
          data['contest_number']!,
          _contestNumberMeta,
        ),
      );
    }
    if (data.containsKey('wheel_id')) {
      context.handle(
        _wheelIdMeta,
        wheelId.isAcceptableOrUnknown(data['wheel_id']!, _wheelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wheelIdMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('structural_integrity_ok')) {
      context.handle(
        _structuralIntegrityOkMeta,
        structuralIntegrityOk.isAcceptableOrUnknown(
          data['structural_integrity_ok']!,
          _structuralIntegrityOkMeta,
        ),
      );
    }
    if (data.containsKey('officially_verified')) {
      context.handle(
        _officiallyVerifiedMeta,
        officiallyVerified.isAcceptableOrUnknown(
          data['officially_verified']!,
          _officiallyVerifiedMeta,
        ),
      );
    }
    if (data.containsKey('provenance')) {
      context.handle(
        _provenanceMeta,
        provenance.isAcceptableOrUnknown(data['provenance']!, _provenanceMeta),
      );
    } else if (isInserting) {
      context.missing(_provenanceMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {drawDate, wheelId},
  ];
  @override
  DrawRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DrawRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      drawDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}draw_date'],
      )!,
      contestNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contest_number'],
      ),
      wheelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wheel_id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_id'],
      )!,
      structuralIntegrityOk: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}structural_integrity_ok'],
      )!,
      officiallyVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}officially_verified'],
      )!,
      provenance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provenance'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
    );
  }

  @override
  $DrawsTable createAlias(String alias) {
    return $DrawsTable(attachedDatabase, alias);
  }
}

class DrawRow extends DataClass implements Insertable<DrawRow> {
  final int id;
  final DateTime drawDate;
  final int? contestNumber;
  final int wheelId;
  final int sourceId;
  final bool structuralIntegrityOk;

  /// Resta falso finché una seconda fonte indipendente non conferma la riga.
  final bool officiallyVerified;
  final String provenance;
  final String contentHash;
  final DateTime importedAt;
  const DrawRow({
    required this.id,
    required this.drawDate,
    this.contestNumber,
    required this.wheelId,
    required this.sourceId,
    required this.structuralIntegrityOk,
    required this.officiallyVerified,
    required this.provenance,
    required this.contentHash,
    required this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['draw_date'] = Variable<DateTime>(drawDate);
    if (!nullToAbsent || contestNumber != null) {
      map['contest_number'] = Variable<int>(contestNumber);
    }
    map['wheel_id'] = Variable<int>(wheelId);
    map['source_id'] = Variable<int>(sourceId);
    map['structural_integrity_ok'] = Variable<bool>(structuralIntegrityOk);
    map['officially_verified'] = Variable<bool>(officiallyVerified);
    map['provenance'] = Variable<String>(provenance);
    map['content_hash'] = Variable<String>(contentHash);
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  DrawsCompanion toCompanion(bool nullToAbsent) {
    return DrawsCompanion(
      id: Value(id),
      drawDate: Value(drawDate),
      contestNumber: contestNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(contestNumber),
      wheelId: Value(wheelId),
      sourceId: Value(sourceId),
      structuralIntegrityOk: Value(structuralIntegrityOk),
      officiallyVerified: Value(officiallyVerified),
      provenance: Value(provenance),
      contentHash: Value(contentHash),
      importedAt: Value(importedAt),
    );
  }

  factory DrawRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DrawRow(
      id: serializer.fromJson<int>(json['id']),
      drawDate: serializer.fromJson<DateTime>(json['drawDate']),
      contestNumber: serializer.fromJson<int?>(json['contestNumber']),
      wheelId: serializer.fromJson<int>(json['wheelId']),
      sourceId: serializer.fromJson<int>(json['sourceId']),
      structuralIntegrityOk: serializer.fromJson<bool>(
        json['structuralIntegrityOk'],
      ),
      officiallyVerified: serializer.fromJson<bool>(json['officiallyVerified']),
      provenance: serializer.fromJson<String>(json['provenance']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'drawDate': serializer.toJson<DateTime>(drawDate),
      'contestNumber': serializer.toJson<int?>(contestNumber),
      'wheelId': serializer.toJson<int>(wheelId),
      'sourceId': serializer.toJson<int>(sourceId),
      'structuralIntegrityOk': serializer.toJson<bool>(structuralIntegrityOk),
      'officiallyVerified': serializer.toJson<bool>(officiallyVerified),
      'provenance': serializer.toJson<String>(provenance),
      'contentHash': serializer.toJson<String>(contentHash),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  DrawRow copyWith({
    int? id,
    DateTime? drawDate,
    Value<int?> contestNumber = const Value.absent(),
    int? wheelId,
    int? sourceId,
    bool? structuralIntegrityOk,
    bool? officiallyVerified,
    String? provenance,
    String? contentHash,
    DateTime? importedAt,
  }) => DrawRow(
    id: id ?? this.id,
    drawDate: drawDate ?? this.drawDate,
    contestNumber: contestNumber.present
        ? contestNumber.value
        : this.contestNumber,
    wheelId: wheelId ?? this.wheelId,
    sourceId: sourceId ?? this.sourceId,
    structuralIntegrityOk: structuralIntegrityOk ?? this.structuralIntegrityOk,
    officiallyVerified: officiallyVerified ?? this.officiallyVerified,
    provenance: provenance ?? this.provenance,
    contentHash: contentHash ?? this.contentHash,
    importedAt: importedAt ?? this.importedAt,
  );
  DrawRow copyWithCompanion(DrawsCompanion data) {
    return DrawRow(
      id: data.id.present ? data.id.value : this.id,
      drawDate: data.drawDate.present ? data.drawDate.value : this.drawDate,
      contestNumber: data.contestNumber.present
          ? data.contestNumber.value
          : this.contestNumber,
      wheelId: data.wheelId.present ? data.wheelId.value : this.wheelId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      structuralIntegrityOk: data.structuralIntegrityOk.present
          ? data.structuralIntegrityOk.value
          : this.structuralIntegrityOk,
      officiallyVerified: data.officiallyVerified.present
          ? data.officiallyVerified.value
          : this.officiallyVerified,
      provenance: data.provenance.present
          ? data.provenance.value
          : this.provenance,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DrawRow(')
          ..write('id: $id, ')
          ..write('drawDate: $drawDate, ')
          ..write('contestNumber: $contestNumber, ')
          ..write('wheelId: $wheelId, ')
          ..write('sourceId: $sourceId, ')
          ..write('structuralIntegrityOk: $structuralIntegrityOk, ')
          ..write('officiallyVerified: $officiallyVerified, ')
          ..write('provenance: $provenance, ')
          ..write('contentHash: $contentHash, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    drawDate,
    contestNumber,
    wheelId,
    sourceId,
    structuralIntegrityOk,
    officiallyVerified,
    provenance,
    contentHash,
    importedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DrawRow &&
          other.id == this.id &&
          other.drawDate == this.drawDate &&
          other.contestNumber == this.contestNumber &&
          other.wheelId == this.wheelId &&
          other.sourceId == this.sourceId &&
          other.structuralIntegrityOk == this.structuralIntegrityOk &&
          other.officiallyVerified == this.officiallyVerified &&
          other.provenance == this.provenance &&
          other.contentHash == this.contentHash &&
          other.importedAt == this.importedAt);
}

class DrawsCompanion extends UpdateCompanion<DrawRow> {
  final Value<int> id;
  final Value<DateTime> drawDate;
  final Value<int?> contestNumber;
  final Value<int> wheelId;
  final Value<int> sourceId;
  final Value<bool> structuralIntegrityOk;
  final Value<bool> officiallyVerified;
  final Value<String> provenance;
  final Value<String> contentHash;
  final Value<DateTime> importedAt;
  const DrawsCompanion({
    this.id = const Value.absent(),
    this.drawDate = const Value.absent(),
    this.contestNumber = const Value.absent(),
    this.wheelId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.structuralIntegrityOk = const Value.absent(),
    this.officiallyVerified = const Value.absent(),
    this.provenance = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.importedAt = const Value.absent(),
  });
  DrawsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime drawDate,
    this.contestNumber = const Value.absent(),
    required int wheelId,
    required int sourceId,
    this.structuralIntegrityOk = const Value.absent(),
    this.officiallyVerified = const Value.absent(),
    required String provenance,
    required String contentHash,
    required DateTime importedAt,
  }) : drawDate = Value(drawDate),
       wheelId = Value(wheelId),
       sourceId = Value(sourceId),
       provenance = Value(provenance),
       contentHash = Value(contentHash),
       importedAt = Value(importedAt);
  static Insertable<DrawRow> custom({
    Expression<int>? id,
    Expression<DateTime>? drawDate,
    Expression<int>? contestNumber,
    Expression<int>? wheelId,
    Expression<int>? sourceId,
    Expression<bool>? structuralIntegrityOk,
    Expression<bool>? officiallyVerified,
    Expression<String>? provenance,
    Expression<String>? contentHash,
    Expression<DateTime>? importedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (drawDate != null) 'draw_date': drawDate,
      if (contestNumber != null) 'contest_number': contestNumber,
      if (wheelId != null) 'wheel_id': wheelId,
      if (sourceId != null) 'source_id': sourceId,
      if (structuralIntegrityOk != null)
        'structural_integrity_ok': structuralIntegrityOk,
      if (officiallyVerified != null) 'officially_verified': officiallyVerified,
      if (provenance != null) 'provenance': provenance,
      if (contentHash != null) 'content_hash': contentHash,
      if (importedAt != null) 'imported_at': importedAt,
    });
  }

  DrawsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? drawDate,
    Value<int?>? contestNumber,
    Value<int>? wheelId,
    Value<int>? sourceId,
    Value<bool>? structuralIntegrityOk,
    Value<bool>? officiallyVerified,
    Value<String>? provenance,
    Value<String>? contentHash,
    Value<DateTime>? importedAt,
  }) {
    return DrawsCompanion(
      id: id ?? this.id,
      drawDate: drawDate ?? this.drawDate,
      contestNumber: contestNumber ?? this.contestNumber,
      wheelId: wheelId ?? this.wheelId,
      sourceId: sourceId ?? this.sourceId,
      structuralIntegrityOk:
          structuralIntegrityOk ?? this.structuralIntegrityOk,
      officiallyVerified: officiallyVerified ?? this.officiallyVerified,
      provenance: provenance ?? this.provenance,
      contentHash: contentHash ?? this.contentHash,
      importedAt: importedAt ?? this.importedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (drawDate.present) {
      map['draw_date'] = Variable<DateTime>(drawDate.value);
    }
    if (contestNumber.present) {
      map['contest_number'] = Variable<int>(contestNumber.value);
    }
    if (wheelId.present) {
      map['wheel_id'] = Variable<int>(wheelId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (structuralIntegrityOk.present) {
      map['structural_integrity_ok'] = Variable<bool>(
        structuralIntegrityOk.value,
      );
    }
    if (officiallyVerified.present) {
      map['officially_verified'] = Variable<bool>(officiallyVerified.value);
    }
    if (provenance.present) {
      map['provenance'] = Variable<String>(provenance.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DrawsCompanion(')
          ..write('id: $id, ')
          ..write('drawDate: $drawDate, ')
          ..write('contestNumber: $contestNumber, ')
          ..write('wheelId: $wheelId, ')
          ..write('sourceId: $sourceId, ')
          ..write('structuralIntegrityOk: $structuralIntegrityOk, ')
          ..write('officiallyVerified: $officiallyVerified, ')
          ..write('provenance: $provenance, ')
          ..write('contentHash: $contentHash, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }
}

class $DrawNumbersTable extends DrawNumbers
    with TableInfo<$DrawNumbersTable, DrawNumberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DrawNumbersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _drawIdMeta = const VerificationMeta('drawId');
  @override
  late final GeneratedColumn<int> drawId = GeneratedColumn<int>(
    'draw_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES draws (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, drawId, position, number];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'draw_numbers';
  @override
  VerificationContext validateIntegrity(
    Insertable<DrawNumberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('draw_id')) {
      context.handle(
        _drawIdMeta,
        drawId.isAcceptableOrUnknown(data['draw_id']!, _drawIdMeta),
      );
    } else if (isInserting) {
      context.missing(_drawIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {drawId, position},
    {drawId, number},
  ];
  @override
  DrawNumberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DrawNumberRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      drawId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}draw_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
    );
  }

  @override
  $DrawNumbersTable createAlias(String alias) {
    return $DrawNumbersTable(attachedDatabase, alias);
  }
}

class DrawNumberRow extends DataClass implements Insertable<DrawNumberRow> {
  final int id;
  final int drawId;
  final int position;
  final int number;
  const DrawNumberRow({
    required this.id,
    required this.drawId,
    required this.position,
    required this.number,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['draw_id'] = Variable<int>(drawId);
    map['position'] = Variable<int>(position);
    map['number'] = Variable<int>(number);
    return map;
  }

  DrawNumbersCompanion toCompanion(bool nullToAbsent) {
    return DrawNumbersCompanion(
      id: Value(id),
      drawId: Value(drawId),
      position: Value(position),
      number: Value(number),
    );
  }

  factory DrawNumberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DrawNumberRow(
      id: serializer.fromJson<int>(json['id']),
      drawId: serializer.fromJson<int>(json['drawId']),
      position: serializer.fromJson<int>(json['position']),
      number: serializer.fromJson<int>(json['number']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'drawId': serializer.toJson<int>(drawId),
      'position': serializer.toJson<int>(position),
      'number': serializer.toJson<int>(number),
    };
  }

  DrawNumberRow copyWith({int? id, int? drawId, int? position, int? number}) =>
      DrawNumberRow(
        id: id ?? this.id,
        drawId: drawId ?? this.drawId,
        position: position ?? this.position,
        number: number ?? this.number,
      );
  DrawNumberRow copyWithCompanion(DrawNumbersCompanion data) {
    return DrawNumberRow(
      id: data.id.present ? data.id.value : this.id,
      drawId: data.drawId.present ? data.drawId.value : this.drawId,
      position: data.position.present ? data.position.value : this.position,
      number: data.number.present ? data.number.value : this.number,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DrawNumberRow(')
          ..write('id: $id, ')
          ..write('drawId: $drawId, ')
          ..write('position: $position, ')
          ..write('number: $number')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, drawId, position, number);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DrawNumberRow &&
          other.id == this.id &&
          other.drawId == this.drawId &&
          other.position == this.position &&
          other.number == this.number);
}

class DrawNumbersCompanion extends UpdateCompanion<DrawNumberRow> {
  final Value<int> id;
  final Value<int> drawId;
  final Value<int> position;
  final Value<int> number;
  const DrawNumbersCompanion({
    this.id = const Value.absent(),
    this.drawId = const Value.absent(),
    this.position = const Value.absent(),
    this.number = const Value.absent(),
  });
  DrawNumbersCompanion.insert({
    this.id = const Value.absent(),
    required int drawId,
    required int position,
    required int number,
  }) : drawId = Value(drawId),
       position = Value(position),
       number = Value(number);
  static Insertable<DrawNumberRow> custom({
    Expression<int>? id,
    Expression<int>? drawId,
    Expression<int>? position,
    Expression<int>? number,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (drawId != null) 'draw_id': drawId,
      if (position != null) 'position': position,
      if (number != null) 'number': number,
    });
  }

  DrawNumbersCompanion copyWith({
    Value<int>? id,
    Value<int>? drawId,
    Value<int>? position,
    Value<int>? number,
  }) {
    return DrawNumbersCompanion(
      id: id ?? this.id,
      drawId: drawId ?? this.drawId,
      position: position ?? this.position,
      number: number ?? this.number,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (drawId.present) {
      map['draw_id'] = Variable<int>(drawId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DrawNumbersCompanion(')
          ..write('id: $id, ')
          ..write('drawId: $drawId, ')
          ..write('position: $position, ')
          ..write('number: $number')
          ..write(')'))
        .toString();
  }
}

class $SyncLogsTable extends SyncLogs
    with TableInfo<$SyncLogsTable, SyncLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES data_sources (id)',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parsedCountMeta = const VerificationMeta(
    'parsedCount',
  );
  @override
  late final GeneratedColumn<int> parsedCount = GeneratedColumn<int>(
    'parsed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _insertedCountMeta = const VerificationMeta(
    'insertedCount',
  );
  @override
  late final GeneratedColumn<int> insertedCount = GeneratedColumn<int>(
    'inserted_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _duplicateCountMeta = const VerificationMeta(
    'duplicateCount',
  );
  @override
  late final GeneratedColumn<int> duplicateCount = GeneratedColumn<int>(
    'duplicate_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _conflictCountMeta = const VerificationMeta(
    'conflictCount',
  );
  @override
  late final GeneratedColumn<int> conflictCount = GeneratedColumn<int>(
    'conflict_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _invalidCountMeta = const VerificationMeta(
    'invalidCount',
  );
  @override
  late final GeneratedColumn<int> invalidCount = GeneratedColumn<int>(
    'invalid_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    startedAt,
    finishedAt,
    status,
    parsedCount,
    insertedCount,
    duplicateCount,
    conflictCount,
    invalidCount,
    message,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('parsed_count')) {
      context.handle(
        _parsedCountMeta,
        parsedCount.isAcceptableOrUnknown(
          data['parsed_count']!,
          _parsedCountMeta,
        ),
      );
    }
    if (data.containsKey('inserted_count')) {
      context.handle(
        _insertedCountMeta,
        insertedCount.isAcceptableOrUnknown(
          data['inserted_count']!,
          _insertedCountMeta,
        ),
      );
    }
    if (data.containsKey('duplicate_count')) {
      context.handle(
        _duplicateCountMeta,
        duplicateCount.isAcceptableOrUnknown(
          data['duplicate_count']!,
          _duplicateCountMeta,
        ),
      );
    }
    if (data.containsKey('conflict_count')) {
      context.handle(
        _conflictCountMeta,
        conflictCount.isAcceptableOrUnknown(
          data['conflict_count']!,
          _conflictCountMeta,
        ),
      );
    }
    if (data.containsKey('invalid_count')) {
      context.handle(
        _invalidCountMeta,
        invalidCount.isAcceptableOrUnknown(
          data['invalid_count']!,
          _invalidCountMeta,
        ),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      parsedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parsed_count'],
      )!,
      insertedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}inserted_count'],
      )!,
      duplicateCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duplicate_count'],
      )!,
      conflictCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conflict_count'],
      )!,
      invalidCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}invalid_count'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      ),
    );
  }

  @override
  $SyncLogsTable createAlias(String alias) {
    return $SyncLogsTable(attachedDatabase, alias);
  }
}

class SyncLogRow extends DataClass implements Insertable<SyncLogRow> {
  final int id;
  final int sourceId;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final String status;
  final int parsedCount;
  final int insertedCount;
  final int duplicateCount;
  final int conflictCount;
  final int invalidCount;
  final String? message;
  const SyncLogRow({
    required this.id,
    required this.sourceId,
    required this.startedAt,
    this.finishedAt,
    required this.status,
    required this.parsedCount,
    required this.insertedCount,
    required this.duplicateCount,
    required this.conflictCount,
    required this.invalidCount,
    this.message,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_id'] = Variable<int>(sourceId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    map['status'] = Variable<String>(status);
    map['parsed_count'] = Variable<int>(parsedCount);
    map['inserted_count'] = Variable<int>(insertedCount);
    map['duplicate_count'] = Variable<int>(duplicateCount);
    map['conflict_count'] = Variable<int>(conflictCount);
    map['invalid_count'] = Variable<int>(invalidCount);
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    return map;
  }

  SyncLogsCompanion toCompanion(bool nullToAbsent) {
    return SyncLogsCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      status: Value(status),
      parsedCount: Value(parsedCount),
      insertedCount: Value(insertedCount),
      duplicateCount: Value(duplicateCount),
      conflictCount: Value(conflictCount),
      invalidCount: Value(invalidCount),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
    );
  }

  factory SyncLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncLogRow(
      id: serializer.fromJson<int>(json['id']),
      sourceId: serializer.fromJson<int>(json['sourceId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      status: serializer.fromJson<String>(json['status']),
      parsedCount: serializer.fromJson<int>(json['parsedCount']),
      insertedCount: serializer.fromJson<int>(json['insertedCount']),
      duplicateCount: serializer.fromJson<int>(json['duplicateCount']),
      conflictCount: serializer.fromJson<int>(json['conflictCount']),
      invalidCount: serializer.fromJson<int>(json['invalidCount']),
      message: serializer.fromJson<String?>(json['message']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceId': serializer.toJson<int>(sourceId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'status': serializer.toJson<String>(status),
      'parsedCount': serializer.toJson<int>(parsedCount),
      'insertedCount': serializer.toJson<int>(insertedCount),
      'duplicateCount': serializer.toJson<int>(duplicateCount),
      'conflictCount': serializer.toJson<int>(conflictCount),
      'invalidCount': serializer.toJson<int>(invalidCount),
      'message': serializer.toJson<String?>(message),
    };
  }

  SyncLogRow copyWith({
    int? id,
    int? sourceId,
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    String? status,
    int? parsedCount,
    int? insertedCount,
    int? duplicateCount,
    int? conflictCount,
    int? invalidCount,
    Value<String?> message = const Value.absent(),
  }) => SyncLogRow(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    status: status ?? this.status,
    parsedCount: parsedCount ?? this.parsedCount,
    insertedCount: insertedCount ?? this.insertedCount,
    duplicateCount: duplicateCount ?? this.duplicateCount,
    conflictCount: conflictCount ?? this.conflictCount,
    invalidCount: invalidCount ?? this.invalidCount,
    message: message.present ? message.value : this.message,
  );
  SyncLogRow copyWithCompanion(SyncLogsCompanion data) {
    return SyncLogRow(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      status: data.status.present ? data.status.value : this.status,
      parsedCount: data.parsedCount.present
          ? data.parsedCount.value
          : this.parsedCount,
      insertedCount: data.insertedCount.present
          ? data.insertedCount.value
          : this.insertedCount,
      duplicateCount: data.duplicateCount.present
          ? data.duplicateCount.value
          : this.duplicateCount,
      conflictCount: data.conflictCount.present
          ? data.conflictCount.value
          : this.conflictCount,
      invalidCount: data.invalidCount.present
          ? data.invalidCount.value
          : this.invalidCount,
      message: data.message.present ? data.message.value : this.message,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogRow(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('status: $status, ')
          ..write('parsedCount: $parsedCount, ')
          ..write('insertedCount: $insertedCount, ')
          ..write('duplicateCount: $duplicateCount, ')
          ..write('conflictCount: $conflictCount, ')
          ..write('invalidCount: $invalidCount, ')
          ..write('message: $message')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceId,
    startedAt,
    finishedAt,
    status,
    parsedCount,
    insertedCount,
    duplicateCount,
    conflictCount,
    invalidCount,
    message,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncLogRow &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.status == this.status &&
          other.parsedCount == this.parsedCount &&
          other.insertedCount == this.insertedCount &&
          other.duplicateCount == this.duplicateCount &&
          other.conflictCount == this.conflictCount &&
          other.invalidCount == this.invalidCount &&
          other.message == this.message);
}

class SyncLogsCompanion extends UpdateCompanion<SyncLogRow> {
  final Value<int> id;
  final Value<int> sourceId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<String> status;
  final Value<int> parsedCount;
  final Value<int> insertedCount;
  final Value<int> duplicateCount;
  final Value<int> conflictCount;
  final Value<int> invalidCount;
  final Value<String?> message;
  const SyncLogsCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.parsedCount = const Value.absent(),
    this.insertedCount = const Value.absent(),
    this.duplicateCount = const Value.absent(),
    this.conflictCount = const Value.absent(),
    this.invalidCount = const Value.absent(),
    this.message = const Value.absent(),
  });
  SyncLogsCompanion.insert({
    this.id = const Value.absent(),
    required int sourceId,
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    required String status,
    this.parsedCount = const Value.absent(),
    this.insertedCount = const Value.absent(),
    this.duplicateCount = const Value.absent(),
    this.conflictCount = const Value.absent(),
    this.invalidCount = const Value.absent(),
    this.message = const Value.absent(),
  }) : sourceId = Value(sourceId),
       startedAt = Value(startedAt),
       status = Value(status);
  static Insertable<SyncLogRow> custom({
    Expression<int>? id,
    Expression<int>? sourceId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<String>? status,
    Expression<int>? parsedCount,
    Expression<int>? insertedCount,
    Expression<int>? duplicateCount,
    Expression<int>? conflictCount,
    Expression<int>? invalidCount,
    Expression<String>? message,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (status != null) 'status': status,
      if (parsedCount != null) 'parsed_count': parsedCount,
      if (insertedCount != null) 'inserted_count': insertedCount,
      if (duplicateCount != null) 'duplicate_count': duplicateCount,
      if (conflictCount != null) 'conflict_count': conflictCount,
      if (invalidCount != null) 'invalid_count': invalidCount,
      if (message != null) 'message': message,
    });
  }

  SyncLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? sourceId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<String>? status,
    Value<int>? parsedCount,
    Value<int>? insertedCount,
    Value<int>? duplicateCount,
    Value<int>? conflictCount,
    Value<int>? invalidCount,
    Value<String?>? message,
  }) {
    return SyncLogsCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      status: status ?? this.status,
      parsedCount: parsedCount ?? this.parsedCount,
      insertedCount: insertedCount ?? this.insertedCount,
      duplicateCount: duplicateCount ?? this.duplicateCount,
      conflictCount: conflictCount ?? this.conflictCount,
      invalidCount: invalidCount ?? this.invalidCount,
      message: message ?? this.message,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (parsedCount.present) {
      map['parsed_count'] = Variable<int>(parsedCount.value);
    }
    if (insertedCount.present) {
      map['inserted_count'] = Variable<int>(insertedCount.value);
    }
    if (duplicateCount.present) {
      map['duplicate_count'] = Variable<int>(duplicateCount.value);
    }
    if (conflictCount.present) {
      map['conflict_count'] = Variable<int>(conflictCount.value);
    }
    if (invalidCount.present) {
      map['invalid_count'] = Variable<int>(invalidCount.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogsCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('status: $status, ')
          ..write('parsedCount: $parsedCount, ')
          ..write('insertedCount: $insertedCount, ')
          ..write('duplicateCount: $duplicateCount, ')
          ..write('conflictCount: $conflictCount, ')
          ..write('invalidCount: $invalidCount, ')
          ..write('message: $message')
          ..write(')'))
        .toString();
  }
}

class $StrategiesTable extends Strategies
    with TableInfo<$StrategiesTable, StrategyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StrategiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wheelCodeMeta = const VerificationMeta(
    'wheelCode',
  );
  @override
  late final GeneratedColumn<String> wheelCode = GeneratedColumn<String>(
    'wheel_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    wheelCode,
    createdAt,
    updatedAt,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'strategies';
  @override
  VerificationContext validateIntegrity(
    Insertable<StrategyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('wheel_code')) {
      context.handle(
        _wheelCodeMeta,
        wheelCode.isAcceptableOrUnknown(data['wheel_code']!, _wheelCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_wheelCodeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StrategyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StrategyRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      wheelCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wheel_code'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $StrategiesTable createAlias(String alias) {
    return $StrategiesTable(attachedDatabase, alias);
  }
}

class StrategyRow extends DataClass implements Insertable<StrategyRow> {
  final int id;
  final String name;
  final String kind;
  final String wheelCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  const StrategyRow({
    required this.id,
    required this.name,
    required this.kind,
    required this.wheelCode,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['wheel_code'] = Variable<String>(wheelCode);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  StrategiesCompanion toCompanion(bool nullToAbsent) {
    return StrategiesCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      wheelCode: Value(wheelCode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory StrategyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StrategyRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      wheelCode: serializer.fromJson<String>(json['wheelCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'wheelCode': serializer.toJson<String>(wheelCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  StrategyRow copyWith({
    int? id,
    String? name,
    String? kind,
    String? wheelCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> notes = const Value.absent(),
  }) => StrategyRow(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    wheelCode: wheelCode ?? this.wheelCode,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    notes: notes.present ? notes.value : this.notes,
  );
  StrategyRow copyWithCompanion(StrategiesCompanion data) {
    return StrategyRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      wheelCode: data.wheelCode.present ? data.wheelCode.value : this.wheelCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StrategyRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('wheelCode: $wheelCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, kind, wheelCode, createdAt, updatedAt, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StrategyRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.wheelCode == this.wheelCode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.notes == this.notes);
}

class StrategiesCompanion extends UpdateCompanion<StrategyRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> wheelCode;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> notes;
  const StrategiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.wheelCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.notes = const Value.absent(),
  });
  StrategiesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String kind,
    required String wheelCode,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.notes = const Value.absent(),
  }) : name = Value(name),
       kind = Value(kind),
       wheelCode = Value(wheelCode),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<StrategyRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? wheelCode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (wheelCode != null) 'wheel_code': wheelCode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (notes != null) 'notes': notes,
    });
  }

  StrategiesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? wheelCode,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? notes,
  }) {
    return StrategiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      wheelCode: wheelCode ?? this.wheelCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (wheelCode.present) {
      map['wheel_code'] = Variable<String>(wheelCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StrategiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('wheelCode: $wheelCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $StrategyParametersTable extends StrategyParameters
    with TableInfo<$StrategyParametersTable, StrategyParameterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StrategyParametersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _strategyIdMeta = const VerificationMeta(
    'strategyId',
  );
  @override
  late final GeneratedColumn<int> strategyId = GeneratedColumn<int>(
    'strategy_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES strategies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _paramKeyMeta = const VerificationMeta(
    'paramKey',
  );
  @override
  late final GeneratedColumn<String> paramKey = GeneratedColumn<String>(
    'param_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paramValueMeta = const VerificationMeta(
    'paramValue',
  );
  @override
  late final GeneratedColumn<String> paramValue = GeneratedColumn<String>(
    'param_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, strategyId, paramKey, paramValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'strategy_parameters';
  @override
  VerificationContext validateIntegrity(
    Insertable<StrategyParameterRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('strategy_id')) {
      context.handle(
        _strategyIdMeta,
        strategyId.isAcceptableOrUnknown(data['strategy_id']!, _strategyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_strategyIdMeta);
    }
    if (data.containsKey('param_key')) {
      context.handle(
        _paramKeyMeta,
        paramKey.isAcceptableOrUnknown(data['param_key']!, _paramKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_paramKeyMeta);
    }
    if (data.containsKey('param_value')) {
      context.handle(
        _paramValueMeta,
        paramValue.isAcceptableOrUnknown(data['param_value']!, _paramValueMeta),
      );
    } else if (isInserting) {
      context.missing(_paramValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StrategyParameterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StrategyParameterRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      strategyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}strategy_id'],
      )!,
      paramKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}param_key'],
      )!,
      paramValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}param_value'],
      )!,
    );
  }

  @override
  $StrategyParametersTable createAlias(String alias) {
    return $StrategyParametersTable(attachedDatabase, alias);
  }
}

class StrategyParameterRow extends DataClass
    implements Insertable<StrategyParameterRow> {
  final int id;
  final int strategyId;
  final String paramKey;
  final String paramValue;
  const StrategyParameterRow({
    required this.id,
    required this.strategyId,
    required this.paramKey,
    required this.paramValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['strategy_id'] = Variable<int>(strategyId);
    map['param_key'] = Variable<String>(paramKey);
    map['param_value'] = Variable<String>(paramValue);
    return map;
  }

  StrategyParametersCompanion toCompanion(bool nullToAbsent) {
    return StrategyParametersCompanion(
      id: Value(id),
      strategyId: Value(strategyId),
      paramKey: Value(paramKey),
      paramValue: Value(paramValue),
    );
  }

  factory StrategyParameterRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StrategyParameterRow(
      id: serializer.fromJson<int>(json['id']),
      strategyId: serializer.fromJson<int>(json['strategyId']),
      paramKey: serializer.fromJson<String>(json['paramKey']),
      paramValue: serializer.fromJson<String>(json['paramValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'strategyId': serializer.toJson<int>(strategyId),
      'paramKey': serializer.toJson<String>(paramKey),
      'paramValue': serializer.toJson<String>(paramValue),
    };
  }

  StrategyParameterRow copyWith({
    int? id,
    int? strategyId,
    String? paramKey,
    String? paramValue,
  }) => StrategyParameterRow(
    id: id ?? this.id,
    strategyId: strategyId ?? this.strategyId,
    paramKey: paramKey ?? this.paramKey,
    paramValue: paramValue ?? this.paramValue,
  );
  StrategyParameterRow copyWithCompanion(StrategyParametersCompanion data) {
    return StrategyParameterRow(
      id: data.id.present ? data.id.value : this.id,
      strategyId: data.strategyId.present
          ? data.strategyId.value
          : this.strategyId,
      paramKey: data.paramKey.present ? data.paramKey.value : this.paramKey,
      paramValue: data.paramValue.present
          ? data.paramValue.value
          : this.paramValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StrategyParameterRow(')
          ..write('id: $id, ')
          ..write('strategyId: $strategyId, ')
          ..write('paramKey: $paramKey, ')
          ..write('paramValue: $paramValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, strategyId, paramKey, paramValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StrategyParameterRow &&
          other.id == this.id &&
          other.strategyId == this.strategyId &&
          other.paramKey == this.paramKey &&
          other.paramValue == this.paramValue);
}

class StrategyParametersCompanion
    extends UpdateCompanion<StrategyParameterRow> {
  final Value<int> id;
  final Value<int> strategyId;
  final Value<String> paramKey;
  final Value<String> paramValue;
  const StrategyParametersCompanion({
    this.id = const Value.absent(),
    this.strategyId = const Value.absent(),
    this.paramKey = const Value.absent(),
    this.paramValue = const Value.absent(),
  });
  StrategyParametersCompanion.insert({
    this.id = const Value.absent(),
    required int strategyId,
    required String paramKey,
    required String paramValue,
  }) : strategyId = Value(strategyId),
       paramKey = Value(paramKey),
       paramValue = Value(paramValue);
  static Insertable<StrategyParameterRow> custom({
    Expression<int>? id,
    Expression<int>? strategyId,
    Expression<String>? paramKey,
    Expression<String>? paramValue,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (strategyId != null) 'strategy_id': strategyId,
      if (paramKey != null) 'param_key': paramKey,
      if (paramValue != null) 'param_value': paramValue,
    });
  }

  StrategyParametersCompanion copyWith({
    Value<int>? id,
    Value<int>? strategyId,
    Value<String>? paramKey,
    Value<String>? paramValue,
  }) {
    return StrategyParametersCompanion(
      id: id ?? this.id,
      strategyId: strategyId ?? this.strategyId,
      paramKey: paramKey ?? this.paramKey,
      paramValue: paramValue ?? this.paramValue,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (strategyId.present) {
      map['strategy_id'] = Variable<int>(strategyId.value);
    }
    if (paramKey.present) {
      map['param_key'] = Variable<String>(paramKey.value);
    }
    if (paramValue.present) {
      map['param_value'] = Variable<String>(paramValue.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StrategyParametersCompanion(')
          ..write('id: $id, ')
          ..write('strategyId: $strategyId, ')
          ..write('paramKey: $paramKey, ')
          ..write('paramValue: $paramValue')
          ..write(')'))
        .toString();
  }
}

class $AiModelsTable extends AiModels
    with TableInfo<$AiModelsTable, AiModelRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiModelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endpointMeta = const VerificationMeta(
    'endpoint',
  );
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
    'endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelNameMeta = const VerificationMeta(
    'modelName',
  );
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
    'model_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _timeoutSecondsMeta = const VerificationMeta(
    'timeoutSeconds',
  );
  @override
  late final GeneratedColumn<int> timeoutSeconds = GeneratedColumn<int>(
    'timeout_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    provider,
    displayName,
    endpoint,
    modelName,
    enabled,
    timeoutSeconds,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_models';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiModelRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('endpoint')) {
      context.handle(
        _endpointMeta,
        endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta),
      );
    } else if (isInserting) {
      context.missing(_endpointMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('timeout_seconds')) {
      context.handle(
        _timeoutSecondsMeta,
        timeoutSeconds.isAcceptableOrUnknown(
          data['timeout_seconds']!,
          _timeoutSecondsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiModelRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiModelRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      endpoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint'],
      )!,
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      timeoutSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timeout_seconds'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AiModelsTable createAlias(String alias) {
    return $AiModelsTable(attachedDatabase, alias);
  }
}

class AiModelRow extends DataClass implements Insertable<AiModelRow> {
  final int id;
  final String provider;
  final String displayName;
  final String endpoint;
  final String modelName;
  final bool enabled;
  final int timeoutSeconds;
  final DateTime createdAt;
  const AiModelRow({
    required this.id,
    required this.provider,
    required this.displayName,
    required this.endpoint,
    required this.modelName,
    required this.enabled,
    required this.timeoutSeconds,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['provider'] = Variable<String>(provider);
    map['display_name'] = Variable<String>(displayName);
    map['endpoint'] = Variable<String>(endpoint);
    map['model_name'] = Variable<String>(modelName);
    map['enabled'] = Variable<bool>(enabled);
    map['timeout_seconds'] = Variable<int>(timeoutSeconds);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AiModelsCompanion toCompanion(bool nullToAbsent) {
    return AiModelsCompanion(
      id: Value(id),
      provider: Value(provider),
      displayName: Value(displayName),
      endpoint: Value(endpoint),
      modelName: Value(modelName),
      enabled: Value(enabled),
      timeoutSeconds: Value(timeoutSeconds),
      createdAt: Value(createdAt),
    );
  }

  factory AiModelRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiModelRow(
      id: serializer.fromJson<int>(json['id']),
      provider: serializer.fromJson<String>(json['provider']),
      displayName: serializer.fromJson<String>(json['displayName']),
      endpoint: serializer.fromJson<String>(json['endpoint']),
      modelName: serializer.fromJson<String>(json['modelName']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      timeoutSeconds: serializer.fromJson<int>(json['timeoutSeconds']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'provider': serializer.toJson<String>(provider),
      'displayName': serializer.toJson<String>(displayName),
      'endpoint': serializer.toJson<String>(endpoint),
      'modelName': serializer.toJson<String>(modelName),
      'enabled': serializer.toJson<bool>(enabled),
      'timeoutSeconds': serializer.toJson<int>(timeoutSeconds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AiModelRow copyWith({
    int? id,
    String? provider,
    String? displayName,
    String? endpoint,
    String? modelName,
    bool? enabled,
    int? timeoutSeconds,
    DateTime? createdAt,
  }) => AiModelRow(
    id: id ?? this.id,
    provider: provider ?? this.provider,
    displayName: displayName ?? this.displayName,
    endpoint: endpoint ?? this.endpoint,
    modelName: modelName ?? this.modelName,
    enabled: enabled ?? this.enabled,
    timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
    createdAt: createdAt ?? this.createdAt,
  );
  AiModelRow copyWithCompanion(AiModelsCompanion data) {
    return AiModelRow(
      id: data.id.present ? data.id.value : this.id,
      provider: data.provider.present ? data.provider.value : this.provider,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      endpoint: data.endpoint.present ? data.endpoint.value : this.endpoint,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      timeoutSeconds: data.timeoutSeconds.present
          ? data.timeoutSeconds.value
          : this.timeoutSeconds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiModelRow(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('displayName: $displayName, ')
          ..write('endpoint: $endpoint, ')
          ..write('modelName: $modelName, ')
          ..write('enabled: $enabled, ')
          ..write('timeoutSeconds: $timeoutSeconds, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    provider,
    displayName,
    endpoint,
    modelName,
    enabled,
    timeoutSeconds,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiModelRow &&
          other.id == this.id &&
          other.provider == this.provider &&
          other.displayName == this.displayName &&
          other.endpoint == this.endpoint &&
          other.modelName == this.modelName &&
          other.enabled == this.enabled &&
          other.timeoutSeconds == this.timeoutSeconds &&
          other.createdAt == this.createdAt);
}

class AiModelsCompanion extends UpdateCompanion<AiModelRow> {
  final Value<int> id;
  final Value<String> provider;
  final Value<String> displayName;
  final Value<String> endpoint;
  final Value<String> modelName;
  final Value<bool> enabled;
  final Value<int> timeoutSeconds;
  final Value<DateTime> createdAt;
  const AiModelsCompanion({
    this.id = const Value.absent(),
    this.provider = const Value.absent(),
    this.displayName = const Value.absent(),
    this.endpoint = const Value.absent(),
    this.modelName = const Value.absent(),
    this.enabled = const Value.absent(),
    this.timeoutSeconds = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AiModelsCompanion.insert({
    this.id = const Value.absent(),
    required String provider,
    required String displayName,
    required String endpoint,
    required String modelName,
    this.enabled = const Value.absent(),
    this.timeoutSeconds = const Value.absent(),
    required DateTime createdAt,
  }) : provider = Value(provider),
       displayName = Value(displayName),
       endpoint = Value(endpoint),
       modelName = Value(modelName),
       createdAt = Value(createdAt);
  static Insertable<AiModelRow> custom({
    Expression<int>? id,
    Expression<String>? provider,
    Expression<String>? displayName,
    Expression<String>? endpoint,
    Expression<String>? modelName,
    Expression<bool>? enabled,
    Expression<int>? timeoutSeconds,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (provider != null) 'provider': provider,
      if (displayName != null) 'display_name': displayName,
      if (endpoint != null) 'endpoint': endpoint,
      if (modelName != null) 'model_name': modelName,
      if (enabled != null) 'enabled': enabled,
      if (timeoutSeconds != null) 'timeout_seconds': timeoutSeconds,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AiModelsCompanion copyWith({
    Value<int>? id,
    Value<String>? provider,
    Value<String>? displayName,
    Value<String>? endpoint,
    Value<String>? modelName,
    Value<bool>? enabled,
    Value<int>? timeoutSeconds,
    Value<DateTime>? createdAt,
  }) {
    return AiModelsCompanion(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      displayName: displayName ?? this.displayName,
      endpoint: endpoint ?? this.endpoint,
      modelName: modelName ?? this.modelName,
      enabled: enabled ?? this.enabled,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (timeoutSeconds.present) {
      map['timeout_seconds'] = Variable<int>(timeoutSeconds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiModelsCompanion(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('displayName: $displayName, ')
          ..write('endpoint: $endpoint, ')
          ..write('modelName: $modelName, ')
          ..write('enabled: $enabled, ')
          ..write('timeoutSeconds: $timeoutSeconds, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PredictionsTable extends Predictions
    with TableInfo<$PredictionsTable, PredictionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PredictionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _strategyIdMeta = const VerificationMeta(
    'strategyId',
  );
  @override
  late final GeneratedColumn<int> strategyId = GeneratedColumn<int>(
    'strategy_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES strategies (id)',
    ),
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<int> modelId = GeneratedColumn<int>(
    'model_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ai_models (id)',
    ),
  );
  static const VerificationMeta _wheelCodeMeta = const VerificationMeta(
    'wheelCode',
  );
  @override
  late final GeneratedColumn<String> wheelCode = GeneratedColumn<String>(
    'wheel_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _engineIdMeta = const VerificationMeta(
    'engineId',
  );
  @override
  late final GeneratedColumn<String> engineId = GeneratedColumn<String>(
    'engine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _engineVersionMeta = const VerificationMeta(
    'engineVersion',
  );
  @override
  late final GeneratedColumn<String> engineVersion = GeneratedColumn<String>(
    'engine_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rationaleMeta = const VerificationMeta(
    'rationale',
  );
  @override
  late final GeneratedColumn<String> rationale = GeneratedColumn<String>(
    'rationale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitationsMeta = const VerificationMeta(
    'limitations',
  );
  @override
  late final GeneratedColumn<String> limitations = GeneratedColumn<String>(
    'limitations',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _datasetNoteMeta = const VerificationMeta(
    'datasetNote',
  );
  @override
  late final GeneratedColumn<String> datasetNote = GeneratedColumn<String>(
    'dataset_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    strategyId,
    modelId,
    wheelCode,
    generatedAt,
    engineId,
    engineVersion,
    method,
    rationale,
    limitations,
    datasetNote,
    configJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'predictions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PredictionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('strategy_id')) {
      context.handle(
        _strategyIdMeta,
        strategyId.isAcceptableOrUnknown(data['strategy_id']!, _strategyIdMeta),
      );
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    }
    if (data.containsKey('wheel_code')) {
      context.handle(
        _wheelCodeMeta,
        wheelCode.isAcceptableOrUnknown(data['wheel_code']!, _wheelCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_wheelCodeMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    if (data.containsKey('engine_id')) {
      context.handle(
        _engineIdMeta,
        engineId.isAcceptableOrUnknown(data['engine_id']!, _engineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_engineIdMeta);
    }
    if (data.containsKey('engine_version')) {
      context.handle(
        _engineVersionMeta,
        engineVersion.isAcceptableOrUnknown(
          data['engine_version']!,
          _engineVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_engineVersionMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('rationale')) {
      context.handle(
        _rationaleMeta,
        rationale.isAcceptableOrUnknown(data['rationale']!, _rationaleMeta),
      );
    } else if (isInserting) {
      context.missing(_rationaleMeta);
    }
    if (data.containsKey('limitations')) {
      context.handle(
        _limitationsMeta,
        limitations.isAcceptableOrUnknown(
          data['limitations']!,
          _limitationsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_limitationsMeta);
    }
    if (data.containsKey('dataset_note')) {
      context.handle(
        _datasetNoteMeta,
        datasetNote.isAcceptableOrUnknown(
          data['dataset_note']!,
          _datasetNoteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_datasetNoteMeta);
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_configJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PredictionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PredictionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      strategyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}strategy_id'],
      ),
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}model_id'],
      ),
      wheelCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wheel_code'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
      engineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}engine_id'],
      )!,
      engineVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}engine_version'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      rationale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rationale'],
      )!,
      limitations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}limitations'],
      )!,
      datasetNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dataset_note'],
      )!,
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
    );
  }

  @override
  $PredictionsTable createAlias(String alias) {
    return $PredictionsTable(attachedDatabase, alias);
  }
}

class PredictionRow extends DataClass implements Insertable<PredictionRow> {
  final int id;
  final int? strategyId;
  final int? modelId;
  final String wheelCode;
  final DateTime generatedAt;
  final String engineId;
  final String engineVersion;
  final String method;
  final String rationale;
  final String limitations;
  final String datasetNote;
  final String configJson;
  const PredictionRow({
    required this.id,
    this.strategyId,
    this.modelId,
    required this.wheelCode,
    required this.generatedAt,
    required this.engineId,
    required this.engineVersion,
    required this.method,
    required this.rationale,
    required this.limitations,
    required this.datasetNote,
    required this.configJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || strategyId != null) {
      map['strategy_id'] = Variable<int>(strategyId);
    }
    if (!nullToAbsent || modelId != null) {
      map['model_id'] = Variable<int>(modelId);
    }
    map['wheel_code'] = Variable<String>(wheelCode);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    map['engine_id'] = Variable<String>(engineId);
    map['engine_version'] = Variable<String>(engineVersion);
    map['method'] = Variable<String>(method);
    map['rationale'] = Variable<String>(rationale);
    map['limitations'] = Variable<String>(limitations);
    map['dataset_note'] = Variable<String>(datasetNote);
    map['config_json'] = Variable<String>(configJson);
    return map;
  }

  PredictionsCompanion toCompanion(bool nullToAbsent) {
    return PredictionsCompanion(
      id: Value(id),
      strategyId: strategyId == null && nullToAbsent
          ? const Value.absent()
          : Value(strategyId),
      modelId: modelId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelId),
      wheelCode: Value(wheelCode),
      generatedAt: Value(generatedAt),
      engineId: Value(engineId),
      engineVersion: Value(engineVersion),
      method: Value(method),
      rationale: Value(rationale),
      limitations: Value(limitations),
      datasetNote: Value(datasetNote),
      configJson: Value(configJson),
    );
  }

  factory PredictionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PredictionRow(
      id: serializer.fromJson<int>(json['id']),
      strategyId: serializer.fromJson<int?>(json['strategyId']),
      modelId: serializer.fromJson<int?>(json['modelId']),
      wheelCode: serializer.fromJson<String>(json['wheelCode']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      engineId: serializer.fromJson<String>(json['engineId']),
      engineVersion: serializer.fromJson<String>(json['engineVersion']),
      method: serializer.fromJson<String>(json['method']),
      rationale: serializer.fromJson<String>(json['rationale']),
      limitations: serializer.fromJson<String>(json['limitations']),
      datasetNote: serializer.fromJson<String>(json['datasetNote']),
      configJson: serializer.fromJson<String>(json['configJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'strategyId': serializer.toJson<int?>(strategyId),
      'modelId': serializer.toJson<int?>(modelId),
      'wheelCode': serializer.toJson<String>(wheelCode),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'engineId': serializer.toJson<String>(engineId),
      'engineVersion': serializer.toJson<String>(engineVersion),
      'method': serializer.toJson<String>(method),
      'rationale': serializer.toJson<String>(rationale),
      'limitations': serializer.toJson<String>(limitations),
      'datasetNote': serializer.toJson<String>(datasetNote),
      'configJson': serializer.toJson<String>(configJson),
    };
  }

  PredictionRow copyWith({
    int? id,
    Value<int?> strategyId = const Value.absent(),
    Value<int?> modelId = const Value.absent(),
    String? wheelCode,
    DateTime? generatedAt,
    String? engineId,
    String? engineVersion,
    String? method,
    String? rationale,
    String? limitations,
    String? datasetNote,
    String? configJson,
  }) => PredictionRow(
    id: id ?? this.id,
    strategyId: strategyId.present ? strategyId.value : this.strategyId,
    modelId: modelId.present ? modelId.value : this.modelId,
    wheelCode: wheelCode ?? this.wheelCode,
    generatedAt: generatedAt ?? this.generatedAt,
    engineId: engineId ?? this.engineId,
    engineVersion: engineVersion ?? this.engineVersion,
    method: method ?? this.method,
    rationale: rationale ?? this.rationale,
    limitations: limitations ?? this.limitations,
    datasetNote: datasetNote ?? this.datasetNote,
    configJson: configJson ?? this.configJson,
  );
  PredictionRow copyWithCompanion(PredictionsCompanion data) {
    return PredictionRow(
      id: data.id.present ? data.id.value : this.id,
      strategyId: data.strategyId.present
          ? data.strategyId.value
          : this.strategyId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      wheelCode: data.wheelCode.present ? data.wheelCode.value : this.wheelCode,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      engineId: data.engineId.present ? data.engineId.value : this.engineId,
      engineVersion: data.engineVersion.present
          ? data.engineVersion.value
          : this.engineVersion,
      method: data.method.present ? data.method.value : this.method,
      rationale: data.rationale.present ? data.rationale.value : this.rationale,
      limitations: data.limitations.present
          ? data.limitations.value
          : this.limitations,
      datasetNote: data.datasetNote.present
          ? data.datasetNote.value
          : this.datasetNote,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PredictionRow(')
          ..write('id: $id, ')
          ..write('strategyId: $strategyId, ')
          ..write('modelId: $modelId, ')
          ..write('wheelCode: $wheelCode, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('engineId: $engineId, ')
          ..write('engineVersion: $engineVersion, ')
          ..write('method: $method, ')
          ..write('rationale: $rationale, ')
          ..write('limitations: $limitations, ')
          ..write('datasetNote: $datasetNote, ')
          ..write('configJson: $configJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    strategyId,
    modelId,
    wheelCode,
    generatedAt,
    engineId,
    engineVersion,
    method,
    rationale,
    limitations,
    datasetNote,
    configJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PredictionRow &&
          other.id == this.id &&
          other.strategyId == this.strategyId &&
          other.modelId == this.modelId &&
          other.wheelCode == this.wheelCode &&
          other.generatedAt == this.generatedAt &&
          other.engineId == this.engineId &&
          other.engineVersion == this.engineVersion &&
          other.method == this.method &&
          other.rationale == this.rationale &&
          other.limitations == this.limitations &&
          other.datasetNote == this.datasetNote &&
          other.configJson == this.configJson);
}

class PredictionsCompanion extends UpdateCompanion<PredictionRow> {
  final Value<int> id;
  final Value<int?> strategyId;
  final Value<int?> modelId;
  final Value<String> wheelCode;
  final Value<DateTime> generatedAt;
  final Value<String> engineId;
  final Value<String> engineVersion;
  final Value<String> method;
  final Value<String> rationale;
  final Value<String> limitations;
  final Value<String> datasetNote;
  final Value<String> configJson;
  const PredictionsCompanion({
    this.id = const Value.absent(),
    this.strategyId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.wheelCode = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.engineId = const Value.absent(),
    this.engineVersion = const Value.absent(),
    this.method = const Value.absent(),
    this.rationale = const Value.absent(),
    this.limitations = const Value.absent(),
    this.datasetNote = const Value.absent(),
    this.configJson = const Value.absent(),
  });
  PredictionsCompanion.insert({
    this.id = const Value.absent(),
    this.strategyId = const Value.absent(),
    this.modelId = const Value.absent(),
    required String wheelCode,
    required DateTime generatedAt,
    required String engineId,
    required String engineVersion,
    required String method,
    required String rationale,
    required String limitations,
    required String datasetNote,
    required String configJson,
  }) : wheelCode = Value(wheelCode),
       generatedAt = Value(generatedAt),
       engineId = Value(engineId),
       engineVersion = Value(engineVersion),
       method = Value(method),
       rationale = Value(rationale),
       limitations = Value(limitations),
       datasetNote = Value(datasetNote),
       configJson = Value(configJson);
  static Insertable<PredictionRow> custom({
    Expression<int>? id,
    Expression<int>? strategyId,
    Expression<int>? modelId,
    Expression<String>? wheelCode,
    Expression<DateTime>? generatedAt,
    Expression<String>? engineId,
    Expression<String>? engineVersion,
    Expression<String>? method,
    Expression<String>? rationale,
    Expression<String>? limitations,
    Expression<String>? datasetNote,
    Expression<String>? configJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (strategyId != null) 'strategy_id': strategyId,
      if (modelId != null) 'model_id': modelId,
      if (wheelCode != null) 'wheel_code': wheelCode,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (engineId != null) 'engine_id': engineId,
      if (engineVersion != null) 'engine_version': engineVersion,
      if (method != null) 'method': method,
      if (rationale != null) 'rationale': rationale,
      if (limitations != null) 'limitations': limitations,
      if (datasetNote != null) 'dataset_note': datasetNote,
      if (configJson != null) 'config_json': configJson,
    });
  }

  PredictionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? strategyId,
    Value<int?>? modelId,
    Value<String>? wheelCode,
    Value<DateTime>? generatedAt,
    Value<String>? engineId,
    Value<String>? engineVersion,
    Value<String>? method,
    Value<String>? rationale,
    Value<String>? limitations,
    Value<String>? datasetNote,
    Value<String>? configJson,
  }) {
    return PredictionsCompanion(
      id: id ?? this.id,
      strategyId: strategyId ?? this.strategyId,
      modelId: modelId ?? this.modelId,
      wheelCode: wheelCode ?? this.wheelCode,
      generatedAt: generatedAt ?? this.generatedAt,
      engineId: engineId ?? this.engineId,
      engineVersion: engineVersion ?? this.engineVersion,
      method: method ?? this.method,
      rationale: rationale ?? this.rationale,
      limitations: limitations ?? this.limitations,
      datasetNote: datasetNote ?? this.datasetNote,
      configJson: configJson ?? this.configJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (strategyId.present) {
      map['strategy_id'] = Variable<int>(strategyId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<int>(modelId.value);
    }
    if (wheelCode.present) {
      map['wheel_code'] = Variable<String>(wheelCode.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (engineId.present) {
      map['engine_id'] = Variable<String>(engineId.value);
    }
    if (engineVersion.present) {
      map['engine_version'] = Variable<String>(engineVersion.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (rationale.present) {
      map['rationale'] = Variable<String>(rationale.value);
    }
    if (limitations.present) {
      map['limitations'] = Variable<String>(limitations.value);
    }
    if (datasetNote.present) {
      map['dataset_note'] = Variable<String>(datasetNote.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PredictionsCompanion(')
          ..write('id: $id, ')
          ..write('strategyId: $strategyId, ')
          ..write('modelId: $modelId, ')
          ..write('wheelCode: $wheelCode, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('engineId: $engineId, ')
          ..write('engineVersion: $engineVersion, ')
          ..write('method: $method, ')
          ..write('rationale: $rationale, ')
          ..write('limitations: $limitations, ')
          ..write('datasetNote: $datasetNote, ')
          ..write('configJson: $configJson')
          ..write(')'))
        .toString();
  }
}

class $PredictionNumbersTable extends PredictionNumbers
    with TableInfo<$PredictionNumbersTable, PredictionNumberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PredictionNumbersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _predictionIdMeta = const VerificationMeta(
    'predictionId',
  );
  @override
  late final GeneratedColumn<int> predictionId = GeneratedColumn<int>(
    'prediction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES predictions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, predictionId, position, number];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prediction_numbers';
  @override
  VerificationContext validateIntegrity(
    Insertable<PredictionNumberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('prediction_id')) {
      context.handle(
        _predictionIdMeta,
        predictionId.isAcceptableOrUnknown(
          data['prediction_id']!,
          _predictionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_predictionIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PredictionNumberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PredictionNumberRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      predictionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prediction_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
    );
  }

  @override
  $PredictionNumbersTable createAlias(String alias) {
    return $PredictionNumbersTable(attachedDatabase, alias);
  }
}

class PredictionNumberRow extends DataClass
    implements Insertable<PredictionNumberRow> {
  final int id;
  final int predictionId;
  final int position;
  final int number;
  const PredictionNumberRow({
    required this.id,
    required this.predictionId,
    required this.position,
    required this.number,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['prediction_id'] = Variable<int>(predictionId);
    map['position'] = Variable<int>(position);
    map['number'] = Variable<int>(number);
    return map;
  }

  PredictionNumbersCompanion toCompanion(bool nullToAbsent) {
    return PredictionNumbersCompanion(
      id: Value(id),
      predictionId: Value(predictionId),
      position: Value(position),
      number: Value(number),
    );
  }

  factory PredictionNumberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PredictionNumberRow(
      id: serializer.fromJson<int>(json['id']),
      predictionId: serializer.fromJson<int>(json['predictionId']),
      position: serializer.fromJson<int>(json['position']),
      number: serializer.fromJson<int>(json['number']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'predictionId': serializer.toJson<int>(predictionId),
      'position': serializer.toJson<int>(position),
      'number': serializer.toJson<int>(number),
    };
  }

  PredictionNumberRow copyWith({
    int? id,
    int? predictionId,
    int? position,
    int? number,
  }) => PredictionNumberRow(
    id: id ?? this.id,
    predictionId: predictionId ?? this.predictionId,
    position: position ?? this.position,
    number: number ?? this.number,
  );
  PredictionNumberRow copyWithCompanion(PredictionNumbersCompanion data) {
    return PredictionNumberRow(
      id: data.id.present ? data.id.value : this.id,
      predictionId: data.predictionId.present
          ? data.predictionId.value
          : this.predictionId,
      position: data.position.present ? data.position.value : this.position,
      number: data.number.present ? data.number.value : this.number,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PredictionNumberRow(')
          ..write('id: $id, ')
          ..write('predictionId: $predictionId, ')
          ..write('position: $position, ')
          ..write('number: $number')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, predictionId, position, number);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PredictionNumberRow &&
          other.id == this.id &&
          other.predictionId == this.predictionId &&
          other.position == this.position &&
          other.number == this.number);
}

class PredictionNumbersCompanion extends UpdateCompanion<PredictionNumberRow> {
  final Value<int> id;
  final Value<int> predictionId;
  final Value<int> position;
  final Value<int> number;
  const PredictionNumbersCompanion({
    this.id = const Value.absent(),
    this.predictionId = const Value.absent(),
    this.position = const Value.absent(),
    this.number = const Value.absent(),
  });
  PredictionNumbersCompanion.insert({
    this.id = const Value.absent(),
    required int predictionId,
    required int position,
    required int number,
  }) : predictionId = Value(predictionId),
       position = Value(position),
       number = Value(number);
  static Insertable<PredictionNumberRow> custom({
    Expression<int>? id,
    Expression<int>? predictionId,
    Expression<int>? position,
    Expression<int>? number,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (predictionId != null) 'prediction_id': predictionId,
      if (position != null) 'position': position,
      if (number != null) 'number': number,
    });
  }

  PredictionNumbersCompanion copyWith({
    Value<int>? id,
    Value<int>? predictionId,
    Value<int>? position,
    Value<int>? number,
  }) {
    return PredictionNumbersCompanion(
      id: id ?? this.id,
      predictionId: predictionId ?? this.predictionId,
      position: position ?? this.position,
      number: number ?? this.number,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (predictionId.present) {
      map['prediction_id'] = Variable<int>(predictionId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PredictionNumbersCompanion(')
          ..write('id: $id, ')
          ..write('predictionId: $predictionId, ')
          ..write('position: $position, ')
          ..write('number: $number')
          ..write(')'))
        .toString();
  }
}

class $AiExecutionLogsTable extends AiExecutionLogs
    with TableInfo<$AiExecutionLogsTable, AiExecutionLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiExecutionLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<int> modelId = GeneratedColumn<int>(
    'model_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ai_models (id)',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _successMeta = const VerificationMeta(
    'success',
  );
  @override
  late final GeneratedColumn<bool> success = GeneratedColumn<bool>(
    'success',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("success" IN (0, 1))',
    ),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestSummaryMeta = const VerificationMeta(
    'requestSummary',
  );
  @override
  late final GeneratedColumn<String> requestSummary = GeneratedColumn<String>(
    'request_summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    modelId,
    startedAt,
    finishedAt,
    success,
    errorMessage,
    requestSummary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_execution_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiExecutionLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('success')) {
      context.handle(
        _successMeta,
        success.isAcceptableOrUnknown(data['success']!, _successMeta),
      );
    } else if (isInserting) {
      context.missing(_successMeta);
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('request_summary')) {
      context.handle(
        _requestSummaryMeta,
        requestSummary.isAcceptableOrUnknown(
          data['request_summary']!,
          _requestSummaryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestSummaryMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiExecutionLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiExecutionLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}model_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      success: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}success'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      requestSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_summary'],
      )!,
    );
  }

  @override
  $AiExecutionLogsTable createAlias(String alias) {
    return $AiExecutionLogsTable(attachedDatabase, alias);
  }
}

class AiExecutionLogRow extends DataClass
    implements Insertable<AiExecutionLogRow> {
  final int id;
  final int? modelId;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final bool success;
  final String? errorMessage;
  final String requestSummary;
  const AiExecutionLogRow({
    required this.id,
    this.modelId,
    required this.startedAt,
    this.finishedAt,
    required this.success,
    this.errorMessage,
    required this.requestSummary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || modelId != null) {
      map['model_id'] = Variable<int>(modelId);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    map['success'] = Variable<bool>(success);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['request_summary'] = Variable<String>(requestSummary);
    return map;
  }

  AiExecutionLogsCompanion toCompanion(bool nullToAbsent) {
    return AiExecutionLogsCompanion(
      id: Value(id),
      modelId: modelId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelId),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      success: Value(success),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      requestSummary: Value(requestSummary),
    );
  }

  factory AiExecutionLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiExecutionLogRow(
      id: serializer.fromJson<int>(json['id']),
      modelId: serializer.fromJson<int?>(json['modelId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      success: serializer.fromJson<bool>(json['success']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      requestSummary: serializer.fromJson<String>(json['requestSummary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'modelId': serializer.toJson<int?>(modelId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'success': serializer.toJson<bool>(success),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'requestSummary': serializer.toJson<String>(requestSummary),
    };
  }

  AiExecutionLogRow copyWith({
    int? id,
    Value<int?> modelId = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    bool? success,
    Value<String?> errorMessage = const Value.absent(),
    String? requestSummary,
  }) => AiExecutionLogRow(
    id: id ?? this.id,
    modelId: modelId.present ? modelId.value : this.modelId,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    success: success ?? this.success,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    requestSummary: requestSummary ?? this.requestSummary,
  );
  AiExecutionLogRow copyWithCompanion(AiExecutionLogsCompanion data) {
    return AiExecutionLogRow(
      id: data.id.present ? data.id.value : this.id,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      success: data.success.present ? data.success.value : this.success,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      requestSummary: data.requestSummary.present
          ? data.requestSummary.value
          : this.requestSummary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiExecutionLogRow(')
          ..write('id: $id, ')
          ..write('modelId: $modelId, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('success: $success, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('requestSummary: $requestSummary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    modelId,
    startedAt,
    finishedAt,
    success,
    errorMessage,
    requestSummary,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiExecutionLogRow &&
          other.id == this.id &&
          other.modelId == this.modelId &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.success == this.success &&
          other.errorMessage == this.errorMessage &&
          other.requestSummary == this.requestSummary);
}

class AiExecutionLogsCompanion extends UpdateCompanion<AiExecutionLogRow> {
  final Value<int> id;
  final Value<int?> modelId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<bool> success;
  final Value<String?> errorMessage;
  final Value<String> requestSummary;
  const AiExecutionLogsCompanion({
    this.id = const Value.absent(),
    this.modelId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.success = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.requestSummary = const Value.absent(),
  });
  AiExecutionLogsCompanion.insert({
    this.id = const Value.absent(),
    this.modelId = const Value.absent(),
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    required bool success,
    this.errorMessage = const Value.absent(),
    required String requestSummary,
  }) : startedAt = Value(startedAt),
       success = Value(success),
       requestSummary = Value(requestSummary);
  static Insertable<AiExecutionLogRow> custom({
    Expression<int>? id,
    Expression<int>? modelId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<bool>? success,
    Expression<String>? errorMessage,
    Expression<String>? requestSummary,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modelId != null) 'model_id': modelId,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (success != null) 'success': success,
      if (errorMessage != null) 'error_message': errorMessage,
      if (requestSummary != null) 'request_summary': requestSummary,
    });
  }

  AiExecutionLogsCompanion copyWith({
    Value<int>? id,
    Value<int?>? modelId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<bool>? success,
    Value<String?>? errorMessage,
    Value<String>? requestSummary,
  }) {
    return AiExecutionLogsCompanion(
      id: id ?? this.id,
      modelId: modelId ?? this.modelId,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
      requestSummary: requestSummary ?? this.requestSummary,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<int>(modelId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (success.present) {
      map['success'] = Variable<bool>(success.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (requestSummary.present) {
      map['request_summary'] = Variable<String>(requestSummary.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiExecutionLogsCompanion(')
          ..write('id: $id, ')
          ..write('modelId: $modelId, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('success: $success, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('requestSummary: $requestSummary')
          ..write(')'))
        .toString();
  }
}

class $BacktestRunsTable extends BacktestRuns
    with TableInfo<$BacktestRunsTable, BacktestRunRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BacktestRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _strategyIdMeta = const VerificationMeta(
    'strategyId',
  );
  @override
  late final GeneratedColumn<int> strategyId = GeneratedColumn<int>(
    'strategy_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES strategies (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wheelCodeMeta = const VerificationMeta(
    'wheelCode',
  );
  @override
  late final GeneratedColumn<String> wheelCode = GeneratedColumn<String>(
    'wheel_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seedMeta = const VerificationMeta('seed');
  @override
  late final GeneratedColumn<int> seed = GeneratedColumn<int>(
    'seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromDateMeta = const VerificationMeta(
    'fromDate',
  );
  @override
  late final GeneratedColumn<DateTime> fromDate = GeneratedColumn<DateTime>(
    'from_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toDateMeta = const VerificationMeta('toDate');
  @override
  late final GeneratedColumn<DateTime> toDate = GeneratedColumn<DateTime>(
    'to_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _warmupDrawsMeta = const VerificationMeta(
    'warmupDraws',
  );
  @override
  late final GeneratedColumn<int> warmupDraws = GeneratedColumn<int>(
    'warmup_draws',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _scoredDrawsMeta = const VerificationMeta(
    'scoredDraws',
  );
  @override
  late final GeneratedColumn<int> scoredDraws = GeneratedColumn<int>(
    'scored_draws',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryJsonMeta = const VerificationMeta(
    'summaryJson',
  );
  @override
  late final GeneratedColumn<String> summaryJson = GeneratedColumn<String>(
    'summary_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    strategyId,
    label,
    wheelCode,
    seed,
    fromDate,
    toDate,
    warmupDraws,
    scoredDraws,
    status,
    summaryJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backtest_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<BacktestRunRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('strategy_id')) {
      context.handle(
        _strategyIdMeta,
        strategyId.isAcceptableOrUnknown(data['strategy_id']!, _strategyIdMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('wheel_code')) {
      context.handle(
        _wheelCodeMeta,
        wheelCode.isAcceptableOrUnknown(data['wheel_code']!, _wheelCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_wheelCodeMeta);
    }
    if (data.containsKey('seed')) {
      context.handle(
        _seedMeta,
        seed.isAcceptableOrUnknown(data['seed']!, _seedMeta),
      );
    } else if (isInserting) {
      context.missing(_seedMeta);
    }
    if (data.containsKey('from_date')) {
      context.handle(
        _fromDateMeta,
        fromDate.isAcceptableOrUnknown(data['from_date']!, _fromDateMeta),
      );
    }
    if (data.containsKey('to_date')) {
      context.handle(
        _toDateMeta,
        toDate.isAcceptableOrUnknown(data['to_date']!, _toDateMeta),
      );
    }
    if (data.containsKey('warmup_draws')) {
      context.handle(
        _warmupDrawsMeta,
        warmupDraws.isAcceptableOrUnknown(
          data['warmup_draws']!,
          _warmupDrawsMeta,
        ),
      );
    }
    if (data.containsKey('scored_draws')) {
      context.handle(
        _scoredDrawsMeta,
        scoredDraws.isAcceptableOrUnknown(
          data['scored_draws']!,
          _scoredDrawsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('summary_json')) {
      context.handle(
        _summaryJsonMeta,
        summaryJson.isAcceptableOrUnknown(
          data['summary_json']!,
          _summaryJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_summaryJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BacktestRunRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BacktestRunRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      strategyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}strategy_id'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      wheelCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wheel_code'],
      )!,
      seed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seed'],
      )!,
      fromDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}from_date'],
      ),
      toDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}to_date'],
      ),
      warmupDraws: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warmup_draws'],
      )!,
      scoredDraws: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scored_draws'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      summaryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BacktestRunsTable createAlias(String alias) {
    return $BacktestRunsTable(attachedDatabase, alias);
  }
}

class BacktestRunRow extends DataClass implements Insertable<BacktestRunRow> {
  final int id;
  final int? strategyId;
  final String label;
  final String wheelCode;
  final int seed;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int warmupDraws;
  final int scoredDraws;
  final String status;
  final String summaryJson;
  final DateTime createdAt;
  const BacktestRunRow({
    required this.id,
    this.strategyId,
    required this.label,
    required this.wheelCode,
    required this.seed,
    this.fromDate,
    this.toDate,
    required this.warmupDraws,
    required this.scoredDraws,
    required this.status,
    required this.summaryJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || strategyId != null) {
      map['strategy_id'] = Variable<int>(strategyId);
    }
    map['label'] = Variable<String>(label);
    map['wheel_code'] = Variable<String>(wheelCode);
    map['seed'] = Variable<int>(seed);
    if (!nullToAbsent || fromDate != null) {
      map['from_date'] = Variable<DateTime>(fromDate);
    }
    if (!nullToAbsent || toDate != null) {
      map['to_date'] = Variable<DateTime>(toDate);
    }
    map['warmup_draws'] = Variable<int>(warmupDraws);
    map['scored_draws'] = Variable<int>(scoredDraws);
    map['status'] = Variable<String>(status);
    map['summary_json'] = Variable<String>(summaryJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BacktestRunsCompanion toCompanion(bool nullToAbsent) {
    return BacktestRunsCompanion(
      id: Value(id),
      strategyId: strategyId == null && nullToAbsent
          ? const Value.absent()
          : Value(strategyId),
      label: Value(label),
      wheelCode: Value(wheelCode),
      seed: Value(seed),
      fromDate: fromDate == null && nullToAbsent
          ? const Value.absent()
          : Value(fromDate),
      toDate: toDate == null && nullToAbsent
          ? const Value.absent()
          : Value(toDate),
      warmupDraws: Value(warmupDraws),
      scoredDraws: Value(scoredDraws),
      status: Value(status),
      summaryJson: Value(summaryJson),
      createdAt: Value(createdAt),
    );
  }

  factory BacktestRunRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BacktestRunRow(
      id: serializer.fromJson<int>(json['id']),
      strategyId: serializer.fromJson<int?>(json['strategyId']),
      label: serializer.fromJson<String>(json['label']),
      wheelCode: serializer.fromJson<String>(json['wheelCode']),
      seed: serializer.fromJson<int>(json['seed']),
      fromDate: serializer.fromJson<DateTime?>(json['fromDate']),
      toDate: serializer.fromJson<DateTime?>(json['toDate']),
      warmupDraws: serializer.fromJson<int>(json['warmupDraws']),
      scoredDraws: serializer.fromJson<int>(json['scoredDraws']),
      status: serializer.fromJson<String>(json['status']),
      summaryJson: serializer.fromJson<String>(json['summaryJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'strategyId': serializer.toJson<int?>(strategyId),
      'label': serializer.toJson<String>(label),
      'wheelCode': serializer.toJson<String>(wheelCode),
      'seed': serializer.toJson<int>(seed),
      'fromDate': serializer.toJson<DateTime?>(fromDate),
      'toDate': serializer.toJson<DateTime?>(toDate),
      'warmupDraws': serializer.toJson<int>(warmupDraws),
      'scoredDraws': serializer.toJson<int>(scoredDraws),
      'status': serializer.toJson<String>(status),
      'summaryJson': serializer.toJson<String>(summaryJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BacktestRunRow copyWith({
    int? id,
    Value<int?> strategyId = const Value.absent(),
    String? label,
    String? wheelCode,
    int? seed,
    Value<DateTime?> fromDate = const Value.absent(),
    Value<DateTime?> toDate = const Value.absent(),
    int? warmupDraws,
    int? scoredDraws,
    String? status,
    String? summaryJson,
    DateTime? createdAt,
  }) => BacktestRunRow(
    id: id ?? this.id,
    strategyId: strategyId.present ? strategyId.value : this.strategyId,
    label: label ?? this.label,
    wheelCode: wheelCode ?? this.wheelCode,
    seed: seed ?? this.seed,
    fromDate: fromDate.present ? fromDate.value : this.fromDate,
    toDate: toDate.present ? toDate.value : this.toDate,
    warmupDraws: warmupDraws ?? this.warmupDraws,
    scoredDraws: scoredDraws ?? this.scoredDraws,
    status: status ?? this.status,
    summaryJson: summaryJson ?? this.summaryJson,
    createdAt: createdAt ?? this.createdAt,
  );
  BacktestRunRow copyWithCompanion(BacktestRunsCompanion data) {
    return BacktestRunRow(
      id: data.id.present ? data.id.value : this.id,
      strategyId: data.strategyId.present
          ? data.strategyId.value
          : this.strategyId,
      label: data.label.present ? data.label.value : this.label,
      wheelCode: data.wheelCode.present ? data.wheelCode.value : this.wheelCode,
      seed: data.seed.present ? data.seed.value : this.seed,
      fromDate: data.fromDate.present ? data.fromDate.value : this.fromDate,
      toDate: data.toDate.present ? data.toDate.value : this.toDate,
      warmupDraws: data.warmupDraws.present
          ? data.warmupDraws.value
          : this.warmupDraws,
      scoredDraws: data.scoredDraws.present
          ? data.scoredDraws.value
          : this.scoredDraws,
      status: data.status.present ? data.status.value : this.status,
      summaryJson: data.summaryJson.present
          ? data.summaryJson.value
          : this.summaryJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BacktestRunRow(')
          ..write('id: $id, ')
          ..write('strategyId: $strategyId, ')
          ..write('label: $label, ')
          ..write('wheelCode: $wheelCode, ')
          ..write('seed: $seed, ')
          ..write('fromDate: $fromDate, ')
          ..write('toDate: $toDate, ')
          ..write('warmupDraws: $warmupDraws, ')
          ..write('scoredDraws: $scoredDraws, ')
          ..write('status: $status, ')
          ..write('summaryJson: $summaryJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    strategyId,
    label,
    wheelCode,
    seed,
    fromDate,
    toDate,
    warmupDraws,
    scoredDraws,
    status,
    summaryJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BacktestRunRow &&
          other.id == this.id &&
          other.strategyId == this.strategyId &&
          other.label == this.label &&
          other.wheelCode == this.wheelCode &&
          other.seed == this.seed &&
          other.fromDate == this.fromDate &&
          other.toDate == this.toDate &&
          other.warmupDraws == this.warmupDraws &&
          other.scoredDraws == this.scoredDraws &&
          other.status == this.status &&
          other.summaryJson == this.summaryJson &&
          other.createdAt == this.createdAt);
}

class BacktestRunsCompanion extends UpdateCompanion<BacktestRunRow> {
  final Value<int> id;
  final Value<int?> strategyId;
  final Value<String> label;
  final Value<String> wheelCode;
  final Value<int> seed;
  final Value<DateTime?> fromDate;
  final Value<DateTime?> toDate;
  final Value<int> warmupDraws;
  final Value<int> scoredDraws;
  final Value<String> status;
  final Value<String> summaryJson;
  final Value<DateTime> createdAt;
  const BacktestRunsCompanion({
    this.id = const Value.absent(),
    this.strategyId = const Value.absent(),
    this.label = const Value.absent(),
    this.wheelCode = const Value.absent(),
    this.seed = const Value.absent(),
    this.fromDate = const Value.absent(),
    this.toDate = const Value.absent(),
    this.warmupDraws = const Value.absent(),
    this.scoredDraws = const Value.absent(),
    this.status = const Value.absent(),
    this.summaryJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BacktestRunsCompanion.insert({
    this.id = const Value.absent(),
    this.strategyId = const Value.absent(),
    required String label,
    required String wheelCode,
    required int seed,
    this.fromDate = const Value.absent(),
    this.toDate = const Value.absent(),
    this.warmupDraws = const Value.absent(),
    this.scoredDraws = const Value.absent(),
    required String status,
    required String summaryJson,
    required DateTime createdAt,
  }) : label = Value(label),
       wheelCode = Value(wheelCode),
       seed = Value(seed),
       status = Value(status),
       summaryJson = Value(summaryJson),
       createdAt = Value(createdAt);
  static Insertable<BacktestRunRow> custom({
    Expression<int>? id,
    Expression<int>? strategyId,
    Expression<String>? label,
    Expression<String>? wheelCode,
    Expression<int>? seed,
    Expression<DateTime>? fromDate,
    Expression<DateTime>? toDate,
    Expression<int>? warmupDraws,
    Expression<int>? scoredDraws,
    Expression<String>? status,
    Expression<String>? summaryJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (strategyId != null) 'strategy_id': strategyId,
      if (label != null) 'label': label,
      if (wheelCode != null) 'wheel_code': wheelCode,
      if (seed != null) 'seed': seed,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
      if (warmupDraws != null) 'warmup_draws': warmupDraws,
      if (scoredDraws != null) 'scored_draws': scoredDraws,
      if (status != null) 'status': status,
      if (summaryJson != null) 'summary_json': summaryJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BacktestRunsCompanion copyWith({
    Value<int>? id,
    Value<int?>? strategyId,
    Value<String>? label,
    Value<String>? wheelCode,
    Value<int>? seed,
    Value<DateTime?>? fromDate,
    Value<DateTime?>? toDate,
    Value<int>? warmupDraws,
    Value<int>? scoredDraws,
    Value<String>? status,
    Value<String>? summaryJson,
    Value<DateTime>? createdAt,
  }) {
    return BacktestRunsCompanion(
      id: id ?? this.id,
      strategyId: strategyId ?? this.strategyId,
      label: label ?? this.label,
      wheelCode: wheelCode ?? this.wheelCode,
      seed: seed ?? this.seed,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      warmupDraws: warmupDraws ?? this.warmupDraws,
      scoredDraws: scoredDraws ?? this.scoredDraws,
      status: status ?? this.status,
      summaryJson: summaryJson ?? this.summaryJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (strategyId.present) {
      map['strategy_id'] = Variable<int>(strategyId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (wheelCode.present) {
      map['wheel_code'] = Variable<String>(wheelCode.value);
    }
    if (seed.present) {
      map['seed'] = Variable<int>(seed.value);
    }
    if (fromDate.present) {
      map['from_date'] = Variable<DateTime>(fromDate.value);
    }
    if (toDate.present) {
      map['to_date'] = Variable<DateTime>(toDate.value);
    }
    if (warmupDraws.present) {
      map['warmup_draws'] = Variable<int>(warmupDraws.value);
    }
    if (scoredDraws.present) {
      map['scored_draws'] = Variable<int>(scoredDraws.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (summaryJson.present) {
      map['summary_json'] = Variable<String>(summaryJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BacktestRunsCompanion(')
          ..write('id: $id, ')
          ..write('strategyId: $strategyId, ')
          ..write('label: $label, ')
          ..write('wheelCode: $wheelCode, ')
          ..write('seed: $seed, ')
          ..write('fromDate: $fromDate, ')
          ..write('toDate: $toDate, ')
          ..write('warmupDraws: $warmupDraws, ')
          ..write('scoredDraws: $scoredDraws, ')
          ..write('status: $status, ')
          ..write('summaryJson: $summaryJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BacktestResultsTable extends BacktestResults
    with TableInfo<$BacktestResultsTable, BacktestResultRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BacktestResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<int> runId = GeneratedColumn<int>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES backtest_runs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _drawDateMeta = const VerificationMeta(
    'drawDate',
  );
  @override
  late final GeneratedColumn<DateTime> drawDate = GeneratedColumn<DateTime>(
    'draw_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hitsMeta = const VerificationMeta('hits');
  @override
  late final GeneratedColumn<int> hits = GeneratedColumn<int>(
    'hits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baselineHitsMeta = const VerificationMeta(
    'baselineHits',
  );
  @override
  late final GeneratedColumn<int> baselineHits = GeneratedColumn<int>(
    'baseline_hits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proposedNumbersMeta = const VerificationMeta(
    'proposedNumbers',
  );
  @override
  late final GeneratedColumn<String> proposedNumbers = GeneratedColumn<String>(
    'proposed_numbers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    runId,
    drawDate,
    hits,
    baselineHits,
    proposedNumbers,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backtest_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<BacktestResultRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('draw_date')) {
      context.handle(
        _drawDateMeta,
        drawDate.isAcceptableOrUnknown(data['draw_date']!, _drawDateMeta),
      );
    } else if (isInserting) {
      context.missing(_drawDateMeta);
    }
    if (data.containsKey('hits')) {
      context.handle(
        _hitsMeta,
        hits.isAcceptableOrUnknown(data['hits']!, _hitsMeta),
      );
    } else if (isInserting) {
      context.missing(_hitsMeta);
    }
    if (data.containsKey('baseline_hits')) {
      context.handle(
        _baselineHitsMeta,
        baselineHits.isAcceptableOrUnknown(
          data['baseline_hits']!,
          _baselineHitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baselineHitsMeta);
    }
    if (data.containsKey('proposed_numbers')) {
      context.handle(
        _proposedNumbersMeta,
        proposedNumbers.isAcceptableOrUnknown(
          data['proposed_numbers']!,
          _proposedNumbersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proposedNumbersMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BacktestResultRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BacktestResultRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}run_id'],
      )!,
      drawDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}draw_date'],
      )!,
      hits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hits'],
      )!,
      baselineHits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baseline_hits'],
      )!,
      proposedNumbers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proposed_numbers'],
      )!,
    );
  }

  @override
  $BacktestResultsTable createAlias(String alias) {
    return $BacktestResultsTable(attachedDatabase, alias);
  }
}

class BacktestResultRow extends DataClass
    implements Insertable<BacktestResultRow> {
  final int id;
  final int runId;
  final DateTime drawDate;
  final int hits;
  final int baselineHits;
  final String proposedNumbers;
  const BacktestResultRow({
    required this.id,
    required this.runId,
    required this.drawDate,
    required this.hits,
    required this.baselineHits,
    required this.proposedNumbers,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['run_id'] = Variable<int>(runId);
    map['draw_date'] = Variable<DateTime>(drawDate);
    map['hits'] = Variable<int>(hits);
    map['baseline_hits'] = Variable<int>(baselineHits);
    map['proposed_numbers'] = Variable<String>(proposedNumbers);
    return map;
  }

  BacktestResultsCompanion toCompanion(bool nullToAbsent) {
    return BacktestResultsCompanion(
      id: Value(id),
      runId: Value(runId),
      drawDate: Value(drawDate),
      hits: Value(hits),
      baselineHits: Value(baselineHits),
      proposedNumbers: Value(proposedNumbers),
    );
  }

  factory BacktestResultRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BacktestResultRow(
      id: serializer.fromJson<int>(json['id']),
      runId: serializer.fromJson<int>(json['runId']),
      drawDate: serializer.fromJson<DateTime>(json['drawDate']),
      hits: serializer.fromJson<int>(json['hits']),
      baselineHits: serializer.fromJson<int>(json['baselineHits']),
      proposedNumbers: serializer.fromJson<String>(json['proposedNumbers']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'runId': serializer.toJson<int>(runId),
      'drawDate': serializer.toJson<DateTime>(drawDate),
      'hits': serializer.toJson<int>(hits),
      'baselineHits': serializer.toJson<int>(baselineHits),
      'proposedNumbers': serializer.toJson<String>(proposedNumbers),
    };
  }

  BacktestResultRow copyWith({
    int? id,
    int? runId,
    DateTime? drawDate,
    int? hits,
    int? baselineHits,
    String? proposedNumbers,
  }) => BacktestResultRow(
    id: id ?? this.id,
    runId: runId ?? this.runId,
    drawDate: drawDate ?? this.drawDate,
    hits: hits ?? this.hits,
    baselineHits: baselineHits ?? this.baselineHits,
    proposedNumbers: proposedNumbers ?? this.proposedNumbers,
  );
  BacktestResultRow copyWithCompanion(BacktestResultsCompanion data) {
    return BacktestResultRow(
      id: data.id.present ? data.id.value : this.id,
      runId: data.runId.present ? data.runId.value : this.runId,
      drawDate: data.drawDate.present ? data.drawDate.value : this.drawDate,
      hits: data.hits.present ? data.hits.value : this.hits,
      baselineHits: data.baselineHits.present
          ? data.baselineHits.value
          : this.baselineHits,
      proposedNumbers: data.proposedNumbers.present
          ? data.proposedNumbers.value
          : this.proposedNumbers,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BacktestResultRow(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('drawDate: $drawDate, ')
          ..write('hits: $hits, ')
          ..write('baselineHits: $baselineHits, ')
          ..write('proposedNumbers: $proposedNumbers')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, runId, drawDate, hits, baselineHits, proposedNumbers);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BacktestResultRow &&
          other.id == this.id &&
          other.runId == this.runId &&
          other.drawDate == this.drawDate &&
          other.hits == this.hits &&
          other.baselineHits == this.baselineHits &&
          other.proposedNumbers == this.proposedNumbers);
}

class BacktestResultsCompanion extends UpdateCompanion<BacktestResultRow> {
  final Value<int> id;
  final Value<int> runId;
  final Value<DateTime> drawDate;
  final Value<int> hits;
  final Value<int> baselineHits;
  final Value<String> proposedNumbers;
  const BacktestResultsCompanion({
    this.id = const Value.absent(),
    this.runId = const Value.absent(),
    this.drawDate = const Value.absent(),
    this.hits = const Value.absent(),
    this.baselineHits = const Value.absent(),
    this.proposedNumbers = const Value.absent(),
  });
  BacktestResultsCompanion.insert({
    this.id = const Value.absent(),
    required int runId,
    required DateTime drawDate,
    required int hits,
    required int baselineHits,
    required String proposedNumbers,
  }) : runId = Value(runId),
       drawDate = Value(drawDate),
       hits = Value(hits),
       baselineHits = Value(baselineHits),
       proposedNumbers = Value(proposedNumbers);
  static Insertable<BacktestResultRow> custom({
    Expression<int>? id,
    Expression<int>? runId,
    Expression<DateTime>? drawDate,
    Expression<int>? hits,
    Expression<int>? baselineHits,
    Expression<String>? proposedNumbers,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (runId != null) 'run_id': runId,
      if (drawDate != null) 'draw_date': drawDate,
      if (hits != null) 'hits': hits,
      if (baselineHits != null) 'baseline_hits': baselineHits,
      if (proposedNumbers != null) 'proposed_numbers': proposedNumbers,
    });
  }

  BacktestResultsCompanion copyWith({
    Value<int>? id,
    Value<int>? runId,
    Value<DateTime>? drawDate,
    Value<int>? hits,
    Value<int>? baselineHits,
    Value<String>? proposedNumbers,
  }) {
    return BacktestResultsCompanion(
      id: id ?? this.id,
      runId: runId ?? this.runId,
      drawDate: drawDate ?? this.drawDate,
      hits: hits ?? this.hits,
      baselineHits: baselineHits ?? this.baselineHits,
      proposedNumbers: proposedNumbers ?? this.proposedNumbers,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<int>(runId.value);
    }
    if (drawDate.present) {
      map['draw_date'] = Variable<DateTime>(drawDate.value);
    }
    if (hits.present) {
      map['hits'] = Variable<int>(hits.value);
    }
    if (baselineHits.present) {
      map['baseline_hits'] = Variable<int>(baselineHits.value);
    }
    if (proposedNumbers.present) {
      map['proposed_numbers'] = Variable<String>(proposedNumbers.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BacktestResultsCompanion(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('drawDate: $drawDate, ')
          ..write('hits: $hits, ')
          ..write('baselineHits: $baselineHits, ')
          ..write('proposedNumbers: $proposedNumbers')
          ..write(')'))
        .toString();
  }
}

class $VirtualTicketsTable extends VirtualTickets
    with TableInfo<$VirtualTicketsTable, VirtualTicketRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VirtualTicketsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _strategyIdMeta = const VerificationMeta(
    'strategyId',
  );
  @override
  late final GeneratedColumn<int> strategyId = GeneratedColumn<int>(
    'strategy_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES strategies (id)',
    ),
  );
  static const VerificationMeta _wheelCodeMeta = const VerificationMeta(
    'wheelCode',
  );
  @override
  late final GeneratedColumn<String> wheelCode = GeneratedColumn<String>(
    'wheel_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stakeCentsMeta = const VerificationMeta(
    'stakeCents',
  );
  @override
  late final GeneratedColumn<int> stakeCents = GeneratedColumn<int>(
    'stake_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stakeEstrattoCentsMeta =
      const VerificationMeta('stakeEstrattoCents');
  @override
  late final GeneratedColumn<int> stakeEstrattoCents = GeneratedColumn<int>(
    'stake_estratto_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stakeAmboCentsMeta = const VerificationMeta(
    'stakeAmboCents',
  );
  @override
  late final GeneratedColumn<int> stakeAmboCents = GeneratedColumn<int>(
    'stake_ambo_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stakeTernoCentsMeta = const VerificationMeta(
    'stakeTernoCents',
  );
  @override
  late final GeneratedColumn<int> stakeTernoCents = GeneratedColumn<int>(
    'stake_terno_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stakeQuaternaCentsMeta =
      const VerificationMeta('stakeQuaternaCents');
  @override
  late final GeneratedColumn<int> stakeQuaternaCents = GeneratedColumn<int>(
    'stake_quaterna_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stakeCinquinaCentsMeta =
      const VerificationMeta('stakeCinquinaCents');
  @override
  late final GeneratedColumn<int> stakeCinquinaCents = GeneratedColumn<int>(
    'stake_cinquina_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _targetDrawDateMeta = const VerificationMeta(
    'targetDrawDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDrawDate =
      GeneratedColumn<DateTime>(
        'target_draw_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    strategyId,
    wheelCode,
    stakeCents,
    createdAt,
    note,
    stakeEstrattoCents,
    stakeAmboCents,
    stakeTernoCents,
    stakeQuaternaCents,
    stakeCinquinaCents,
    targetDrawDate,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'virtual_tickets';
  @override
  VerificationContext validateIntegrity(
    Insertable<VirtualTicketRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('strategy_id')) {
      context.handle(
        _strategyIdMeta,
        strategyId.isAcceptableOrUnknown(data['strategy_id']!, _strategyIdMeta),
      );
    }
    if (data.containsKey('wheel_code')) {
      context.handle(
        _wheelCodeMeta,
        wheelCode.isAcceptableOrUnknown(data['wheel_code']!, _wheelCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_wheelCodeMeta);
    }
    if (data.containsKey('stake_cents')) {
      context.handle(
        _stakeCentsMeta,
        stakeCents.isAcceptableOrUnknown(data['stake_cents']!, _stakeCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_stakeCentsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('stake_estratto_cents')) {
      context.handle(
        _stakeEstrattoCentsMeta,
        stakeEstrattoCents.isAcceptableOrUnknown(
          data['stake_estratto_cents']!,
          _stakeEstrattoCentsMeta,
        ),
      );
    }
    if (data.containsKey('stake_ambo_cents')) {
      context.handle(
        _stakeAmboCentsMeta,
        stakeAmboCents.isAcceptableOrUnknown(
          data['stake_ambo_cents']!,
          _stakeAmboCentsMeta,
        ),
      );
    }
    if (data.containsKey('stake_terno_cents')) {
      context.handle(
        _stakeTernoCentsMeta,
        stakeTernoCents.isAcceptableOrUnknown(
          data['stake_terno_cents']!,
          _stakeTernoCentsMeta,
        ),
      );
    }
    if (data.containsKey('stake_quaterna_cents')) {
      context.handle(
        _stakeQuaternaCentsMeta,
        stakeQuaternaCents.isAcceptableOrUnknown(
          data['stake_quaterna_cents']!,
          _stakeQuaternaCentsMeta,
        ),
      );
    }
    if (data.containsKey('stake_cinquina_cents')) {
      context.handle(
        _stakeCinquinaCentsMeta,
        stakeCinquinaCents.isAcceptableOrUnknown(
          data['stake_cinquina_cents']!,
          _stakeCinquinaCentsMeta,
        ),
      );
    }
    if (data.containsKey('target_draw_date')) {
      context.handle(
        _targetDrawDateMeta,
        targetDrawDate.isAcceptableOrUnknown(
          data['target_draw_date']!,
          _targetDrawDateMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VirtualTicketRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VirtualTicketRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      strategyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}strategy_id'],
      ),
      wheelCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wheel_code'],
      )!,
      stakeCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stake_cents'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      stakeEstrattoCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stake_estratto_cents'],
      )!,
      stakeAmboCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stake_ambo_cents'],
      )!,
      stakeTernoCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stake_terno_cents'],
      )!,
      stakeQuaternaCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stake_quaterna_cents'],
      )!,
      stakeCinquinaCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stake_cinquina_cents'],
      )!,
      targetDrawDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_draw_date'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $VirtualTicketsTable createAlias(String alias) {
    return $VirtualTicketsTable(attachedDatabase, alias);
  }
}

class VirtualTicketRow extends DataClass
    implements Insertable<VirtualTicketRow> {
  final int id;
  final int? strategyId;
  final String wheelCode;
  final int stakeCents;
  final DateTime createdAt;
  final String? note;
  final int stakeEstrattoCents;
  final int stakeAmboCents;
  final int stakeTernoCents;
  final int stakeQuaternaCents;
  final int stakeCinquinaCents;

  /// Giorno di estrazione a cui la schedina partecipa (mezzanotte UTC).
  final DateTime? targetDrawDate;

  /// `open`, `evaluated`, `legacy`.
  final String status;
  const VirtualTicketRow({
    required this.id,
    this.strategyId,
    required this.wheelCode,
    required this.stakeCents,
    required this.createdAt,
    this.note,
    required this.stakeEstrattoCents,
    required this.stakeAmboCents,
    required this.stakeTernoCents,
    required this.stakeQuaternaCents,
    required this.stakeCinquinaCents,
    this.targetDrawDate,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || strategyId != null) {
      map['strategy_id'] = Variable<int>(strategyId);
    }
    map['wheel_code'] = Variable<String>(wheelCode);
    map['stake_cents'] = Variable<int>(stakeCents);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['stake_estratto_cents'] = Variable<int>(stakeEstrattoCents);
    map['stake_ambo_cents'] = Variable<int>(stakeAmboCents);
    map['stake_terno_cents'] = Variable<int>(stakeTernoCents);
    map['stake_quaterna_cents'] = Variable<int>(stakeQuaternaCents);
    map['stake_cinquina_cents'] = Variable<int>(stakeCinquinaCents);
    if (!nullToAbsent || targetDrawDate != null) {
      map['target_draw_date'] = Variable<DateTime>(targetDrawDate);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  VirtualTicketsCompanion toCompanion(bool nullToAbsent) {
    return VirtualTicketsCompanion(
      id: Value(id),
      strategyId: strategyId == null && nullToAbsent
          ? const Value.absent()
          : Value(strategyId),
      wheelCode: Value(wheelCode),
      stakeCents: Value(stakeCents),
      createdAt: Value(createdAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      stakeEstrattoCents: Value(stakeEstrattoCents),
      stakeAmboCents: Value(stakeAmboCents),
      stakeTernoCents: Value(stakeTernoCents),
      stakeQuaternaCents: Value(stakeQuaternaCents),
      stakeCinquinaCents: Value(stakeCinquinaCents),
      targetDrawDate: targetDrawDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDrawDate),
      status: Value(status),
    );
  }

  factory VirtualTicketRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VirtualTicketRow(
      id: serializer.fromJson<int>(json['id']),
      strategyId: serializer.fromJson<int?>(json['strategyId']),
      wheelCode: serializer.fromJson<String>(json['wheelCode']),
      stakeCents: serializer.fromJson<int>(json['stakeCents']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      note: serializer.fromJson<String?>(json['note']),
      stakeEstrattoCents: serializer.fromJson<int>(json['stakeEstrattoCents']),
      stakeAmboCents: serializer.fromJson<int>(json['stakeAmboCents']),
      stakeTernoCents: serializer.fromJson<int>(json['stakeTernoCents']),
      stakeQuaternaCents: serializer.fromJson<int>(json['stakeQuaternaCents']),
      stakeCinquinaCents: serializer.fromJson<int>(json['stakeCinquinaCents']),
      targetDrawDate: serializer.fromJson<DateTime?>(json['targetDrawDate']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'strategyId': serializer.toJson<int?>(strategyId),
      'wheelCode': serializer.toJson<String>(wheelCode),
      'stakeCents': serializer.toJson<int>(stakeCents),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'note': serializer.toJson<String?>(note),
      'stakeEstrattoCents': serializer.toJson<int>(stakeEstrattoCents),
      'stakeAmboCents': serializer.toJson<int>(stakeAmboCents),
      'stakeTernoCents': serializer.toJson<int>(stakeTernoCents),
      'stakeQuaternaCents': serializer.toJson<int>(stakeQuaternaCents),
      'stakeCinquinaCents': serializer.toJson<int>(stakeCinquinaCents),
      'targetDrawDate': serializer.toJson<DateTime?>(targetDrawDate),
      'status': serializer.toJson<String>(status),
    };
  }

  VirtualTicketRow copyWith({
    int? id,
    Value<int?> strategyId = const Value.absent(),
    String? wheelCode,
    int? stakeCents,
    DateTime? createdAt,
    Value<String?> note = const Value.absent(),
    int? stakeEstrattoCents,
    int? stakeAmboCents,
    int? stakeTernoCents,
    int? stakeQuaternaCents,
    int? stakeCinquinaCents,
    Value<DateTime?> targetDrawDate = const Value.absent(),
    String? status,
  }) => VirtualTicketRow(
    id: id ?? this.id,
    strategyId: strategyId.present ? strategyId.value : this.strategyId,
    wheelCode: wheelCode ?? this.wheelCode,
    stakeCents: stakeCents ?? this.stakeCents,
    createdAt: createdAt ?? this.createdAt,
    note: note.present ? note.value : this.note,
    stakeEstrattoCents: stakeEstrattoCents ?? this.stakeEstrattoCents,
    stakeAmboCents: stakeAmboCents ?? this.stakeAmboCents,
    stakeTernoCents: stakeTernoCents ?? this.stakeTernoCents,
    stakeQuaternaCents: stakeQuaternaCents ?? this.stakeQuaternaCents,
    stakeCinquinaCents: stakeCinquinaCents ?? this.stakeCinquinaCents,
    targetDrawDate: targetDrawDate.present
        ? targetDrawDate.value
        : this.targetDrawDate,
    status: status ?? this.status,
  );
  VirtualTicketRow copyWithCompanion(VirtualTicketsCompanion data) {
    return VirtualTicketRow(
      id: data.id.present ? data.id.value : this.id,
      strategyId: data.strategyId.present
          ? data.strategyId.value
          : this.strategyId,
      wheelCode: data.wheelCode.present ? data.wheelCode.value : this.wheelCode,
      stakeCents: data.stakeCents.present
          ? data.stakeCents.value
          : this.stakeCents,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      note: data.note.present ? data.note.value : this.note,
      stakeEstrattoCents: data.stakeEstrattoCents.present
          ? data.stakeEstrattoCents.value
          : this.stakeEstrattoCents,
      stakeAmboCents: data.stakeAmboCents.present
          ? data.stakeAmboCents.value
          : this.stakeAmboCents,
      stakeTernoCents: data.stakeTernoCents.present
          ? data.stakeTernoCents.value
          : this.stakeTernoCents,
      stakeQuaternaCents: data.stakeQuaternaCents.present
          ? data.stakeQuaternaCents.value
          : this.stakeQuaternaCents,
      stakeCinquinaCents: data.stakeCinquinaCents.present
          ? data.stakeCinquinaCents.value
          : this.stakeCinquinaCents,
      targetDrawDate: data.targetDrawDate.present
          ? data.targetDrawDate.value
          : this.targetDrawDate,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VirtualTicketRow(')
          ..write('id: $id, ')
          ..write('strategyId: $strategyId, ')
          ..write('wheelCode: $wheelCode, ')
          ..write('stakeCents: $stakeCents, ')
          ..write('createdAt: $createdAt, ')
          ..write('note: $note, ')
          ..write('stakeEstrattoCents: $stakeEstrattoCents, ')
          ..write('stakeAmboCents: $stakeAmboCents, ')
          ..write('stakeTernoCents: $stakeTernoCents, ')
          ..write('stakeQuaternaCents: $stakeQuaternaCents, ')
          ..write('stakeCinquinaCents: $stakeCinquinaCents, ')
          ..write('targetDrawDate: $targetDrawDate, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    strategyId,
    wheelCode,
    stakeCents,
    createdAt,
    note,
    stakeEstrattoCents,
    stakeAmboCents,
    stakeTernoCents,
    stakeQuaternaCents,
    stakeCinquinaCents,
    targetDrawDate,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VirtualTicketRow &&
          other.id == this.id &&
          other.strategyId == this.strategyId &&
          other.wheelCode == this.wheelCode &&
          other.stakeCents == this.stakeCents &&
          other.createdAt == this.createdAt &&
          other.note == this.note &&
          other.stakeEstrattoCents == this.stakeEstrattoCents &&
          other.stakeAmboCents == this.stakeAmboCents &&
          other.stakeTernoCents == this.stakeTernoCents &&
          other.stakeQuaternaCents == this.stakeQuaternaCents &&
          other.stakeCinquinaCents == this.stakeCinquinaCents &&
          other.targetDrawDate == this.targetDrawDate &&
          other.status == this.status);
}

class VirtualTicketsCompanion extends UpdateCompanion<VirtualTicketRow> {
  final Value<int> id;
  final Value<int?> strategyId;
  final Value<String> wheelCode;
  final Value<int> stakeCents;
  final Value<DateTime> createdAt;
  final Value<String?> note;
  final Value<int> stakeEstrattoCents;
  final Value<int> stakeAmboCents;
  final Value<int> stakeTernoCents;
  final Value<int> stakeQuaternaCents;
  final Value<int> stakeCinquinaCents;
  final Value<DateTime?> targetDrawDate;
  final Value<String> status;
  const VirtualTicketsCompanion({
    this.id = const Value.absent(),
    this.strategyId = const Value.absent(),
    this.wheelCode = const Value.absent(),
    this.stakeCents = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.note = const Value.absent(),
    this.stakeEstrattoCents = const Value.absent(),
    this.stakeAmboCents = const Value.absent(),
    this.stakeTernoCents = const Value.absent(),
    this.stakeQuaternaCents = const Value.absent(),
    this.stakeCinquinaCents = const Value.absent(),
    this.targetDrawDate = const Value.absent(),
    this.status = const Value.absent(),
  });
  VirtualTicketsCompanion.insert({
    this.id = const Value.absent(),
    this.strategyId = const Value.absent(),
    required String wheelCode,
    required int stakeCents,
    required DateTime createdAt,
    this.note = const Value.absent(),
    this.stakeEstrattoCents = const Value.absent(),
    this.stakeAmboCents = const Value.absent(),
    this.stakeTernoCents = const Value.absent(),
    this.stakeQuaternaCents = const Value.absent(),
    this.stakeCinquinaCents = const Value.absent(),
    this.targetDrawDate = const Value.absent(),
    this.status = const Value.absent(),
  }) : wheelCode = Value(wheelCode),
       stakeCents = Value(stakeCents),
       createdAt = Value(createdAt);
  static Insertable<VirtualTicketRow> custom({
    Expression<int>? id,
    Expression<int>? strategyId,
    Expression<String>? wheelCode,
    Expression<int>? stakeCents,
    Expression<DateTime>? createdAt,
    Expression<String>? note,
    Expression<int>? stakeEstrattoCents,
    Expression<int>? stakeAmboCents,
    Expression<int>? stakeTernoCents,
    Expression<int>? stakeQuaternaCents,
    Expression<int>? stakeCinquinaCents,
    Expression<DateTime>? targetDrawDate,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (strategyId != null) 'strategy_id': strategyId,
      if (wheelCode != null) 'wheel_code': wheelCode,
      if (stakeCents != null) 'stake_cents': stakeCents,
      if (createdAt != null) 'created_at': createdAt,
      if (note != null) 'note': note,
      if (stakeEstrattoCents != null)
        'stake_estratto_cents': stakeEstrattoCents,
      if (stakeAmboCents != null) 'stake_ambo_cents': stakeAmboCents,
      if (stakeTernoCents != null) 'stake_terno_cents': stakeTernoCents,
      if (stakeQuaternaCents != null)
        'stake_quaterna_cents': stakeQuaternaCents,
      if (stakeCinquinaCents != null)
        'stake_cinquina_cents': stakeCinquinaCents,
      if (targetDrawDate != null) 'target_draw_date': targetDrawDate,
      if (status != null) 'status': status,
    });
  }

  VirtualTicketsCompanion copyWith({
    Value<int>? id,
    Value<int?>? strategyId,
    Value<String>? wheelCode,
    Value<int>? stakeCents,
    Value<DateTime>? createdAt,
    Value<String?>? note,
    Value<int>? stakeEstrattoCents,
    Value<int>? stakeAmboCents,
    Value<int>? stakeTernoCents,
    Value<int>? stakeQuaternaCents,
    Value<int>? stakeCinquinaCents,
    Value<DateTime?>? targetDrawDate,
    Value<String>? status,
  }) {
    return VirtualTicketsCompanion(
      id: id ?? this.id,
      strategyId: strategyId ?? this.strategyId,
      wheelCode: wheelCode ?? this.wheelCode,
      stakeCents: stakeCents ?? this.stakeCents,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      stakeEstrattoCents: stakeEstrattoCents ?? this.stakeEstrattoCents,
      stakeAmboCents: stakeAmboCents ?? this.stakeAmboCents,
      stakeTernoCents: stakeTernoCents ?? this.stakeTernoCents,
      stakeQuaternaCents: stakeQuaternaCents ?? this.stakeQuaternaCents,
      stakeCinquinaCents: stakeCinquinaCents ?? this.stakeCinquinaCents,
      targetDrawDate: targetDrawDate ?? this.targetDrawDate,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (strategyId.present) {
      map['strategy_id'] = Variable<int>(strategyId.value);
    }
    if (wheelCode.present) {
      map['wheel_code'] = Variable<String>(wheelCode.value);
    }
    if (stakeCents.present) {
      map['stake_cents'] = Variable<int>(stakeCents.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (stakeEstrattoCents.present) {
      map['stake_estratto_cents'] = Variable<int>(stakeEstrattoCents.value);
    }
    if (stakeAmboCents.present) {
      map['stake_ambo_cents'] = Variable<int>(stakeAmboCents.value);
    }
    if (stakeTernoCents.present) {
      map['stake_terno_cents'] = Variable<int>(stakeTernoCents.value);
    }
    if (stakeQuaternaCents.present) {
      map['stake_quaterna_cents'] = Variable<int>(stakeQuaternaCents.value);
    }
    if (stakeCinquinaCents.present) {
      map['stake_cinquina_cents'] = Variable<int>(stakeCinquinaCents.value);
    }
    if (targetDrawDate.present) {
      map['target_draw_date'] = Variable<DateTime>(targetDrawDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VirtualTicketsCompanion(')
          ..write('id: $id, ')
          ..write('strategyId: $strategyId, ')
          ..write('wheelCode: $wheelCode, ')
          ..write('stakeCents: $stakeCents, ')
          ..write('createdAt: $createdAt, ')
          ..write('note: $note, ')
          ..write('stakeEstrattoCents: $stakeEstrattoCents, ')
          ..write('stakeAmboCents: $stakeAmboCents, ')
          ..write('stakeTernoCents: $stakeTernoCents, ')
          ..write('stakeQuaternaCents: $stakeQuaternaCents, ')
          ..write('stakeCinquinaCents: $stakeCinquinaCents, ')
          ..write('targetDrawDate: $targetDrawDate, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $TicketNumbersTable extends TicketNumbers
    with TableInfo<$TicketNumbersTable, TicketNumberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TicketNumbersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ticketIdMeta = const VerificationMeta(
    'ticketId',
  );
  @override
  late final GeneratedColumn<int> ticketId = GeneratedColumn<int>(
    'ticket_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES virtual_tickets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, ticketId, position, number];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ticket_numbers';
  @override
  VerificationContext validateIntegrity(
    Insertable<TicketNumberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ticket_id')) {
      context.handle(
        _ticketIdMeta,
        ticketId.isAcceptableOrUnknown(data['ticket_id']!, _ticketIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ticketIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TicketNumberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TicketNumberRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ticketId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ticket_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
    );
  }

  @override
  $TicketNumbersTable createAlias(String alias) {
    return $TicketNumbersTable(attachedDatabase, alias);
  }
}

class TicketNumberRow extends DataClass implements Insertable<TicketNumberRow> {
  final int id;
  final int ticketId;
  final int position;
  final int number;
  const TicketNumberRow({
    required this.id,
    required this.ticketId,
    required this.position,
    required this.number,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ticket_id'] = Variable<int>(ticketId);
    map['position'] = Variable<int>(position);
    map['number'] = Variable<int>(number);
    return map;
  }

  TicketNumbersCompanion toCompanion(bool nullToAbsent) {
    return TicketNumbersCompanion(
      id: Value(id),
      ticketId: Value(ticketId),
      position: Value(position),
      number: Value(number),
    );
  }

  factory TicketNumberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TicketNumberRow(
      id: serializer.fromJson<int>(json['id']),
      ticketId: serializer.fromJson<int>(json['ticketId']),
      position: serializer.fromJson<int>(json['position']),
      number: serializer.fromJson<int>(json['number']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ticketId': serializer.toJson<int>(ticketId),
      'position': serializer.toJson<int>(position),
      'number': serializer.toJson<int>(number),
    };
  }

  TicketNumberRow copyWith({
    int? id,
    int? ticketId,
    int? position,
    int? number,
  }) => TicketNumberRow(
    id: id ?? this.id,
    ticketId: ticketId ?? this.ticketId,
    position: position ?? this.position,
    number: number ?? this.number,
  );
  TicketNumberRow copyWithCompanion(TicketNumbersCompanion data) {
    return TicketNumberRow(
      id: data.id.present ? data.id.value : this.id,
      ticketId: data.ticketId.present ? data.ticketId.value : this.ticketId,
      position: data.position.present ? data.position.value : this.position,
      number: data.number.present ? data.number.value : this.number,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TicketNumberRow(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('position: $position, ')
          ..write('number: $number')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ticketId, position, number);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TicketNumberRow &&
          other.id == this.id &&
          other.ticketId == this.ticketId &&
          other.position == this.position &&
          other.number == this.number);
}

class TicketNumbersCompanion extends UpdateCompanion<TicketNumberRow> {
  final Value<int> id;
  final Value<int> ticketId;
  final Value<int> position;
  final Value<int> number;
  const TicketNumbersCompanion({
    this.id = const Value.absent(),
    this.ticketId = const Value.absent(),
    this.position = const Value.absent(),
    this.number = const Value.absent(),
  });
  TicketNumbersCompanion.insert({
    this.id = const Value.absent(),
    required int ticketId,
    required int position,
    required int number,
  }) : ticketId = Value(ticketId),
       position = Value(position),
       number = Value(number);
  static Insertable<TicketNumberRow> custom({
    Expression<int>? id,
    Expression<int>? ticketId,
    Expression<int>? position,
    Expression<int>? number,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ticketId != null) 'ticket_id': ticketId,
      if (position != null) 'position': position,
      if (number != null) 'number': number,
    });
  }

  TicketNumbersCompanion copyWith({
    Value<int>? id,
    Value<int>? ticketId,
    Value<int>? position,
    Value<int>? number,
  }) {
    return TicketNumbersCompanion(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      position: position ?? this.position,
      number: number ?? this.number,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ticketId.present) {
      map['ticket_id'] = Variable<int>(ticketId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TicketNumbersCompanion(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('position: $position, ')
          ..write('number: $number')
          ..write(')'))
        .toString();
  }
}

class $TicketResultsTable extends TicketResults
    with TableInfo<$TicketResultsTable, TicketResultRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TicketResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ticketIdMeta = const VerificationMeta(
    'ticketId',
  );
  @override
  late final GeneratedColumn<int> ticketId = GeneratedColumn<int>(
    'ticket_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES virtual_tickets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _drawIdMeta = const VerificationMeta('drawId');
  @override
  late final GeneratedColumn<int> drawId = GeneratedColumn<int>(
    'draw_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES draws (id)',
    ),
  );
  static const VerificationMeta _evaluatedAtMeta = const VerificationMeta(
    'evaluatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> evaluatedAt = GeneratedColumn<DateTime>(
    'evaluated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hitsMeta = const VerificationMeta('hits');
  @override
  late final GeneratedColumn<int> hits = GeneratedColumn<int>(
    'hits',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grossCentsMeta = const VerificationMeta(
    'grossCents',
  );
  @override
  late final GeneratedColumn<int> grossCents = GeneratedColumn<int>(
    'gross_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _netCentsMeta = const VerificationMeta(
    'netCents',
  );
  @override
  late final GeneratedColumn<int> netCents = GeneratedColumn<int>(
    'net_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outcomeNoteMeta = const VerificationMeta(
    'outcomeNote',
  );
  @override
  late final GeneratedColumn<String> outcomeNote = GeneratedColumn<String>(
    'outcome_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailJsonMeta = const VerificationMeta(
    'detailJson',
  );
  @override
  late final GeneratedColumn<String> detailJson = GeneratedColumn<String>(
    'detail_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ticketId,
    drawId,
    evaluatedAt,
    hits,
    grossCents,
    netCents,
    outcomeNote,
    detailJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ticket_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<TicketResultRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ticket_id')) {
      context.handle(
        _ticketIdMeta,
        ticketId.isAcceptableOrUnknown(data['ticket_id']!, _ticketIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ticketIdMeta);
    }
    if (data.containsKey('draw_id')) {
      context.handle(
        _drawIdMeta,
        drawId.isAcceptableOrUnknown(data['draw_id']!, _drawIdMeta),
      );
    }
    if (data.containsKey('evaluated_at')) {
      context.handle(
        _evaluatedAtMeta,
        evaluatedAt.isAcceptableOrUnknown(
          data['evaluated_at']!,
          _evaluatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_evaluatedAtMeta);
    }
    if (data.containsKey('hits')) {
      context.handle(
        _hitsMeta,
        hits.isAcceptableOrUnknown(data['hits']!, _hitsMeta),
      );
    }
    if (data.containsKey('gross_cents')) {
      context.handle(
        _grossCentsMeta,
        grossCents.isAcceptableOrUnknown(data['gross_cents']!, _grossCentsMeta),
      );
    }
    if (data.containsKey('net_cents')) {
      context.handle(
        _netCentsMeta,
        netCents.isAcceptableOrUnknown(data['net_cents']!, _netCentsMeta),
      );
    }
    if (data.containsKey('outcome_note')) {
      context.handle(
        _outcomeNoteMeta,
        outcomeNote.isAcceptableOrUnknown(
          data['outcome_note']!,
          _outcomeNoteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_outcomeNoteMeta);
    }
    if (data.containsKey('detail_json')) {
      context.handle(
        _detailJsonMeta,
        detailJson.isAcceptableOrUnknown(data['detail_json']!, _detailJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TicketResultRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TicketResultRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ticketId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ticket_id'],
      )!,
      drawId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}draw_id'],
      ),
      evaluatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}evaluated_at'],
      )!,
      hits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hits'],
      ),
      grossCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gross_cents'],
      ),
      netCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}net_cents'],
      ),
      outcomeNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome_note'],
      )!,
      detailJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail_json'],
      ),
    );
  }

  @override
  $TicketResultsTable createAlias(String alias) {
    return $TicketResultsTable(attachedDatabase, alias);
  }
}

class TicketResultRow extends DataClass implements Insertable<TicketResultRow> {
  final int id;
  final int ticketId;
  final int? drawId;
  final DateTime evaluatedAt;
  final int? hits;
  final int? grossCents;
  final int? netCents;
  final String outcomeNote;

  /// JSON con centri per ruota e lordo per sorte (schema 2).
  final String? detailJson;
  const TicketResultRow({
    required this.id,
    required this.ticketId,
    this.drawId,
    required this.evaluatedAt,
    this.hits,
    this.grossCents,
    this.netCents,
    required this.outcomeNote,
    this.detailJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ticket_id'] = Variable<int>(ticketId);
    if (!nullToAbsent || drawId != null) {
      map['draw_id'] = Variable<int>(drawId);
    }
    map['evaluated_at'] = Variable<DateTime>(evaluatedAt);
    if (!nullToAbsent || hits != null) {
      map['hits'] = Variable<int>(hits);
    }
    if (!nullToAbsent || grossCents != null) {
      map['gross_cents'] = Variable<int>(grossCents);
    }
    if (!nullToAbsent || netCents != null) {
      map['net_cents'] = Variable<int>(netCents);
    }
    map['outcome_note'] = Variable<String>(outcomeNote);
    if (!nullToAbsent || detailJson != null) {
      map['detail_json'] = Variable<String>(detailJson);
    }
    return map;
  }

  TicketResultsCompanion toCompanion(bool nullToAbsent) {
    return TicketResultsCompanion(
      id: Value(id),
      ticketId: Value(ticketId),
      drawId: drawId == null && nullToAbsent
          ? const Value.absent()
          : Value(drawId),
      evaluatedAt: Value(evaluatedAt),
      hits: hits == null && nullToAbsent ? const Value.absent() : Value(hits),
      grossCents: grossCents == null && nullToAbsent
          ? const Value.absent()
          : Value(grossCents),
      netCents: netCents == null && nullToAbsent
          ? const Value.absent()
          : Value(netCents),
      outcomeNote: Value(outcomeNote),
      detailJson: detailJson == null && nullToAbsent
          ? const Value.absent()
          : Value(detailJson),
    );
  }

  factory TicketResultRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TicketResultRow(
      id: serializer.fromJson<int>(json['id']),
      ticketId: serializer.fromJson<int>(json['ticketId']),
      drawId: serializer.fromJson<int?>(json['drawId']),
      evaluatedAt: serializer.fromJson<DateTime>(json['evaluatedAt']),
      hits: serializer.fromJson<int?>(json['hits']),
      grossCents: serializer.fromJson<int?>(json['grossCents']),
      netCents: serializer.fromJson<int?>(json['netCents']),
      outcomeNote: serializer.fromJson<String>(json['outcomeNote']),
      detailJson: serializer.fromJson<String?>(json['detailJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ticketId': serializer.toJson<int>(ticketId),
      'drawId': serializer.toJson<int?>(drawId),
      'evaluatedAt': serializer.toJson<DateTime>(evaluatedAt),
      'hits': serializer.toJson<int?>(hits),
      'grossCents': serializer.toJson<int?>(grossCents),
      'netCents': serializer.toJson<int?>(netCents),
      'outcomeNote': serializer.toJson<String>(outcomeNote),
      'detailJson': serializer.toJson<String?>(detailJson),
    };
  }

  TicketResultRow copyWith({
    int? id,
    int? ticketId,
    Value<int?> drawId = const Value.absent(),
    DateTime? evaluatedAt,
    Value<int?> hits = const Value.absent(),
    Value<int?> grossCents = const Value.absent(),
    Value<int?> netCents = const Value.absent(),
    String? outcomeNote,
    Value<String?> detailJson = const Value.absent(),
  }) => TicketResultRow(
    id: id ?? this.id,
    ticketId: ticketId ?? this.ticketId,
    drawId: drawId.present ? drawId.value : this.drawId,
    evaluatedAt: evaluatedAt ?? this.evaluatedAt,
    hits: hits.present ? hits.value : this.hits,
    grossCents: grossCents.present ? grossCents.value : this.grossCents,
    netCents: netCents.present ? netCents.value : this.netCents,
    outcomeNote: outcomeNote ?? this.outcomeNote,
    detailJson: detailJson.present ? detailJson.value : this.detailJson,
  );
  TicketResultRow copyWithCompanion(TicketResultsCompanion data) {
    return TicketResultRow(
      id: data.id.present ? data.id.value : this.id,
      ticketId: data.ticketId.present ? data.ticketId.value : this.ticketId,
      drawId: data.drawId.present ? data.drawId.value : this.drawId,
      evaluatedAt: data.evaluatedAt.present
          ? data.evaluatedAt.value
          : this.evaluatedAt,
      hits: data.hits.present ? data.hits.value : this.hits,
      grossCents: data.grossCents.present
          ? data.grossCents.value
          : this.grossCents,
      netCents: data.netCents.present ? data.netCents.value : this.netCents,
      outcomeNote: data.outcomeNote.present
          ? data.outcomeNote.value
          : this.outcomeNote,
      detailJson: data.detailJson.present
          ? data.detailJson.value
          : this.detailJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TicketResultRow(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('drawId: $drawId, ')
          ..write('evaluatedAt: $evaluatedAt, ')
          ..write('hits: $hits, ')
          ..write('grossCents: $grossCents, ')
          ..write('netCents: $netCents, ')
          ..write('outcomeNote: $outcomeNote, ')
          ..write('detailJson: $detailJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ticketId,
    drawId,
    evaluatedAt,
    hits,
    grossCents,
    netCents,
    outcomeNote,
    detailJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TicketResultRow &&
          other.id == this.id &&
          other.ticketId == this.ticketId &&
          other.drawId == this.drawId &&
          other.evaluatedAt == this.evaluatedAt &&
          other.hits == this.hits &&
          other.grossCents == this.grossCents &&
          other.netCents == this.netCents &&
          other.outcomeNote == this.outcomeNote &&
          other.detailJson == this.detailJson);
}

class TicketResultsCompanion extends UpdateCompanion<TicketResultRow> {
  final Value<int> id;
  final Value<int> ticketId;
  final Value<int?> drawId;
  final Value<DateTime> evaluatedAt;
  final Value<int?> hits;
  final Value<int?> grossCents;
  final Value<int?> netCents;
  final Value<String> outcomeNote;
  final Value<String?> detailJson;
  const TicketResultsCompanion({
    this.id = const Value.absent(),
    this.ticketId = const Value.absent(),
    this.drawId = const Value.absent(),
    this.evaluatedAt = const Value.absent(),
    this.hits = const Value.absent(),
    this.grossCents = const Value.absent(),
    this.netCents = const Value.absent(),
    this.outcomeNote = const Value.absent(),
    this.detailJson = const Value.absent(),
  });
  TicketResultsCompanion.insert({
    this.id = const Value.absent(),
    required int ticketId,
    this.drawId = const Value.absent(),
    required DateTime evaluatedAt,
    this.hits = const Value.absent(),
    this.grossCents = const Value.absent(),
    this.netCents = const Value.absent(),
    required String outcomeNote,
    this.detailJson = const Value.absent(),
  }) : ticketId = Value(ticketId),
       evaluatedAt = Value(evaluatedAt),
       outcomeNote = Value(outcomeNote);
  static Insertable<TicketResultRow> custom({
    Expression<int>? id,
    Expression<int>? ticketId,
    Expression<int>? drawId,
    Expression<DateTime>? evaluatedAt,
    Expression<int>? hits,
    Expression<int>? grossCents,
    Expression<int>? netCents,
    Expression<String>? outcomeNote,
    Expression<String>? detailJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ticketId != null) 'ticket_id': ticketId,
      if (drawId != null) 'draw_id': drawId,
      if (evaluatedAt != null) 'evaluated_at': evaluatedAt,
      if (hits != null) 'hits': hits,
      if (grossCents != null) 'gross_cents': grossCents,
      if (netCents != null) 'net_cents': netCents,
      if (outcomeNote != null) 'outcome_note': outcomeNote,
      if (detailJson != null) 'detail_json': detailJson,
    });
  }

  TicketResultsCompanion copyWith({
    Value<int>? id,
    Value<int>? ticketId,
    Value<int?>? drawId,
    Value<DateTime>? evaluatedAt,
    Value<int?>? hits,
    Value<int?>? grossCents,
    Value<int?>? netCents,
    Value<String>? outcomeNote,
    Value<String?>? detailJson,
  }) {
    return TicketResultsCompanion(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      drawId: drawId ?? this.drawId,
      evaluatedAt: evaluatedAt ?? this.evaluatedAt,
      hits: hits ?? this.hits,
      grossCents: grossCents ?? this.grossCents,
      netCents: netCents ?? this.netCents,
      outcomeNote: outcomeNote ?? this.outcomeNote,
      detailJson: detailJson ?? this.detailJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ticketId.present) {
      map['ticket_id'] = Variable<int>(ticketId.value);
    }
    if (drawId.present) {
      map['draw_id'] = Variable<int>(drawId.value);
    }
    if (evaluatedAt.present) {
      map['evaluated_at'] = Variable<DateTime>(evaluatedAt.value);
    }
    if (hits.present) {
      map['hits'] = Variable<int>(hits.value);
    }
    if (grossCents.present) {
      map['gross_cents'] = Variable<int>(grossCents.value);
    }
    if (netCents.present) {
      map['net_cents'] = Variable<int>(netCents.value);
    }
    if (outcomeNote.present) {
      map['outcome_note'] = Variable<String>(outcomeNote.value);
    }
    if (detailJson.present) {
      map['detail_json'] = Variable<String>(detailJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TicketResultsCompanion(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('drawId: $drawId, ')
          ..write('evaluatedAt: $evaluatedAt, ')
          ..write('hits: $hits, ')
          ..write('grossCents: $grossCents, ')
          ..write('netCents: $netCents, ')
          ..write('outcomeNote: $outcomeNote, ')
          ..write('detailJson: $detailJson')
          ..write(')'))
        .toString();
  }
}

class $SuperenalottoDrawsTable extends SuperenalottoDraws
    with TableInfo<$SuperenalottoDrawsTable, SuperenalottoDrawRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuperenalottoDrawsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _drawDateMeta = const VerificationMeta(
    'drawDate',
  );
  @override
  late final GeneratedColumn<DateTime> drawDate = GeneratedColumn<DateTime>(
    'draw_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contestNumberMeta = const VerificationMeta(
    'contestNumber',
  );
  @override
  late final GeneratedColumn<int> contestNumber = GeneratedColumn<int>(
    'contest_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _n1Meta = const VerificationMeta('n1');
  @override
  late final GeneratedColumn<int> n1 = GeneratedColumn<int>(
    'n1',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _n2Meta = const VerificationMeta('n2');
  @override
  late final GeneratedColumn<int> n2 = GeneratedColumn<int>(
    'n2',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _n3Meta = const VerificationMeta('n3');
  @override
  late final GeneratedColumn<int> n3 = GeneratedColumn<int>(
    'n3',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _n4Meta = const VerificationMeta('n4');
  @override
  late final GeneratedColumn<int> n4 = GeneratedColumn<int>(
    'n4',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _n5Meta = const VerificationMeta('n5');
  @override
  late final GeneratedColumn<int> n5 = GeneratedColumn<int>(
    'n5',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _n6Meta = const VerificationMeta('n6');
  @override
  late final GeneratedColumn<int> n6 = GeneratedColumn<int>(
    'n6',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jollyMeta = const VerificationMeta('jolly');
  @override
  late final GeneratedColumn<int> jolly = GeneratedColumn<int>(
    'jolly',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _superstarMeta = const VerificationMeta(
    'superstar',
  );
  @override
  late final GeneratedColumn<int> superstar = GeneratedColumn<int>(
    'superstar',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _officiallyVerifiedMeta =
      const VerificationMeta('officiallyVerified');
  @override
  late final GeneratedColumn<bool> officiallyVerified = GeneratedColumn<bool>(
    'officially_verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("officially_verified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _provenanceMeta = const VerificationMeta(
    'provenance',
  );
  @override
  late final GeneratedColumn<String> provenance = GeneratedColumn<String>(
    'provenance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    drawDate,
    contestNumber,
    n1,
    n2,
    n3,
    n4,
    n5,
    n6,
    jolly,
    superstar,
    contentHash,
    officiallyVerified,
    provenance,
    importedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'superenalotto_draws';
  @override
  VerificationContext validateIntegrity(
    Insertable<SuperenalottoDrawRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('draw_date')) {
      context.handle(
        _drawDateMeta,
        drawDate.isAcceptableOrUnknown(data['draw_date']!, _drawDateMeta),
      );
    } else if (isInserting) {
      context.missing(_drawDateMeta);
    }
    if (data.containsKey('contest_number')) {
      context.handle(
        _contestNumberMeta,
        contestNumber.isAcceptableOrUnknown(
          data['contest_number']!,
          _contestNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contestNumberMeta);
    }
    if (data.containsKey('n1')) {
      context.handle(_n1Meta, n1.isAcceptableOrUnknown(data['n1']!, _n1Meta));
    } else if (isInserting) {
      context.missing(_n1Meta);
    }
    if (data.containsKey('n2')) {
      context.handle(_n2Meta, n2.isAcceptableOrUnknown(data['n2']!, _n2Meta));
    } else if (isInserting) {
      context.missing(_n2Meta);
    }
    if (data.containsKey('n3')) {
      context.handle(_n3Meta, n3.isAcceptableOrUnknown(data['n3']!, _n3Meta));
    } else if (isInserting) {
      context.missing(_n3Meta);
    }
    if (data.containsKey('n4')) {
      context.handle(_n4Meta, n4.isAcceptableOrUnknown(data['n4']!, _n4Meta));
    } else if (isInserting) {
      context.missing(_n4Meta);
    }
    if (data.containsKey('n5')) {
      context.handle(_n5Meta, n5.isAcceptableOrUnknown(data['n5']!, _n5Meta));
    } else if (isInserting) {
      context.missing(_n5Meta);
    }
    if (data.containsKey('n6')) {
      context.handle(_n6Meta, n6.isAcceptableOrUnknown(data['n6']!, _n6Meta));
    } else if (isInserting) {
      context.missing(_n6Meta);
    }
    if (data.containsKey('jolly')) {
      context.handle(
        _jollyMeta,
        jolly.isAcceptableOrUnknown(data['jolly']!, _jollyMeta),
      );
    } else if (isInserting) {
      context.missing(_jollyMeta);
    }
    if (data.containsKey('superstar')) {
      context.handle(
        _superstarMeta,
        superstar.isAcceptableOrUnknown(data['superstar']!, _superstarMeta),
      );
    } else if (isInserting) {
      context.missing(_superstarMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('officially_verified')) {
      context.handle(
        _officiallyVerifiedMeta,
        officiallyVerified.isAcceptableOrUnknown(
          data['officially_verified']!,
          _officiallyVerifiedMeta,
        ),
      );
    }
    if (data.containsKey('provenance')) {
      context.handle(
        _provenanceMeta,
        provenance.isAcceptableOrUnknown(data['provenance']!, _provenanceMeta),
      );
    } else if (isInserting) {
      context.missing(_provenanceMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SuperenalottoDrawRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SuperenalottoDrawRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      drawDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}draw_date'],
      )!,
      contestNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contest_number'],
      )!,
      n1: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}n1'],
      )!,
      n2: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}n2'],
      )!,
      n3: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}n3'],
      )!,
      n4: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}n4'],
      )!,
      n5: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}n5'],
      )!,
      n6: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}n6'],
      )!,
      jolly: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jolly'],
      )!,
      superstar: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}superstar'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      officiallyVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}officially_verified'],
      )!,
      provenance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provenance'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
    );
  }

  @override
  $SuperenalottoDrawsTable createAlias(String alias) {
    return $SuperenalottoDrawsTable(attachedDatabase, alias);
  }
}

class SuperenalottoDrawRow extends DataClass
    implements Insertable<SuperenalottoDrawRow> {
  final int id;
  final DateTime drawDate;
  final int contestNumber;
  final int n1;
  final int n2;
  final int n3;
  final int n4;
  final int n5;
  final int n6;
  final int jolly;
  final int superstar;
  final String contentHash;
  final bool officiallyVerified;
  final String provenance;
  final DateTime importedAt;
  const SuperenalottoDrawRow({
    required this.id,
    required this.drawDate,
    required this.contestNumber,
    required this.n1,
    required this.n2,
    required this.n3,
    required this.n4,
    required this.n5,
    required this.n6,
    required this.jolly,
    required this.superstar,
    required this.contentHash,
    required this.officiallyVerified,
    required this.provenance,
    required this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['draw_date'] = Variable<DateTime>(drawDate);
    map['contest_number'] = Variable<int>(contestNumber);
    map['n1'] = Variable<int>(n1);
    map['n2'] = Variable<int>(n2);
    map['n3'] = Variable<int>(n3);
    map['n4'] = Variable<int>(n4);
    map['n5'] = Variable<int>(n5);
    map['n6'] = Variable<int>(n6);
    map['jolly'] = Variable<int>(jolly);
    map['superstar'] = Variable<int>(superstar);
    map['content_hash'] = Variable<String>(contentHash);
    map['officially_verified'] = Variable<bool>(officiallyVerified);
    map['provenance'] = Variable<String>(provenance);
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  SuperenalottoDrawsCompanion toCompanion(bool nullToAbsent) {
    return SuperenalottoDrawsCompanion(
      id: Value(id),
      drawDate: Value(drawDate),
      contestNumber: Value(contestNumber),
      n1: Value(n1),
      n2: Value(n2),
      n3: Value(n3),
      n4: Value(n4),
      n5: Value(n5),
      n6: Value(n6),
      jolly: Value(jolly),
      superstar: Value(superstar),
      contentHash: Value(contentHash),
      officiallyVerified: Value(officiallyVerified),
      provenance: Value(provenance),
      importedAt: Value(importedAt),
    );
  }

  factory SuperenalottoDrawRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SuperenalottoDrawRow(
      id: serializer.fromJson<int>(json['id']),
      drawDate: serializer.fromJson<DateTime>(json['drawDate']),
      contestNumber: serializer.fromJson<int>(json['contestNumber']),
      n1: serializer.fromJson<int>(json['n1']),
      n2: serializer.fromJson<int>(json['n2']),
      n3: serializer.fromJson<int>(json['n3']),
      n4: serializer.fromJson<int>(json['n4']),
      n5: serializer.fromJson<int>(json['n5']),
      n6: serializer.fromJson<int>(json['n6']),
      jolly: serializer.fromJson<int>(json['jolly']),
      superstar: serializer.fromJson<int>(json['superstar']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      officiallyVerified: serializer.fromJson<bool>(json['officiallyVerified']),
      provenance: serializer.fromJson<String>(json['provenance']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'drawDate': serializer.toJson<DateTime>(drawDate),
      'contestNumber': serializer.toJson<int>(contestNumber),
      'n1': serializer.toJson<int>(n1),
      'n2': serializer.toJson<int>(n2),
      'n3': serializer.toJson<int>(n3),
      'n4': serializer.toJson<int>(n4),
      'n5': serializer.toJson<int>(n5),
      'n6': serializer.toJson<int>(n6),
      'jolly': serializer.toJson<int>(jolly),
      'superstar': serializer.toJson<int>(superstar),
      'contentHash': serializer.toJson<String>(contentHash),
      'officiallyVerified': serializer.toJson<bool>(officiallyVerified),
      'provenance': serializer.toJson<String>(provenance),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  SuperenalottoDrawRow copyWith({
    int? id,
    DateTime? drawDate,
    int? contestNumber,
    int? n1,
    int? n2,
    int? n3,
    int? n4,
    int? n5,
    int? n6,
    int? jolly,
    int? superstar,
    String? contentHash,
    bool? officiallyVerified,
    String? provenance,
    DateTime? importedAt,
  }) => SuperenalottoDrawRow(
    id: id ?? this.id,
    drawDate: drawDate ?? this.drawDate,
    contestNumber: contestNumber ?? this.contestNumber,
    n1: n1 ?? this.n1,
    n2: n2 ?? this.n2,
    n3: n3 ?? this.n3,
    n4: n4 ?? this.n4,
    n5: n5 ?? this.n5,
    n6: n6 ?? this.n6,
    jolly: jolly ?? this.jolly,
    superstar: superstar ?? this.superstar,
    contentHash: contentHash ?? this.contentHash,
    officiallyVerified: officiallyVerified ?? this.officiallyVerified,
    provenance: provenance ?? this.provenance,
    importedAt: importedAt ?? this.importedAt,
  );
  SuperenalottoDrawRow copyWithCompanion(SuperenalottoDrawsCompanion data) {
    return SuperenalottoDrawRow(
      id: data.id.present ? data.id.value : this.id,
      drawDate: data.drawDate.present ? data.drawDate.value : this.drawDate,
      contestNumber: data.contestNumber.present
          ? data.contestNumber.value
          : this.contestNumber,
      n1: data.n1.present ? data.n1.value : this.n1,
      n2: data.n2.present ? data.n2.value : this.n2,
      n3: data.n3.present ? data.n3.value : this.n3,
      n4: data.n4.present ? data.n4.value : this.n4,
      n5: data.n5.present ? data.n5.value : this.n5,
      n6: data.n6.present ? data.n6.value : this.n6,
      jolly: data.jolly.present ? data.jolly.value : this.jolly,
      superstar: data.superstar.present ? data.superstar.value : this.superstar,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      officiallyVerified: data.officiallyVerified.present
          ? data.officiallyVerified.value
          : this.officiallyVerified,
      provenance: data.provenance.present
          ? data.provenance.value
          : this.provenance,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SuperenalottoDrawRow(')
          ..write('id: $id, ')
          ..write('drawDate: $drawDate, ')
          ..write('contestNumber: $contestNumber, ')
          ..write('n1: $n1, ')
          ..write('n2: $n2, ')
          ..write('n3: $n3, ')
          ..write('n4: $n4, ')
          ..write('n5: $n5, ')
          ..write('n6: $n6, ')
          ..write('jolly: $jolly, ')
          ..write('superstar: $superstar, ')
          ..write('contentHash: $contentHash, ')
          ..write('officiallyVerified: $officiallyVerified, ')
          ..write('provenance: $provenance, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    drawDate,
    contestNumber,
    n1,
    n2,
    n3,
    n4,
    n5,
    n6,
    jolly,
    superstar,
    contentHash,
    officiallyVerified,
    provenance,
    importedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SuperenalottoDrawRow &&
          other.id == this.id &&
          other.drawDate == this.drawDate &&
          other.contestNumber == this.contestNumber &&
          other.n1 == this.n1 &&
          other.n2 == this.n2 &&
          other.n3 == this.n3 &&
          other.n4 == this.n4 &&
          other.n5 == this.n5 &&
          other.n6 == this.n6 &&
          other.jolly == this.jolly &&
          other.superstar == this.superstar &&
          other.contentHash == this.contentHash &&
          other.officiallyVerified == this.officiallyVerified &&
          other.provenance == this.provenance &&
          other.importedAt == this.importedAt);
}

class SuperenalottoDrawsCompanion
    extends UpdateCompanion<SuperenalottoDrawRow> {
  final Value<int> id;
  final Value<DateTime> drawDate;
  final Value<int> contestNumber;
  final Value<int> n1;
  final Value<int> n2;
  final Value<int> n3;
  final Value<int> n4;
  final Value<int> n5;
  final Value<int> n6;
  final Value<int> jolly;
  final Value<int> superstar;
  final Value<String> contentHash;
  final Value<bool> officiallyVerified;
  final Value<String> provenance;
  final Value<DateTime> importedAt;
  const SuperenalottoDrawsCompanion({
    this.id = const Value.absent(),
    this.drawDate = const Value.absent(),
    this.contestNumber = const Value.absent(),
    this.n1 = const Value.absent(),
    this.n2 = const Value.absent(),
    this.n3 = const Value.absent(),
    this.n4 = const Value.absent(),
    this.n5 = const Value.absent(),
    this.n6 = const Value.absent(),
    this.jolly = const Value.absent(),
    this.superstar = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.officiallyVerified = const Value.absent(),
    this.provenance = const Value.absent(),
    this.importedAt = const Value.absent(),
  });
  SuperenalottoDrawsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime drawDate,
    required int contestNumber,
    required int n1,
    required int n2,
    required int n3,
    required int n4,
    required int n5,
    required int n6,
    required int jolly,
    required int superstar,
    required String contentHash,
    this.officiallyVerified = const Value.absent(),
    required String provenance,
    required DateTime importedAt,
  }) : drawDate = Value(drawDate),
       contestNumber = Value(contestNumber),
       n1 = Value(n1),
       n2 = Value(n2),
       n3 = Value(n3),
       n4 = Value(n4),
       n5 = Value(n5),
       n6 = Value(n6),
       jolly = Value(jolly),
       superstar = Value(superstar),
       contentHash = Value(contentHash),
       provenance = Value(provenance),
       importedAt = Value(importedAt);
  static Insertable<SuperenalottoDrawRow> custom({
    Expression<int>? id,
    Expression<DateTime>? drawDate,
    Expression<int>? contestNumber,
    Expression<int>? n1,
    Expression<int>? n2,
    Expression<int>? n3,
    Expression<int>? n4,
    Expression<int>? n5,
    Expression<int>? n6,
    Expression<int>? jolly,
    Expression<int>? superstar,
    Expression<String>? contentHash,
    Expression<bool>? officiallyVerified,
    Expression<String>? provenance,
    Expression<DateTime>? importedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (drawDate != null) 'draw_date': drawDate,
      if (contestNumber != null) 'contest_number': contestNumber,
      if (n1 != null) 'n1': n1,
      if (n2 != null) 'n2': n2,
      if (n3 != null) 'n3': n3,
      if (n4 != null) 'n4': n4,
      if (n5 != null) 'n5': n5,
      if (n6 != null) 'n6': n6,
      if (jolly != null) 'jolly': jolly,
      if (superstar != null) 'superstar': superstar,
      if (contentHash != null) 'content_hash': contentHash,
      if (officiallyVerified != null) 'officially_verified': officiallyVerified,
      if (provenance != null) 'provenance': provenance,
      if (importedAt != null) 'imported_at': importedAt,
    });
  }

  SuperenalottoDrawsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? drawDate,
    Value<int>? contestNumber,
    Value<int>? n1,
    Value<int>? n2,
    Value<int>? n3,
    Value<int>? n4,
    Value<int>? n5,
    Value<int>? n6,
    Value<int>? jolly,
    Value<int>? superstar,
    Value<String>? contentHash,
    Value<bool>? officiallyVerified,
    Value<String>? provenance,
    Value<DateTime>? importedAt,
  }) {
    return SuperenalottoDrawsCompanion(
      id: id ?? this.id,
      drawDate: drawDate ?? this.drawDate,
      contestNumber: contestNumber ?? this.contestNumber,
      n1: n1 ?? this.n1,
      n2: n2 ?? this.n2,
      n3: n3 ?? this.n3,
      n4: n4 ?? this.n4,
      n5: n5 ?? this.n5,
      n6: n6 ?? this.n6,
      jolly: jolly ?? this.jolly,
      superstar: superstar ?? this.superstar,
      contentHash: contentHash ?? this.contentHash,
      officiallyVerified: officiallyVerified ?? this.officiallyVerified,
      provenance: provenance ?? this.provenance,
      importedAt: importedAt ?? this.importedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (drawDate.present) {
      map['draw_date'] = Variable<DateTime>(drawDate.value);
    }
    if (contestNumber.present) {
      map['contest_number'] = Variable<int>(contestNumber.value);
    }
    if (n1.present) {
      map['n1'] = Variable<int>(n1.value);
    }
    if (n2.present) {
      map['n2'] = Variable<int>(n2.value);
    }
    if (n3.present) {
      map['n3'] = Variable<int>(n3.value);
    }
    if (n4.present) {
      map['n4'] = Variable<int>(n4.value);
    }
    if (n5.present) {
      map['n5'] = Variable<int>(n5.value);
    }
    if (n6.present) {
      map['n6'] = Variable<int>(n6.value);
    }
    if (jolly.present) {
      map['jolly'] = Variable<int>(jolly.value);
    }
    if (superstar.present) {
      map['superstar'] = Variable<int>(superstar.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (officiallyVerified.present) {
      map['officially_verified'] = Variable<bool>(officiallyVerified.value);
    }
    if (provenance.present) {
      map['provenance'] = Variable<String>(provenance.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuperenalottoDrawsCompanion(')
          ..write('id: $id, ')
          ..write('drawDate: $drawDate, ')
          ..write('contestNumber: $contestNumber, ')
          ..write('n1: $n1, ')
          ..write('n2: $n2, ')
          ..write('n3: $n3, ')
          ..write('n4: $n4, ')
          ..write('n5: $n5, ')
          ..write('n6: $n6, ')
          ..write('jolly: $jolly, ')
          ..write('superstar: $superstar, ')
          ..write('contentHash: $contentHash, ')
          ..write('officiallyVerified: $officiallyVerified, ')
          ..write('provenance: $provenance, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }
}

class $SuperenalottoTicketsTable extends SuperenalottoTickets
    with TableInfo<$SuperenalottoTicketsTable, SuperenalottoTicketRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuperenalottoTicketsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _n1Meta = const VerificationMeta('n1');
  @override
  late final GeneratedColumn<int> n1 = GeneratedColumn<int>(
    'n1',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _n2Meta = const VerificationMeta('n2');
  @override
  late final GeneratedColumn<int> n2 = GeneratedColumn<int>(
    'n2',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _n3Meta = const VerificationMeta('n3');
  @override
  late final GeneratedColumn<int> n3 = GeneratedColumn<int>(
    'n3',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _n4Meta = const VerificationMeta('n4');
  @override
  late final GeneratedColumn<int> n4 = GeneratedColumn<int>(
    'n4',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _n5Meta = const VerificationMeta('n5');
  @override
  late final GeneratedColumn<int> n5 = GeneratedColumn<int>(
    'n5',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _n6Meta = const VerificationMeta('n6');
  @override
  late final GeneratedColumn<int> n6 = GeneratedColumn<int>(
    'n6',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _superstarMeta = const VerificationMeta(
    'superstar',
  );
  @override
  late final GeneratedColumn<int> superstar = GeneratedColumn<int>(
    'superstar',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetDrawDateMeta = const VerificationMeta(
    'targetDrawDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDrawDate =
      GeneratedColumn<DateTime>(
        'target_draw_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manuale'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    n1,
    n2,
    n3,
    n4,
    n5,
    n6,
    superstar,
    targetDrawDate,
    status,
    origin,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'superenalotto_tickets';
  @override
  VerificationContext validateIntegrity(
    Insertable<SuperenalottoTicketRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('n1')) {
      context.handle(_n1Meta, n1.isAcceptableOrUnknown(data['n1']!, _n1Meta));
    } else if (isInserting) {
      context.missing(_n1Meta);
    }
    if (data.containsKey('n2')) {
      context.handle(_n2Meta, n2.isAcceptableOrUnknown(data['n2']!, _n2Meta));
    } else if (isInserting) {
      context.missing(_n2Meta);
    }
    if (data.containsKey('n3')) {
      context.handle(_n3Meta, n3.isAcceptableOrUnknown(data['n3']!, _n3Meta));
    } else if (isInserting) {
      context.missing(_n3Meta);
    }
    if (data.containsKey('n4')) {
      context.handle(_n4Meta, n4.isAcceptableOrUnknown(data['n4']!, _n4Meta));
    } else if (isInserting) {
      context.missing(_n4Meta);
    }
    if (data.containsKey('n5')) {
      context.handle(_n5Meta, n5.isAcceptableOrUnknown(data['n5']!, _n5Meta));
    } else if (isInserting) {
      context.missing(_n5Meta);
    }
    if (data.containsKey('n6')) {
      context.handle(_n6Meta, n6.isAcceptableOrUnknown(data['n6']!, _n6Meta));
    } else if (isInserting) {
      context.missing(_n6Meta);
    }
    if (data.containsKey('superstar')) {
      context.handle(
        _superstarMeta,
        superstar.isAcceptableOrUnknown(data['superstar']!, _superstarMeta),
      );
    }
    if (data.containsKey('target_draw_date')) {
      context.handle(
        _targetDrawDateMeta,
        targetDrawDate.isAcceptableOrUnknown(
          data['target_draw_date']!,
          _targetDrawDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetDrawDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SuperenalottoTicketRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SuperenalottoTicketRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      n1: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}n1'],
      )!,
      n2: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}n2'],
      )!,
      n3: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}n3'],
      )!,
      n4: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}n4'],
      )!,
      n5: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}n5'],
      )!,
      n6: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}n6'],
      )!,
      superstar: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}superstar'],
      ),
      targetDrawDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_draw_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SuperenalottoTicketsTable createAlias(String alias) {
    return $SuperenalottoTicketsTable(attachedDatabase, alias);
  }
}

class SuperenalottoTicketRow extends DataClass
    implements Insertable<SuperenalottoTicketRow> {
  final int id;
  final int n1;
  final int n2;
  final int n3;
  final int n4;
  final int n5;
  final int n6;
  final int? superstar;
  final DateTime targetDrawDate;
  final String status;
  final String origin;
  final String? note;
  final DateTime createdAt;
  const SuperenalottoTicketRow({
    required this.id,
    required this.n1,
    required this.n2,
    required this.n3,
    required this.n4,
    required this.n5,
    required this.n6,
    this.superstar,
    required this.targetDrawDate,
    required this.status,
    required this.origin,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['n1'] = Variable<int>(n1);
    map['n2'] = Variable<int>(n2);
    map['n3'] = Variable<int>(n3);
    map['n4'] = Variable<int>(n4);
    map['n5'] = Variable<int>(n5);
    map['n6'] = Variable<int>(n6);
    if (!nullToAbsent || superstar != null) {
      map['superstar'] = Variable<int>(superstar);
    }
    map['target_draw_date'] = Variable<DateTime>(targetDrawDate);
    map['status'] = Variable<String>(status);
    map['origin'] = Variable<String>(origin);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SuperenalottoTicketsCompanion toCompanion(bool nullToAbsent) {
    return SuperenalottoTicketsCompanion(
      id: Value(id),
      n1: Value(n1),
      n2: Value(n2),
      n3: Value(n3),
      n4: Value(n4),
      n5: Value(n5),
      n6: Value(n6),
      superstar: superstar == null && nullToAbsent
          ? const Value.absent()
          : Value(superstar),
      targetDrawDate: Value(targetDrawDate),
      status: Value(status),
      origin: Value(origin),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory SuperenalottoTicketRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SuperenalottoTicketRow(
      id: serializer.fromJson<int>(json['id']),
      n1: serializer.fromJson<int>(json['n1']),
      n2: serializer.fromJson<int>(json['n2']),
      n3: serializer.fromJson<int>(json['n3']),
      n4: serializer.fromJson<int>(json['n4']),
      n5: serializer.fromJson<int>(json['n5']),
      n6: serializer.fromJson<int>(json['n6']),
      superstar: serializer.fromJson<int?>(json['superstar']),
      targetDrawDate: serializer.fromJson<DateTime>(json['targetDrawDate']),
      status: serializer.fromJson<String>(json['status']),
      origin: serializer.fromJson<String>(json['origin']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'n1': serializer.toJson<int>(n1),
      'n2': serializer.toJson<int>(n2),
      'n3': serializer.toJson<int>(n3),
      'n4': serializer.toJson<int>(n4),
      'n5': serializer.toJson<int>(n5),
      'n6': serializer.toJson<int>(n6),
      'superstar': serializer.toJson<int?>(superstar),
      'targetDrawDate': serializer.toJson<DateTime>(targetDrawDate),
      'status': serializer.toJson<String>(status),
      'origin': serializer.toJson<String>(origin),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SuperenalottoTicketRow copyWith({
    int? id,
    int? n1,
    int? n2,
    int? n3,
    int? n4,
    int? n5,
    int? n6,
    Value<int?> superstar = const Value.absent(),
    DateTime? targetDrawDate,
    String? status,
    String? origin,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => SuperenalottoTicketRow(
    id: id ?? this.id,
    n1: n1 ?? this.n1,
    n2: n2 ?? this.n2,
    n3: n3 ?? this.n3,
    n4: n4 ?? this.n4,
    n5: n5 ?? this.n5,
    n6: n6 ?? this.n6,
    superstar: superstar.present ? superstar.value : this.superstar,
    targetDrawDate: targetDrawDate ?? this.targetDrawDate,
    status: status ?? this.status,
    origin: origin ?? this.origin,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  SuperenalottoTicketRow copyWithCompanion(SuperenalottoTicketsCompanion data) {
    return SuperenalottoTicketRow(
      id: data.id.present ? data.id.value : this.id,
      n1: data.n1.present ? data.n1.value : this.n1,
      n2: data.n2.present ? data.n2.value : this.n2,
      n3: data.n3.present ? data.n3.value : this.n3,
      n4: data.n4.present ? data.n4.value : this.n4,
      n5: data.n5.present ? data.n5.value : this.n5,
      n6: data.n6.present ? data.n6.value : this.n6,
      superstar: data.superstar.present ? data.superstar.value : this.superstar,
      targetDrawDate: data.targetDrawDate.present
          ? data.targetDrawDate.value
          : this.targetDrawDate,
      status: data.status.present ? data.status.value : this.status,
      origin: data.origin.present ? data.origin.value : this.origin,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SuperenalottoTicketRow(')
          ..write('id: $id, ')
          ..write('n1: $n1, ')
          ..write('n2: $n2, ')
          ..write('n3: $n3, ')
          ..write('n4: $n4, ')
          ..write('n5: $n5, ')
          ..write('n6: $n6, ')
          ..write('superstar: $superstar, ')
          ..write('targetDrawDate: $targetDrawDate, ')
          ..write('status: $status, ')
          ..write('origin: $origin, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    n1,
    n2,
    n3,
    n4,
    n5,
    n6,
    superstar,
    targetDrawDate,
    status,
    origin,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SuperenalottoTicketRow &&
          other.id == this.id &&
          other.n1 == this.n1 &&
          other.n2 == this.n2 &&
          other.n3 == this.n3 &&
          other.n4 == this.n4 &&
          other.n5 == this.n5 &&
          other.n6 == this.n6 &&
          other.superstar == this.superstar &&
          other.targetDrawDate == this.targetDrawDate &&
          other.status == this.status &&
          other.origin == this.origin &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class SuperenalottoTicketsCompanion
    extends UpdateCompanion<SuperenalottoTicketRow> {
  final Value<int> id;
  final Value<int> n1;
  final Value<int> n2;
  final Value<int> n3;
  final Value<int> n4;
  final Value<int> n5;
  final Value<int> n6;
  final Value<int?> superstar;
  final Value<DateTime> targetDrawDate;
  final Value<String> status;
  final Value<String> origin;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const SuperenalottoTicketsCompanion({
    this.id = const Value.absent(),
    this.n1 = const Value.absent(),
    this.n2 = const Value.absent(),
    this.n3 = const Value.absent(),
    this.n4 = const Value.absent(),
    this.n5 = const Value.absent(),
    this.n6 = const Value.absent(),
    this.superstar = const Value.absent(),
    this.targetDrawDate = const Value.absent(),
    this.status = const Value.absent(),
    this.origin = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SuperenalottoTicketsCompanion.insert({
    this.id = const Value.absent(),
    required int n1,
    required int n2,
    required int n3,
    required int n4,
    required int n5,
    required int n6,
    this.superstar = const Value.absent(),
    required DateTime targetDrawDate,
    this.status = const Value.absent(),
    this.origin = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
  }) : n1 = Value(n1),
       n2 = Value(n2),
       n3 = Value(n3),
       n4 = Value(n4),
       n5 = Value(n5),
       n6 = Value(n6),
       targetDrawDate = Value(targetDrawDate),
       createdAt = Value(createdAt);
  static Insertable<SuperenalottoTicketRow> custom({
    Expression<int>? id,
    Expression<int>? n1,
    Expression<int>? n2,
    Expression<int>? n3,
    Expression<int>? n4,
    Expression<int>? n5,
    Expression<int>? n6,
    Expression<int>? superstar,
    Expression<DateTime>? targetDrawDate,
    Expression<String>? status,
    Expression<String>? origin,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (n1 != null) 'n1': n1,
      if (n2 != null) 'n2': n2,
      if (n3 != null) 'n3': n3,
      if (n4 != null) 'n4': n4,
      if (n5 != null) 'n5': n5,
      if (n6 != null) 'n6': n6,
      if (superstar != null) 'superstar': superstar,
      if (targetDrawDate != null) 'target_draw_date': targetDrawDate,
      if (status != null) 'status': status,
      if (origin != null) 'origin': origin,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SuperenalottoTicketsCompanion copyWith({
    Value<int>? id,
    Value<int>? n1,
    Value<int>? n2,
    Value<int>? n3,
    Value<int>? n4,
    Value<int>? n5,
    Value<int>? n6,
    Value<int?>? superstar,
    Value<DateTime>? targetDrawDate,
    Value<String>? status,
    Value<String>? origin,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return SuperenalottoTicketsCompanion(
      id: id ?? this.id,
      n1: n1 ?? this.n1,
      n2: n2 ?? this.n2,
      n3: n3 ?? this.n3,
      n4: n4 ?? this.n4,
      n5: n5 ?? this.n5,
      n6: n6 ?? this.n6,
      superstar: superstar ?? this.superstar,
      targetDrawDate: targetDrawDate ?? this.targetDrawDate,
      status: status ?? this.status,
      origin: origin ?? this.origin,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (n1.present) {
      map['n1'] = Variable<int>(n1.value);
    }
    if (n2.present) {
      map['n2'] = Variable<int>(n2.value);
    }
    if (n3.present) {
      map['n3'] = Variable<int>(n3.value);
    }
    if (n4.present) {
      map['n4'] = Variable<int>(n4.value);
    }
    if (n5.present) {
      map['n5'] = Variable<int>(n5.value);
    }
    if (n6.present) {
      map['n6'] = Variable<int>(n6.value);
    }
    if (superstar.present) {
      map['superstar'] = Variable<int>(superstar.value);
    }
    if (targetDrawDate.present) {
      map['target_draw_date'] = Variable<DateTime>(targetDrawDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuperenalottoTicketsCompanion(')
          ..write('id: $id, ')
          ..write('n1: $n1, ')
          ..write('n2: $n2, ')
          ..write('n3: $n3, ')
          ..write('n4: $n4, ')
          ..write('n5: $n5, ')
          ..write('n6: $n6, ')
          ..write('superstar: $superstar, ')
          ..write('targetDrawDate: $targetDrawDate, ')
          ..write('status: $status, ')
          ..write('origin: $origin, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SuperenalottoTicketResultsTable extends SuperenalottoTicketResults
    with
        TableInfo<
          $SuperenalottoTicketResultsTable,
          SuperenalottoTicketResultRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuperenalottoTicketResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ticketIdMeta = const VerificationMeta(
    'ticketId',
  );
  @override
  late final GeneratedColumn<int> ticketId = GeneratedColumn<int>(
    'ticket_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES superenalotto_tickets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _contestNumberMeta = const VerificationMeta(
    'contestNumber',
  );
  @override
  late final GeneratedColumn<int> contestNumber = GeneratedColumn<int>(
    'contest_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _drawDateMeta = const VerificationMeta(
    'drawDate',
  );
  @override
  late final GeneratedColumn<DateTime> drawDate = GeneratedColumn<DateTime>(
    'draw_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hitsMeta = const VerificationMeta('hits');
  @override
  late final GeneratedColumn<int> hits = GeneratedColumn<int>(
    'hits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jollyMatchedMeta = const VerificationMeta(
    'jollyMatched',
  );
  @override
  late final GeneratedColumn<bool> jollyMatched = GeneratedColumn<bool>(
    'jolly_matched',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("jolly_matched" IN (0, 1))',
    ),
  );
  static const VerificationMeta _superstarMatchedMeta = const VerificationMeta(
    'superstarMatched',
  );
  @override
  late final GeneratedColumn<bool> superstarMatched = GeneratedColumn<bool>(
    'superstar_matched',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("superstar_matched" IN (0, 1))',
    ),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evaluatedAtMeta = const VerificationMeta(
    'evaluatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> evaluatedAt = GeneratedColumn<DateTime>(
    'evaluated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ticketId,
    contestNumber,
    drawDate,
    hits,
    jollyMatched,
    superstarMatched,
    category,
    evaluatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'superenalotto_ticket_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<SuperenalottoTicketResultRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ticket_id')) {
      context.handle(
        _ticketIdMeta,
        ticketId.isAcceptableOrUnknown(data['ticket_id']!, _ticketIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ticketIdMeta);
    }
    if (data.containsKey('contest_number')) {
      context.handle(
        _contestNumberMeta,
        contestNumber.isAcceptableOrUnknown(
          data['contest_number']!,
          _contestNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contestNumberMeta);
    }
    if (data.containsKey('draw_date')) {
      context.handle(
        _drawDateMeta,
        drawDate.isAcceptableOrUnknown(data['draw_date']!, _drawDateMeta),
      );
    } else if (isInserting) {
      context.missing(_drawDateMeta);
    }
    if (data.containsKey('hits')) {
      context.handle(
        _hitsMeta,
        hits.isAcceptableOrUnknown(data['hits']!, _hitsMeta),
      );
    } else if (isInserting) {
      context.missing(_hitsMeta);
    }
    if (data.containsKey('jolly_matched')) {
      context.handle(
        _jollyMatchedMeta,
        jollyMatched.isAcceptableOrUnknown(
          data['jolly_matched']!,
          _jollyMatchedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jollyMatchedMeta);
    }
    if (data.containsKey('superstar_matched')) {
      context.handle(
        _superstarMatchedMeta,
        superstarMatched.isAcceptableOrUnknown(
          data['superstar_matched']!,
          _superstarMatchedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_superstarMatchedMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('evaluated_at')) {
      context.handle(
        _evaluatedAtMeta,
        evaluatedAt.isAcceptableOrUnknown(
          data['evaluated_at']!,
          _evaluatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_evaluatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SuperenalottoTicketResultRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SuperenalottoTicketResultRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ticketId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ticket_id'],
      )!,
      contestNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contest_number'],
      )!,
      drawDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}draw_date'],
      )!,
      hits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hits'],
      )!,
      jollyMatched: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}jolly_matched'],
      )!,
      superstarMatched: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}superstar_matched'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      evaluatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}evaluated_at'],
      )!,
    );
  }

  @override
  $SuperenalottoTicketResultsTable createAlias(String alias) {
    return $SuperenalottoTicketResultsTable(attachedDatabase, alias);
  }
}

class SuperenalottoTicketResultRow extends DataClass
    implements Insertable<SuperenalottoTicketResultRow> {
  final int id;
  final int ticketId;
  final int contestNumber;
  final DateTime drawDate;
  final int hits;
  final bool jollyMatched;
  final bool superstarMatched;
  final String category;
  final DateTime evaluatedAt;
  const SuperenalottoTicketResultRow({
    required this.id,
    required this.ticketId,
    required this.contestNumber,
    required this.drawDate,
    required this.hits,
    required this.jollyMatched,
    required this.superstarMatched,
    required this.category,
    required this.evaluatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ticket_id'] = Variable<int>(ticketId);
    map['contest_number'] = Variable<int>(contestNumber);
    map['draw_date'] = Variable<DateTime>(drawDate);
    map['hits'] = Variable<int>(hits);
    map['jolly_matched'] = Variable<bool>(jollyMatched);
    map['superstar_matched'] = Variable<bool>(superstarMatched);
    map['category'] = Variable<String>(category);
    map['evaluated_at'] = Variable<DateTime>(evaluatedAt);
    return map;
  }

  SuperenalottoTicketResultsCompanion toCompanion(bool nullToAbsent) {
    return SuperenalottoTicketResultsCompanion(
      id: Value(id),
      ticketId: Value(ticketId),
      contestNumber: Value(contestNumber),
      drawDate: Value(drawDate),
      hits: Value(hits),
      jollyMatched: Value(jollyMatched),
      superstarMatched: Value(superstarMatched),
      category: Value(category),
      evaluatedAt: Value(evaluatedAt),
    );
  }

  factory SuperenalottoTicketResultRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SuperenalottoTicketResultRow(
      id: serializer.fromJson<int>(json['id']),
      ticketId: serializer.fromJson<int>(json['ticketId']),
      contestNumber: serializer.fromJson<int>(json['contestNumber']),
      drawDate: serializer.fromJson<DateTime>(json['drawDate']),
      hits: serializer.fromJson<int>(json['hits']),
      jollyMatched: serializer.fromJson<bool>(json['jollyMatched']),
      superstarMatched: serializer.fromJson<bool>(json['superstarMatched']),
      category: serializer.fromJson<String>(json['category']),
      evaluatedAt: serializer.fromJson<DateTime>(json['evaluatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ticketId': serializer.toJson<int>(ticketId),
      'contestNumber': serializer.toJson<int>(contestNumber),
      'drawDate': serializer.toJson<DateTime>(drawDate),
      'hits': serializer.toJson<int>(hits),
      'jollyMatched': serializer.toJson<bool>(jollyMatched),
      'superstarMatched': serializer.toJson<bool>(superstarMatched),
      'category': serializer.toJson<String>(category),
      'evaluatedAt': serializer.toJson<DateTime>(evaluatedAt),
    };
  }

  SuperenalottoTicketResultRow copyWith({
    int? id,
    int? ticketId,
    int? contestNumber,
    DateTime? drawDate,
    int? hits,
    bool? jollyMatched,
    bool? superstarMatched,
    String? category,
    DateTime? evaluatedAt,
  }) => SuperenalottoTicketResultRow(
    id: id ?? this.id,
    ticketId: ticketId ?? this.ticketId,
    contestNumber: contestNumber ?? this.contestNumber,
    drawDate: drawDate ?? this.drawDate,
    hits: hits ?? this.hits,
    jollyMatched: jollyMatched ?? this.jollyMatched,
    superstarMatched: superstarMatched ?? this.superstarMatched,
    category: category ?? this.category,
    evaluatedAt: evaluatedAt ?? this.evaluatedAt,
  );
  SuperenalottoTicketResultRow copyWithCompanion(
    SuperenalottoTicketResultsCompanion data,
  ) {
    return SuperenalottoTicketResultRow(
      id: data.id.present ? data.id.value : this.id,
      ticketId: data.ticketId.present ? data.ticketId.value : this.ticketId,
      contestNumber: data.contestNumber.present
          ? data.contestNumber.value
          : this.contestNumber,
      drawDate: data.drawDate.present ? data.drawDate.value : this.drawDate,
      hits: data.hits.present ? data.hits.value : this.hits,
      jollyMatched: data.jollyMatched.present
          ? data.jollyMatched.value
          : this.jollyMatched,
      superstarMatched: data.superstarMatched.present
          ? data.superstarMatched.value
          : this.superstarMatched,
      category: data.category.present ? data.category.value : this.category,
      evaluatedAt: data.evaluatedAt.present
          ? data.evaluatedAt.value
          : this.evaluatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SuperenalottoTicketResultRow(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('contestNumber: $contestNumber, ')
          ..write('drawDate: $drawDate, ')
          ..write('hits: $hits, ')
          ..write('jollyMatched: $jollyMatched, ')
          ..write('superstarMatched: $superstarMatched, ')
          ..write('category: $category, ')
          ..write('evaluatedAt: $evaluatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ticketId,
    contestNumber,
    drawDate,
    hits,
    jollyMatched,
    superstarMatched,
    category,
    evaluatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SuperenalottoTicketResultRow &&
          other.id == this.id &&
          other.ticketId == this.ticketId &&
          other.contestNumber == this.contestNumber &&
          other.drawDate == this.drawDate &&
          other.hits == this.hits &&
          other.jollyMatched == this.jollyMatched &&
          other.superstarMatched == this.superstarMatched &&
          other.category == this.category &&
          other.evaluatedAt == this.evaluatedAt);
}

class SuperenalottoTicketResultsCompanion
    extends UpdateCompanion<SuperenalottoTicketResultRow> {
  final Value<int> id;
  final Value<int> ticketId;
  final Value<int> contestNumber;
  final Value<DateTime> drawDate;
  final Value<int> hits;
  final Value<bool> jollyMatched;
  final Value<bool> superstarMatched;
  final Value<String> category;
  final Value<DateTime> evaluatedAt;
  const SuperenalottoTicketResultsCompanion({
    this.id = const Value.absent(),
    this.ticketId = const Value.absent(),
    this.contestNumber = const Value.absent(),
    this.drawDate = const Value.absent(),
    this.hits = const Value.absent(),
    this.jollyMatched = const Value.absent(),
    this.superstarMatched = const Value.absent(),
    this.category = const Value.absent(),
    this.evaluatedAt = const Value.absent(),
  });
  SuperenalottoTicketResultsCompanion.insert({
    this.id = const Value.absent(),
    required int ticketId,
    required int contestNumber,
    required DateTime drawDate,
    required int hits,
    required bool jollyMatched,
    required bool superstarMatched,
    required String category,
    required DateTime evaluatedAt,
  }) : ticketId = Value(ticketId),
       contestNumber = Value(contestNumber),
       drawDate = Value(drawDate),
       hits = Value(hits),
       jollyMatched = Value(jollyMatched),
       superstarMatched = Value(superstarMatched),
       category = Value(category),
       evaluatedAt = Value(evaluatedAt);
  static Insertable<SuperenalottoTicketResultRow> custom({
    Expression<int>? id,
    Expression<int>? ticketId,
    Expression<int>? contestNumber,
    Expression<DateTime>? drawDate,
    Expression<int>? hits,
    Expression<bool>? jollyMatched,
    Expression<bool>? superstarMatched,
    Expression<String>? category,
    Expression<DateTime>? evaluatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ticketId != null) 'ticket_id': ticketId,
      if (contestNumber != null) 'contest_number': contestNumber,
      if (drawDate != null) 'draw_date': drawDate,
      if (hits != null) 'hits': hits,
      if (jollyMatched != null) 'jolly_matched': jollyMatched,
      if (superstarMatched != null) 'superstar_matched': superstarMatched,
      if (category != null) 'category': category,
      if (evaluatedAt != null) 'evaluated_at': evaluatedAt,
    });
  }

  SuperenalottoTicketResultsCompanion copyWith({
    Value<int>? id,
    Value<int>? ticketId,
    Value<int>? contestNumber,
    Value<DateTime>? drawDate,
    Value<int>? hits,
    Value<bool>? jollyMatched,
    Value<bool>? superstarMatched,
    Value<String>? category,
    Value<DateTime>? evaluatedAt,
  }) {
    return SuperenalottoTicketResultsCompanion(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      contestNumber: contestNumber ?? this.contestNumber,
      drawDate: drawDate ?? this.drawDate,
      hits: hits ?? this.hits,
      jollyMatched: jollyMatched ?? this.jollyMatched,
      superstarMatched: superstarMatched ?? this.superstarMatched,
      category: category ?? this.category,
      evaluatedAt: evaluatedAt ?? this.evaluatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ticketId.present) {
      map['ticket_id'] = Variable<int>(ticketId.value);
    }
    if (contestNumber.present) {
      map['contest_number'] = Variable<int>(contestNumber.value);
    }
    if (drawDate.present) {
      map['draw_date'] = Variable<DateTime>(drawDate.value);
    }
    if (hits.present) {
      map['hits'] = Variable<int>(hits.value);
    }
    if (jollyMatched.present) {
      map['jolly_matched'] = Variable<bool>(jollyMatched.value);
    }
    if (superstarMatched.present) {
      map['superstar_matched'] = Variable<bool>(superstarMatched.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (evaluatedAt.present) {
      map['evaluated_at'] = Variable<DateTime>(evaluatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuperenalottoTicketResultsCompanion(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('contestNumber: $contestNumber, ')
          ..write('drawDate: $drawDate, ')
          ..write('hits: $hits, ')
          ..write('jollyMatched: $jollyMatched, ')
          ..write('superstarMatched: $superstarMatched, ')
          ..write('category: $category, ')
          ..write('evaluatedAt: $evaluatedAt')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  UserSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSettingRow extends DataClass implements Insertable<UserSettingRow> {
  final String key;
  final String value;
  const UserSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory UserSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  UserSettingRow copyWith({String? key, String? value}) =>
      UserSettingRow(key: key ?? this.key, value: value ?? this.value);
  UserSettingRow copyWithCompanion(UserSettingsCompanion data) {
    return UserSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class UserSettingsCompanion extends UpdateCompanion<UserSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<UserSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return UserSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WheelsTable wheels = $WheelsTable(this);
  late final $DataSourcesTable dataSources = $DataSourcesTable(this);
  late final $DrawsTable draws = $DrawsTable(this);
  late final $DrawNumbersTable drawNumbers = $DrawNumbersTable(this);
  late final $SyncLogsTable syncLogs = $SyncLogsTable(this);
  late final $StrategiesTable strategies = $StrategiesTable(this);
  late final $StrategyParametersTable strategyParameters =
      $StrategyParametersTable(this);
  late final $AiModelsTable aiModels = $AiModelsTable(this);
  late final $PredictionsTable predictions = $PredictionsTable(this);
  late final $PredictionNumbersTable predictionNumbers =
      $PredictionNumbersTable(this);
  late final $AiExecutionLogsTable aiExecutionLogs = $AiExecutionLogsTable(
    this,
  );
  late final $BacktestRunsTable backtestRuns = $BacktestRunsTable(this);
  late final $BacktestResultsTable backtestResults = $BacktestResultsTable(
    this,
  );
  late final $VirtualTicketsTable virtualTickets = $VirtualTicketsTable(this);
  late final $TicketNumbersTable ticketNumbers = $TicketNumbersTable(this);
  late final $TicketResultsTable ticketResults = $TicketResultsTable(this);
  late final $SuperenalottoDrawsTable superenalottoDraws =
      $SuperenalottoDrawsTable(this);
  late final $SuperenalottoTicketsTable superenalottoTickets =
      $SuperenalottoTicketsTable(this);
  late final $SuperenalottoTicketResultsTable superenalottoTicketResults =
      $SuperenalottoTicketResultsTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final Index idxDrawsWheelDate = Index(
    'idx_draws_wheel_date',
    'CREATE INDEX idx_draws_wheel_date ON draws (wheel_id, draw_date)',
  );
  late final Index idxDrawsDate = Index(
    'idx_draws_date',
    'CREATE INDEX idx_draws_date ON draws (draw_date)',
  );
  late final Index idxDrawNumbersDraw = Index(
    'idx_draw_numbers_draw',
    'CREATE INDEX idx_draw_numbers_draw ON draw_numbers (draw_id)',
  );
  late final Index idxPredictionNumbers = Index(
    'idx_prediction_numbers',
    'CREATE INDEX idx_prediction_numbers ON prediction_numbers (prediction_id)',
  );
  late final Index idxBacktestResultsRun = Index(
    'idx_backtest_results_run',
    'CREATE INDEX idx_backtest_results_run ON backtest_results (run_id)',
  );
  late final Index idxTicketNumbers = Index(
    'idx_ticket_numbers',
    'CREATE INDEX idx_ticket_numbers ON ticket_numbers (ticket_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    wheels,
    dataSources,
    draws,
    drawNumbers,
    syncLogs,
    strategies,
    strategyParameters,
    aiModels,
    predictions,
    predictionNumbers,
    aiExecutionLogs,
    backtestRuns,
    backtestResults,
    virtualTickets,
    ticketNumbers,
    ticketResults,
    superenalottoDraws,
    superenalottoTickets,
    superenalottoTicketResults,
    userSettings,
    idxDrawsWheelDate,
    idxDrawsDate,
    idxDrawNumbersDraw,
    idxPredictionNumbers,
    idxBacktestResultsRun,
    idxTicketNumbers,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'draws',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('draw_numbers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'strategies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('strategy_parameters', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'predictions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('prediction_numbers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'backtest_runs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('backtest_results', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'virtual_tickets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ticket_numbers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'virtual_tickets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ticket_results', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'superenalotto_tickets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('superenalotto_ticket_results', kind: UpdateKind.delete),
      ],
    ),
  ]);
}

typedef $$WheelsTableCreateCompanionBuilder =
    WheelsCompanion Function({
      Value<int> id,
      required String code,
      required String name,
      required int sortOrder,
    });
typedef $$WheelsTableUpdateCompanionBuilder =
    WheelsCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<String> name,
      Value<int> sortOrder,
    });

final class $$WheelsTableReferences
    extends BaseReferences<_$AppDatabase, $WheelsTable, WheelRow> {
  $$WheelsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DrawsTable, List<DrawRow>> _drawsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.draws,
    aliasName: $_aliasNameGenerator(db.wheels.id, db.draws.wheelId),
  );

  $$DrawsTableProcessedTableManager get drawsRefs {
    final manager = $$DrawsTableTableManager(
      $_db,
      $_db.draws,
    ).filter((f) => f.wheelId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_drawsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WheelsTableFilterComposer
    extends Composer<_$AppDatabase, $WheelsTable> {
  $$WheelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> drawsRefs(
    Expression<bool> Function($$DrawsTableFilterComposer f) f,
  ) {
    final $$DrawsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.draws,
      getReferencedColumn: (t) => t.wheelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrawsTableFilterComposer(
            $db: $db,
            $table: $db.draws,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WheelsTableOrderingComposer
    extends Composer<_$AppDatabase, $WheelsTable> {
  $$WheelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WheelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WheelsTable> {
  $$WheelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> drawsRefs<T extends Object>(
    Expression<T> Function($$DrawsTableAnnotationComposer a) f,
  ) {
    final $$DrawsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.draws,
      getReferencedColumn: (t) => t.wheelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrawsTableAnnotationComposer(
            $db: $db,
            $table: $db.draws,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WheelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WheelsTable,
          WheelRow,
          $$WheelsTableFilterComposer,
          $$WheelsTableOrderingComposer,
          $$WheelsTableAnnotationComposer,
          $$WheelsTableCreateCompanionBuilder,
          $$WheelsTableUpdateCompanionBuilder,
          (WheelRow, $$WheelsTableReferences),
          WheelRow,
          PrefetchHooks Function({bool drawsRefs})
        > {
  $$WheelsTableTableManager(_$AppDatabase db, $WheelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WheelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WheelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WheelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => WheelsCompanion(
                id: id,
                code: code,
                name: name,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String code,
                required String name,
                required int sortOrder,
              }) => WheelsCompanion.insert(
                id: id,
                code: code,
                name: name,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$WheelsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({drawsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (drawsRefs) db.draws],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (drawsRefs)
                    await $_getPrefetchedData<WheelRow, $WheelsTable, DrawRow>(
                      currentTable: table,
                      referencedTable: $$WheelsTableReferences._drawsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$WheelsTableReferences(db, table, p0).drawsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.wheelId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WheelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WheelsTable,
      WheelRow,
      $$WheelsTableFilterComposer,
      $$WheelsTableOrderingComposer,
      $$WheelsTableAnnotationComposer,
      $$WheelsTableCreateCompanionBuilder,
      $$WheelsTableUpdateCompanionBuilder,
      (WheelRow, $$WheelsTableReferences),
      WheelRow,
      PrefetchHooks Function({bool drawsRefs})
    >;
typedef $$DataSourcesTableCreateCompanionBuilder =
    DataSourcesCompanion Function({
      Value<int> id,
      required String code,
      required String name,
      required String kind,
      Value<String?> pageUrl,
      Value<String?> archiveUrl,
      required String status,
      Value<DateTime?> lastCheckedAt,
      Value<DateTime?> lastSuccessAt,
      Value<String?> lastError,
      Value<String?> httpLastModified,
      Value<String?> notes,
    });
typedef $$DataSourcesTableUpdateCompanionBuilder =
    DataSourcesCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<String> name,
      Value<String> kind,
      Value<String?> pageUrl,
      Value<String?> archiveUrl,
      Value<String> status,
      Value<DateTime?> lastCheckedAt,
      Value<DateTime?> lastSuccessAt,
      Value<String?> lastError,
      Value<String?> httpLastModified,
      Value<String?> notes,
    });

final class $$DataSourcesTableReferences
    extends BaseReferences<_$AppDatabase, $DataSourcesTable, DataSourceRow> {
  $$DataSourcesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DrawsTable, List<DrawRow>> _drawsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.draws,
    aliasName: $_aliasNameGenerator(db.dataSources.id, db.draws.sourceId),
  );

  $$DrawsTableProcessedTableManager get drawsRefs {
    final manager = $$DrawsTableTableManager(
      $_db,
      $_db.draws,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_drawsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SyncLogsTable, List<SyncLogRow>>
  _syncLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.syncLogs,
    aliasName: $_aliasNameGenerator(db.dataSources.id, db.syncLogs.sourceId),
  );

  $$SyncLogsTableProcessedTableManager get syncLogsRefs {
    final manager = $$SyncLogsTableTableManager(
      $_db,
      $_db.syncLogs,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_syncLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DataSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $DataSourcesTable> {
  $$DataSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pageUrl => $composableBuilder(
    column: $table.pageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archiveUrl => $composableBuilder(
    column: $table.archiveUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get httpLastModified => $composableBuilder(
    column: $table.httpLastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> drawsRefs(
    Expression<bool> Function($$DrawsTableFilterComposer f) f,
  ) {
    final $$DrawsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.draws,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrawsTableFilterComposer(
            $db: $db,
            $table: $db.draws,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> syncLogsRefs(
    Expression<bool> Function($$SyncLogsTableFilterComposer f) f,
  ) {
    final $$SyncLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncLogs,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncLogsTableFilterComposer(
            $db: $db,
            $table: $db.syncLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DataSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $DataSourcesTable> {
  $$DataSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pageUrl => $composableBuilder(
    column: $table.pageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archiveUrl => $composableBuilder(
    column: $table.archiveUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get httpLastModified => $composableBuilder(
    column: $table.httpLastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DataSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DataSourcesTable> {
  $$DataSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get pageUrl =>
      $composableBuilder(column: $table.pageUrl, builder: (column) => column);

  GeneratedColumn<String> get archiveUrl => $composableBuilder(
    column: $table.archiveUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get httpLastModified => $composableBuilder(
    column: $table.httpLastModified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> drawsRefs<T extends Object>(
    Expression<T> Function($$DrawsTableAnnotationComposer a) f,
  ) {
    final $$DrawsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.draws,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrawsTableAnnotationComposer(
            $db: $db,
            $table: $db.draws,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> syncLogsRefs<T extends Object>(
    Expression<T> Function($$SyncLogsTableAnnotationComposer a) f,
  ) {
    final $$SyncLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncLogs,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DataSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DataSourcesTable,
          DataSourceRow,
          $$DataSourcesTableFilterComposer,
          $$DataSourcesTableOrderingComposer,
          $$DataSourcesTableAnnotationComposer,
          $$DataSourcesTableCreateCompanionBuilder,
          $$DataSourcesTableUpdateCompanionBuilder,
          (DataSourceRow, $$DataSourcesTableReferences),
          DataSourceRow,
          PrefetchHooks Function({bool drawsRefs, bool syncLogsRefs})
        > {
  $$DataSourcesTableTableManager(_$AppDatabase db, $DataSourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DataSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DataSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DataSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> pageUrl = const Value.absent(),
                Value<String?> archiveUrl = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> lastCheckedAt = const Value.absent(),
                Value<DateTime?> lastSuccessAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> httpLastModified = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => DataSourcesCompanion(
                id: id,
                code: code,
                name: name,
                kind: kind,
                pageUrl: pageUrl,
                archiveUrl: archiveUrl,
                status: status,
                lastCheckedAt: lastCheckedAt,
                lastSuccessAt: lastSuccessAt,
                lastError: lastError,
                httpLastModified: httpLastModified,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String code,
                required String name,
                required String kind,
                Value<String?> pageUrl = const Value.absent(),
                Value<String?> archiveUrl = const Value.absent(),
                required String status,
                Value<DateTime?> lastCheckedAt = const Value.absent(),
                Value<DateTime?> lastSuccessAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> httpLastModified = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => DataSourcesCompanion.insert(
                id: id,
                code: code,
                name: name,
                kind: kind,
                pageUrl: pageUrl,
                archiveUrl: archiveUrl,
                status: status,
                lastCheckedAt: lastCheckedAt,
                lastSuccessAt: lastSuccessAt,
                lastError: lastError,
                httpLastModified: httpLastModified,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DataSourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({drawsRefs = false, syncLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (drawsRefs) db.draws,
                if (syncLogsRefs) db.syncLogs,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (drawsRefs)
                    await $_getPrefetchedData<
                      DataSourceRow,
                      $DataSourcesTable,
                      DrawRow
                    >(
                      currentTable: table,
                      referencedTable: $$DataSourcesTableReferences
                          ._drawsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DataSourcesTableReferences(db, table, p0).drawsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sourceId == item.id),
                      typedResults: items,
                    ),
                  if (syncLogsRefs)
                    await $_getPrefetchedData<
                      DataSourceRow,
                      $DataSourcesTable,
                      SyncLogRow
                    >(
                      currentTable: table,
                      referencedTable: $$DataSourcesTableReferences
                          ._syncLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DataSourcesTableReferences(
                            db,
                            table,
                            p0,
                          ).syncLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sourceId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DataSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DataSourcesTable,
      DataSourceRow,
      $$DataSourcesTableFilterComposer,
      $$DataSourcesTableOrderingComposer,
      $$DataSourcesTableAnnotationComposer,
      $$DataSourcesTableCreateCompanionBuilder,
      $$DataSourcesTableUpdateCompanionBuilder,
      (DataSourceRow, $$DataSourcesTableReferences),
      DataSourceRow,
      PrefetchHooks Function({bool drawsRefs, bool syncLogsRefs})
    >;
typedef $$DrawsTableCreateCompanionBuilder =
    DrawsCompanion Function({
      Value<int> id,
      required DateTime drawDate,
      Value<int?> contestNumber,
      required int wheelId,
      required int sourceId,
      Value<bool> structuralIntegrityOk,
      Value<bool> officiallyVerified,
      required String provenance,
      required String contentHash,
      required DateTime importedAt,
    });
typedef $$DrawsTableUpdateCompanionBuilder =
    DrawsCompanion Function({
      Value<int> id,
      Value<DateTime> drawDate,
      Value<int?> contestNumber,
      Value<int> wheelId,
      Value<int> sourceId,
      Value<bool> structuralIntegrityOk,
      Value<bool> officiallyVerified,
      Value<String> provenance,
      Value<String> contentHash,
      Value<DateTime> importedAt,
    });

final class $$DrawsTableReferences
    extends BaseReferences<_$AppDatabase, $DrawsTable, DrawRow> {
  $$DrawsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WheelsTable _wheelIdTable(_$AppDatabase db) => db.wheels.createAlias(
    $_aliasNameGenerator(db.draws.wheelId, db.wheels.id),
  );

  $$WheelsTableProcessedTableManager get wheelId {
    final $_column = $_itemColumn<int>('wheel_id')!;

    final manager = $$WheelsTableTableManager(
      $_db,
      $_db.wheels,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wheelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DataSourcesTable _sourceIdTable(_$AppDatabase db) => db.dataSources
      .createAlias($_aliasNameGenerator(db.draws.sourceId, db.dataSources.id));

  $$DataSourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<int>('source_id')!;

    final manager = $$DataSourcesTableTableManager(
      $_db,
      $_db.dataSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DrawNumbersTable, List<DrawNumberRow>>
  _drawNumbersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.drawNumbers,
    aliasName: $_aliasNameGenerator(db.draws.id, db.drawNumbers.drawId),
  );

  $$DrawNumbersTableProcessedTableManager get drawNumbersRefs {
    final manager = $$DrawNumbersTableTableManager(
      $_db,
      $_db.drawNumbers,
    ).filter((f) => f.drawId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_drawNumbersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TicketResultsTable, List<TicketResultRow>>
  _ticketResultsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ticketResults,
    aliasName: $_aliasNameGenerator(db.draws.id, db.ticketResults.drawId),
  );

  $$TicketResultsTableProcessedTableManager get ticketResultsRefs {
    final manager = $$TicketResultsTableTableManager(
      $_db,
      $_db.ticketResults,
    ).filter((f) => f.drawId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ticketResultsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DrawsTableFilterComposer extends Composer<_$AppDatabase, $DrawsTable> {
  $$DrawsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get drawDate => $composableBuilder(
    column: $table.drawDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contestNumber => $composableBuilder(
    column: $table.contestNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get structuralIntegrityOk => $composableBuilder(
    column: $table.structuralIntegrityOk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get officiallyVerified => $composableBuilder(
    column: $table.officiallyVerified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WheelsTableFilterComposer get wheelId {
    final $$WheelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wheelId,
      referencedTable: $db.wheels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WheelsTableFilterComposer(
            $db: $db,
            $table: $db.wheels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DataSourcesTableFilterComposer get sourceId {
    final $$DataSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.dataSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DataSourcesTableFilterComposer(
            $db: $db,
            $table: $db.dataSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> drawNumbersRefs(
    Expression<bool> Function($$DrawNumbersTableFilterComposer f) f,
  ) {
    final $$DrawNumbersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.drawNumbers,
      getReferencedColumn: (t) => t.drawId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrawNumbersTableFilterComposer(
            $db: $db,
            $table: $db.drawNumbers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ticketResultsRefs(
    Expression<bool> Function($$TicketResultsTableFilterComposer f) f,
  ) {
    final $$TicketResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ticketResults,
      getReferencedColumn: (t) => t.drawId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketResultsTableFilterComposer(
            $db: $db,
            $table: $db.ticketResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DrawsTableOrderingComposer
    extends Composer<_$AppDatabase, $DrawsTable> {
  $$DrawsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get drawDate => $composableBuilder(
    column: $table.drawDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contestNumber => $composableBuilder(
    column: $table.contestNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get structuralIntegrityOk => $composableBuilder(
    column: $table.structuralIntegrityOk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get officiallyVerified => $composableBuilder(
    column: $table.officiallyVerified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WheelsTableOrderingComposer get wheelId {
    final $$WheelsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wheelId,
      referencedTable: $db.wheels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WheelsTableOrderingComposer(
            $db: $db,
            $table: $db.wheels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DataSourcesTableOrderingComposer get sourceId {
    final $$DataSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.dataSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DataSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.dataSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DrawsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DrawsTable> {
  $$DrawsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get drawDate =>
      $composableBuilder(column: $table.drawDate, builder: (column) => column);

  GeneratedColumn<int> get contestNumber => $composableBuilder(
    column: $table.contestNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get structuralIntegrityOk => $composableBuilder(
    column: $table.structuralIntegrityOk,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get officiallyVerified => $composableBuilder(
    column: $table.officiallyVerified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  $$WheelsTableAnnotationComposer get wheelId {
    final $$WheelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wheelId,
      referencedTable: $db.wheels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WheelsTableAnnotationComposer(
            $db: $db,
            $table: $db.wheels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DataSourcesTableAnnotationComposer get sourceId {
    final $$DataSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.dataSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DataSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.dataSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> drawNumbersRefs<T extends Object>(
    Expression<T> Function($$DrawNumbersTableAnnotationComposer a) f,
  ) {
    final $$DrawNumbersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.drawNumbers,
      getReferencedColumn: (t) => t.drawId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrawNumbersTableAnnotationComposer(
            $db: $db,
            $table: $db.drawNumbers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ticketResultsRefs<T extends Object>(
    Expression<T> Function($$TicketResultsTableAnnotationComposer a) f,
  ) {
    final $$TicketResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ticketResults,
      getReferencedColumn: (t) => t.drawId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.ticketResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DrawsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DrawsTable,
          DrawRow,
          $$DrawsTableFilterComposer,
          $$DrawsTableOrderingComposer,
          $$DrawsTableAnnotationComposer,
          $$DrawsTableCreateCompanionBuilder,
          $$DrawsTableUpdateCompanionBuilder,
          (DrawRow, $$DrawsTableReferences),
          DrawRow,
          PrefetchHooks Function({
            bool wheelId,
            bool sourceId,
            bool drawNumbersRefs,
            bool ticketResultsRefs,
          })
        > {
  $$DrawsTableTableManager(_$AppDatabase db, $DrawsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DrawsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DrawsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DrawsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> drawDate = const Value.absent(),
                Value<int?> contestNumber = const Value.absent(),
                Value<int> wheelId = const Value.absent(),
                Value<int> sourceId = const Value.absent(),
                Value<bool> structuralIntegrityOk = const Value.absent(),
                Value<bool> officiallyVerified = const Value.absent(),
                Value<String> provenance = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
              }) => DrawsCompanion(
                id: id,
                drawDate: drawDate,
                contestNumber: contestNumber,
                wheelId: wheelId,
                sourceId: sourceId,
                structuralIntegrityOk: structuralIntegrityOk,
                officiallyVerified: officiallyVerified,
                provenance: provenance,
                contentHash: contentHash,
                importedAt: importedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime drawDate,
                Value<int?> contestNumber = const Value.absent(),
                required int wheelId,
                required int sourceId,
                Value<bool> structuralIntegrityOk = const Value.absent(),
                Value<bool> officiallyVerified = const Value.absent(),
                required String provenance,
                required String contentHash,
                required DateTime importedAt,
              }) => DrawsCompanion.insert(
                id: id,
                drawDate: drawDate,
                contestNumber: contestNumber,
                wheelId: wheelId,
                sourceId: sourceId,
                structuralIntegrityOk: structuralIntegrityOk,
                officiallyVerified: officiallyVerified,
                provenance: provenance,
                contentHash: contentHash,
                importedAt: importedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$DrawsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                wheelId = false,
                sourceId = false,
                drawNumbersRefs = false,
                ticketResultsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (drawNumbersRefs) db.drawNumbers,
                    if (ticketResultsRefs) db.ticketResults,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (wheelId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.wheelId,
                                    referencedTable: $$DrawsTableReferences
                                        ._wheelIdTable(db),
                                    referencedColumn: $$DrawsTableReferences
                                        ._wheelIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (sourceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceId,
                                    referencedTable: $$DrawsTableReferences
                                        ._sourceIdTable(db),
                                    referencedColumn: $$DrawsTableReferences
                                        ._sourceIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (drawNumbersRefs)
                        await $_getPrefetchedData<
                          DrawRow,
                          $DrawsTable,
                          DrawNumberRow
                        >(
                          currentTable: table,
                          referencedTable: $$DrawsTableReferences
                              ._drawNumbersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DrawsTableReferences(
                                db,
                                table,
                                p0,
                              ).drawNumbersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.drawId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ticketResultsRefs)
                        await $_getPrefetchedData<
                          DrawRow,
                          $DrawsTable,
                          TicketResultRow
                        >(
                          currentTable: table,
                          referencedTable: $$DrawsTableReferences
                              ._ticketResultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DrawsTableReferences(
                                db,
                                table,
                                p0,
                              ).ticketResultsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.drawId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DrawsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DrawsTable,
      DrawRow,
      $$DrawsTableFilterComposer,
      $$DrawsTableOrderingComposer,
      $$DrawsTableAnnotationComposer,
      $$DrawsTableCreateCompanionBuilder,
      $$DrawsTableUpdateCompanionBuilder,
      (DrawRow, $$DrawsTableReferences),
      DrawRow,
      PrefetchHooks Function({
        bool wheelId,
        bool sourceId,
        bool drawNumbersRefs,
        bool ticketResultsRefs,
      })
    >;
typedef $$DrawNumbersTableCreateCompanionBuilder =
    DrawNumbersCompanion Function({
      Value<int> id,
      required int drawId,
      required int position,
      required int number,
    });
typedef $$DrawNumbersTableUpdateCompanionBuilder =
    DrawNumbersCompanion Function({
      Value<int> id,
      Value<int> drawId,
      Value<int> position,
      Value<int> number,
    });

final class $$DrawNumbersTableReferences
    extends BaseReferences<_$AppDatabase, $DrawNumbersTable, DrawNumberRow> {
  $$DrawNumbersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DrawsTable _drawIdTable(_$AppDatabase db) => db.draws.createAlias(
    $_aliasNameGenerator(db.drawNumbers.drawId, db.draws.id),
  );

  $$DrawsTableProcessedTableManager get drawId {
    final $_column = $_itemColumn<int>('draw_id')!;

    final manager = $$DrawsTableTableManager(
      $_db,
      $_db.draws,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_drawIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DrawNumbersTableFilterComposer
    extends Composer<_$AppDatabase, $DrawNumbersTable> {
  $$DrawNumbersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  $$DrawsTableFilterComposer get drawId {
    final $$DrawsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.drawId,
      referencedTable: $db.draws,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrawsTableFilterComposer(
            $db: $db,
            $table: $db.draws,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DrawNumbersTableOrderingComposer
    extends Composer<_$AppDatabase, $DrawNumbersTable> {
  $$DrawNumbersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  $$DrawsTableOrderingComposer get drawId {
    final $$DrawsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.drawId,
      referencedTable: $db.draws,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrawsTableOrderingComposer(
            $db: $db,
            $table: $db.draws,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DrawNumbersTableAnnotationComposer
    extends Composer<_$AppDatabase, $DrawNumbersTable> {
  $$DrawNumbersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  $$DrawsTableAnnotationComposer get drawId {
    final $$DrawsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.drawId,
      referencedTable: $db.draws,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrawsTableAnnotationComposer(
            $db: $db,
            $table: $db.draws,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DrawNumbersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DrawNumbersTable,
          DrawNumberRow,
          $$DrawNumbersTableFilterComposer,
          $$DrawNumbersTableOrderingComposer,
          $$DrawNumbersTableAnnotationComposer,
          $$DrawNumbersTableCreateCompanionBuilder,
          $$DrawNumbersTableUpdateCompanionBuilder,
          (DrawNumberRow, $$DrawNumbersTableReferences),
          DrawNumberRow,
          PrefetchHooks Function({bool drawId})
        > {
  $$DrawNumbersTableTableManager(_$AppDatabase db, $DrawNumbersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DrawNumbersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DrawNumbersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DrawNumbersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> drawId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> number = const Value.absent(),
              }) => DrawNumbersCompanion(
                id: id,
                drawId: drawId,
                position: position,
                number: number,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int drawId,
                required int position,
                required int number,
              }) => DrawNumbersCompanion.insert(
                id: id,
                drawId: drawId,
                position: position,
                number: number,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DrawNumbersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({drawId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (drawId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.drawId,
                                referencedTable: $$DrawNumbersTableReferences
                                    ._drawIdTable(db),
                                referencedColumn: $$DrawNumbersTableReferences
                                    ._drawIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DrawNumbersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DrawNumbersTable,
      DrawNumberRow,
      $$DrawNumbersTableFilterComposer,
      $$DrawNumbersTableOrderingComposer,
      $$DrawNumbersTableAnnotationComposer,
      $$DrawNumbersTableCreateCompanionBuilder,
      $$DrawNumbersTableUpdateCompanionBuilder,
      (DrawNumberRow, $$DrawNumbersTableReferences),
      DrawNumberRow,
      PrefetchHooks Function({bool drawId})
    >;
typedef $$SyncLogsTableCreateCompanionBuilder =
    SyncLogsCompanion Function({
      Value<int> id,
      required int sourceId,
      required DateTime startedAt,
      Value<DateTime?> finishedAt,
      required String status,
      Value<int> parsedCount,
      Value<int> insertedCount,
      Value<int> duplicateCount,
      Value<int> conflictCount,
      Value<int> invalidCount,
      Value<String?> message,
    });
typedef $$SyncLogsTableUpdateCompanionBuilder =
    SyncLogsCompanion Function({
      Value<int> id,
      Value<int> sourceId,
      Value<DateTime> startedAt,
      Value<DateTime?> finishedAt,
      Value<String> status,
      Value<int> parsedCount,
      Value<int> insertedCount,
      Value<int> duplicateCount,
      Value<int> conflictCount,
      Value<int> invalidCount,
      Value<String?> message,
    });

final class $$SyncLogsTableReferences
    extends BaseReferences<_$AppDatabase, $SyncLogsTable, SyncLogRow> {
  $$SyncLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DataSourcesTable _sourceIdTable(_$AppDatabase db) =>
      db.dataSources.createAlias(
        $_aliasNameGenerator(db.syncLogs.sourceId, db.dataSources.id),
      );

  $$DataSourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<int>('source_id')!;

    final manager = $$DataSourcesTableTableManager(
      $_db,
      $_db.dataSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SyncLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parsedCount => $composableBuilder(
    column: $table.parsedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get insertedCount => $composableBuilder(
    column: $table.insertedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duplicateCount => $composableBuilder(
    column: $table.duplicateCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get conflictCount => $composableBuilder(
    column: $table.conflictCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get invalidCount => $composableBuilder(
    column: $table.invalidCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  $$DataSourcesTableFilterComposer get sourceId {
    final $$DataSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.dataSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DataSourcesTableFilterComposer(
            $db: $db,
            $table: $db.dataSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parsedCount => $composableBuilder(
    column: $table.parsedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get insertedCount => $composableBuilder(
    column: $table.insertedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duplicateCount => $composableBuilder(
    column: $table.duplicateCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get conflictCount => $composableBuilder(
    column: $table.conflictCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get invalidCount => $composableBuilder(
    column: $table.invalidCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  $$DataSourcesTableOrderingComposer get sourceId {
    final $$DataSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.dataSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DataSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.dataSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get parsedCount => $composableBuilder(
    column: $table.parsedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get insertedCount => $composableBuilder(
    column: $table.insertedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get duplicateCount => $composableBuilder(
    column: $table.duplicateCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get conflictCount => $composableBuilder(
    column: $table.conflictCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get invalidCount => $composableBuilder(
    column: $table.invalidCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  $$DataSourcesTableAnnotationComposer get sourceId {
    final $$DataSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.dataSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DataSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.dataSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncLogsTable,
          SyncLogRow,
          $$SyncLogsTableFilterComposer,
          $$SyncLogsTableOrderingComposer,
          $$SyncLogsTableAnnotationComposer,
          $$SyncLogsTableCreateCompanionBuilder,
          $$SyncLogsTableUpdateCompanionBuilder,
          (SyncLogRow, $$SyncLogsTableReferences),
          SyncLogRow,
          PrefetchHooks Function({bool sourceId})
        > {
  $$SyncLogsTableTableManager(_$AppDatabase db, $SyncLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sourceId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> parsedCount = const Value.absent(),
                Value<int> insertedCount = const Value.absent(),
                Value<int> duplicateCount = const Value.absent(),
                Value<int> conflictCount = const Value.absent(),
                Value<int> invalidCount = const Value.absent(),
                Value<String?> message = const Value.absent(),
              }) => SyncLogsCompanion(
                id: id,
                sourceId: sourceId,
                startedAt: startedAt,
                finishedAt: finishedAt,
                status: status,
                parsedCount: parsedCount,
                insertedCount: insertedCount,
                duplicateCount: duplicateCount,
                conflictCount: conflictCount,
                invalidCount: invalidCount,
                message: message,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sourceId,
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                required String status,
                Value<int> parsedCount = const Value.absent(),
                Value<int> insertedCount = const Value.absent(),
                Value<int> duplicateCount = const Value.absent(),
                Value<int> conflictCount = const Value.absent(),
                Value<int> invalidCount = const Value.absent(),
                Value<String?> message = const Value.absent(),
              }) => SyncLogsCompanion.insert(
                id: id,
                sourceId: sourceId,
                startedAt: startedAt,
                finishedAt: finishedAt,
                status: status,
                parsedCount: parsedCount,
                insertedCount: insertedCount,
                duplicateCount: duplicateCount,
                conflictCount: conflictCount,
                invalidCount: invalidCount,
                message: message,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SyncLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sourceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sourceId,
                                referencedTable: $$SyncLogsTableReferences
                                    ._sourceIdTable(db),
                                referencedColumn: $$SyncLogsTableReferences
                                    ._sourceIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SyncLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncLogsTable,
      SyncLogRow,
      $$SyncLogsTableFilterComposer,
      $$SyncLogsTableOrderingComposer,
      $$SyncLogsTableAnnotationComposer,
      $$SyncLogsTableCreateCompanionBuilder,
      $$SyncLogsTableUpdateCompanionBuilder,
      (SyncLogRow, $$SyncLogsTableReferences),
      SyncLogRow,
      PrefetchHooks Function({bool sourceId})
    >;
typedef $$StrategiesTableCreateCompanionBuilder =
    StrategiesCompanion Function({
      Value<int> id,
      required String name,
      required String kind,
      required String wheelCode,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> notes,
    });
typedef $$StrategiesTableUpdateCompanionBuilder =
    StrategiesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> kind,
      Value<String> wheelCode,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> notes,
    });

final class $$StrategiesTableReferences
    extends BaseReferences<_$AppDatabase, $StrategiesTable, StrategyRow> {
  $$StrategiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $StrategyParametersTable,
    List<StrategyParameterRow>
  >
  _strategyParametersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.strategyParameters,
        aliasName: $_aliasNameGenerator(
          db.strategies.id,
          db.strategyParameters.strategyId,
        ),
      );

  $$StrategyParametersTableProcessedTableManager get strategyParametersRefs {
    final manager = $$StrategyParametersTableTableManager(
      $_db,
      $_db.strategyParameters,
    ).filter((f) => f.strategyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _strategyParametersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PredictionsTable, List<PredictionRow>>
  _predictionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.predictions,
    aliasName: $_aliasNameGenerator(
      db.strategies.id,
      db.predictions.strategyId,
    ),
  );

  $$PredictionsTableProcessedTableManager get predictionsRefs {
    final manager = $$PredictionsTableTableManager(
      $_db,
      $_db.predictions,
    ).filter((f) => f.strategyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_predictionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BacktestRunsTable, List<BacktestRunRow>>
  _backtestRunsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.backtestRuns,
    aliasName: $_aliasNameGenerator(
      db.strategies.id,
      db.backtestRuns.strategyId,
    ),
  );

  $$BacktestRunsTableProcessedTableManager get backtestRunsRefs {
    final manager = $$BacktestRunsTableTableManager(
      $_db,
      $_db.backtestRuns,
    ).filter((f) => f.strategyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_backtestRunsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VirtualTicketsTable, List<VirtualTicketRow>>
  _virtualTicketsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.virtualTickets,
    aliasName: $_aliasNameGenerator(
      db.strategies.id,
      db.virtualTickets.strategyId,
    ),
  );

  $$VirtualTicketsTableProcessedTableManager get virtualTicketsRefs {
    final manager = $$VirtualTicketsTableTableManager(
      $_db,
      $_db.virtualTickets,
    ).filter((f) => f.strategyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_virtualTicketsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StrategiesTableFilterComposer
    extends Composer<_$AppDatabase, $StrategiesTable> {
  $$StrategiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wheelCode => $composableBuilder(
    column: $table.wheelCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> strategyParametersRefs(
    Expression<bool> Function($$StrategyParametersTableFilterComposer f) f,
  ) {
    final $$StrategyParametersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.strategyParameters,
      getReferencedColumn: (t) => t.strategyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategyParametersTableFilterComposer(
            $db: $db,
            $table: $db.strategyParameters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> predictionsRefs(
    Expression<bool> Function($$PredictionsTableFilterComposer f) f,
  ) {
    final $$PredictionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.predictions,
      getReferencedColumn: (t) => t.strategyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredictionsTableFilterComposer(
            $db: $db,
            $table: $db.predictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> backtestRunsRefs(
    Expression<bool> Function($$BacktestRunsTableFilterComposer f) f,
  ) {
    final $$BacktestRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.backtestRuns,
      getReferencedColumn: (t) => t.strategyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BacktestRunsTableFilterComposer(
            $db: $db,
            $table: $db.backtestRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> virtualTicketsRefs(
    Expression<bool> Function($$VirtualTicketsTableFilterComposer f) f,
  ) {
    final $$VirtualTicketsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.virtualTickets,
      getReferencedColumn: (t) => t.strategyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VirtualTicketsTableFilterComposer(
            $db: $db,
            $table: $db.virtualTickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StrategiesTableOrderingComposer
    extends Composer<_$AppDatabase, $StrategiesTable> {
  $$StrategiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wheelCode => $composableBuilder(
    column: $table.wheelCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StrategiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StrategiesTable> {
  $$StrategiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get wheelCode =>
      $composableBuilder(column: $table.wheelCode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> strategyParametersRefs<T extends Object>(
    Expression<T> Function($$StrategyParametersTableAnnotationComposer a) f,
  ) {
    final $$StrategyParametersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.strategyParameters,
          getReferencedColumn: (t) => t.strategyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StrategyParametersTableAnnotationComposer(
                $db: $db,
                $table: $db.strategyParameters,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> predictionsRefs<T extends Object>(
    Expression<T> Function($$PredictionsTableAnnotationComposer a) f,
  ) {
    final $$PredictionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.predictions,
      getReferencedColumn: (t) => t.strategyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredictionsTableAnnotationComposer(
            $db: $db,
            $table: $db.predictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> backtestRunsRefs<T extends Object>(
    Expression<T> Function($$BacktestRunsTableAnnotationComposer a) f,
  ) {
    final $$BacktestRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.backtestRuns,
      getReferencedColumn: (t) => t.strategyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BacktestRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.backtestRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> virtualTicketsRefs<T extends Object>(
    Expression<T> Function($$VirtualTicketsTableAnnotationComposer a) f,
  ) {
    final $$VirtualTicketsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.virtualTickets,
      getReferencedColumn: (t) => t.strategyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VirtualTicketsTableAnnotationComposer(
            $db: $db,
            $table: $db.virtualTickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StrategiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StrategiesTable,
          StrategyRow,
          $$StrategiesTableFilterComposer,
          $$StrategiesTableOrderingComposer,
          $$StrategiesTableAnnotationComposer,
          $$StrategiesTableCreateCompanionBuilder,
          $$StrategiesTableUpdateCompanionBuilder,
          (StrategyRow, $$StrategiesTableReferences),
          StrategyRow,
          PrefetchHooks Function({
            bool strategyParametersRefs,
            bool predictionsRefs,
            bool backtestRunsRefs,
            bool virtualTicketsRefs,
          })
        > {
  $$StrategiesTableTableManager(_$AppDatabase db, $StrategiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StrategiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StrategiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StrategiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> wheelCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => StrategiesCompanion(
                id: id,
                name: name,
                kind: kind,
                wheelCode: wheelCode,
                createdAt: createdAt,
                updatedAt: updatedAt,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String kind,
                required String wheelCode,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> notes = const Value.absent(),
              }) => StrategiesCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                wheelCode: wheelCode,
                createdAt: createdAt,
                updatedAt: updatedAt,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StrategiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                strategyParametersRefs = false,
                predictionsRefs = false,
                backtestRunsRefs = false,
                virtualTicketsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (strategyParametersRefs) db.strategyParameters,
                    if (predictionsRefs) db.predictions,
                    if (backtestRunsRefs) db.backtestRuns,
                    if (virtualTicketsRefs) db.virtualTickets,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (strategyParametersRefs)
                        await $_getPrefetchedData<
                          StrategyRow,
                          $StrategiesTable,
                          StrategyParameterRow
                        >(
                          currentTable: table,
                          referencedTable: $$StrategiesTableReferences
                              ._strategyParametersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StrategiesTableReferences(
                                db,
                                table,
                                p0,
                              ).strategyParametersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.strategyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (predictionsRefs)
                        await $_getPrefetchedData<
                          StrategyRow,
                          $StrategiesTable,
                          PredictionRow
                        >(
                          currentTable: table,
                          referencedTable: $$StrategiesTableReferences
                              ._predictionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StrategiesTableReferences(
                                db,
                                table,
                                p0,
                              ).predictionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.strategyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (backtestRunsRefs)
                        await $_getPrefetchedData<
                          StrategyRow,
                          $StrategiesTable,
                          BacktestRunRow
                        >(
                          currentTable: table,
                          referencedTable: $$StrategiesTableReferences
                              ._backtestRunsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StrategiesTableReferences(
                                db,
                                table,
                                p0,
                              ).backtestRunsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.strategyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (virtualTicketsRefs)
                        await $_getPrefetchedData<
                          StrategyRow,
                          $StrategiesTable,
                          VirtualTicketRow
                        >(
                          currentTable: table,
                          referencedTable: $$StrategiesTableReferences
                              ._virtualTicketsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StrategiesTableReferences(
                                db,
                                table,
                                p0,
                              ).virtualTicketsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.strategyId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StrategiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StrategiesTable,
      StrategyRow,
      $$StrategiesTableFilterComposer,
      $$StrategiesTableOrderingComposer,
      $$StrategiesTableAnnotationComposer,
      $$StrategiesTableCreateCompanionBuilder,
      $$StrategiesTableUpdateCompanionBuilder,
      (StrategyRow, $$StrategiesTableReferences),
      StrategyRow,
      PrefetchHooks Function({
        bool strategyParametersRefs,
        bool predictionsRefs,
        bool backtestRunsRefs,
        bool virtualTicketsRefs,
      })
    >;
typedef $$StrategyParametersTableCreateCompanionBuilder =
    StrategyParametersCompanion Function({
      Value<int> id,
      required int strategyId,
      required String paramKey,
      required String paramValue,
    });
typedef $$StrategyParametersTableUpdateCompanionBuilder =
    StrategyParametersCompanion Function({
      Value<int> id,
      Value<int> strategyId,
      Value<String> paramKey,
      Value<String> paramValue,
    });

final class $$StrategyParametersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StrategyParametersTable,
          StrategyParameterRow
        > {
  $$StrategyParametersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StrategiesTable _strategyIdTable(_$AppDatabase db) =>
      db.strategies.createAlias(
        $_aliasNameGenerator(
          db.strategyParameters.strategyId,
          db.strategies.id,
        ),
      );

  $$StrategiesTableProcessedTableManager get strategyId {
    final $_column = $_itemColumn<int>('strategy_id')!;

    final manager = $$StrategiesTableTableManager(
      $_db,
      $_db.strategies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_strategyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StrategyParametersTableFilterComposer
    extends Composer<_$AppDatabase, $StrategyParametersTable> {
  $$StrategyParametersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paramKey => $composableBuilder(
    column: $table.paramKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paramValue => $composableBuilder(
    column: $table.paramValue,
    builder: (column) => ColumnFilters(column),
  );

  $$StrategiesTableFilterComposer get strategyId {
    final $$StrategiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableFilterComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrategyParametersTableOrderingComposer
    extends Composer<_$AppDatabase, $StrategyParametersTable> {
  $$StrategyParametersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paramKey => $composableBuilder(
    column: $table.paramKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paramValue => $composableBuilder(
    column: $table.paramValue,
    builder: (column) => ColumnOrderings(column),
  );

  $$StrategiesTableOrderingComposer get strategyId {
    final $$StrategiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableOrderingComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrategyParametersTableAnnotationComposer
    extends Composer<_$AppDatabase, $StrategyParametersTable> {
  $$StrategyParametersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get paramKey =>
      $composableBuilder(column: $table.paramKey, builder: (column) => column);

  GeneratedColumn<String> get paramValue => $composableBuilder(
    column: $table.paramValue,
    builder: (column) => column,
  );

  $$StrategiesTableAnnotationComposer get strategyId {
    final $$StrategiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableAnnotationComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrategyParametersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StrategyParametersTable,
          StrategyParameterRow,
          $$StrategyParametersTableFilterComposer,
          $$StrategyParametersTableOrderingComposer,
          $$StrategyParametersTableAnnotationComposer,
          $$StrategyParametersTableCreateCompanionBuilder,
          $$StrategyParametersTableUpdateCompanionBuilder,
          (StrategyParameterRow, $$StrategyParametersTableReferences),
          StrategyParameterRow,
          PrefetchHooks Function({bool strategyId})
        > {
  $$StrategyParametersTableTableManager(
    _$AppDatabase db,
    $StrategyParametersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StrategyParametersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StrategyParametersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StrategyParametersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> strategyId = const Value.absent(),
                Value<String> paramKey = const Value.absent(),
                Value<String> paramValue = const Value.absent(),
              }) => StrategyParametersCompanion(
                id: id,
                strategyId: strategyId,
                paramKey: paramKey,
                paramValue: paramValue,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int strategyId,
                required String paramKey,
                required String paramValue,
              }) => StrategyParametersCompanion.insert(
                id: id,
                strategyId: strategyId,
                paramKey: paramKey,
                paramValue: paramValue,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StrategyParametersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({strategyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (strategyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.strategyId,
                                referencedTable:
                                    $$StrategyParametersTableReferences
                                        ._strategyIdTable(db),
                                referencedColumn:
                                    $$StrategyParametersTableReferences
                                        ._strategyIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StrategyParametersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StrategyParametersTable,
      StrategyParameterRow,
      $$StrategyParametersTableFilterComposer,
      $$StrategyParametersTableOrderingComposer,
      $$StrategyParametersTableAnnotationComposer,
      $$StrategyParametersTableCreateCompanionBuilder,
      $$StrategyParametersTableUpdateCompanionBuilder,
      (StrategyParameterRow, $$StrategyParametersTableReferences),
      StrategyParameterRow,
      PrefetchHooks Function({bool strategyId})
    >;
typedef $$AiModelsTableCreateCompanionBuilder =
    AiModelsCompanion Function({
      Value<int> id,
      required String provider,
      required String displayName,
      required String endpoint,
      required String modelName,
      Value<bool> enabled,
      Value<int> timeoutSeconds,
      required DateTime createdAt,
    });
typedef $$AiModelsTableUpdateCompanionBuilder =
    AiModelsCompanion Function({
      Value<int> id,
      Value<String> provider,
      Value<String> displayName,
      Value<String> endpoint,
      Value<String> modelName,
      Value<bool> enabled,
      Value<int> timeoutSeconds,
      Value<DateTime> createdAt,
    });

final class $$AiModelsTableReferences
    extends BaseReferences<_$AppDatabase, $AiModelsTable, AiModelRow> {
  $$AiModelsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PredictionsTable, List<PredictionRow>>
  _predictionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.predictions,
    aliasName: $_aliasNameGenerator(db.aiModels.id, db.predictions.modelId),
  );

  $$PredictionsTableProcessedTableManager get predictionsRefs {
    final manager = $$PredictionsTableTableManager(
      $_db,
      $_db.predictions,
    ).filter((f) => f.modelId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_predictionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AiExecutionLogsTable, List<AiExecutionLogRow>>
  _aiExecutionLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.aiExecutionLogs,
    aliasName: $_aliasNameGenerator(db.aiModels.id, db.aiExecutionLogs.modelId),
  );

  $$AiExecutionLogsTableProcessedTableManager get aiExecutionLogsRefs {
    final manager = $$AiExecutionLogsTableTableManager(
      $_db,
      $_db.aiExecutionLogs,
    ).filter((f) => f.modelId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _aiExecutionLogsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AiModelsTableFilterComposer
    extends Composer<_$AppDatabase, $AiModelsTable> {
  $$AiModelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeoutSeconds => $composableBuilder(
    column: $table.timeoutSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> predictionsRefs(
    Expression<bool> Function($$PredictionsTableFilterComposer f) f,
  ) {
    final $$PredictionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.predictions,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredictionsTableFilterComposer(
            $db: $db,
            $table: $db.predictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> aiExecutionLogsRefs(
    Expression<bool> Function($$AiExecutionLogsTableFilterComposer f) f,
  ) {
    final $$AiExecutionLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.aiExecutionLogs,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiExecutionLogsTableFilterComposer(
            $db: $db,
            $table: $db.aiExecutionLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AiModelsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiModelsTable> {
  $$AiModelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeoutSeconds => $composableBuilder(
    column: $table.timeoutSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiModelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiModelsTable> {
  $$AiModelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get timeoutSeconds => $composableBuilder(
    column: $table.timeoutSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> predictionsRefs<T extends Object>(
    Expression<T> Function($$PredictionsTableAnnotationComposer a) f,
  ) {
    final $$PredictionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.predictions,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredictionsTableAnnotationComposer(
            $db: $db,
            $table: $db.predictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> aiExecutionLogsRefs<T extends Object>(
    Expression<T> Function($$AiExecutionLogsTableAnnotationComposer a) f,
  ) {
    final $$AiExecutionLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.aiExecutionLogs,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiExecutionLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.aiExecutionLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AiModelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiModelsTable,
          AiModelRow,
          $$AiModelsTableFilterComposer,
          $$AiModelsTableOrderingComposer,
          $$AiModelsTableAnnotationComposer,
          $$AiModelsTableCreateCompanionBuilder,
          $$AiModelsTableUpdateCompanionBuilder,
          (AiModelRow, $$AiModelsTableReferences),
          AiModelRow,
          PrefetchHooks Function({
            bool predictionsRefs,
            bool aiExecutionLogsRefs,
          })
        > {
  $$AiModelsTableTableManager(_$AppDatabase db, $AiModelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiModelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiModelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiModelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> endpoint = const Value.absent(),
                Value<String> modelName = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> timeoutSeconds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AiModelsCompanion(
                id: id,
                provider: provider,
                displayName: displayName,
                endpoint: endpoint,
                modelName: modelName,
                enabled: enabled,
                timeoutSeconds: timeoutSeconds,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String provider,
                required String displayName,
                required String endpoint,
                required String modelName,
                Value<bool> enabled = const Value.absent(),
                Value<int> timeoutSeconds = const Value.absent(),
                required DateTime createdAt,
              }) => AiModelsCompanion.insert(
                id: id,
                provider: provider,
                displayName: displayName,
                endpoint: endpoint,
                modelName: modelName,
                enabled: enabled,
                timeoutSeconds: timeoutSeconds,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AiModelsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({predictionsRefs = false, aiExecutionLogsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (predictionsRefs) db.predictions,
                    if (aiExecutionLogsRefs) db.aiExecutionLogs,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (predictionsRefs)
                        await $_getPrefetchedData<
                          AiModelRow,
                          $AiModelsTable,
                          PredictionRow
                        >(
                          currentTable: table,
                          referencedTable: $$AiModelsTableReferences
                              ._predictionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AiModelsTableReferences(
                                db,
                                table,
                                p0,
                              ).predictionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.modelId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (aiExecutionLogsRefs)
                        await $_getPrefetchedData<
                          AiModelRow,
                          $AiModelsTable,
                          AiExecutionLogRow
                        >(
                          currentTable: table,
                          referencedTable: $$AiModelsTableReferences
                              ._aiExecutionLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AiModelsTableReferences(
                                db,
                                table,
                                p0,
                              ).aiExecutionLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.modelId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AiModelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiModelsTable,
      AiModelRow,
      $$AiModelsTableFilterComposer,
      $$AiModelsTableOrderingComposer,
      $$AiModelsTableAnnotationComposer,
      $$AiModelsTableCreateCompanionBuilder,
      $$AiModelsTableUpdateCompanionBuilder,
      (AiModelRow, $$AiModelsTableReferences),
      AiModelRow,
      PrefetchHooks Function({bool predictionsRefs, bool aiExecutionLogsRefs})
    >;
typedef $$PredictionsTableCreateCompanionBuilder =
    PredictionsCompanion Function({
      Value<int> id,
      Value<int?> strategyId,
      Value<int?> modelId,
      required String wheelCode,
      required DateTime generatedAt,
      required String engineId,
      required String engineVersion,
      required String method,
      required String rationale,
      required String limitations,
      required String datasetNote,
      required String configJson,
    });
typedef $$PredictionsTableUpdateCompanionBuilder =
    PredictionsCompanion Function({
      Value<int> id,
      Value<int?> strategyId,
      Value<int?> modelId,
      Value<String> wheelCode,
      Value<DateTime> generatedAt,
      Value<String> engineId,
      Value<String> engineVersion,
      Value<String> method,
      Value<String> rationale,
      Value<String> limitations,
      Value<String> datasetNote,
      Value<String> configJson,
    });

final class $$PredictionsTableReferences
    extends BaseReferences<_$AppDatabase, $PredictionsTable, PredictionRow> {
  $$PredictionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StrategiesTable _strategyIdTable(_$AppDatabase db) =>
      db.strategies.createAlias(
        $_aliasNameGenerator(db.predictions.strategyId, db.strategies.id),
      );

  $$StrategiesTableProcessedTableManager? get strategyId {
    final $_column = $_itemColumn<int>('strategy_id');
    if ($_column == null) return null;
    final manager = $$StrategiesTableTableManager(
      $_db,
      $_db.strategies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_strategyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AiModelsTable _modelIdTable(_$AppDatabase db) =>
      db.aiModels.createAlias(
        $_aliasNameGenerator(db.predictions.modelId, db.aiModels.id),
      );

  $$AiModelsTableProcessedTableManager? get modelId {
    final $_column = $_itemColumn<int>('model_id');
    if ($_column == null) return null;
    final manager = $$AiModelsTableTableManager(
      $_db,
      $_db.aiModels,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_modelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PredictionNumbersTable, List<PredictionNumberRow>>
  _predictionNumbersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.predictionNumbers,
        aliasName: $_aliasNameGenerator(
          db.predictions.id,
          db.predictionNumbers.predictionId,
        ),
      );

  $$PredictionNumbersTableProcessedTableManager get predictionNumbersRefs {
    final manager = $$PredictionNumbersTableTableManager(
      $_db,
      $_db.predictionNumbers,
    ).filter((f) => f.predictionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _predictionNumbersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PredictionsTableFilterComposer
    extends Composer<_$AppDatabase, $PredictionsTable> {
  $$PredictionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wheelCode => $composableBuilder(
    column: $table.wheelCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get engineId => $composableBuilder(
    column: $table.engineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get engineVersion => $composableBuilder(
    column: $table.engineVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rationale => $composableBuilder(
    column: $table.rationale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get limitations => $composableBuilder(
    column: $table.limitations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datasetNote => $composableBuilder(
    column: $table.datasetNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );

  $$StrategiesTableFilterComposer get strategyId {
    final $$StrategiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableFilterComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AiModelsTableFilterComposer get modelId {
    final $$AiModelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.aiModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiModelsTableFilterComposer(
            $db: $db,
            $table: $db.aiModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> predictionNumbersRefs(
    Expression<bool> Function($$PredictionNumbersTableFilterComposer f) f,
  ) {
    final $$PredictionNumbersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.predictionNumbers,
      getReferencedColumn: (t) => t.predictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredictionNumbersTableFilterComposer(
            $db: $db,
            $table: $db.predictionNumbers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PredictionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PredictionsTable> {
  $$PredictionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wheelCode => $composableBuilder(
    column: $table.wheelCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engineId => $composableBuilder(
    column: $table.engineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engineVersion => $composableBuilder(
    column: $table.engineVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rationale => $composableBuilder(
    column: $table.rationale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get limitations => $composableBuilder(
    column: $table.limitations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datasetNote => $composableBuilder(
    column: $table.datasetNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$StrategiesTableOrderingComposer get strategyId {
    final $$StrategiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableOrderingComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AiModelsTableOrderingComposer get modelId {
    final $$AiModelsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.aiModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiModelsTableOrderingComposer(
            $db: $db,
            $table: $db.aiModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PredictionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PredictionsTable> {
  $$PredictionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get wheelCode =>
      $composableBuilder(column: $table.wheelCode, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get engineId =>
      $composableBuilder(column: $table.engineId, builder: (column) => column);

  GeneratedColumn<String> get engineVersion => $composableBuilder(
    column: $table.engineVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get rationale =>
      $composableBuilder(column: $table.rationale, builder: (column) => column);

  GeneratedColumn<String> get limitations => $composableBuilder(
    column: $table.limitations,
    builder: (column) => column,
  );

  GeneratedColumn<String> get datasetNote => $composableBuilder(
    column: $table.datasetNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  $$StrategiesTableAnnotationComposer get strategyId {
    final $$StrategiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableAnnotationComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AiModelsTableAnnotationComposer get modelId {
    final $$AiModelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.aiModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiModelsTableAnnotationComposer(
            $db: $db,
            $table: $db.aiModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> predictionNumbersRefs<T extends Object>(
    Expression<T> Function($$PredictionNumbersTableAnnotationComposer a) f,
  ) {
    final $$PredictionNumbersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.predictionNumbers,
          getReferencedColumn: (t) => t.predictionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PredictionNumbersTableAnnotationComposer(
                $db: $db,
                $table: $db.predictionNumbers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PredictionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PredictionsTable,
          PredictionRow,
          $$PredictionsTableFilterComposer,
          $$PredictionsTableOrderingComposer,
          $$PredictionsTableAnnotationComposer,
          $$PredictionsTableCreateCompanionBuilder,
          $$PredictionsTableUpdateCompanionBuilder,
          (PredictionRow, $$PredictionsTableReferences),
          PredictionRow,
          PrefetchHooks Function({
            bool strategyId,
            bool modelId,
            bool predictionNumbersRefs,
          })
        > {
  $$PredictionsTableTableManager(_$AppDatabase db, $PredictionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PredictionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PredictionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PredictionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> strategyId = const Value.absent(),
                Value<int?> modelId = const Value.absent(),
                Value<String> wheelCode = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<String> engineId = const Value.absent(),
                Value<String> engineVersion = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> rationale = const Value.absent(),
                Value<String> limitations = const Value.absent(),
                Value<String> datasetNote = const Value.absent(),
                Value<String> configJson = const Value.absent(),
              }) => PredictionsCompanion(
                id: id,
                strategyId: strategyId,
                modelId: modelId,
                wheelCode: wheelCode,
                generatedAt: generatedAt,
                engineId: engineId,
                engineVersion: engineVersion,
                method: method,
                rationale: rationale,
                limitations: limitations,
                datasetNote: datasetNote,
                configJson: configJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> strategyId = const Value.absent(),
                Value<int?> modelId = const Value.absent(),
                required String wheelCode,
                required DateTime generatedAt,
                required String engineId,
                required String engineVersion,
                required String method,
                required String rationale,
                required String limitations,
                required String datasetNote,
                required String configJson,
              }) => PredictionsCompanion.insert(
                id: id,
                strategyId: strategyId,
                modelId: modelId,
                wheelCode: wheelCode,
                generatedAt: generatedAt,
                engineId: engineId,
                engineVersion: engineVersion,
                method: method,
                rationale: rationale,
                limitations: limitations,
                datasetNote: datasetNote,
                configJson: configJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PredictionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                strategyId = false,
                modelId = false,
                predictionNumbersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (predictionNumbersRefs) db.predictionNumbers,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (strategyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.strategyId,
                                    referencedTable:
                                        $$PredictionsTableReferences
                                            ._strategyIdTable(db),
                                    referencedColumn:
                                        $$PredictionsTableReferences
                                            ._strategyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (modelId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.modelId,
                                    referencedTable:
                                        $$PredictionsTableReferences
                                            ._modelIdTable(db),
                                    referencedColumn:
                                        $$PredictionsTableReferences
                                            ._modelIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (predictionNumbersRefs)
                        await $_getPrefetchedData<
                          PredictionRow,
                          $PredictionsTable,
                          PredictionNumberRow
                        >(
                          currentTable: table,
                          referencedTable: $$PredictionsTableReferences
                              ._predictionNumbersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PredictionsTableReferences(
                                db,
                                table,
                                p0,
                              ).predictionNumbersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.predictionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PredictionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PredictionsTable,
      PredictionRow,
      $$PredictionsTableFilterComposer,
      $$PredictionsTableOrderingComposer,
      $$PredictionsTableAnnotationComposer,
      $$PredictionsTableCreateCompanionBuilder,
      $$PredictionsTableUpdateCompanionBuilder,
      (PredictionRow, $$PredictionsTableReferences),
      PredictionRow,
      PrefetchHooks Function({
        bool strategyId,
        bool modelId,
        bool predictionNumbersRefs,
      })
    >;
typedef $$PredictionNumbersTableCreateCompanionBuilder =
    PredictionNumbersCompanion Function({
      Value<int> id,
      required int predictionId,
      required int position,
      required int number,
    });
typedef $$PredictionNumbersTableUpdateCompanionBuilder =
    PredictionNumbersCompanion Function({
      Value<int> id,
      Value<int> predictionId,
      Value<int> position,
      Value<int> number,
    });

final class $$PredictionNumbersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PredictionNumbersTable,
          PredictionNumberRow
        > {
  $$PredictionNumbersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PredictionsTable _predictionIdTable(_$AppDatabase db) =>
      db.predictions.createAlias(
        $_aliasNameGenerator(
          db.predictionNumbers.predictionId,
          db.predictions.id,
        ),
      );

  $$PredictionsTableProcessedTableManager get predictionId {
    final $_column = $_itemColumn<int>('prediction_id')!;

    final manager = $$PredictionsTableTableManager(
      $_db,
      $_db.predictions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_predictionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PredictionNumbersTableFilterComposer
    extends Composer<_$AppDatabase, $PredictionNumbersTable> {
  $$PredictionNumbersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  $$PredictionsTableFilterComposer get predictionId {
    final $$PredictionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predictionId,
      referencedTable: $db.predictions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredictionsTableFilterComposer(
            $db: $db,
            $table: $db.predictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PredictionNumbersTableOrderingComposer
    extends Composer<_$AppDatabase, $PredictionNumbersTable> {
  $$PredictionNumbersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  $$PredictionsTableOrderingComposer get predictionId {
    final $$PredictionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predictionId,
      referencedTable: $db.predictions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredictionsTableOrderingComposer(
            $db: $db,
            $table: $db.predictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PredictionNumbersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PredictionNumbersTable> {
  $$PredictionNumbersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  $$PredictionsTableAnnotationComposer get predictionId {
    final $$PredictionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predictionId,
      referencedTable: $db.predictions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredictionsTableAnnotationComposer(
            $db: $db,
            $table: $db.predictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PredictionNumbersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PredictionNumbersTable,
          PredictionNumberRow,
          $$PredictionNumbersTableFilterComposer,
          $$PredictionNumbersTableOrderingComposer,
          $$PredictionNumbersTableAnnotationComposer,
          $$PredictionNumbersTableCreateCompanionBuilder,
          $$PredictionNumbersTableUpdateCompanionBuilder,
          (PredictionNumberRow, $$PredictionNumbersTableReferences),
          PredictionNumberRow,
          PrefetchHooks Function({bool predictionId})
        > {
  $$PredictionNumbersTableTableManager(
    _$AppDatabase db,
    $PredictionNumbersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PredictionNumbersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PredictionNumbersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PredictionNumbersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> predictionId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> number = const Value.absent(),
              }) => PredictionNumbersCompanion(
                id: id,
                predictionId: predictionId,
                position: position,
                number: number,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int predictionId,
                required int position,
                required int number,
              }) => PredictionNumbersCompanion.insert(
                id: id,
                predictionId: predictionId,
                position: position,
                number: number,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PredictionNumbersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({predictionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (predictionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.predictionId,
                                referencedTable:
                                    $$PredictionNumbersTableReferences
                                        ._predictionIdTable(db),
                                referencedColumn:
                                    $$PredictionNumbersTableReferences
                                        ._predictionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PredictionNumbersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PredictionNumbersTable,
      PredictionNumberRow,
      $$PredictionNumbersTableFilterComposer,
      $$PredictionNumbersTableOrderingComposer,
      $$PredictionNumbersTableAnnotationComposer,
      $$PredictionNumbersTableCreateCompanionBuilder,
      $$PredictionNumbersTableUpdateCompanionBuilder,
      (PredictionNumberRow, $$PredictionNumbersTableReferences),
      PredictionNumberRow,
      PrefetchHooks Function({bool predictionId})
    >;
typedef $$AiExecutionLogsTableCreateCompanionBuilder =
    AiExecutionLogsCompanion Function({
      Value<int> id,
      Value<int?> modelId,
      required DateTime startedAt,
      Value<DateTime?> finishedAt,
      required bool success,
      Value<String?> errorMessage,
      required String requestSummary,
    });
typedef $$AiExecutionLogsTableUpdateCompanionBuilder =
    AiExecutionLogsCompanion Function({
      Value<int> id,
      Value<int?> modelId,
      Value<DateTime> startedAt,
      Value<DateTime?> finishedAt,
      Value<bool> success,
      Value<String?> errorMessage,
      Value<String> requestSummary,
    });

final class $$AiExecutionLogsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AiExecutionLogsTable,
          AiExecutionLogRow
        > {
  $$AiExecutionLogsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AiModelsTable _modelIdTable(_$AppDatabase db) =>
      db.aiModels.createAlias(
        $_aliasNameGenerator(db.aiExecutionLogs.modelId, db.aiModels.id),
      );

  $$AiModelsTableProcessedTableManager? get modelId {
    final $_column = $_itemColumn<int>('model_id');
    if ($_column == null) return null;
    final manager = $$AiModelsTableTableManager(
      $_db,
      $_db.aiModels,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_modelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AiExecutionLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AiExecutionLogsTable> {
  $$AiExecutionLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestSummary => $composableBuilder(
    column: $table.requestSummary,
    builder: (column) => ColumnFilters(column),
  );

  $$AiModelsTableFilterComposer get modelId {
    final $$AiModelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.aiModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiModelsTableFilterComposer(
            $db: $db,
            $table: $db.aiModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AiExecutionLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiExecutionLogsTable> {
  $$AiExecutionLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestSummary => $composableBuilder(
    column: $table.requestSummary,
    builder: (column) => ColumnOrderings(column),
  );

  $$AiModelsTableOrderingComposer get modelId {
    final $$AiModelsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.aiModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiModelsTableOrderingComposer(
            $db: $db,
            $table: $db.aiModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AiExecutionLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiExecutionLogsTable> {
  $$AiExecutionLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get success =>
      $composableBuilder(column: $table.success, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestSummary => $composableBuilder(
    column: $table.requestSummary,
    builder: (column) => column,
  );

  $$AiModelsTableAnnotationComposer get modelId {
    final $$AiModelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.aiModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiModelsTableAnnotationComposer(
            $db: $db,
            $table: $db.aiModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AiExecutionLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiExecutionLogsTable,
          AiExecutionLogRow,
          $$AiExecutionLogsTableFilterComposer,
          $$AiExecutionLogsTableOrderingComposer,
          $$AiExecutionLogsTableAnnotationComposer,
          $$AiExecutionLogsTableCreateCompanionBuilder,
          $$AiExecutionLogsTableUpdateCompanionBuilder,
          (AiExecutionLogRow, $$AiExecutionLogsTableReferences),
          AiExecutionLogRow,
          PrefetchHooks Function({bool modelId})
        > {
  $$AiExecutionLogsTableTableManager(
    _$AppDatabase db,
    $AiExecutionLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiExecutionLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiExecutionLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiExecutionLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> modelId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<bool> success = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String> requestSummary = const Value.absent(),
              }) => AiExecutionLogsCompanion(
                id: id,
                modelId: modelId,
                startedAt: startedAt,
                finishedAt: finishedAt,
                success: success,
                errorMessage: errorMessage,
                requestSummary: requestSummary,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> modelId = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                required bool success,
                Value<String?> errorMessage = const Value.absent(),
                required String requestSummary,
              }) => AiExecutionLogsCompanion.insert(
                id: id,
                modelId: modelId,
                startedAt: startedAt,
                finishedAt: finishedAt,
                success: success,
                errorMessage: errorMessage,
                requestSummary: requestSummary,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AiExecutionLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({modelId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (modelId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.modelId,
                                referencedTable:
                                    $$AiExecutionLogsTableReferences
                                        ._modelIdTable(db),
                                referencedColumn:
                                    $$AiExecutionLogsTableReferences
                                        ._modelIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AiExecutionLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiExecutionLogsTable,
      AiExecutionLogRow,
      $$AiExecutionLogsTableFilterComposer,
      $$AiExecutionLogsTableOrderingComposer,
      $$AiExecutionLogsTableAnnotationComposer,
      $$AiExecutionLogsTableCreateCompanionBuilder,
      $$AiExecutionLogsTableUpdateCompanionBuilder,
      (AiExecutionLogRow, $$AiExecutionLogsTableReferences),
      AiExecutionLogRow,
      PrefetchHooks Function({bool modelId})
    >;
typedef $$BacktestRunsTableCreateCompanionBuilder =
    BacktestRunsCompanion Function({
      Value<int> id,
      Value<int?> strategyId,
      required String label,
      required String wheelCode,
      required int seed,
      Value<DateTime?> fromDate,
      Value<DateTime?> toDate,
      Value<int> warmupDraws,
      Value<int> scoredDraws,
      required String status,
      required String summaryJson,
      required DateTime createdAt,
    });
typedef $$BacktestRunsTableUpdateCompanionBuilder =
    BacktestRunsCompanion Function({
      Value<int> id,
      Value<int?> strategyId,
      Value<String> label,
      Value<String> wheelCode,
      Value<int> seed,
      Value<DateTime?> fromDate,
      Value<DateTime?> toDate,
      Value<int> warmupDraws,
      Value<int> scoredDraws,
      Value<String> status,
      Value<String> summaryJson,
      Value<DateTime> createdAt,
    });

final class $$BacktestRunsTableReferences
    extends BaseReferences<_$AppDatabase, $BacktestRunsTable, BacktestRunRow> {
  $$BacktestRunsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StrategiesTable _strategyIdTable(_$AppDatabase db) =>
      db.strategies.createAlias(
        $_aliasNameGenerator(db.backtestRuns.strategyId, db.strategies.id),
      );

  $$StrategiesTableProcessedTableManager? get strategyId {
    final $_column = $_itemColumn<int>('strategy_id');
    if ($_column == null) return null;
    final manager = $$StrategiesTableTableManager(
      $_db,
      $_db.strategies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_strategyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BacktestResultsTable, List<BacktestResultRow>>
  _backtestResultsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.backtestResults,
    aliasName: $_aliasNameGenerator(
      db.backtestRuns.id,
      db.backtestResults.runId,
    ),
  );

  $$BacktestResultsTableProcessedTableManager get backtestResultsRefs {
    final manager = $$BacktestResultsTableTableManager(
      $_db,
      $_db.backtestResults,
    ).filter((f) => f.runId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _backtestResultsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BacktestRunsTableFilterComposer
    extends Composer<_$AppDatabase, $BacktestRunsTable> {
  $$BacktestRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wheelCode => $composableBuilder(
    column: $table.wheelCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fromDate => $composableBuilder(
    column: $table.fromDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get toDate => $composableBuilder(
    column: $table.toDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warmupDraws => $composableBuilder(
    column: $table.warmupDraws,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scoredDraws => $composableBuilder(
    column: $table.scoredDraws,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StrategiesTableFilterComposer get strategyId {
    final $$StrategiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableFilterComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> backtestResultsRefs(
    Expression<bool> Function($$BacktestResultsTableFilterComposer f) f,
  ) {
    final $$BacktestResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.backtestResults,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BacktestResultsTableFilterComposer(
            $db: $db,
            $table: $db.backtestResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BacktestRunsTableOrderingComposer
    extends Composer<_$AppDatabase, $BacktestRunsTable> {
  $$BacktestRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wheelCode => $composableBuilder(
    column: $table.wheelCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fromDate => $composableBuilder(
    column: $table.fromDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get toDate => $composableBuilder(
    column: $table.toDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warmupDraws => $composableBuilder(
    column: $table.warmupDraws,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scoredDraws => $composableBuilder(
    column: $table.scoredDraws,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StrategiesTableOrderingComposer get strategyId {
    final $$StrategiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableOrderingComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BacktestRunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BacktestRunsTable> {
  $$BacktestRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get wheelCode =>
      $composableBuilder(column: $table.wheelCode, builder: (column) => column);

  GeneratedColumn<int> get seed =>
      $composableBuilder(column: $table.seed, builder: (column) => column);

  GeneratedColumn<DateTime> get fromDate =>
      $composableBuilder(column: $table.fromDate, builder: (column) => column);

  GeneratedColumn<DateTime> get toDate =>
      $composableBuilder(column: $table.toDate, builder: (column) => column);

  GeneratedColumn<int> get warmupDraws => $composableBuilder(
    column: $table.warmupDraws,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scoredDraws => $composableBuilder(
    column: $table.scoredDraws,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$StrategiesTableAnnotationComposer get strategyId {
    final $$StrategiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableAnnotationComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> backtestResultsRefs<T extends Object>(
    Expression<T> Function($$BacktestResultsTableAnnotationComposer a) f,
  ) {
    final $$BacktestResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.backtestResults,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BacktestResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.backtestResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BacktestRunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BacktestRunsTable,
          BacktestRunRow,
          $$BacktestRunsTableFilterComposer,
          $$BacktestRunsTableOrderingComposer,
          $$BacktestRunsTableAnnotationComposer,
          $$BacktestRunsTableCreateCompanionBuilder,
          $$BacktestRunsTableUpdateCompanionBuilder,
          (BacktestRunRow, $$BacktestRunsTableReferences),
          BacktestRunRow,
          PrefetchHooks Function({bool strategyId, bool backtestResultsRefs})
        > {
  $$BacktestRunsTableTableManager(_$AppDatabase db, $BacktestRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BacktestRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BacktestRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BacktestRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> strategyId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> wheelCode = const Value.absent(),
                Value<int> seed = const Value.absent(),
                Value<DateTime?> fromDate = const Value.absent(),
                Value<DateTime?> toDate = const Value.absent(),
                Value<int> warmupDraws = const Value.absent(),
                Value<int> scoredDraws = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> summaryJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BacktestRunsCompanion(
                id: id,
                strategyId: strategyId,
                label: label,
                wheelCode: wheelCode,
                seed: seed,
                fromDate: fromDate,
                toDate: toDate,
                warmupDraws: warmupDraws,
                scoredDraws: scoredDraws,
                status: status,
                summaryJson: summaryJson,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> strategyId = const Value.absent(),
                required String label,
                required String wheelCode,
                required int seed,
                Value<DateTime?> fromDate = const Value.absent(),
                Value<DateTime?> toDate = const Value.absent(),
                Value<int> warmupDraws = const Value.absent(),
                Value<int> scoredDraws = const Value.absent(),
                required String status,
                required String summaryJson,
                required DateTime createdAt,
              }) => BacktestRunsCompanion.insert(
                id: id,
                strategyId: strategyId,
                label: label,
                wheelCode: wheelCode,
                seed: seed,
                fromDate: fromDate,
                toDate: toDate,
                warmupDraws: warmupDraws,
                scoredDraws: scoredDraws,
                status: status,
                summaryJson: summaryJson,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BacktestRunsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({strategyId = false, backtestResultsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (backtestResultsRefs) db.backtestResults,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (strategyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.strategyId,
                                    referencedTable:
                                        $$BacktestRunsTableReferences
                                            ._strategyIdTable(db),
                                    referencedColumn:
                                        $$BacktestRunsTableReferences
                                            ._strategyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (backtestResultsRefs)
                        await $_getPrefetchedData<
                          BacktestRunRow,
                          $BacktestRunsTable,
                          BacktestResultRow
                        >(
                          currentTable: table,
                          referencedTable: $$BacktestRunsTableReferences
                              ._backtestResultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BacktestRunsTableReferences(
                                db,
                                table,
                                p0,
                              ).backtestResultsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.runId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BacktestRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BacktestRunsTable,
      BacktestRunRow,
      $$BacktestRunsTableFilterComposer,
      $$BacktestRunsTableOrderingComposer,
      $$BacktestRunsTableAnnotationComposer,
      $$BacktestRunsTableCreateCompanionBuilder,
      $$BacktestRunsTableUpdateCompanionBuilder,
      (BacktestRunRow, $$BacktestRunsTableReferences),
      BacktestRunRow,
      PrefetchHooks Function({bool strategyId, bool backtestResultsRefs})
    >;
typedef $$BacktestResultsTableCreateCompanionBuilder =
    BacktestResultsCompanion Function({
      Value<int> id,
      required int runId,
      required DateTime drawDate,
      required int hits,
      required int baselineHits,
      required String proposedNumbers,
    });
typedef $$BacktestResultsTableUpdateCompanionBuilder =
    BacktestResultsCompanion Function({
      Value<int> id,
      Value<int> runId,
      Value<DateTime> drawDate,
      Value<int> hits,
      Value<int> baselineHits,
      Value<String> proposedNumbers,
    });

final class $$BacktestResultsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BacktestResultsTable,
          BacktestResultRow
        > {
  $$BacktestResultsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BacktestRunsTable _runIdTable(_$AppDatabase db) =>
      db.backtestRuns.createAlias(
        $_aliasNameGenerator(db.backtestResults.runId, db.backtestRuns.id),
      );

  $$BacktestRunsTableProcessedTableManager get runId {
    final $_column = $_itemColumn<int>('run_id')!;

    final manager = $$BacktestRunsTableTableManager(
      $_db,
      $_db.backtestRuns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_runIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BacktestResultsTableFilterComposer
    extends Composer<_$AppDatabase, $BacktestResultsTable> {
  $$BacktestResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get drawDate => $composableBuilder(
    column: $table.drawDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hits => $composableBuilder(
    column: $table.hits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baselineHits => $composableBuilder(
    column: $table.baselineHits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proposedNumbers => $composableBuilder(
    column: $table.proposedNumbers,
    builder: (column) => ColumnFilters(column),
  );

  $$BacktestRunsTableFilterComposer get runId {
    final $$BacktestRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.backtestRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BacktestRunsTableFilterComposer(
            $db: $db,
            $table: $db.backtestRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BacktestResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $BacktestResultsTable> {
  $$BacktestResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get drawDate => $composableBuilder(
    column: $table.drawDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hits => $composableBuilder(
    column: $table.hits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baselineHits => $composableBuilder(
    column: $table.baselineHits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proposedNumbers => $composableBuilder(
    column: $table.proposedNumbers,
    builder: (column) => ColumnOrderings(column),
  );

  $$BacktestRunsTableOrderingComposer get runId {
    final $$BacktestRunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.backtestRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BacktestRunsTableOrderingComposer(
            $db: $db,
            $table: $db.backtestRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BacktestResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BacktestResultsTable> {
  $$BacktestResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get drawDate =>
      $composableBuilder(column: $table.drawDate, builder: (column) => column);

  GeneratedColumn<int> get hits =>
      $composableBuilder(column: $table.hits, builder: (column) => column);

  GeneratedColumn<int> get baselineHits => $composableBuilder(
    column: $table.baselineHits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get proposedNumbers => $composableBuilder(
    column: $table.proposedNumbers,
    builder: (column) => column,
  );

  $$BacktestRunsTableAnnotationComposer get runId {
    final $$BacktestRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.backtestRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BacktestRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.backtestRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BacktestResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BacktestResultsTable,
          BacktestResultRow,
          $$BacktestResultsTableFilterComposer,
          $$BacktestResultsTableOrderingComposer,
          $$BacktestResultsTableAnnotationComposer,
          $$BacktestResultsTableCreateCompanionBuilder,
          $$BacktestResultsTableUpdateCompanionBuilder,
          (BacktestResultRow, $$BacktestResultsTableReferences),
          BacktestResultRow,
          PrefetchHooks Function({bool runId})
        > {
  $$BacktestResultsTableTableManager(
    _$AppDatabase db,
    $BacktestResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BacktestResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BacktestResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BacktestResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> runId = const Value.absent(),
                Value<DateTime> drawDate = const Value.absent(),
                Value<int> hits = const Value.absent(),
                Value<int> baselineHits = const Value.absent(),
                Value<String> proposedNumbers = const Value.absent(),
              }) => BacktestResultsCompanion(
                id: id,
                runId: runId,
                drawDate: drawDate,
                hits: hits,
                baselineHits: baselineHits,
                proposedNumbers: proposedNumbers,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int runId,
                required DateTime drawDate,
                required int hits,
                required int baselineHits,
                required String proposedNumbers,
              }) => BacktestResultsCompanion.insert(
                id: id,
                runId: runId,
                drawDate: drawDate,
                hits: hits,
                baselineHits: baselineHits,
                proposedNumbers: proposedNumbers,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BacktestResultsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({runId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (runId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.runId,
                                referencedTable:
                                    $$BacktestResultsTableReferences
                                        ._runIdTable(db),
                                referencedColumn:
                                    $$BacktestResultsTableReferences
                                        ._runIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BacktestResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BacktestResultsTable,
      BacktestResultRow,
      $$BacktestResultsTableFilterComposer,
      $$BacktestResultsTableOrderingComposer,
      $$BacktestResultsTableAnnotationComposer,
      $$BacktestResultsTableCreateCompanionBuilder,
      $$BacktestResultsTableUpdateCompanionBuilder,
      (BacktestResultRow, $$BacktestResultsTableReferences),
      BacktestResultRow,
      PrefetchHooks Function({bool runId})
    >;
typedef $$VirtualTicketsTableCreateCompanionBuilder =
    VirtualTicketsCompanion Function({
      Value<int> id,
      Value<int?> strategyId,
      required String wheelCode,
      required int stakeCents,
      required DateTime createdAt,
      Value<String?> note,
      Value<int> stakeEstrattoCents,
      Value<int> stakeAmboCents,
      Value<int> stakeTernoCents,
      Value<int> stakeQuaternaCents,
      Value<int> stakeCinquinaCents,
      Value<DateTime?> targetDrawDate,
      Value<String> status,
    });
typedef $$VirtualTicketsTableUpdateCompanionBuilder =
    VirtualTicketsCompanion Function({
      Value<int> id,
      Value<int?> strategyId,
      Value<String> wheelCode,
      Value<int> stakeCents,
      Value<DateTime> createdAt,
      Value<String?> note,
      Value<int> stakeEstrattoCents,
      Value<int> stakeAmboCents,
      Value<int> stakeTernoCents,
      Value<int> stakeQuaternaCents,
      Value<int> stakeCinquinaCents,
      Value<DateTime?> targetDrawDate,
      Value<String> status,
    });

final class $$VirtualTicketsTableReferences
    extends
        BaseReferences<_$AppDatabase, $VirtualTicketsTable, VirtualTicketRow> {
  $$VirtualTicketsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StrategiesTable _strategyIdTable(_$AppDatabase db) =>
      db.strategies.createAlias(
        $_aliasNameGenerator(db.virtualTickets.strategyId, db.strategies.id),
      );

  $$StrategiesTableProcessedTableManager? get strategyId {
    final $_column = $_itemColumn<int>('strategy_id');
    if ($_column == null) return null;
    final manager = $$StrategiesTableTableManager(
      $_db,
      $_db.strategies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_strategyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TicketNumbersTable, List<TicketNumberRow>>
  _ticketNumbersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ticketNumbers,
    aliasName: $_aliasNameGenerator(
      db.virtualTickets.id,
      db.ticketNumbers.ticketId,
    ),
  );

  $$TicketNumbersTableProcessedTableManager get ticketNumbersRefs {
    final manager = $$TicketNumbersTableTableManager(
      $_db,
      $_db.ticketNumbers,
    ).filter((f) => f.ticketId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ticketNumbersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TicketResultsTable, List<TicketResultRow>>
  _ticketResultsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ticketResults,
    aliasName: $_aliasNameGenerator(
      db.virtualTickets.id,
      db.ticketResults.ticketId,
    ),
  );

  $$TicketResultsTableProcessedTableManager get ticketResultsRefs {
    final manager = $$TicketResultsTableTableManager(
      $_db,
      $_db.ticketResults,
    ).filter((f) => f.ticketId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ticketResultsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VirtualTicketsTableFilterComposer
    extends Composer<_$AppDatabase, $VirtualTicketsTable> {
  $$VirtualTicketsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wheelCode => $composableBuilder(
    column: $table.wheelCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stakeCents => $composableBuilder(
    column: $table.stakeCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stakeEstrattoCents => $composableBuilder(
    column: $table.stakeEstrattoCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stakeAmboCents => $composableBuilder(
    column: $table.stakeAmboCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stakeTernoCents => $composableBuilder(
    column: $table.stakeTernoCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stakeQuaternaCents => $composableBuilder(
    column: $table.stakeQuaternaCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stakeCinquinaCents => $composableBuilder(
    column: $table.stakeCinquinaCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDrawDate => $composableBuilder(
    column: $table.targetDrawDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $$StrategiesTableFilterComposer get strategyId {
    final $$StrategiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableFilterComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> ticketNumbersRefs(
    Expression<bool> Function($$TicketNumbersTableFilterComposer f) f,
  ) {
    final $$TicketNumbersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ticketNumbers,
      getReferencedColumn: (t) => t.ticketId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketNumbersTableFilterComposer(
            $db: $db,
            $table: $db.ticketNumbers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ticketResultsRefs(
    Expression<bool> Function($$TicketResultsTableFilterComposer f) f,
  ) {
    final $$TicketResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ticketResults,
      getReferencedColumn: (t) => t.ticketId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketResultsTableFilterComposer(
            $db: $db,
            $table: $db.ticketResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VirtualTicketsTableOrderingComposer
    extends Composer<_$AppDatabase, $VirtualTicketsTable> {
  $$VirtualTicketsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wheelCode => $composableBuilder(
    column: $table.wheelCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stakeCents => $composableBuilder(
    column: $table.stakeCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stakeEstrattoCents => $composableBuilder(
    column: $table.stakeEstrattoCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stakeAmboCents => $composableBuilder(
    column: $table.stakeAmboCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stakeTernoCents => $composableBuilder(
    column: $table.stakeTernoCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stakeQuaternaCents => $composableBuilder(
    column: $table.stakeQuaternaCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stakeCinquinaCents => $composableBuilder(
    column: $table.stakeCinquinaCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDrawDate => $composableBuilder(
    column: $table.targetDrawDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$StrategiesTableOrderingComposer get strategyId {
    final $$StrategiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableOrderingComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VirtualTicketsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VirtualTicketsTable> {
  $$VirtualTicketsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get wheelCode =>
      $composableBuilder(column: $table.wheelCode, builder: (column) => column);

  GeneratedColumn<int> get stakeCents => $composableBuilder(
    column: $table.stakeCents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get stakeEstrattoCents => $composableBuilder(
    column: $table.stakeEstrattoCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stakeAmboCents => $composableBuilder(
    column: $table.stakeAmboCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stakeTernoCents => $composableBuilder(
    column: $table.stakeTernoCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stakeQuaternaCents => $composableBuilder(
    column: $table.stakeQuaternaCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stakeCinquinaCents => $composableBuilder(
    column: $table.stakeCinquinaCents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get targetDrawDate => $composableBuilder(
    column: $table.targetDrawDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$StrategiesTableAnnotationComposer get strategyId {
    final $$StrategiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableAnnotationComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> ticketNumbersRefs<T extends Object>(
    Expression<T> Function($$TicketNumbersTableAnnotationComposer a) f,
  ) {
    final $$TicketNumbersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ticketNumbers,
      getReferencedColumn: (t) => t.ticketId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketNumbersTableAnnotationComposer(
            $db: $db,
            $table: $db.ticketNumbers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ticketResultsRefs<T extends Object>(
    Expression<T> Function($$TicketResultsTableAnnotationComposer a) f,
  ) {
    final $$TicketResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ticketResults,
      getReferencedColumn: (t) => t.ticketId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.ticketResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VirtualTicketsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VirtualTicketsTable,
          VirtualTicketRow,
          $$VirtualTicketsTableFilterComposer,
          $$VirtualTicketsTableOrderingComposer,
          $$VirtualTicketsTableAnnotationComposer,
          $$VirtualTicketsTableCreateCompanionBuilder,
          $$VirtualTicketsTableUpdateCompanionBuilder,
          (VirtualTicketRow, $$VirtualTicketsTableReferences),
          VirtualTicketRow,
          PrefetchHooks Function({
            bool strategyId,
            bool ticketNumbersRefs,
            bool ticketResultsRefs,
          })
        > {
  $$VirtualTicketsTableTableManager(
    _$AppDatabase db,
    $VirtualTicketsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VirtualTicketsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VirtualTicketsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VirtualTicketsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> strategyId = const Value.absent(),
                Value<String> wheelCode = const Value.absent(),
                Value<int> stakeCents = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> stakeEstrattoCents = const Value.absent(),
                Value<int> stakeAmboCents = const Value.absent(),
                Value<int> stakeTernoCents = const Value.absent(),
                Value<int> stakeQuaternaCents = const Value.absent(),
                Value<int> stakeCinquinaCents = const Value.absent(),
                Value<DateTime?> targetDrawDate = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => VirtualTicketsCompanion(
                id: id,
                strategyId: strategyId,
                wheelCode: wheelCode,
                stakeCents: stakeCents,
                createdAt: createdAt,
                note: note,
                stakeEstrattoCents: stakeEstrattoCents,
                stakeAmboCents: stakeAmboCents,
                stakeTernoCents: stakeTernoCents,
                stakeQuaternaCents: stakeQuaternaCents,
                stakeCinquinaCents: stakeCinquinaCents,
                targetDrawDate: targetDrawDate,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> strategyId = const Value.absent(),
                required String wheelCode,
                required int stakeCents,
                required DateTime createdAt,
                Value<String?> note = const Value.absent(),
                Value<int> stakeEstrattoCents = const Value.absent(),
                Value<int> stakeAmboCents = const Value.absent(),
                Value<int> stakeTernoCents = const Value.absent(),
                Value<int> stakeQuaternaCents = const Value.absent(),
                Value<int> stakeCinquinaCents = const Value.absent(),
                Value<DateTime?> targetDrawDate = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => VirtualTicketsCompanion.insert(
                id: id,
                strategyId: strategyId,
                wheelCode: wheelCode,
                stakeCents: stakeCents,
                createdAt: createdAt,
                note: note,
                stakeEstrattoCents: stakeEstrattoCents,
                stakeAmboCents: stakeAmboCents,
                stakeTernoCents: stakeTernoCents,
                stakeQuaternaCents: stakeQuaternaCents,
                stakeCinquinaCents: stakeCinquinaCents,
                targetDrawDate: targetDrawDate,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VirtualTicketsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                strategyId = false,
                ticketNumbersRefs = false,
                ticketResultsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ticketNumbersRefs) db.ticketNumbers,
                    if (ticketResultsRefs) db.ticketResults,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (strategyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.strategyId,
                                    referencedTable:
                                        $$VirtualTicketsTableReferences
                                            ._strategyIdTable(db),
                                    referencedColumn:
                                        $$VirtualTicketsTableReferences
                                            ._strategyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ticketNumbersRefs)
                        await $_getPrefetchedData<
                          VirtualTicketRow,
                          $VirtualTicketsTable,
                          TicketNumberRow
                        >(
                          currentTable: table,
                          referencedTable: $$VirtualTicketsTableReferences
                              ._ticketNumbersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VirtualTicketsTableReferences(
                                db,
                                table,
                                p0,
                              ).ticketNumbersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ticketId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ticketResultsRefs)
                        await $_getPrefetchedData<
                          VirtualTicketRow,
                          $VirtualTicketsTable,
                          TicketResultRow
                        >(
                          currentTable: table,
                          referencedTable: $$VirtualTicketsTableReferences
                              ._ticketResultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VirtualTicketsTableReferences(
                                db,
                                table,
                                p0,
                              ).ticketResultsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ticketId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VirtualTicketsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VirtualTicketsTable,
      VirtualTicketRow,
      $$VirtualTicketsTableFilterComposer,
      $$VirtualTicketsTableOrderingComposer,
      $$VirtualTicketsTableAnnotationComposer,
      $$VirtualTicketsTableCreateCompanionBuilder,
      $$VirtualTicketsTableUpdateCompanionBuilder,
      (VirtualTicketRow, $$VirtualTicketsTableReferences),
      VirtualTicketRow,
      PrefetchHooks Function({
        bool strategyId,
        bool ticketNumbersRefs,
        bool ticketResultsRefs,
      })
    >;
typedef $$TicketNumbersTableCreateCompanionBuilder =
    TicketNumbersCompanion Function({
      Value<int> id,
      required int ticketId,
      required int position,
      required int number,
    });
typedef $$TicketNumbersTableUpdateCompanionBuilder =
    TicketNumbersCompanion Function({
      Value<int> id,
      Value<int> ticketId,
      Value<int> position,
      Value<int> number,
    });

final class $$TicketNumbersTableReferences
    extends
        BaseReferences<_$AppDatabase, $TicketNumbersTable, TicketNumberRow> {
  $$TicketNumbersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VirtualTicketsTable _ticketIdTable(_$AppDatabase db) =>
      db.virtualTickets.createAlias(
        $_aliasNameGenerator(db.ticketNumbers.ticketId, db.virtualTickets.id),
      );

  $$VirtualTicketsTableProcessedTableManager get ticketId {
    final $_column = $_itemColumn<int>('ticket_id')!;

    final manager = $$VirtualTicketsTableTableManager(
      $_db,
      $_db.virtualTickets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ticketIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TicketNumbersTableFilterComposer
    extends Composer<_$AppDatabase, $TicketNumbersTable> {
  $$TicketNumbersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  $$VirtualTicketsTableFilterComposer get ticketId {
    final $$VirtualTicketsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ticketId,
      referencedTable: $db.virtualTickets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VirtualTicketsTableFilterComposer(
            $db: $db,
            $table: $db.virtualTickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TicketNumbersTableOrderingComposer
    extends Composer<_$AppDatabase, $TicketNumbersTable> {
  $$TicketNumbersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  $$VirtualTicketsTableOrderingComposer get ticketId {
    final $$VirtualTicketsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ticketId,
      referencedTable: $db.virtualTickets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VirtualTicketsTableOrderingComposer(
            $db: $db,
            $table: $db.virtualTickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TicketNumbersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TicketNumbersTable> {
  $$TicketNumbersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  $$VirtualTicketsTableAnnotationComposer get ticketId {
    final $$VirtualTicketsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ticketId,
      referencedTable: $db.virtualTickets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VirtualTicketsTableAnnotationComposer(
            $db: $db,
            $table: $db.virtualTickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TicketNumbersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TicketNumbersTable,
          TicketNumberRow,
          $$TicketNumbersTableFilterComposer,
          $$TicketNumbersTableOrderingComposer,
          $$TicketNumbersTableAnnotationComposer,
          $$TicketNumbersTableCreateCompanionBuilder,
          $$TicketNumbersTableUpdateCompanionBuilder,
          (TicketNumberRow, $$TicketNumbersTableReferences),
          TicketNumberRow,
          PrefetchHooks Function({bool ticketId})
        > {
  $$TicketNumbersTableTableManager(_$AppDatabase db, $TicketNumbersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TicketNumbersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TicketNumbersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TicketNumbersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ticketId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> number = const Value.absent(),
              }) => TicketNumbersCompanion(
                id: id,
                ticketId: ticketId,
                position: position,
                number: number,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ticketId,
                required int position,
                required int number,
              }) => TicketNumbersCompanion.insert(
                id: id,
                ticketId: ticketId,
                position: position,
                number: number,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TicketNumbersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ticketId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ticketId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ticketId,
                                referencedTable: $$TicketNumbersTableReferences
                                    ._ticketIdTable(db),
                                referencedColumn: $$TicketNumbersTableReferences
                                    ._ticketIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TicketNumbersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TicketNumbersTable,
      TicketNumberRow,
      $$TicketNumbersTableFilterComposer,
      $$TicketNumbersTableOrderingComposer,
      $$TicketNumbersTableAnnotationComposer,
      $$TicketNumbersTableCreateCompanionBuilder,
      $$TicketNumbersTableUpdateCompanionBuilder,
      (TicketNumberRow, $$TicketNumbersTableReferences),
      TicketNumberRow,
      PrefetchHooks Function({bool ticketId})
    >;
typedef $$TicketResultsTableCreateCompanionBuilder =
    TicketResultsCompanion Function({
      Value<int> id,
      required int ticketId,
      Value<int?> drawId,
      required DateTime evaluatedAt,
      Value<int?> hits,
      Value<int?> grossCents,
      Value<int?> netCents,
      required String outcomeNote,
      Value<String?> detailJson,
    });
typedef $$TicketResultsTableUpdateCompanionBuilder =
    TicketResultsCompanion Function({
      Value<int> id,
      Value<int> ticketId,
      Value<int?> drawId,
      Value<DateTime> evaluatedAt,
      Value<int?> hits,
      Value<int?> grossCents,
      Value<int?> netCents,
      Value<String> outcomeNote,
      Value<String?> detailJson,
    });

final class $$TicketResultsTableReferences
    extends
        BaseReferences<_$AppDatabase, $TicketResultsTable, TicketResultRow> {
  $$TicketResultsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VirtualTicketsTable _ticketIdTable(_$AppDatabase db) =>
      db.virtualTickets.createAlias(
        $_aliasNameGenerator(db.ticketResults.ticketId, db.virtualTickets.id),
      );

  $$VirtualTicketsTableProcessedTableManager get ticketId {
    final $_column = $_itemColumn<int>('ticket_id')!;

    final manager = $$VirtualTicketsTableTableManager(
      $_db,
      $_db.virtualTickets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ticketIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DrawsTable _drawIdTable(_$AppDatabase db) => db.draws.createAlias(
    $_aliasNameGenerator(db.ticketResults.drawId, db.draws.id),
  );

  $$DrawsTableProcessedTableManager? get drawId {
    final $_column = $_itemColumn<int>('draw_id');
    if ($_column == null) return null;
    final manager = $$DrawsTableTableManager(
      $_db,
      $_db.draws,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_drawIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TicketResultsTableFilterComposer
    extends Composer<_$AppDatabase, $TicketResultsTable> {
  $$TicketResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get evaluatedAt => $composableBuilder(
    column: $table.evaluatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hits => $composableBuilder(
    column: $table.hits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grossCents => $composableBuilder(
    column: $table.grossCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get netCents => $composableBuilder(
    column: $table.netCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcomeNote => $composableBuilder(
    column: $table.outcomeNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailJson => $composableBuilder(
    column: $table.detailJson,
    builder: (column) => ColumnFilters(column),
  );

  $$VirtualTicketsTableFilterComposer get ticketId {
    final $$VirtualTicketsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ticketId,
      referencedTable: $db.virtualTickets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VirtualTicketsTableFilterComposer(
            $db: $db,
            $table: $db.virtualTickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DrawsTableFilterComposer get drawId {
    final $$DrawsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.drawId,
      referencedTable: $db.draws,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrawsTableFilterComposer(
            $db: $db,
            $table: $db.draws,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TicketResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $TicketResultsTable> {
  $$TicketResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get evaluatedAt => $composableBuilder(
    column: $table.evaluatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hits => $composableBuilder(
    column: $table.hits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grossCents => $composableBuilder(
    column: $table.grossCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get netCents => $composableBuilder(
    column: $table.netCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcomeNote => $composableBuilder(
    column: $table.outcomeNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailJson => $composableBuilder(
    column: $table.detailJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$VirtualTicketsTableOrderingComposer get ticketId {
    final $$VirtualTicketsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ticketId,
      referencedTable: $db.virtualTickets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VirtualTicketsTableOrderingComposer(
            $db: $db,
            $table: $db.virtualTickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DrawsTableOrderingComposer get drawId {
    final $$DrawsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.drawId,
      referencedTable: $db.draws,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrawsTableOrderingComposer(
            $db: $db,
            $table: $db.draws,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TicketResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TicketResultsTable> {
  $$TicketResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get evaluatedAt => $composableBuilder(
    column: $table.evaluatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hits =>
      $composableBuilder(column: $table.hits, builder: (column) => column);

  GeneratedColumn<int> get grossCents => $composableBuilder(
    column: $table.grossCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get netCents =>
      $composableBuilder(column: $table.netCents, builder: (column) => column);

  GeneratedColumn<String> get outcomeNote => $composableBuilder(
    column: $table.outcomeNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detailJson => $composableBuilder(
    column: $table.detailJson,
    builder: (column) => column,
  );

  $$VirtualTicketsTableAnnotationComposer get ticketId {
    final $$VirtualTicketsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ticketId,
      referencedTable: $db.virtualTickets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VirtualTicketsTableAnnotationComposer(
            $db: $db,
            $table: $db.virtualTickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DrawsTableAnnotationComposer get drawId {
    final $$DrawsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.drawId,
      referencedTable: $db.draws,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrawsTableAnnotationComposer(
            $db: $db,
            $table: $db.draws,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TicketResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TicketResultsTable,
          TicketResultRow,
          $$TicketResultsTableFilterComposer,
          $$TicketResultsTableOrderingComposer,
          $$TicketResultsTableAnnotationComposer,
          $$TicketResultsTableCreateCompanionBuilder,
          $$TicketResultsTableUpdateCompanionBuilder,
          (TicketResultRow, $$TicketResultsTableReferences),
          TicketResultRow,
          PrefetchHooks Function({bool ticketId, bool drawId})
        > {
  $$TicketResultsTableTableManager(_$AppDatabase db, $TicketResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TicketResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TicketResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TicketResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ticketId = const Value.absent(),
                Value<int?> drawId = const Value.absent(),
                Value<DateTime> evaluatedAt = const Value.absent(),
                Value<int?> hits = const Value.absent(),
                Value<int?> grossCents = const Value.absent(),
                Value<int?> netCents = const Value.absent(),
                Value<String> outcomeNote = const Value.absent(),
                Value<String?> detailJson = const Value.absent(),
              }) => TicketResultsCompanion(
                id: id,
                ticketId: ticketId,
                drawId: drawId,
                evaluatedAt: evaluatedAt,
                hits: hits,
                grossCents: grossCents,
                netCents: netCents,
                outcomeNote: outcomeNote,
                detailJson: detailJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ticketId,
                Value<int?> drawId = const Value.absent(),
                required DateTime evaluatedAt,
                Value<int?> hits = const Value.absent(),
                Value<int?> grossCents = const Value.absent(),
                Value<int?> netCents = const Value.absent(),
                required String outcomeNote,
                Value<String?> detailJson = const Value.absent(),
              }) => TicketResultsCompanion.insert(
                id: id,
                ticketId: ticketId,
                drawId: drawId,
                evaluatedAt: evaluatedAt,
                hits: hits,
                grossCents: grossCents,
                netCents: netCents,
                outcomeNote: outcomeNote,
                detailJson: detailJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TicketResultsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ticketId = false, drawId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ticketId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ticketId,
                                referencedTable: $$TicketResultsTableReferences
                                    ._ticketIdTable(db),
                                referencedColumn: $$TicketResultsTableReferences
                                    ._ticketIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (drawId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.drawId,
                                referencedTable: $$TicketResultsTableReferences
                                    ._drawIdTable(db),
                                referencedColumn: $$TicketResultsTableReferences
                                    ._drawIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TicketResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TicketResultsTable,
      TicketResultRow,
      $$TicketResultsTableFilterComposer,
      $$TicketResultsTableOrderingComposer,
      $$TicketResultsTableAnnotationComposer,
      $$TicketResultsTableCreateCompanionBuilder,
      $$TicketResultsTableUpdateCompanionBuilder,
      (TicketResultRow, $$TicketResultsTableReferences),
      TicketResultRow,
      PrefetchHooks Function({bool ticketId, bool drawId})
    >;
typedef $$SuperenalottoDrawsTableCreateCompanionBuilder =
    SuperenalottoDrawsCompanion Function({
      Value<int> id,
      required DateTime drawDate,
      required int contestNumber,
      required int n1,
      required int n2,
      required int n3,
      required int n4,
      required int n5,
      required int n6,
      required int jolly,
      required int superstar,
      required String contentHash,
      Value<bool> officiallyVerified,
      required String provenance,
      required DateTime importedAt,
    });
typedef $$SuperenalottoDrawsTableUpdateCompanionBuilder =
    SuperenalottoDrawsCompanion Function({
      Value<int> id,
      Value<DateTime> drawDate,
      Value<int> contestNumber,
      Value<int> n1,
      Value<int> n2,
      Value<int> n3,
      Value<int> n4,
      Value<int> n5,
      Value<int> n6,
      Value<int> jolly,
      Value<int> superstar,
      Value<String> contentHash,
      Value<bool> officiallyVerified,
      Value<String> provenance,
      Value<DateTime> importedAt,
    });

class $$SuperenalottoDrawsTableFilterComposer
    extends Composer<_$AppDatabase, $SuperenalottoDrawsTable> {
  $$SuperenalottoDrawsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get drawDate => $composableBuilder(
    column: $table.drawDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contestNumber => $composableBuilder(
    column: $table.contestNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get n1 => $composableBuilder(
    column: $table.n1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get n2 => $composableBuilder(
    column: $table.n2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get n3 => $composableBuilder(
    column: $table.n3,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get n4 => $composableBuilder(
    column: $table.n4,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get n5 => $composableBuilder(
    column: $table.n5,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get n6 => $composableBuilder(
    column: $table.n6,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jolly => $composableBuilder(
    column: $table.jolly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get superstar => $composableBuilder(
    column: $table.superstar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get officiallyVerified => $composableBuilder(
    column: $table.officiallyVerified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SuperenalottoDrawsTableOrderingComposer
    extends Composer<_$AppDatabase, $SuperenalottoDrawsTable> {
  $$SuperenalottoDrawsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get drawDate => $composableBuilder(
    column: $table.drawDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contestNumber => $composableBuilder(
    column: $table.contestNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get n1 => $composableBuilder(
    column: $table.n1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get n2 => $composableBuilder(
    column: $table.n2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get n3 => $composableBuilder(
    column: $table.n3,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get n4 => $composableBuilder(
    column: $table.n4,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get n5 => $composableBuilder(
    column: $table.n5,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get n6 => $composableBuilder(
    column: $table.n6,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jolly => $composableBuilder(
    column: $table.jolly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get superstar => $composableBuilder(
    column: $table.superstar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get officiallyVerified => $composableBuilder(
    column: $table.officiallyVerified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuperenalottoDrawsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuperenalottoDrawsTable> {
  $$SuperenalottoDrawsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get drawDate =>
      $composableBuilder(column: $table.drawDate, builder: (column) => column);

  GeneratedColumn<int> get contestNumber => $composableBuilder(
    column: $table.contestNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get n1 =>
      $composableBuilder(column: $table.n1, builder: (column) => column);

  GeneratedColumn<int> get n2 =>
      $composableBuilder(column: $table.n2, builder: (column) => column);

  GeneratedColumn<int> get n3 =>
      $composableBuilder(column: $table.n3, builder: (column) => column);

  GeneratedColumn<int> get n4 =>
      $composableBuilder(column: $table.n4, builder: (column) => column);

  GeneratedColumn<int> get n5 =>
      $composableBuilder(column: $table.n5, builder: (column) => column);

  GeneratedColumn<int> get n6 =>
      $composableBuilder(column: $table.n6, builder: (column) => column);

  GeneratedColumn<int> get jolly =>
      $composableBuilder(column: $table.jolly, builder: (column) => column);

  GeneratedColumn<int> get superstar =>
      $composableBuilder(column: $table.superstar, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get officiallyVerified => $composableBuilder(
    column: $table.officiallyVerified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );
}

class $$SuperenalottoDrawsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuperenalottoDrawsTable,
          SuperenalottoDrawRow,
          $$SuperenalottoDrawsTableFilterComposer,
          $$SuperenalottoDrawsTableOrderingComposer,
          $$SuperenalottoDrawsTableAnnotationComposer,
          $$SuperenalottoDrawsTableCreateCompanionBuilder,
          $$SuperenalottoDrawsTableUpdateCompanionBuilder,
          (
            SuperenalottoDrawRow,
            BaseReferences<
              _$AppDatabase,
              $SuperenalottoDrawsTable,
              SuperenalottoDrawRow
            >,
          ),
          SuperenalottoDrawRow,
          PrefetchHooks Function()
        > {
  $$SuperenalottoDrawsTableTableManager(
    _$AppDatabase db,
    $SuperenalottoDrawsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuperenalottoDrawsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuperenalottoDrawsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuperenalottoDrawsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> drawDate = const Value.absent(),
                Value<int> contestNumber = const Value.absent(),
                Value<int> n1 = const Value.absent(),
                Value<int> n2 = const Value.absent(),
                Value<int> n3 = const Value.absent(),
                Value<int> n4 = const Value.absent(),
                Value<int> n5 = const Value.absent(),
                Value<int> n6 = const Value.absent(),
                Value<int> jolly = const Value.absent(),
                Value<int> superstar = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<bool> officiallyVerified = const Value.absent(),
                Value<String> provenance = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
              }) => SuperenalottoDrawsCompanion(
                id: id,
                drawDate: drawDate,
                contestNumber: contestNumber,
                n1: n1,
                n2: n2,
                n3: n3,
                n4: n4,
                n5: n5,
                n6: n6,
                jolly: jolly,
                superstar: superstar,
                contentHash: contentHash,
                officiallyVerified: officiallyVerified,
                provenance: provenance,
                importedAt: importedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime drawDate,
                required int contestNumber,
                required int n1,
                required int n2,
                required int n3,
                required int n4,
                required int n5,
                required int n6,
                required int jolly,
                required int superstar,
                required String contentHash,
                Value<bool> officiallyVerified = const Value.absent(),
                required String provenance,
                required DateTime importedAt,
              }) => SuperenalottoDrawsCompanion.insert(
                id: id,
                drawDate: drawDate,
                contestNumber: contestNumber,
                n1: n1,
                n2: n2,
                n3: n3,
                n4: n4,
                n5: n5,
                n6: n6,
                jolly: jolly,
                superstar: superstar,
                contentHash: contentHash,
                officiallyVerified: officiallyVerified,
                provenance: provenance,
                importedAt: importedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SuperenalottoDrawsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuperenalottoDrawsTable,
      SuperenalottoDrawRow,
      $$SuperenalottoDrawsTableFilterComposer,
      $$SuperenalottoDrawsTableOrderingComposer,
      $$SuperenalottoDrawsTableAnnotationComposer,
      $$SuperenalottoDrawsTableCreateCompanionBuilder,
      $$SuperenalottoDrawsTableUpdateCompanionBuilder,
      (
        SuperenalottoDrawRow,
        BaseReferences<
          _$AppDatabase,
          $SuperenalottoDrawsTable,
          SuperenalottoDrawRow
        >,
      ),
      SuperenalottoDrawRow,
      PrefetchHooks Function()
    >;
typedef $$SuperenalottoTicketsTableCreateCompanionBuilder =
    SuperenalottoTicketsCompanion Function({
      Value<int> id,
      required int n1,
      required int n2,
      required int n3,
      required int n4,
      required int n5,
      required int n6,
      Value<int?> superstar,
      required DateTime targetDrawDate,
      Value<String> status,
      Value<String> origin,
      Value<String?> note,
      required DateTime createdAt,
    });
typedef $$SuperenalottoTicketsTableUpdateCompanionBuilder =
    SuperenalottoTicketsCompanion Function({
      Value<int> id,
      Value<int> n1,
      Value<int> n2,
      Value<int> n3,
      Value<int> n4,
      Value<int> n5,
      Value<int> n6,
      Value<int?> superstar,
      Value<DateTime> targetDrawDate,
      Value<String> status,
      Value<String> origin,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

final class $$SuperenalottoTicketsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SuperenalottoTicketsTable,
          SuperenalottoTicketRow
        > {
  $$SuperenalottoTicketsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $SuperenalottoTicketResultsTable,
    List<SuperenalottoTicketResultRow>
  >
  _superenalottoTicketResultsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.superenalottoTicketResults,
        aliasName: $_aliasNameGenerator(
          db.superenalottoTickets.id,
          db.superenalottoTicketResults.ticketId,
        ),
      );

  $$SuperenalottoTicketResultsTableProcessedTableManager
  get superenalottoTicketResultsRefs {
    final manager = $$SuperenalottoTicketResultsTableTableManager(
      $_db,
      $_db.superenalottoTicketResults,
    ).filter((f) => f.ticketId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _superenalottoTicketResultsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SuperenalottoTicketsTableFilterComposer
    extends Composer<_$AppDatabase, $SuperenalottoTicketsTable> {
  $$SuperenalottoTicketsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get n1 => $composableBuilder(
    column: $table.n1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get n2 => $composableBuilder(
    column: $table.n2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get n3 => $composableBuilder(
    column: $table.n3,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get n4 => $composableBuilder(
    column: $table.n4,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get n5 => $composableBuilder(
    column: $table.n5,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get n6 => $composableBuilder(
    column: $table.n6,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get superstar => $composableBuilder(
    column: $table.superstar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDrawDate => $composableBuilder(
    column: $table.targetDrawDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> superenalottoTicketResultsRefs(
    Expression<bool> Function($$SuperenalottoTicketResultsTableFilterComposer f)
    f,
  ) {
    final $$SuperenalottoTicketResultsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.superenalottoTicketResults,
          getReferencedColumn: (t) => t.ticketId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SuperenalottoTicketResultsTableFilterComposer(
                $db: $db,
                $table: $db.superenalottoTicketResults,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SuperenalottoTicketsTableOrderingComposer
    extends Composer<_$AppDatabase, $SuperenalottoTicketsTable> {
  $$SuperenalottoTicketsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get n1 => $composableBuilder(
    column: $table.n1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get n2 => $composableBuilder(
    column: $table.n2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get n3 => $composableBuilder(
    column: $table.n3,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get n4 => $composableBuilder(
    column: $table.n4,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get n5 => $composableBuilder(
    column: $table.n5,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get n6 => $composableBuilder(
    column: $table.n6,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get superstar => $composableBuilder(
    column: $table.superstar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDrawDate => $composableBuilder(
    column: $table.targetDrawDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuperenalottoTicketsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuperenalottoTicketsTable> {
  $$SuperenalottoTicketsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get n1 =>
      $composableBuilder(column: $table.n1, builder: (column) => column);

  GeneratedColumn<int> get n2 =>
      $composableBuilder(column: $table.n2, builder: (column) => column);

  GeneratedColumn<int> get n3 =>
      $composableBuilder(column: $table.n3, builder: (column) => column);

  GeneratedColumn<int> get n4 =>
      $composableBuilder(column: $table.n4, builder: (column) => column);

  GeneratedColumn<int> get n5 =>
      $composableBuilder(column: $table.n5, builder: (column) => column);

  GeneratedColumn<int> get n6 =>
      $composableBuilder(column: $table.n6, builder: (column) => column);

  GeneratedColumn<int> get superstar =>
      $composableBuilder(column: $table.superstar, builder: (column) => column);

  GeneratedColumn<DateTime> get targetDrawDate => $composableBuilder(
    column: $table.targetDrawDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> superenalottoTicketResultsRefs<T extends Object>(
    Expression<T> Function(
      $$SuperenalottoTicketResultsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$SuperenalottoTicketResultsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.superenalottoTicketResults,
          getReferencedColumn: (t) => t.ticketId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SuperenalottoTicketResultsTableAnnotationComposer(
                $db: $db,
                $table: $db.superenalottoTicketResults,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SuperenalottoTicketsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuperenalottoTicketsTable,
          SuperenalottoTicketRow,
          $$SuperenalottoTicketsTableFilterComposer,
          $$SuperenalottoTicketsTableOrderingComposer,
          $$SuperenalottoTicketsTableAnnotationComposer,
          $$SuperenalottoTicketsTableCreateCompanionBuilder,
          $$SuperenalottoTicketsTableUpdateCompanionBuilder,
          (SuperenalottoTicketRow, $$SuperenalottoTicketsTableReferences),
          SuperenalottoTicketRow,
          PrefetchHooks Function({bool superenalottoTicketResultsRefs})
        > {
  $$SuperenalottoTicketsTableTableManager(
    _$AppDatabase db,
    $SuperenalottoTicketsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuperenalottoTicketsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuperenalottoTicketsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SuperenalottoTicketsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> n1 = const Value.absent(),
                Value<int> n2 = const Value.absent(),
                Value<int> n3 = const Value.absent(),
                Value<int> n4 = const Value.absent(),
                Value<int> n5 = const Value.absent(),
                Value<int> n6 = const Value.absent(),
                Value<int?> superstar = const Value.absent(),
                Value<DateTime> targetDrawDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SuperenalottoTicketsCompanion(
                id: id,
                n1: n1,
                n2: n2,
                n3: n3,
                n4: n4,
                n5: n5,
                n6: n6,
                superstar: superstar,
                targetDrawDate: targetDrawDate,
                status: status,
                origin: origin,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int n1,
                required int n2,
                required int n3,
                required int n4,
                required int n5,
                required int n6,
                Value<int?> superstar = const Value.absent(),
                required DateTime targetDrawDate,
                Value<String> status = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
              }) => SuperenalottoTicketsCompanion.insert(
                id: id,
                n1: n1,
                n2: n2,
                n3: n3,
                n4: n4,
                n5: n5,
                n6: n6,
                superstar: superstar,
                targetDrawDate: targetDrawDate,
                status: status,
                origin: origin,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SuperenalottoTicketsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({superenalottoTicketResultsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (superenalottoTicketResultsRefs)
                  db.superenalottoTicketResults,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (superenalottoTicketResultsRefs)
                    await $_getPrefetchedData<
                      SuperenalottoTicketRow,
                      $SuperenalottoTicketsTable,
                      SuperenalottoTicketResultRow
                    >(
                      currentTable: table,
                      referencedTable: $$SuperenalottoTicketsTableReferences
                          ._superenalottoTicketResultsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SuperenalottoTicketsTableReferences(
                            db,
                            table,
                            p0,
                          ).superenalottoTicketResultsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.ticketId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SuperenalottoTicketsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuperenalottoTicketsTable,
      SuperenalottoTicketRow,
      $$SuperenalottoTicketsTableFilterComposer,
      $$SuperenalottoTicketsTableOrderingComposer,
      $$SuperenalottoTicketsTableAnnotationComposer,
      $$SuperenalottoTicketsTableCreateCompanionBuilder,
      $$SuperenalottoTicketsTableUpdateCompanionBuilder,
      (SuperenalottoTicketRow, $$SuperenalottoTicketsTableReferences),
      SuperenalottoTicketRow,
      PrefetchHooks Function({bool superenalottoTicketResultsRefs})
    >;
typedef $$SuperenalottoTicketResultsTableCreateCompanionBuilder =
    SuperenalottoTicketResultsCompanion Function({
      Value<int> id,
      required int ticketId,
      required int contestNumber,
      required DateTime drawDate,
      required int hits,
      required bool jollyMatched,
      required bool superstarMatched,
      required String category,
      required DateTime evaluatedAt,
    });
typedef $$SuperenalottoTicketResultsTableUpdateCompanionBuilder =
    SuperenalottoTicketResultsCompanion Function({
      Value<int> id,
      Value<int> ticketId,
      Value<int> contestNumber,
      Value<DateTime> drawDate,
      Value<int> hits,
      Value<bool> jollyMatched,
      Value<bool> superstarMatched,
      Value<String> category,
      Value<DateTime> evaluatedAt,
    });

final class $$SuperenalottoTicketResultsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SuperenalottoTicketResultsTable,
          SuperenalottoTicketResultRow
        > {
  $$SuperenalottoTicketResultsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SuperenalottoTicketsTable _ticketIdTable(_$AppDatabase db) =>
      db.superenalottoTickets.createAlias(
        $_aliasNameGenerator(
          db.superenalottoTicketResults.ticketId,
          db.superenalottoTickets.id,
        ),
      );

  $$SuperenalottoTicketsTableProcessedTableManager get ticketId {
    final $_column = $_itemColumn<int>('ticket_id')!;

    final manager = $$SuperenalottoTicketsTableTableManager(
      $_db,
      $_db.superenalottoTickets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ticketIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SuperenalottoTicketResultsTableFilterComposer
    extends Composer<_$AppDatabase, $SuperenalottoTicketResultsTable> {
  $$SuperenalottoTicketResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contestNumber => $composableBuilder(
    column: $table.contestNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get drawDate => $composableBuilder(
    column: $table.drawDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hits => $composableBuilder(
    column: $table.hits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get jollyMatched => $composableBuilder(
    column: $table.jollyMatched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get superstarMatched => $composableBuilder(
    column: $table.superstarMatched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get evaluatedAt => $composableBuilder(
    column: $table.evaluatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SuperenalottoTicketsTableFilterComposer get ticketId {
    final $$SuperenalottoTicketsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ticketId,
      referencedTable: $db.superenalottoTickets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuperenalottoTicketsTableFilterComposer(
            $db: $db,
            $table: $db.superenalottoTickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SuperenalottoTicketResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $SuperenalottoTicketResultsTable> {
  $$SuperenalottoTicketResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contestNumber => $composableBuilder(
    column: $table.contestNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get drawDate => $composableBuilder(
    column: $table.drawDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hits => $composableBuilder(
    column: $table.hits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get jollyMatched => $composableBuilder(
    column: $table.jollyMatched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get superstarMatched => $composableBuilder(
    column: $table.superstarMatched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get evaluatedAt => $composableBuilder(
    column: $table.evaluatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SuperenalottoTicketsTableOrderingComposer get ticketId {
    final $$SuperenalottoTicketsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.ticketId,
          referencedTable: $db.superenalottoTickets,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SuperenalottoTicketsTableOrderingComposer(
                $db: $db,
                $table: $db.superenalottoTickets,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SuperenalottoTicketResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuperenalottoTicketResultsTable> {
  $$SuperenalottoTicketResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get contestNumber => $composableBuilder(
    column: $table.contestNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get drawDate =>
      $composableBuilder(column: $table.drawDate, builder: (column) => column);

  GeneratedColumn<int> get hits =>
      $composableBuilder(column: $table.hits, builder: (column) => column);

  GeneratedColumn<bool> get jollyMatched => $composableBuilder(
    column: $table.jollyMatched,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get superstarMatched => $composableBuilder(
    column: $table.superstarMatched,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get evaluatedAt => $composableBuilder(
    column: $table.evaluatedAt,
    builder: (column) => column,
  );

  $$SuperenalottoTicketsTableAnnotationComposer get ticketId {
    final $$SuperenalottoTicketsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.ticketId,
          referencedTable: $db.superenalottoTickets,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SuperenalottoTicketsTableAnnotationComposer(
                $db: $db,
                $table: $db.superenalottoTickets,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SuperenalottoTicketResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuperenalottoTicketResultsTable,
          SuperenalottoTicketResultRow,
          $$SuperenalottoTicketResultsTableFilterComposer,
          $$SuperenalottoTicketResultsTableOrderingComposer,
          $$SuperenalottoTicketResultsTableAnnotationComposer,
          $$SuperenalottoTicketResultsTableCreateCompanionBuilder,
          $$SuperenalottoTicketResultsTableUpdateCompanionBuilder,
          (
            SuperenalottoTicketResultRow,
            $$SuperenalottoTicketResultsTableReferences,
          ),
          SuperenalottoTicketResultRow,
          PrefetchHooks Function({bool ticketId})
        > {
  $$SuperenalottoTicketResultsTableTableManager(
    _$AppDatabase db,
    $SuperenalottoTicketResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuperenalottoTicketResultsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SuperenalottoTicketResultsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SuperenalottoTicketResultsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ticketId = const Value.absent(),
                Value<int> contestNumber = const Value.absent(),
                Value<DateTime> drawDate = const Value.absent(),
                Value<int> hits = const Value.absent(),
                Value<bool> jollyMatched = const Value.absent(),
                Value<bool> superstarMatched = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime> evaluatedAt = const Value.absent(),
              }) => SuperenalottoTicketResultsCompanion(
                id: id,
                ticketId: ticketId,
                contestNumber: contestNumber,
                drawDate: drawDate,
                hits: hits,
                jollyMatched: jollyMatched,
                superstarMatched: superstarMatched,
                category: category,
                evaluatedAt: evaluatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ticketId,
                required int contestNumber,
                required DateTime drawDate,
                required int hits,
                required bool jollyMatched,
                required bool superstarMatched,
                required String category,
                required DateTime evaluatedAt,
              }) => SuperenalottoTicketResultsCompanion.insert(
                id: id,
                ticketId: ticketId,
                contestNumber: contestNumber,
                drawDate: drawDate,
                hits: hits,
                jollyMatched: jollyMatched,
                superstarMatched: superstarMatched,
                category: category,
                evaluatedAt: evaluatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SuperenalottoTicketResultsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ticketId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ticketId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ticketId,
                                referencedTable:
                                    $$SuperenalottoTicketResultsTableReferences
                                        ._ticketIdTable(db),
                                referencedColumn:
                                    $$SuperenalottoTicketResultsTableReferences
                                        ._ticketIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SuperenalottoTicketResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuperenalottoTicketResultsTable,
      SuperenalottoTicketResultRow,
      $$SuperenalottoTicketResultsTableFilterComposer,
      $$SuperenalottoTicketResultsTableOrderingComposer,
      $$SuperenalottoTicketResultsTableAnnotationComposer,
      $$SuperenalottoTicketResultsTableCreateCompanionBuilder,
      $$SuperenalottoTicketResultsTableUpdateCompanionBuilder,
      (
        SuperenalottoTicketResultRow,
        $$SuperenalottoTicketResultsTableReferences,
      ),
      SuperenalottoTicketResultRow,
      PrefetchHooks Function({bool ticketId})
    >;
typedef $$UserSettingsTableCreateCompanionBuilder =
    UserSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$UserSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsTable,
          UserSettingRow,
          $$UserSettingsTableFilterComposer,
          $$UserSettingsTableOrderingComposer,
          $$UserSettingsTableAnnotationComposer,
          $$UserSettingsTableCreateCompanionBuilder,
          $$UserSettingsTableUpdateCompanionBuilder,
          (
            UserSettingRow,
            BaseReferences<_$AppDatabase, $UserSettingsTable, UserSettingRow>,
          ),
          UserSettingRow,
          PrefetchHooks Function()
        > {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsTable,
      UserSettingRow,
      $$UserSettingsTableFilterComposer,
      $$UserSettingsTableOrderingComposer,
      $$UserSettingsTableAnnotationComposer,
      $$UserSettingsTableCreateCompanionBuilder,
      $$UserSettingsTableUpdateCompanionBuilder,
      (
        UserSettingRow,
        BaseReferences<_$AppDatabase, $UserSettingsTable, UserSettingRow>,
      ),
      UserSettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WheelsTableTableManager get wheels =>
      $$WheelsTableTableManager(_db, _db.wheels);
  $$DataSourcesTableTableManager get dataSources =>
      $$DataSourcesTableTableManager(_db, _db.dataSources);
  $$DrawsTableTableManager get draws =>
      $$DrawsTableTableManager(_db, _db.draws);
  $$DrawNumbersTableTableManager get drawNumbers =>
      $$DrawNumbersTableTableManager(_db, _db.drawNumbers);
  $$SyncLogsTableTableManager get syncLogs =>
      $$SyncLogsTableTableManager(_db, _db.syncLogs);
  $$StrategiesTableTableManager get strategies =>
      $$StrategiesTableTableManager(_db, _db.strategies);
  $$StrategyParametersTableTableManager get strategyParameters =>
      $$StrategyParametersTableTableManager(_db, _db.strategyParameters);
  $$AiModelsTableTableManager get aiModels =>
      $$AiModelsTableTableManager(_db, _db.aiModels);
  $$PredictionsTableTableManager get predictions =>
      $$PredictionsTableTableManager(_db, _db.predictions);
  $$PredictionNumbersTableTableManager get predictionNumbers =>
      $$PredictionNumbersTableTableManager(_db, _db.predictionNumbers);
  $$AiExecutionLogsTableTableManager get aiExecutionLogs =>
      $$AiExecutionLogsTableTableManager(_db, _db.aiExecutionLogs);
  $$BacktestRunsTableTableManager get backtestRuns =>
      $$BacktestRunsTableTableManager(_db, _db.backtestRuns);
  $$BacktestResultsTableTableManager get backtestResults =>
      $$BacktestResultsTableTableManager(_db, _db.backtestResults);
  $$VirtualTicketsTableTableManager get virtualTickets =>
      $$VirtualTicketsTableTableManager(_db, _db.virtualTickets);
  $$TicketNumbersTableTableManager get ticketNumbers =>
      $$TicketNumbersTableTableManager(_db, _db.ticketNumbers);
  $$TicketResultsTableTableManager get ticketResults =>
      $$TicketResultsTableTableManager(_db, _db.ticketResults);
  $$SuperenalottoDrawsTableTableManager get superenalottoDraws =>
      $$SuperenalottoDrawsTableTableManager(_db, _db.superenalottoDraws);
  $$SuperenalottoTicketsTableTableManager get superenalottoTickets =>
      $$SuperenalottoTicketsTableTableManager(_db, _db.superenalottoTickets);
  $$SuperenalottoTicketResultsTableTableManager
  get superenalottoTicketResults =>
      $$SuperenalottoTicketResultsTableTableManager(
        _db,
        _db.superenalottoTicketResults,
      );
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
}
