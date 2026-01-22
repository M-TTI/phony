// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SongsTable extends Songs with TableInfo<$SongsTable, Song> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileChecksumMeta = const VerificationMeta(
    'fileChecksum',
  );
  @override
  late final GeneratedColumn<String> fileChecksum = GeneratedColumn<String>(
    'file_checksum',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasCustomMetadataMeta = const VerificationMeta(
    'hasCustomMetadata',
  );
  @override
  late final GeneratedColumn<bool> hasCustomMetadata = GeneratedColumn<bool>(
    'has_custom_metadata',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_custom_metadata" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    duration,
    filePath,
    imagePath,
    fileChecksum,
    hasCustomMetadata,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Song> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('file_checksum')) {
      context.handle(
        _fileChecksumMeta,
        fileChecksum.isAcceptableOrUnknown(
          data['file_checksum']!,
          _fileChecksumMeta,
        ),
      );
    }
    if (data.containsKey('has_custom_metadata')) {
      context.handle(
        _hasCustomMetadataMeta,
        hasCustomMetadata.isAcceptableOrUnknown(
          data['has_custom_metadata']!,
          _hasCustomMetadataMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Song map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Song(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      fileChecksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_checksum'],
      ),
      hasCustomMetadata: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_custom_metadata'],
      )!,
    );
  }

  @override
  $SongsTable createAlias(String alias) {
    return $SongsTable(attachedDatabase, alias);
  }
}

class Song extends DataClass implements Insertable<Song> {
  final int id;
  final String title;
  final int duration;
  final String filePath;
  final String? imagePath;
  final String? fileChecksum;
  final bool hasCustomMetadata;
  const Song({
    required this.id,
    required this.title,
    required this.duration,
    required this.filePath,
    this.imagePath,
    this.fileChecksum,
    required this.hasCustomMetadata,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['duration'] = Variable<int>(duration);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || fileChecksum != null) {
      map['file_checksum'] = Variable<String>(fileChecksum);
    }
    map['has_custom_metadata'] = Variable<bool>(hasCustomMetadata);
    return map;
  }

  SongsCompanion toCompanion(bool nullToAbsent) {
    return SongsCompanion(
      id: Value(id),
      title: Value(title),
      duration: Value(duration),
      filePath: Value(filePath),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      fileChecksum: fileChecksum == null && nullToAbsent
          ? const Value.absent()
          : Value(fileChecksum),
      hasCustomMetadata: Value(hasCustomMetadata),
    );
  }

