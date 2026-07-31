// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VocabularyTableTable extends VocabularyTable
    with TableInfo<$VocabularyTableTable, VocabularyTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VocabularyTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  @override
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
    'term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _definitionMeta = const VerificationMeta(
    'definition',
  );
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
    'definition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneticMeta = const VerificationMeta(
    'phonetic',
  );
  @override
  late final GeneratedColumn<String> phonetic = GeneratedColumn<String>(
    'phonetic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partOfSpeechMeta = const VerificationMeta(
    'partOfSpeech',
  );
  @override
  late final GeneratedColumn<String> partOfSpeech = GeneratedColumn<String>(
    'part_of_speech',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exampleSentenceMeta = const VerificationMeta(
    'exampleSentence',
  );
  @override
  late final GeneratedColumn<String> exampleSentence = GeneratedColumn<String>(
    'example_sentence',
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
  static const VerificationMeta _catalogIdMeta = const VerificationMeta(
    'catalogId',
  );
  @override
  late final GeneratedColumn<String> catalogId = GeneratedColumn<String>(
    'catalog_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    term,
    definition,
    language,
    phonetic,
    partOfSpeech,
    exampleSentence,
    createdAt,
    catalogId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vocabulary_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<VocabularyTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('term')) {
      context.handle(
        _termMeta,
        term.isAcceptableOrUnknown(data['term']!, _termMeta),
      );
    } else if (isInserting) {
      context.missing(_termMeta);
    }
    if (data.containsKey('definition')) {
      context.handle(
        _definitionMeta,
        definition.isAcceptableOrUnknown(data['definition']!, _definitionMeta),
      );
    } else if (isInserting) {
      context.missing(_definitionMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('phonetic')) {
      context.handle(
        _phoneticMeta,
        phonetic.isAcceptableOrUnknown(data['phonetic']!, _phoneticMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneticMeta);
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
        _partOfSpeechMeta,
        partOfSpeech.isAcceptableOrUnknown(
          data['part_of_speech']!,
          _partOfSpeechMeta,
        ),
      );
    }
    if (data.containsKey('example_sentence')) {
      context.handle(
        _exampleSentenceMeta,
        exampleSentence.isAcceptableOrUnknown(
          data['example_sentence']!,
          _exampleSentenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exampleSentenceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('catalog_id')) {
      context.handle(
        _catalogIdMeta,
        catalogId.isAcceptableOrUnknown(data['catalog_id']!, _catalogIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VocabularyTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VocabularyTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      term: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term'],
      )!,
      definition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      phonetic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phonetic'],
      )!,
      partOfSpeech: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_of_speech'],
      ),
      exampleSentence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_sentence'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      catalogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_id'],
      ),
    );
  }

  @override
  $VocabularyTableTable createAlias(String alias) {
    return $VocabularyTableTable(attachedDatabase, alias);
  }
}