  factory Song.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Song(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      duration: serializer.fromJson<int>(json['duration']),
      filePath: serializer.fromJson<String>(json['filePath']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      fileChecksum: serializer.fromJson<String?>(json['fileChecksum']),
      hasCustomMetadata: serializer.fromJson<bool>(json['hasCustomMetadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'duration': serializer.toJson<int>(duration),
      'filePath': serializer.toJson<String>(filePath),
      'imagePath': serializer.toJson<String?>(imagePath),
      'fileChecksum': serializer.toJson<String?>(fileChecksum),
      'hasCustomMetadata': serializer.toJson<bool>(hasCustomMetadata),
    };
  }

  Song copyWith({
    int? id,
    String? title,
    int? duration,
    String? filePath,
    Value<String?> imagePath = const Value.absent(),
    Value<String?> fileChecksum = const Value.absent(),
    bool? hasCustomMetadata,
  }) => Song(
    id: id ?? this.id,
    title: title ?? this.title,
    duration: duration ?? this.duration,
    filePath: filePath ?? this.filePath,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    fileChecksum: fileChecksum.present ? fileChecksum.value : this.fileChecksum,
    hasCustomMetadata: hasCustomMetadata ?? this.hasCustomMetadata,
  );
  Song copyWithCompanion(SongsCompanion data) {
    return Song(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      duration: data.duration.present ? data.duration.value : this.duration,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      fileChecksum: data.fileChecksum.present
          ? data.fileChecksum.value
          : this.fileChecksum,
      hasCustomMetadata: data.hasCustomMetadata.present
          ? data.hasCustomMetadata.value
          : this.hasCustomMetadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Song(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('duration: $duration, ')
          ..write('filePath: $filePath, ')
          ..write('imagePath: $imagePath, ')
          ..write('fileChecksum: $fileChecksum, ')
          ..write('hasCustomMetadata: $hasCustomMetadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    duration,
    filePath,
    imagePath,
    fileChecksum,
    hasCustomMetadata,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Song &&
          other.id == this.id &&
          other.title == this.title &&
          other.duration == this.duration &&
          other.filePath == this.filePath &&
          other.imagePath == this.imagePath &&
          other.fileChecksum == this.fileChecksum &&
          other.hasCustomMetadata == this.hasCustomMetadata);
}

class SongsCompanion extends UpdateCompanion<Song> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> duration;
  final Value<String> filePath;
  final Value<String?> imagePath;
  final Value<String?> fileChecksum;
  final Value<bool> hasCustomMetadata;
  const SongsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.duration = const Value.absent(),
    this.filePath = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.fileChecksum = const Value.absent(),
    this.hasCustomMetadata = const Value.absent(),
  });
  SongsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int duration,
    required String filePath,
    this.imagePath = const Value.absent(),
    this.fileChecksum = const Value.absent(),
    this.hasCustomMetadata = const Value.absent(),
  }) : title = Value(title),
       duration = Value(duration),
       filePath = Value(filePath);
  static Insertable<Song> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? duration,
    Expression<String>? filePath,
    Expression<String>? imagePath,
    Expression<String>? fileChecksum,
    Expression<bool>? hasCustomMetadata,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (duration != null) 'duration': duration,
      if (filePath != null) 'file_path': filePath,
      if (imagePath != null) 'image_path': imagePath,
      if (fileChecksum != null) 'file_checksum': fileChecksum,
      if (hasCustomMetadata != null) 'has_custom_metadata': hasCustomMetadata,
    });
  }

  SongsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int>? duration,
    Value<String>? filePath,
    Value<String?>? imagePath,
    Value<String?>? fileChecksum,
    Value<bool>? hasCustomMetadata,
  }) {
    return SongsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
      imagePath: imagePath ?? this.imagePath,
      fileChecksum: fileChecksum ?? this.fileChecksum,
      hasCustomMetadata: hasCustomMetadata ?? this.hasCustomMetadata,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (fileChecksum.present) {
      map['file_checksum'] = Variable<String>(fileChecksum.value);
    }
    if (hasCustomMetadata.present) {
      map['has_custom_metadata'] = Variable<bool>(hasCustomMetadata.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('duration: $duration, ')
          ..write('filePath: $filePath, ')
          ..write('imagePath: $imagePath, ')
          ..write('fileChecksum: $fileChecksum, ')
          ..write('hasCustomMetadata: $hasCustomMetadata')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SongsTable songs = $SongsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [songs];
}

typedef $$SongsTableCreateCompanionBuilder =
    SongsCompanion Function({
      Value<int> id,
      required String title,
      required int duration,
      required String filePath,
      Value<String?> imagePath,
      Value<String?> fileChecksum,
      Value<bool> hasCustomMetadata,
    });
typedef $$SongsTableUpdateCompanionBuilder =
    SongsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<int> duration,
      Value<String> filePath,
      Value<String?> imagePath,
      Value<String?> fileChecksum,
      Value<bool> hasCustomMetadata,
    });

class $$SongsTableFilterComposer extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileChecksum => $composableBuilder(
    column: $table.fileChecksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasCustomMetadata => $composableBuilder(
    column: $table.hasCustomMetadata,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SongsTableOrderingComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileChecksum => $composableBuilder(
    column: $table.fileChecksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasCustomMetadata => $composableBuilder(
    column: $table.hasCustomMetadata,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get fileChecksum => $composableBuilder(
    column: $table.fileChecksum,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasCustomMetadata => $composableBuilder(
    column: $table.hasCustomMetadata,
    builder: (column) => column,
  );
}

class $$SongsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongsTable,
          Song,
          $$SongsTableFilterComposer,
          $$SongsTableOrderingComposer,
          $$SongsTableAnnotationComposer,
          $$SongsTableCreateCompanionBuilder,
          $$SongsTableUpdateCompanionBuilder,
          (Song, BaseReferences<_$AppDatabase, $SongsTable, Song>),
          Song,
          PrefetchHooks Function()
        > {
  $$SongsTableTableManager(_$AppDatabase db, $SongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> fileChecksum = const Value.absent(),
                Value<bool> hasCustomMetadata = const Value.absent(),
              }) => SongsCompanion(
                id: id,
                title: title,
                duration: duration,
                filePath: filePath,
                imagePath: imagePath,
                fileChecksum: fileChecksum,
                hasCustomMetadata: hasCustomMetadata,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required int duration,
                required String filePath,
                Value<String?> imagePath = const Value.absent(),
                Value<String?> fileChecksum = const Value.absent(),
                Value<bool> hasCustomMetadata = const Value.absent(),
              }) => SongsCompanion.insert(
                id: id,
                title: title,
                duration: duration,
                filePath: filePath,
                imagePath: imagePath,
                fileChecksum: fileChecksum,
                hasCustomMetadata: hasCustomMetadata,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SongsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongsTable,
      Song,
      $$SongsTableFilterComposer,
      $$SongsTableOrderingComposer,
      $$SongsTableAnnotationComposer,
      $$SongsTableCreateCompanionBuilder,
      $$SongsTableUpdateCompanionBuilder,
      (Song, BaseReferences<_$AppDatabase, $SongsTable, Song>),
      Song,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db, _db.songs);
}