class VocabularyTableData extends DataClass
    implements Insertable<VocabularyTableData> {
  /// Khóa chính, tự tăng.
  final int id;

  /// Từ tiếng Anh cần học — mặt trước của thẻ.
  final String term;

  /// Nghĩa tiếng Việt — mặt sau của thẻ.
  final String definition;

  /// Ngôn ngữ của [term]. Hiện cố định `'en'` — app chỉ học tiếng Anh, UI/
  /// [definition] luôn tiếng Việt. Không tách `termLanguage`/
  /// `definitionLanguage` trừ khi thật sự cần hỗ trợ nhiều cặp ngôn ngữ.
  final String language;

  /// Phiên âm IPA, vd `/ɪˈfem.ər.əl/` — bắt buộc để người học đọc đúng.
  final String phonetic;

  /// Từ loại (noun/verb/adj/adv...). Nullable — không phải nguồn dữ liệu
  /// nào cũng xác định được từ loại rõ ràng (vd import tự động từ điển),
  /// UI cần tự xử lý khi thiếu (không hiển thị thay vì hiển thị rỗng).
  final String? partOfSpeech;

  /// Câu ví dụ có dùng [term] — cho ngữ cảnh, tăng hiệu quả ghi nhớ SRS.
  final String exampleSentence;

  /// Thời điểm từ được thêm vào — phục vụ audit/sort, không dùng cho SRS.
  final DateTime createdAt;

  /// ID ổn định của từ trong catalog remote (vd `"travel-001"`), `null`
  /// nếu từ được nhập tay/seed cục bộ, không đến từ catalog. Dùng để
  /// match lại đúng row khi đồng bộ lại một chủ đề đã tải — tránh tạo
  /// trùng, giữ nguyên tiến độ SRS đã có. Thêm ở schema v3.
  final String? catalogId;
  const VocabularyTableData({
    required this.id,
    required this.term,
    required this.definition,
    required this.language,
    required this.phonetic,
    this.partOfSpeech,
    required this.exampleSentence,
    required this.createdAt,
    this.catalogId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['term'] = Variable<String>(term);
    map['definition'] = Variable<String>(definition);
    map['language'] = Variable<String>(language);
    map['phonetic'] = Variable<String>(phonetic);
    if (!nullToAbsent || partOfSpeech != null) {
      map['part_of_speech'] = Variable<String>(partOfSpeech);
    }
    map['example_sentence'] = Variable<String>(exampleSentence);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || catalogId != null) {
      map['catalog_id'] = Variable<String>(catalogId);
    }
    return map;
  }

  VocabularyTableCompanion toCompanion(bool nullToAbsent) {
    return VocabularyTableCompanion(
      id: Value(id),
      term: Value(term),
      definition: Value(definition),
      language: Value(language),
      phonetic: Value(phonetic),
      partOfSpeech: partOfSpeech == null && nullToAbsent
          ? const Value.absent()
          : Value(partOfSpeech),
      exampleSentence: Value(exampleSentence),
      createdAt: Value(createdAt),
      catalogId: catalogId == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogId),
    );
  }

  factory VocabularyTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VocabularyTableData(
      id: serializer.fromJson<int>(json['id']),
      term: serializer.fromJson<String>(json['term']),
      definition: serializer.fromJson<String>(json['definition']),
      language: serializer.fromJson<String>(json['language']),
      phonetic: serializer.fromJson<String>(json['phonetic']),
      partOfSpeech: serializer.fromJson<String?>(json['partOfSpeech']),
      exampleSentence: serializer.fromJson<String>(json['exampleSentence']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      catalogId: serializer.fromJson<String?>(json['catalogId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'term': serializer.toJson<String>(term),
      'definition': serializer.toJson<String>(definition),
      'language': serializer.toJson<String>(language),
      'phonetic': serializer.toJson<String>(phonetic),
      'partOfSpeech': serializer.toJson<String?>(partOfSpeech),
      'exampleSentence': serializer.toJson<String>(exampleSentence),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'catalogId': serializer.toJson<String?>(catalogId),
    };
  }

  VocabularyTableData copyWith({
    int? id,
    String? term,
    String? definition,
    String? language,
    String? phonetic,
    Value<String?> partOfSpeech = const Value.absent(),
    String? exampleSentence,
    DateTime? createdAt,
    Value<String?> catalogId = const Value.absent(),
  }) => VocabularyTableData(
    id: id ?? this.id,
    term: term ?? this.term,
    definition: definition ?? this.definition,
    language: language ?? this.language,
    phonetic: phonetic ?? this.phonetic,
    partOfSpeech: partOfSpeech.present ? partOfSpeech.value : this.partOfSpeech,
    exampleSentence: exampleSentence ?? this.exampleSentence,
    createdAt: createdAt ?? this.createdAt,
    catalogId: catalogId.present ? catalogId.value : this.catalogId,
  );
  VocabularyTableData copyWithCompanion(VocabularyTableCompanion data) {
    return VocabularyTableData(
      id: data.id.present ? data.id.value : this.id,
      term: data.term.present ? data.term.value : this.term,
      definition: data.definition.present
          ? data.definition.value
          : this.definition,
      language: data.language.present ? data.language.value : this.language,
      phonetic: data.phonetic.present ? data.phonetic.value : this.phonetic,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
      exampleSentence: data.exampleSentence.present
          ? data.exampleSentence.value
          : this.exampleSentence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      catalogId: data.catalogId.present ? data.catalogId.value : this.catalogId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VocabularyTableData(')
          ..write('id: $id, ')
          ..write('term: $term, ')
          ..write('definition: $definition, ')
          ..write('language: $language, ')
          ..write('phonetic: $phonetic, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('exampleSentence: $exampleSentence, ')
          ..write('createdAt: $createdAt, ')
          ..write('catalogId: $catalogId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    term,
    definition,
    language,
    phonetic,
    partOfSpeech,
    exampleSentence,
    createdAt,
    catalogId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VocabularyTableData &&
          other.id == this.id &&
          other.term == this.term &&
          other.definition == this.definition &&
          other.language == this.language &&
          other.phonetic == this.phonetic &&
          other.partOfSpeech == this.partOfSpeech &&
          other.exampleSentence == this.exampleSentence &&
          other.createdAt == this.createdAt &&
          other.catalogId == this.catalogId);
}

class VocabularyTableCompanion extends UpdateCompanion<VocabularyTableData> {
  final Value<int> id;
  final Value<String> term;
  final Value<String> definition;
  final Value<String> language;
  final Value<String> phonetic;
  final Value<String?> partOfSpeech;
  final Value<String> exampleSentence;
  final Value<DateTime> createdAt;
  final Value<String?> catalogId;
  const VocabularyTableCompanion({
    this.id = const Value.absent(),
    this.term = const Value.absent(),
    this.definition = const Value.absent(),
    this.language = const Value.absent(),
    this.phonetic = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.exampleSentence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.catalogId = const Value.absent(),
  });
  VocabularyTableCompanion.insert({
    this.id = const Value.absent(),
    required String term,
    required String definition,
    required String language,
    required String phonetic,
    this.partOfSpeech = const Value.absent(),
    required String exampleSentence,
    required DateTime createdAt,
    this.catalogId = const Value.absent(),
  }) : term = Value(term),
       definition = Value(definition),
       language = Value(language),
       phonetic = Value(phonetic),
       exampleSentence = Value(exampleSentence),
       createdAt = Value(createdAt);
  static Insertable<VocabularyTableData> custom({
    Expression<int>? id,
    Expression<String>? term,
    Expression<String>? definition,
    Expression<String>? language,
    Expression<String>? phonetic,
    Expression<String>? partOfSpeech,
    Expression<String>? exampleSentence,
    Expression<DateTime>? createdAt,
    Expression<String>? catalogId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (term != null) 'term': term,
      if (definition != null) 'definition': definition,
      if (language != null) 'language': language,
      if (phonetic != null) 'phonetic': phonetic,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (exampleSentence != null) 'example_sentence': exampleSentence,
      if (createdAt != null) 'created_at': createdAt,
      if (catalogId != null) 'catalog_id': catalogId,
    });
  }

  VocabularyTableCompanion copyWith({
    Value<int>? id,
    Value<String>? term,
    Value<String>? definition,
    Value<String>? language,
    Value<String>? phonetic,
    Value<String?>? partOfSpeech,
    Value<String>? exampleSentence,
    Value<DateTime>? createdAt,
    Value<String?>? catalogId,
  }) {
    return VocabularyTableCompanion(
      id: id ?? this.id,
      term: term ?? this.term,
      definition: definition ?? this.definition,
      language: language ?? this.language,
      phonetic: phonetic ?? this.phonetic,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      createdAt: createdAt ?? this.createdAt,
      catalogId: catalogId ?? this.catalogId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (phonetic.present) {
      map['phonetic'] = Variable<String>(phonetic.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (exampleSentence.present) {
      map['example_sentence'] = Variable<String>(exampleSentence.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (catalogId.present) {
      map['catalog_id'] = Variable<String>(catalogId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VocabularyTableCompanion(')
          ..write('id: $id, ')
          ..write('term: $term, ')
          ..write('definition: $definition, ')
          ..write('language: $language, ')
          ..write('phonetic: $phonetic, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('exampleSentence: $exampleSentence, ')
          ..write('createdAt: $createdAt, ')
          ..write('catalogId: $catalogId')
          ..write(')'))
        .toString();
  }
}

class $ProgressTableTable extends ProgressTable
    with TableInfo<$ProgressTableTable, ProgressTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgressTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _vocabIdMeta = const VerificationMeta(
    'vocabId',
  );
  @override
  late final GeneratedColumn<int> vocabId = GeneratedColumn<int>(
    'vocab_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vocabulary_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _intervalMeta = const VerificationMeta(
    'interval',
  );
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
    'interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _easeFactorMeta = const VerificationMeta(
    'easeFactor',
  );
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
    'ease_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _learningStepMeta = const VerificationMeta(
    'learningStep',
  );
  @override
  late final GeneratedColumn<int> learningStep = GeneratedColumn<int>(
    'learning_step',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextReviewMeta = const VerificationMeta(
    'nextReview',
  );
  @override
  late final GeneratedColumn<DateTime> nextReview = GeneratedColumn<DateTime>(
    'next_review',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastReviewMeta = const VerificationMeta(
    'lastReview',
  );
  @override
  late final GeneratedColumn<DateTime> lastReview = GeneratedColumn<DateTime>(
    'last_review',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vocabId,
    interval,
    easeFactor,
    reps,
    lapses,
    learningStep,
    nextReview,
    lastReview,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progress_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgressTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vocab_id')) {
      context.handle(
        _vocabIdMeta,
        vocabId.isAcceptableOrUnknown(data['vocab_id']!, _vocabIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vocabIdMeta);
    }
    if (data.containsKey('interval')) {
      context.handle(
        _intervalMeta,
        interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta),
      );
    } else if (isInserting) {
      context.missing(_intervalMeta);
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
        _easeFactorMeta,
        easeFactor.isAcceptableOrUnknown(data['ease_factor']!, _easeFactorMeta),
      );
    } else if (isInserting) {
      context.missing(_easeFactorMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    } else if (isInserting) {
      context.missing(_lapsesMeta);
    }
    if (data.containsKey('learning_step')) {
      context.handle(
        _learningStepMeta,
        learningStep.isAcceptableOrUnknown(
          data['learning_step']!,
          _learningStepMeta,
        ),
      );
    }
    if (data.containsKey('next_review')) {
      context.handle(
        _nextReviewMeta,
        nextReview.isAcceptableOrUnknown(data['next_review']!, _nextReviewMeta),
      );
    } else if (isInserting) {
      context.missing(_nextReviewMeta);
    }
    if (data.containsKey('last_review')) {
      context.handle(
        _lastReviewMeta,
        lastReview.isAcceptableOrUnknown(data['last_review']!, _lastReviewMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {vocabId},
  ];
  @override
  ProgressTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vocabId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vocab_id'],
      )!,
      interval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval'],
      )!,
      easeFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease_factor'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      learningStep: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}learning_step'],
      ),
      nextReview: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review'],
      )!,
      lastReview: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_review'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProgressTableTable createAlias(String alias) {
    return $ProgressTableTable(attachedDatabase, alias);
  }
}

class ProgressTableData extends DataClass
    implements Insertable<ProgressTableData> {
  /// Khóa chính, tự tăng.
  final int id;

  /// FK → `VocabularyTable.id`. Xóa từ vựng sẽ xóa luôn dòng tiến độ này
  /// (`CASCADE`) — không có soft-delete, mất lịch sử ôn tập của từ đó.
  final int vocabId;

  /// Khoảng cách tới lần ôn tiếp theo, đơn vị NGÀY. Xem ADR-010 (SM-2).
  final int interval;

  /// Hệ số dễ nhớ SM-2 — khởi tạo 2.5, sàn 1.3 (ADR-010).
  final double easeFactor;

  /// Số lần trả lời đúng liên tiếp kể từ lần lapse gần nhất. Reset về 0
  /// khi rating = Again.
  final int reps;

  /// Tổng số lần trả lời sai (Again) trong suốt lịch sử của từ này —
  /// không reset, chỉ tăng.
  final int lapses;

  /// `null` = đã graduate, ở review phase (`interval` tính bằng ngày).
  /// `0, 1, ...` = đang ở learning/relearning phase, index vào
  /// `learningStepsMinutes` (phút) — xem ADR-011. Thêm ở schema v2.
  final int? learningStep;

  /// Mốc thời gian thẻ này đến hạn ôn lại tiếp theo.
  final DateTime nextReview;

  /// Lần ôn gần nhất. `null` nghĩa là thẻ chưa từng được ôn (vẫn ở trạng
  /// thái mới, dù đã có dòng progress).
  final DateTime? lastReview;

  /// Thời điểm dòng tiến độ này được tạo lần đầu.
  final DateTime createdAt;

  /// Thời điểm dòng tiến độ này được ghi đè lần gần nhất (mỗi lần
  /// `recordAnswer`).
  final DateTime updatedAt;
  const ProgressTableData({
    required this.id,
    required this.vocabId,
    required this.interval,
    required this.easeFactor,
    required this.reps,
    required this.lapses,
    this.learningStep,
    required this.nextReview,
    this.lastReview,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vocab_id'] = Variable<int>(vocabId);
    map['interval'] = Variable<int>(interval);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['reps'] = Variable<int>(reps);
    map['lapses'] = Variable<int>(lapses);
    if (!nullToAbsent || learningStep != null) {
      map['learning_step'] = Variable<int>(learningStep);
    }
    map['next_review'] = Variable<DateTime>(nextReview);
    if (!nullToAbsent || lastReview != null) {
      map['last_review'] = Variable<DateTime>(lastReview);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProgressTableCompanion toCompanion(bool nullToAbsent) {
    return ProgressTableCompanion(
      id: Value(id),
      vocabId: Value(vocabId),
      interval: Value(interval),
      easeFactor: Value(easeFactor),
      reps: Value(reps),
      lapses: Value(lapses),
      learningStep: learningStep == null && nullToAbsent
          ? const Value.absent()
          : Value(learningStep),
      nextReview: Value(nextReview),
      lastReview: lastReview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReview),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProgressTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressTableData(
      id: serializer.fromJson<int>(json['id']),
      vocabId: serializer.fromJson<int>(json['vocabId']),
      interval: serializer.fromJson<int>(json['interval']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      reps: serializer.fromJson<int>(json['reps']),
      lapses: serializer.fromJson<int>(json['lapses']),
      learningStep: serializer.fromJson<int?>(json['learningStep']),
      nextReview: serializer.fromJson<DateTime>(json['nextReview']),
      lastReview: serializer.fromJson<DateTime?>(json['lastReview']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vocabId': serializer.toJson<int>(vocabId),
      'interval': serializer.toJson<int>(interval),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'reps': serializer.toJson<int>(reps),
      'lapses': serializer.toJson<int>(lapses),
      'learningStep': serializer.toJson<int?>(learningStep),
      'nextReview': serializer.toJson<DateTime>(nextReview),
      'lastReview': serializer.toJson<DateTime?>(lastReview),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProgressTableData copyWith({
    int? id,
    int? vocabId,
    int? interval,
    double? easeFactor,
    int? reps,
    int? lapses,
    Value<int?> learningStep = const Value.absent(),
    DateTime? nextReview,
    Value<DateTime?> lastReview = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ProgressTableData(
    id: id ?? this.id,
    vocabId: vocabId ?? this.vocabId,
    interval: interval ?? this.interval,
    easeFactor: easeFactor ?? this.easeFactor,
    reps: reps ?? this.reps,
    lapses: lapses ?? this.lapses,
    learningStep: learningStep.present ? learningStep.value : this.learningStep,
    nextReview: nextReview ?? this.nextReview,
    lastReview: lastReview.present ? lastReview.value : this.lastReview,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProgressTableData copyWithCompanion(ProgressTableCompanion data) {
    return ProgressTableData(
      id: data.id.present ? data.id.value : this.id,
      vocabId: data.vocabId.present ? data.vocabId.value : this.vocabId,
      interval: data.interval.present ? data.interval.value : this.interval,
      easeFactor: data.easeFactor.present
          ? data.easeFactor.value
          : this.easeFactor,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      learningStep: data.learningStep.present
          ? data.learningStep.value
          : this.learningStep,
      nextReview: data.nextReview.present
          ? data.nextReview.value
          : this.nextReview,
      lastReview: data.lastReview.present
          ? data.lastReview.value
          : this.lastReview,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressTableData(')
          ..write('id: $id, ')
          ..write('vocabId: $vocabId, ')
          ..write('interval: $interval, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('learningStep: $learningStep, ')
          ..write('nextReview: $nextReview, ')
          ..write('lastReview: $lastReview, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vocabId,
    interval,
    easeFactor,
    reps,
    lapses,
    learningStep,
    nextReview,
    lastReview,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressTableData &&
          other.id == this.id &&
          other.vocabId == this.vocabId &&
          other.interval == this.interval &&
          other.easeFactor == this.easeFactor &&
          other.reps == this.reps &&
          other.lapses == this.lapses &&
          other.learningStep == this.learningStep &&
          other.nextReview == this.nextReview &&
          other.lastReview == this.lastReview &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProgressTableCompanion extends UpdateCompanion<ProgressTableData> {
  final Value<int> id;
  final Value<int> vocabId;
  final Value<int> interval;
  final Value<double> easeFactor;
  final Value<int> reps;
  final Value<int> lapses;
  final Value<int?> learningStep;
  final Value<DateTime> nextReview;
  final Value<DateTime?> lastReview;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ProgressTableCompanion({
    this.id = const Value.absent(),
    this.vocabId = const Value.absent(),
    this.interval = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.learningStep = const Value.absent(),
    this.nextReview = const Value.absent(),
    this.lastReview = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProgressTableCompanion.insert({
    this.id = const Value.absent(),
    required int vocabId,
    required int interval,
    required double easeFactor,
    required int reps,
    required int lapses,
    this.learningStep = const Value.absent(),
    required DateTime nextReview,
    this.lastReview = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : vocabId = Value(vocabId),
       interval = Value(interval),
       easeFactor = Value(easeFactor),
       reps = Value(reps),
       lapses = Value(lapses),
       nextReview = Value(nextReview),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProgressTableData> custom({
    Expression<int>? id,
    Expression<int>? vocabId,
    Expression<int>? interval,
    Expression<double>? easeFactor,
    Expression<int>? reps,
    Expression<int>? lapses,
    Expression<int>? learningStep,
    Expression<DateTime>? nextReview,
    Expression<DateTime>? lastReview,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vocabId != null) 'vocab_id': vocabId,
      if (interval != null) 'interval': interval,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (reps != null) 'reps': reps,
      if (lapses != null) 'lapses': lapses,
      if (learningStep != null) 'learning_step': learningStep,
      if (nextReview != null) 'next_review': nextReview,
      if (lastReview != null) 'last_review': lastReview,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProgressTableCompanion copyWith({
    Value<int>? id,
    Value<int>? vocabId,
    Value<int>? interval,
    Value<double>? easeFactor,
    Value<int>? reps,
    Value<int>? lapses,
    Value<int?>? learningStep,
    Value<DateTime>? nextReview,
    Value<DateTime?>? lastReview,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ProgressTableCompanion(
      id: id ?? this.id,
      vocabId: vocabId ?? this.vocabId,
      interval: interval ?? this.interval,
      easeFactor: easeFactor ?? this.easeFactor,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      learningStep: learningStep ?? this.learningStep,
      nextReview: nextReview ?? this.nextReview,
      lastReview: lastReview ?? this.lastReview,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vocabId.present) {
      map['vocab_id'] = Variable<int>(vocabId.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (learningStep.present) {
      map['learning_step'] = Variable<int>(learningStep.value);
    }
    if (nextReview.present) {
      map['next_review'] = Variable<DateTime>(nextReview.value);
    }
    if (lastReview.present) {
      map['last_review'] = Variable<DateTime>(lastReview.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgressTableCompanion(')
          ..write('id: $id, ')
          ..write('vocabId: $vocabId, ')
          ..write('interval: $interval, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('learningStep: $learningStep, ')
          ..write('nextReview: $nextReview, ')
          ..write('lastReview: $lastReview, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DownloadedTopicsTableTable extends DownloadedTopicsTable
    with TableInfo<$DownloadedTopicsTableTable, DownloadedTopicsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadedTopicsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
    'topic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadedVersionMeta = const VerificationMeta(
    'downloadedVersion',
  );
  @override
  late final GeneratedColumn<int> downloadedVersion = GeneratedColumn<int>(
    'downloaded_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    topicId,
    downloadedVersion,
    downloadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloaded_topics_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadedTopicsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('downloaded_version')) {
      context.handle(
        _downloadedVersionMeta,
        downloadedVersion.isAcceptableOrUnknown(
          data['downloaded_version']!,
          _downloadedVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedVersionMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {topicId};
  @override
  DownloadedTopicsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadedTopicsTableData(
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_id'],
      )!,
      downloadedVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_version'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
    );
  }

  @override
  $DownloadedTopicsTableTable createAlias(String alias) {
    return $DownloadedTopicsTableTable(attachedDatabase, alias);
  }
}

class DownloadedTopicsTableData extends DataClass
    implements Insertable<DownloadedTopicsTableData> {
  /// ID chủ đề, khớp `Topic.id` trong catalog (vd `"travel"`).
  final String topicId;

  /// Version của chủ đề tại thời điểm tải — so với version hiện tại trên
  /// remote để biết có cần đồng bộ lại không.
  final int downloadedVersion;
  final DateTime downloadedAt;
  const DownloadedTopicsTableData({
    required this.topicId,
    required this.downloadedVersion,
    required this.downloadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['topic_id'] = Variable<String>(topicId);
    map['downloaded_version'] = Variable<int>(downloadedVersion);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    return map;
  }

  DownloadedTopicsTableCompanion toCompanion(bool nullToAbsent) {
    return DownloadedTopicsTableCompanion(
      topicId: Value(topicId),
      downloadedVersion: Value(downloadedVersion),
      downloadedAt: Value(downloadedAt),
    );
  }

  factory DownloadedTopicsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadedTopicsTableData(
      topicId: serializer.fromJson<String>(json['topicId']),
      downloadedVersion: serializer.fromJson<int>(json['downloadedVersion']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'topicId': serializer.toJson<String>(topicId),
      'downloadedVersion': serializer.toJson<int>(downloadedVersion),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
    };
  }

  DownloadedTopicsTableData copyWith({
    String? topicId,
    int? downloadedVersion,
    DateTime? downloadedAt,
  }) => DownloadedTopicsTableData(
    topicId: topicId ?? this.topicId,
    downloadedVersion: downloadedVersion ?? this.downloadedVersion,
    downloadedAt: downloadedAt ?? this.downloadedAt,
  );
  DownloadedTopicsTableData copyWithCompanion(
    DownloadedTopicsTableCompanion data,
  ) {
    return DownloadedTopicsTableData(
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      downloadedVersion: data.downloadedVersion.present
          ? data.downloadedVersion.value
          : this.downloadedVersion,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedTopicsTableData(')
          ..write('topicId: $topicId, ')
          ..write('downloadedVersion: $downloadedVersion, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(topicId, downloadedVersion, downloadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadedTopicsTableData &&
          other.topicId == this.topicId &&
          other.downloadedVersion == this.downloadedVersion &&
          other.downloadedAt == this.downloadedAt);
}

class DownloadedTopicsTableCompanion
    extends UpdateCompanion<DownloadedTopicsTableData> {
  final Value<String> topicId;
  final Value<int> downloadedVersion;
  final Value<DateTime> downloadedAt;
  final Value<int> rowid;
  const DownloadedTopicsTableCompanion({
    this.topicId = const Value.absent(),
    this.downloadedVersion = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadedTopicsTableCompanion.insert({
    required String topicId,
    required int downloadedVersion,
    required DateTime downloadedAt,
    this.rowid = const Value.absent(),
  }) : topicId = Value(topicId),
       downloadedVersion = Value(downloadedVersion),
       downloadedAt = Value(downloadedAt);
  static Insertable<DownloadedTopicsTableData> custom({
    Expression<String>? topicId,
    Expression<int>? downloadedVersion,
    Expression<DateTime>? downloadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (topicId != null) 'topic_id': topicId,
      if (downloadedVersion != null) 'downloaded_version': downloadedVersion,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadedTopicsTableCompanion copyWith({
    Value<String>? topicId,
    Value<int>? downloadedVersion,
    Value<DateTime>? downloadedAt,
    Value<int>? rowid,
  }) {
    return DownloadedTopicsTableCompanion(
      topicId: topicId ?? this.topicId,
      downloadedVersion: downloadedVersion ?? this.downloadedVersion,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (downloadedVersion.present) {
      map['downloaded_version'] = Variable<int>(downloadedVersion.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedTopicsTableCompanion(')
          ..write('topicId: $topicId, ')
          ..write('downloadedVersion: $downloadedVersion, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VocabularyTableTable vocabularyTable = $VocabularyTableTable(
    this,
  );
  late final $ProgressTableTable progressTable = $ProgressTableTable(this);
  late final $DownloadedTopicsTableTable downloadedTopicsTable =
      $DownloadedTopicsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vocabularyTable,
    progressTable,
    downloadedTopicsTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vocabulary_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('progress_table', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$VocabularyTableTableCreateCompanionBuilder =
    VocabularyTableCompanion Function({
      Value<int> id,
      required String term,
      required String definition,
      required String language,
      required String phonetic,
      Value<String?> partOfSpeech,
      required String exampleSentence,
      required DateTime createdAt,
      Value<String?> catalogId,
    });
typedef $$VocabularyTableTableUpdateCompanionBuilder =
    VocabularyTableCompanion Function({
      Value<int> id,
      Value<String> term,
      Value<String> definition,
      Value<String> language,
      Value<String> phonetic,
      Value<String?> partOfSpeech,
      Value<String> exampleSentence,
      Value<DateTime> createdAt,
      Value<String?> catalogId,
    });

final class $$VocabularyTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $VocabularyTableTable,
          VocabularyTableData
        > {
  $$VocabularyTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ProgressTableTable, List<ProgressTableData>>
  _progressTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.progressTable,
    aliasName: 'vocabulary_table__id__progress_table__vocab_id',
  );

  $$ProgressTableTableProcessedTableManager get progressTableRefs {
    final manager = $$ProgressTableTableTableManager(
      $_db,
      $_db.progressTable,
    ).filter((f) => f.vocabId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_progressTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VocabularyTableTableFilterComposer
    extends Composer<_$AppDatabase, $VocabularyTableTable> {
  $$VocabularyTableTableFilterComposer({
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

  ColumnFilters<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phonetic => $composableBuilder(
    column: $table.phonetic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogId => $composableBuilder(
    column: $table.catalogId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> progressTableRefs(
    Expression<bool> Function($$ProgressTableTableFilterComposer f) f,
  ) {
    final $$ProgressTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.progressTable,
      getReferencedColumn: (t) => t.vocabId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgressTableTableFilterComposer(
            $db: $db,
            $table: $db.progressTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VocabularyTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VocabularyTableTable> {
  $$VocabularyTableTableOrderingComposer({
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

  ColumnOrderings<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phonetic => $composableBuilder(
    column: $table.phonetic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogId => $composableBuilder(
    column: $table.catalogId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VocabularyTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VocabularyTableTable> {
  $$VocabularyTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);

  GeneratedColumn<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get phonetic =>
      $composableBuilder(column: $table.phonetic, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get catalogId =>
      $composableBuilder(column: $table.catalogId, builder: (column) => column);

  Expression<T> progressTableRefs<T extends Object>(
    Expression<T> Function($$ProgressTableTableAnnotationComposer a) f,
  ) {
    final $$ProgressTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.progressTable,
      getReferencedColumn: (t) => t.vocabId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgressTableTableAnnotationComposer(
            $db: $db,
            $table: $db.progressTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VocabularyTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VocabularyTableTable,
          VocabularyTableData,
          $$VocabularyTableTableFilterComposer,
          $$VocabularyTableTableOrderingComposer,
          $$VocabularyTableTableAnnotationComposer,
          $$VocabularyTableTableCreateCompanionBuilder,
          $$VocabularyTableTableUpdateCompanionBuilder,
          (VocabularyTableData, $$VocabularyTableTableReferences),
          VocabularyTableData,
          PrefetchHooks Function({bool progressTableRefs})
        > {
  $$VocabularyTableTableTableManager(
    _$AppDatabase db,
    $VocabularyTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VocabularyTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VocabularyTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VocabularyTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> term = const Value.absent(),
                Value<String> definition = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> phonetic = const Value.absent(),
                Value<String?> partOfSpeech = const Value.absent(),
                Value<String> exampleSentence = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> catalogId = const Value.absent(),
              }) => VocabularyTableCompanion(
                id: id,
                term: term,
                definition: definition,
                language: language,
                phonetic: phonetic,
                partOfSpeech: partOfSpeech,
                exampleSentence: exampleSentence,
                createdAt: createdAt,
                catalogId: catalogId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String term,
                required String definition,
                required String language,
                required String phonetic,
                Value<String?> partOfSpeech = const Value.absent(),
                required String exampleSentence,
                required DateTime createdAt,
                Value<String?> catalogId = const Value.absent(),
              }) => VocabularyTableCompanion.insert(
                id: id,
                term: term,
                definition: definition,
                language: language,
                phonetic: phonetic,
                partOfSpeech: partOfSpeech,
                exampleSentence: exampleSentence,
                createdAt: createdAt,
                catalogId: catalogId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VocabularyTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({progressTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (progressTableRefs) db.progressTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (progressTableRefs)
                    await $_getPrefetchedData<
                      VocabularyTableData,
                      $VocabularyTableTable,
                      ProgressTableData
                    >(
                      currentTable: table,
                      referencedTable: $$VocabularyTableTableReferences
                          ._progressTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$VocabularyTableTableReferences(
                            db,
                            table,
                            p0,
                          ).progressTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.vocabId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VocabularyTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VocabularyTableTable,
      VocabularyTableData,
      $$VocabularyTableTableFilterComposer,
      $$VocabularyTableTableOrderingComposer,
      $$VocabularyTableTableAnnotationComposer,
      $$VocabularyTableTableCreateCompanionBuilder,
      $$VocabularyTableTableUpdateCompanionBuilder,
      (VocabularyTableData, $$VocabularyTableTableReferences),
      VocabularyTableData,
      PrefetchHooks Function({bool progressTableRefs})
    >;
typedef $$ProgressTableTableCreateCompanionBuilder =
    ProgressTableCompanion Function({
      Value<int> id,
      required int vocabId,
      required int interval,
      required double easeFactor,
      required int reps,
      required int lapses,
      Value<int?> learningStep,
      required DateTime nextReview,
      Value<DateTime?> lastReview,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$ProgressTableTableUpdateCompanionBuilder =
    ProgressTableCompanion Function({
      Value<int> id,
      Value<int> vocabId,
      Value<int> interval,
      Value<double> easeFactor,
      Value<int> reps,
      Value<int> lapses,
      Value<int?> learningStep,
      Value<DateTime> nextReview,
      Value<DateTime?> lastReview,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ProgressTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $ProgressTableTable, ProgressTableData> {
  $$ProgressTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VocabularyTableTable _vocabIdTable(_$AppDatabase db) => db
      .vocabularyTable
      .createAlias('progress_table__vocab_id__vocabulary_table__id');

  $$VocabularyTableTableProcessedTableManager get vocabId {
    final $_column = $_itemColumn<int>('vocab_id')!;

    final manager = $$VocabularyTableTableTableManager(
      $_db,
      $_db.vocabularyTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vocabIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProgressTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProgressTableTable> {
  $$ProgressTableTableFilterComposer({
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

  ColumnFilters<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get learningStep => $composableBuilder(
    column: $table.learningStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
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

  $$VocabularyTableTableFilterComposer get vocabId {
    final $$VocabularyTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabId,
      referencedTable: $db.vocabularyTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableTableFilterComposer(
            $db: $db,
            $table: $db.vocabularyTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgressTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgressTableTable> {
  $$ProgressTableTableOrderingComposer({
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

  ColumnOrderings<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get learningStep => $composableBuilder(
    column: $table.learningStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
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

  $$VocabularyTableTableOrderingComposer get vocabId {
    final $$VocabularyTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabId,
      referencedTable: $db.vocabularyTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableTableOrderingComposer(
            $db: $db,
            $table: $db.vocabularyTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgressTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgressTableTable> {
  $$ProgressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<int> get learningStep => $composableBuilder(
    column: $table.learningStep,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$VocabularyTableTableAnnotationComposer get vocabId {
    final $$VocabularyTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabId,
      referencedTable: $db.vocabularyTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableTableAnnotationComposer(
            $db: $db,
            $table: $db.vocabularyTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgressTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgressTableTable,
          ProgressTableData,
          $$ProgressTableTableFilterComposer,
          $$ProgressTableTableOrderingComposer,
          $$ProgressTableTableAnnotationComposer,
          $$ProgressTableTableCreateCompanionBuilder,
          $$ProgressTableTableUpdateCompanionBuilder,
          (ProgressTableData, $$ProgressTableTableReferences),
          ProgressTableData,
          PrefetchHooks Function({bool vocabId})
        > {
  $$ProgressTableTableTableManager(_$AppDatabase db, $ProgressTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgressTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgressTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgressTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> vocabId = const Value.absent(),
                Value<int> interval = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<int?> learningStep = const Value.absent(),
                Value<DateTime> nextReview = const Value.absent(),
                Value<DateTime?> lastReview = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProgressTableCompanion(
                id: id,
                vocabId: vocabId,
                interval: interval,
                easeFactor: easeFactor,
                reps: reps,
                lapses: lapses,
                learningStep: learningStep,
                nextReview: nextReview,
                lastReview: lastReview,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int vocabId,
                required int interval,
                required double easeFactor,
                required int reps,
                required int lapses,
                Value<int?> learningStep = const Value.absent(),
                required DateTime nextReview,
                Value<DateTime?> lastReview = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => ProgressTableCompanion.insert(
                id: id,
                vocabId: vocabId,
                interval: interval,
                easeFactor: easeFactor,
                reps: reps,
                lapses: lapses,
                learningStep: learningStep,
                nextReview: nextReview,
                lastReview: lastReview,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProgressTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vocabId = false}) {
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
                    if (vocabId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vocabId,
                                referencedTable: $$ProgressTableTableReferences
                                    ._vocabIdTable(db),
                                referencedColumn: $$ProgressTableTableReferences
                                    ._vocabIdTable(db)
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

typedef $$ProgressTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgressTableTable,
      ProgressTableData,
      $$ProgressTableTableFilterComposer,
      $$ProgressTableTableOrderingComposer,
      $$ProgressTableTableAnnotationComposer,
      $$ProgressTableTableCreateCompanionBuilder,
      $$ProgressTableTableUpdateCompanionBuilder,
      (ProgressTableData, $$ProgressTableTableReferences),
      ProgressTableData,
      PrefetchHooks Function({bool vocabId})
    >;
typedef $$DownloadedTopicsTableTableCreateCompanionBuilder =
    DownloadedTopicsTableCompanion Function({
      required String topicId,
      required int downloadedVersion,
      required DateTime downloadedAt,
      Value<int> rowid,
    });
typedef $$DownloadedTopicsTableTableUpdateCompanionBuilder =
    DownloadedTopicsTableCompanion Function({
      Value<String> topicId,
      Value<int> downloadedVersion,
      Value<DateTime> downloadedAt,
      Value<int> rowid,
    });

class $$DownloadedTopicsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadedTopicsTableTable> {
  $$DownloadedTopicsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadedVersion => $composableBuilder(
    column: $table.downloadedVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadedTopicsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadedTopicsTableTable> {
  $$DownloadedTopicsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedVersion => $composableBuilder(
    column: $table.downloadedVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadedTopicsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadedTopicsTableTable> {
  $$DownloadedTopicsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<int> get downloadedVersion => $composableBuilder(
    column: $table.downloadedVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );
}

class $$DownloadedTopicsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadedTopicsTableTable,
          DownloadedTopicsTableData,
          $$DownloadedTopicsTableTableFilterComposer,
          $$DownloadedTopicsTableTableOrderingComposer,
          $$DownloadedTopicsTableTableAnnotationComposer,
          $$DownloadedTopicsTableTableCreateCompanionBuilder,
          $$DownloadedTopicsTableTableUpdateCompanionBuilder,
          (
            DownloadedTopicsTableData,
            BaseReferences<
              _$AppDatabase,
              $DownloadedTopicsTableTable,
              DownloadedTopicsTableData
            >,
          ),
          DownloadedTopicsTableData,
          PrefetchHooks Function()
        > {
  $$DownloadedTopicsTableTableTableManager(
    _$AppDatabase db,
    $DownloadedTopicsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadedTopicsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DownloadedTopicsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DownloadedTopicsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> topicId = const Value.absent(),
                Value<int> downloadedVersion = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadedTopicsTableCompanion(
                topicId: topicId,
                downloadedVersion: downloadedVersion,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String topicId,
                required int downloadedVersion,
                required DateTime downloadedAt,
                Value<int> rowid = const Value.absent(),
              }) => DownloadedTopicsTableCompanion.insert(
                topicId: topicId,
                downloadedVersion: downloadedVersion,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadedTopicsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadedTopicsTableTable,
      DownloadedTopicsTableData,
      $$DownloadedTopicsTableTableFilterComposer,
      $$DownloadedTopicsTableTableOrderingComposer,
      $$DownloadedTopicsTableTableAnnotationComposer,
      $$DownloadedTopicsTableTableCreateCompanionBuilder,
      $$DownloadedTopicsTableTableUpdateCompanionBuilder,
      (
        DownloadedTopicsTableData,
        BaseReferences<
          _$AppDatabase,
          $DownloadedTopicsTableTable,
          DownloadedTopicsTableData
        >,
      ),
      DownloadedTopicsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VocabularyTableTableTableManager get vocabularyTable =>
      $$VocabularyTableTableTableManager(_db, _db.vocabularyTable);
  $$ProgressTableTableTableManager get progressTable =>
      $$ProgressTableTableTableManager(_db, _db.progressTable);
  $$DownloadedTopicsTableTableTableManager get downloadedTopicsTable =>
      $$DownloadedTopicsTableTableTableManager(_db, _db.downloadedTopicsTable);
}
