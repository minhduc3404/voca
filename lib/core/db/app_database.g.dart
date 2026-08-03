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
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
    'topic_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    topicId,
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
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
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
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_id'],
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

  /// ID chủ đề catalog mà từ này thuộc về (vd `"travel"`), `null` nếu từ
  /// nhập tay/không đến từ catalog. Dùng cho màn "Hôm nay" hiển thị chủ đề
  /// đang học. Backfill từ [catalogId] (cắt hậu tố `-<số>`) khi migrate v4→v5.
  /// Thêm ở schema v5.
  final String? topicId;
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
    this.topicId,
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
    if (!nullToAbsent || topicId != null) {
      map['topic_id'] = Variable<String>(topicId);
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
      topicId: topicId == null && nullToAbsent
          ? const Value.absent()
          : Value(topicId),
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
      topicId: serializer.fromJson<String?>(json['topicId']),
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
      'topicId': serializer.toJson<String?>(topicId),
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
    Value<String?> topicId = const Value.absent(),
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
    topicId: topicId.present ? topicId.value : this.topicId,
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
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
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
          ..write('catalogId: $catalogId, ')
          ..write('topicId: $topicId')
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
    topicId,
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
          other.catalogId == this.catalogId &&
          other.topicId == this.topicId);
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
  final Value<String?> topicId;
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
    this.topicId = const Value.absent(),
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
    this.topicId = const Value.absent(),
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
    Expression<String>? topicId,
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
      if (topicId != null) 'topic_id': topicId,
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
    Value<String?>? topicId,
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
      topicId: topicId ?? this.topicId,
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
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
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
          ..write('catalogId: $catalogId, ')
          ..write('topicId: $topicId')
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
  static const VerificationMeta _topicNameMeta = const VerificationMeta(
    'topicName',
  );
  @override
  late final GeneratedColumn<String> topicName = GeneratedColumn<String>(
    'topic_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    topicId,
    downloadedVersion,
    downloadedAt,
    topicName,
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
    if (data.containsKey('topic_name')) {
      context.handle(
        _topicNameMeta,
        topicName.isAcceptableOrUnknown(data['topic_name']!, _topicNameMeta),
      );
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
      topicName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_name'],
      ),
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

  /// Tên hiển thị của chủ đề tại thời điểm tải (vd `"Du lịch"`) — lưu lại
  /// để màn "Hôm nay" hiển thị chủ đề đang học mà không cần đọc catalog
  /// remote (offline). Thêm ở schema v5.
  final String? topicName;
  const DownloadedTopicsTableData({
    required this.topicId,
    required this.downloadedVersion,
    required this.downloadedAt,
    this.topicName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['topic_id'] = Variable<String>(topicId);
    map['downloaded_version'] = Variable<int>(downloadedVersion);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    if (!nullToAbsent || topicName != null) {
      map['topic_name'] = Variable<String>(topicName);
    }
    return map;
  }

  DownloadedTopicsTableCompanion toCompanion(bool nullToAbsent) {
    return DownloadedTopicsTableCompanion(
      topicId: Value(topicId),
      downloadedVersion: Value(downloadedVersion),
      downloadedAt: Value(downloadedAt),
      topicName: topicName == null && nullToAbsent
          ? const Value.absent()
          : Value(topicName),
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
      topicName: serializer.fromJson<String?>(json['topicName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'topicId': serializer.toJson<String>(topicId),
      'downloadedVersion': serializer.toJson<int>(downloadedVersion),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
      'topicName': serializer.toJson<String?>(topicName),
    };
  }

  DownloadedTopicsTableData copyWith({
    String? topicId,
    int? downloadedVersion,
    DateTime? downloadedAt,
    Value<String?> topicName = const Value.absent(),
  }) => DownloadedTopicsTableData(
    topicId: topicId ?? this.topicId,
    downloadedVersion: downloadedVersion ?? this.downloadedVersion,
    downloadedAt: downloadedAt ?? this.downloadedAt,
    topicName: topicName.present ? topicName.value : this.topicName,
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
      topicName: data.topicName.present ? data.topicName.value : this.topicName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedTopicsTableData(')
          ..write('topicId: $topicId, ')
          ..write('downloadedVersion: $downloadedVersion, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('topicName: $topicName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(topicId, downloadedVersion, downloadedAt, topicName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadedTopicsTableData &&
          other.topicId == this.topicId &&
          other.downloadedVersion == this.downloadedVersion &&
          other.downloadedAt == this.downloadedAt &&
          other.topicName == this.topicName);
}

class DownloadedTopicsTableCompanion
    extends UpdateCompanion<DownloadedTopicsTableData> {
  final Value<String> topicId;
  final Value<int> downloadedVersion;
  final Value<DateTime> downloadedAt;
  final Value<String?> topicName;
  final Value<int> rowid;
  const DownloadedTopicsTableCompanion({
    this.topicId = const Value.absent(),
    this.downloadedVersion = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.topicName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadedTopicsTableCompanion.insert({
    required String topicId,
    required int downloadedVersion,
    required DateTime downloadedAt,
    this.topicName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : topicId = Value(topicId),
       downloadedVersion = Value(downloadedVersion),
       downloadedAt = Value(downloadedAt);
  static Insertable<DownloadedTopicsTableData> custom({
    Expression<String>? topicId,
    Expression<int>? downloadedVersion,
    Expression<DateTime>? downloadedAt,
    Expression<String>? topicName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (topicId != null) 'topic_id': topicId,
      if (downloadedVersion != null) 'downloaded_version': downloadedVersion,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (topicName != null) 'topic_name': topicName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadedTopicsTableCompanion copyWith({
    Value<String>? topicId,
    Value<int>? downloadedVersion,
    Value<DateTime>? downloadedAt,
    Value<String?>? topicName,
    Value<int>? rowid,
  }) {
    return DownloadedTopicsTableCompanion(
      topicId: topicId ?? this.topicId,
      downloadedVersion: downloadedVersion ?? this.downloadedVersion,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      topicName: topicName ?? this.topicName,
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
    if (topicName.present) {
      map['topic_name'] = Variable<String>(topicName.value);
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
          ..write('topicName: $topicName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PronunciationSegmentsTableTable extends PronunciationSegmentsTable
    with
        TableInfo<
          $PronunciationSegmentsTableTable,
          PronunciationSegmentsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PronunciationSegmentsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _startOffsetMeta = const VerificationMeta(
    'startOffset',
  );
  @override
  late final GeneratedColumn<int> startOffset = GeneratedColumn<int>(
    'start_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endOffsetMeta = const VerificationMeta(
    'endOffset',
  );
  @override
  late final GeneratedColumn<int> endOffset = GeneratedColumn<int>(
    'end_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _segmentTextMeta = const VerificationMeta(
    'segmentText',
  );
  @override
  late final GeneratedColumn<String> segmentText = GeneratedColumn<String>(
    'segment_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ipaMeta = const VerificationMeta('ipa');
  @override
  late final GeneratedColumn<String> ipa = GeneratedColumn<String>(
    'ipa',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stressMeta = const VerificationMeta('stress');
  @override
  late final GeneratedColumn<String> stress = GeneratedColumn<String>(
    'stress',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timingWeightMeta = const VerificationMeta(
    'timingWeight',
  );
  @override
  late final GeneratedColumn<double> timingWeight = GeneratedColumn<double>(
    'timing_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vocabId,
    position,
    startOffset,
    endOffset,
    segmentText,
    ipa,
    stress,
    timingWeight,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pronunciation_segments_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PronunciationSegmentsTableData> instance, {
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
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('start_offset')) {
      context.handle(
        _startOffsetMeta,
        startOffset.isAcceptableOrUnknown(
          data['start_offset']!,
          _startOffsetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startOffsetMeta);
    }
    if (data.containsKey('end_offset')) {
      context.handle(
        _endOffsetMeta,
        endOffset.isAcceptableOrUnknown(data['end_offset']!, _endOffsetMeta),
      );
    } else if (isInserting) {
      context.missing(_endOffsetMeta);
    }
    if (data.containsKey('segment_text')) {
      context.handle(
        _segmentTextMeta,
        segmentText.isAcceptableOrUnknown(
          data['segment_text']!,
          _segmentTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_segmentTextMeta);
    }
    if (data.containsKey('ipa')) {
      context.handle(
        _ipaMeta,
        ipa.isAcceptableOrUnknown(data['ipa']!, _ipaMeta),
      );
    } else if (isInserting) {
      context.missing(_ipaMeta);
    }
    if (data.containsKey('stress')) {
      context.handle(
        _stressMeta,
        stress.isAcceptableOrUnknown(data['stress']!, _stressMeta),
      );
    } else if (isInserting) {
      context.missing(_stressMeta);
    }
    if (data.containsKey('timing_weight')) {
      context.handle(
        _timingWeightMeta,
        timingWeight.isAcceptableOrUnknown(
          data['timing_weight']!,
          _timingWeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timingWeightMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {vocabId, position},
  ];
  @override
  PronunciationSegmentsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PronunciationSegmentsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vocabId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vocab_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      startOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_offset'],
      )!,
      endOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_offset'],
      )!,
      segmentText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}segment_text'],
      )!,
      ipa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ipa'],
      )!,
      stress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stress'],
      )!,
      timingWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}timing_weight'],
      )!,
    );
  }

  @override
  $PronunciationSegmentsTableTable createAlias(String alias) {
    return $PronunciationSegmentsTableTable(attachedDatabase, alias);
  }
}

class PronunciationSegmentsTableData extends DataClass
    implements Insertable<PronunciationSegmentsTableData> {
  final int id;
  final int vocabId;
  final int position;
  final int startOffset;
  final int endOffset;
  final String segmentText;
  final String ipa;
  final String stress;
  final double timingWeight;
  const PronunciationSegmentsTableData({
    required this.id,
    required this.vocabId,
    required this.position,
    required this.startOffset,
    required this.endOffset,
    required this.segmentText,
    required this.ipa,
    required this.stress,
    required this.timingWeight,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vocab_id'] = Variable<int>(vocabId);
    map['position'] = Variable<int>(position);
    map['start_offset'] = Variable<int>(startOffset);
    map['end_offset'] = Variable<int>(endOffset);
    map['segment_text'] = Variable<String>(segmentText);
    map['ipa'] = Variable<String>(ipa);
    map['stress'] = Variable<String>(stress);
    map['timing_weight'] = Variable<double>(timingWeight);
    return map;
  }

  PronunciationSegmentsTableCompanion toCompanion(bool nullToAbsent) {
    return PronunciationSegmentsTableCompanion(
      id: Value(id),
      vocabId: Value(vocabId),
      position: Value(position),
      startOffset: Value(startOffset),
      endOffset: Value(endOffset),
      segmentText: Value(segmentText),
      ipa: Value(ipa),
      stress: Value(stress),
      timingWeight: Value(timingWeight),
    );
  }

  factory PronunciationSegmentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PronunciationSegmentsTableData(
      id: serializer.fromJson<int>(json['id']),
      vocabId: serializer.fromJson<int>(json['vocabId']),
      position: serializer.fromJson<int>(json['position']),
      startOffset: serializer.fromJson<int>(json['startOffset']),
      endOffset: serializer.fromJson<int>(json['endOffset']),
      segmentText: serializer.fromJson<String>(json['segmentText']),
      ipa: serializer.fromJson<String>(json['ipa']),
      stress: serializer.fromJson<String>(json['stress']),
      timingWeight: serializer.fromJson<double>(json['timingWeight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vocabId': serializer.toJson<int>(vocabId),
      'position': serializer.toJson<int>(position),
      'startOffset': serializer.toJson<int>(startOffset),
      'endOffset': serializer.toJson<int>(endOffset),
      'segmentText': serializer.toJson<String>(segmentText),
      'ipa': serializer.toJson<String>(ipa),
      'stress': serializer.toJson<String>(stress),
      'timingWeight': serializer.toJson<double>(timingWeight),
    };
  }

  PronunciationSegmentsTableData copyWith({
    int? id,
    int? vocabId,
    int? position,
    int? startOffset,
    int? endOffset,
    String? segmentText,
    String? ipa,
    String? stress,
    double? timingWeight,
  }) => PronunciationSegmentsTableData(
    id: id ?? this.id,
    vocabId: vocabId ?? this.vocabId,
    position: position ?? this.position,
    startOffset: startOffset ?? this.startOffset,
    endOffset: endOffset ?? this.endOffset,
    segmentText: segmentText ?? this.segmentText,
    ipa: ipa ?? this.ipa,
    stress: stress ?? this.stress,
    timingWeight: timingWeight ?? this.timingWeight,
  );
  PronunciationSegmentsTableData copyWithCompanion(
    PronunciationSegmentsTableCompanion data,
  ) {
    return PronunciationSegmentsTableData(
      id: data.id.present ? data.id.value : this.id,
      vocabId: data.vocabId.present ? data.vocabId.value : this.vocabId,
      position: data.position.present ? data.position.value : this.position,
      startOffset: data.startOffset.present
          ? data.startOffset.value
          : this.startOffset,
      endOffset: data.endOffset.present ? data.endOffset.value : this.endOffset,
      segmentText: data.segmentText.present
          ? data.segmentText.value
          : this.segmentText,
      ipa: data.ipa.present ? data.ipa.value : this.ipa,
      stress: data.stress.present ? data.stress.value : this.stress,
      timingWeight: data.timingWeight.present
          ? data.timingWeight.value
          : this.timingWeight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PronunciationSegmentsTableData(')
          ..write('id: $id, ')
          ..write('vocabId: $vocabId, ')
          ..write('position: $position, ')
          ..write('startOffset: $startOffset, ')
          ..write('endOffset: $endOffset, ')
          ..write('segmentText: $segmentText, ')
          ..write('ipa: $ipa, ')
          ..write('stress: $stress, ')
          ..write('timingWeight: $timingWeight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vocabId,
    position,
    startOffset,
    endOffset,
    segmentText,
    ipa,
    stress,
    timingWeight,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PronunciationSegmentsTableData &&
          other.id == this.id &&
          other.vocabId == this.vocabId &&
          other.position == this.position &&
          other.startOffset == this.startOffset &&
          other.endOffset == this.endOffset &&
          other.segmentText == this.segmentText &&
          other.ipa == this.ipa &&
          other.stress == this.stress &&
          other.timingWeight == this.timingWeight);
}

class PronunciationSegmentsTableCompanion
    extends UpdateCompanion<PronunciationSegmentsTableData> {
  final Value<int> id;
  final Value<int> vocabId;
  final Value<int> position;
  final Value<int> startOffset;
  final Value<int> endOffset;
  final Value<String> segmentText;
  final Value<String> ipa;
  final Value<String> stress;
  final Value<double> timingWeight;
  const PronunciationSegmentsTableCompanion({
    this.id = const Value.absent(),
    this.vocabId = const Value.absent(),
    this.position = const Value.absent(),
    this.startOffset = const Value.absent(),
    this.endOffset = const Value.absent(),
    this.segmentText = const Value.absent(),
    this.ipa = const Value.absent(),
    this.stress = const Value.absent(),
    this.timingWeight = const Value.absent(),
  });
  PronunciationSegmentsTableCompanion.insert({
    this.id = const Value.absent(),
    required int vocabId,
    required int position,
    required int startOffset,
    required int endOffset,
    required String segmentText,
    required String ipa,
    required String stress,
    required double timingWeight,
  }) : vocabId = Value(vocabId),
       position = Value(position),
       startOffset = Value(startOffset),
       endOffset = Value(endOffset),
       segmentText = Value(segmentText),
       ipa = Value(ipa),
       stress = Value(stress),
       timingWeight = Value(timingWeight);
  static Insertable<PronunciationSegmentsTableData> custom({
    Expression<int>? id,
    Expression<int>? vocabId,
    Expression<int>? position,
    Expression<int>? startOffset,
    Expression<int>? endOffset,
    Expression<String>? segmentText,
    Expression<String>? ipa,
    Expression<String>? stress,
    Expression<double>? timingWeight,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vocabId != null) 'vocab_id': vocabId,
      if (position != null) 'position': position,
      if (startOffset != null) 'start_offset': startOffset,
      if (endOffset != null) 'end_offset': endOffset,
      if (segmentText != null) 'segment_text': segmentText,
      if (ipa != null) 'ipa': ipa,
      if (stress != null) 'stress': stress,
      if (timingWeight != null) 'timing_weight': timingWeight,
    });
  }

  PronunciationSegmentsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? vocabId,
    Value<int>? position,
    Value<int>? startOffset,
    Value<int>? endOffset,
    Value<String>? segmentText,
    Value<String>? ipa,
    Value<String>? stress,
    Value<double>? timingWeight,
  }) {
    return PronunciationSegmentsTableCompanion(
      id: id ?? this.id,
      vocabId: vocabId ?? this.vocabId,
      position: position ?? this.position,
      startOffset: startOffset ?? this.startOffset,
      endOffset: endOffset ?? this.endOffset,
      segmentText: segmentText ?? this.segmentText,
      ipa: ipa ?? this.ipa,
      stress: stress ?? this.stress,
      timingWeight: timingWeight ?? this.timingWeight,
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
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (startOffset.present) {
      map['start_offset'] = Variable<int>(startOffset.value);
    }
    if (endOffset.present) {
      map['end_offset'] = Variable<int>(endOffset.value);
    }
    if (segmentText.present) {
      map['segment_text'] = Variable<String>(segmentText.value);
    }
    if (ipa.present) {
      map['ipa'] = Variable<String>(ipa.value);
    }
    if (stress.present) {
      map['stress'] = Variable<String>(stress.value);
    }
    if (timingWeight.present) {
      map['timing_weight'] = Variable<double>(timingWeight.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PronunciationSegmentsTableCompanion(')
          ..write('id: $id, ')
          ..write('vocabId: $vocabId, ')
          ..write('position: $position, ')
          ..write('startOffset: $startOffset, ')
          ..write('endOffset: $endOffset, ')
          ..write('segmentText: $segmentText, ')
          ..write('ipa: $ipa, ')
          ..write('stress: $stress, ')
          ..write('timingWeight: $timingWeight')
          ..write(')'))
        .toString();
  }
}

class $TtsWordTimingCacheTableTable extends TtsWordTimingCacheTable
    with TableInfo<$TtsWordTimingCacheTableTable, TtsWordTimingCacheTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TtsWordTimingCacheTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _wordStartOffsetMeta = const VerificationMeta(
    'wordStartOffset',
  );
  @override
  late final GeneratedColumn<int> wordStartOffset = GeneratedColumn<int>(
    'word_start_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordEndOffsetMeta = const VerificationMeta(
    'wordEndOffset',
  );
  @override
  late final GeneratedColumn<int> wordEndOffset = GeneratedColumn<int>(
    'word_end_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voiceKeyMeta = const VerificationMeta(
    'voiceKey',
  );
  @override
  late final GeneratedColumn<String> voiceKey = GeneratedColumn<String>(
    'voice_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speechRateMeta = const VerificationMeta(
    'speechRate',
  );
  @override
  late final GeneratedColumn<double> speechRate = GeneratedColumn<double>(
    'speech_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    wordStartOffset,
    wordEndOffset,
    voiceKey,
    speechRate,
    durationMs,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tts_word_timing_cache_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TtsWordTimingCacheTableData> instance, {
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
    if (data.containsKey('word_start_offset')) {
      context.handle(
        _wordStartOffsetMeta,
        wordStartOffset.isAcceptableOrUnknown(
          data['word_start_offset']!,
          _wordStartOffsetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wordStartOffsetMeta);
    }
    if (data.containsKey('word_end_offset')) {
      context.handle(
        _wordEndOffsetMeta,
        wordEndOffset.isAcceptableOrUnknown(
          data['word_end_offset']!,
          _wordEndOffsetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wordEndOffsetMeta);
    }
    if (data.containsKey('voice_key')) {
      context.handle(
        _voiceKeyMeta,
        voiceKey.isAcceptableOrUnknown(data['voice_key']!, _voiceKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_voiceKeyMeta);
    }
    if (data.containsKey('speech_rate')) {
      context.handle(
        _speechRateMeta,
        speechRate.isAcceptableOrUnknown(data['speech_rate']!, _speechRateMeta),
      );
    } else if (isInserting) {
      context.missing(_speechRateMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
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
    {vocabId, wordStartOffset, wordEndOffset, voiceKey, speechRate},
  ];
  @override
  TtsWordTimingCacheTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TtsWordTimingCacheTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vocabId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vocab_id'],
      )!,
      wordStartOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_start_offset'],
      )!,
      wordEndOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_end_offset'],
      )!,
      voiceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voice_key'],
      )!,
      speechRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speech_rate'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TtsWordTimingCacheTableTable createAlias(String alias) {
    return $TtsWordTimingCacheTableTable(attachedDatabase, alias);
  }
}

class TtsWordTimingCacheTableData extends DataClass
    implements Insertable<TtsWordTimingCacheTableData> {
  final int id;
  final int vocabId;
  final int wordStartOffset;
  final int wordEndOffset;
  final String voiceKey;
  final double speechRate;
  final int durationMs;
  final DateTime updatedAt;
  const TtsWordTimingCacheTableData({
    required this.id,
    required this.vocabId,
    required this.wordStartOffset,
    required this.wordEndOffset,
    required this.voiceKey,
    required this.speechRate,
    required this.durationMs,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vocab_id'] = Variable<int>(vocabId);
    map['word_start_offset'] = Variable<int>(wordStartOffset);
    map['word_end_offset'] = Variable<int>(wordEndOffset);
    map['voice_key'] = Variable<String>(voiceKey);
    map['speech_rate'] = Variable<double>(speechRate);
    map['duration_ms'] = Variable<int>(durationMs);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TtsWordTimingCacheTableCompanion toCompanion(bool nullToAbsent) {
    return TtsWordTimingCacheTableCompanion(
      id: Value(id),
      vocabId: Value(vocabId),
      wordStartOffset: Value(wordStartOffset),
      wordEndOffset: Value(wordEndOffset),
      voiceKey: Value(voiceKey),
      speechRate: Value(speechRate),
      durationMs: Value(durationMs),
      updatedAt: Value(updatedAt),
    );
  }

  factory TtsWordTimingCacheTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TtsWordTimingCacheTableData(
      id: serializer.fromJson<int>(json['id']),
      vocabId: serializer.fromJson<int>(json['vocabId']),
      wordStartOffset: serializer.fromJson<int>(json['wordStartOffset']),
      wordEndOffset: serializer.fromJson<int>(json['wordEndOffset']),
      voiceKey: serializer.fromJson<String>(json['voiceKey']),
      speechRate: serializer.fromJson<double>(json['speechRate']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vocabId': serializer.toJson<int>(vocabId),
      'wordStartOffset': serializer.toJson<int>(wordStartOffset),
      'wordEndOffset': serializer.toJson<int>(wordEndOffset),
      'voiceKey': serializer.toJson<String>(voiceKey),
      'speechRate': serializer.toJson<double>(speechRate),
      'durationMs': serializer.toJson<int>(durationMs),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TtsWordTimingCacheTableData copyWith({
    int? id,
    int? vocabId,
    int? wordStartOffset,
    int? wordEndOffset,
    String? voiceKey,
    double? speechRate,
    int? durationMs,
    DateTime? updatedAt,
  }) => TtsWordTimingCacheTableData(
    id: id ?? this.id,
    vocabId: vocabId ?? this.vocabId,
    wordStartOffset: wordStartOffset ?? this.wordStartOffset,
    wordEndOffset: wordEndOffset ?? this.wordEndOffset,
    voiceKey: voiceKey ?? this.voiceKey,
    speechRate: speechRate ?? this.speechRate,
    durationMs: durationMs ?? this.durationMs,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TtsWordTimingCacheTableData copyWithCompanion(
    TtsWordTimingCacheTableCompanion data,
  ) {
    return TtsWordTimingCacheTableData(
      id: data.id.present ? data.id.value : this.id,
      vocabId: data.vocabId.present ? data.vocabId.value : this.vocabId,
      wordStartOffset: data.wordStartOffset.present
          ? data.wordStartOffset.value
          : this.wordStartOffset,
      wordEndOffset: data.wordEndOffset.present
          ? data.wordEndOffset.value
          : this.wordEndOffset,
      voiceKey: data.voiceKey.present ? data.voiceKey.value : this.voiceKey,
      speechRate: data.speechRate.present
          ? data.speechRate.value
          : this.speechRate,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TtsWordTimingCacheTableData(')
          ..write('id: $id, ')
          ..write('vocabId: $vocabId, ')
          ..write('wordStartOffset: $wordStartOffset, ')
          ..write('wordEndOffset: $wordEndOffset, ')
          ..write('voiceKey: $voiceKey, ')
          ..write('speechRate: $speechRate, ')
          ..write('durationMs: $durationMs, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vocabId,
    wordStartOffset,
    wordEndOffset,
    voiceKey,
    speechRate,
    durationMs,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TtsWordTimingCacheTableData &&
          other.id == this.id &&
          other.vocabId == this.vocabId &&
          other.wordStartOffset == this.wordStartOffset &&
          other.wordEndOffset == this.wordEndOffset &&
          other.voiceKey == this.voiceKey &&
          other.speechRate == this.speechRate &&
          other.durationMs == this.durationMs &&
          other.updatedAt == this.updatedAt);
}

class TtsWordTimingCacheTableCompanion
    extends UpdateCompanion<TtsWordTimingCacheTableData> {
  final Value<int> id;
  final Value<int> vocabId;
  final Value<int> wordStartOffset;
  final Value<int> wordEndOffset;
  final Value<String> voiceKey;
  final Value<double> speechRate;
  final Value<int> durationMs;
  final Value<DateTime> updatedAt;
  const TtsWordTimingCacheTableCompanion({
    this.id = const Value.absent(),
    this.vocabId = const Value.absent(),
    this.wordStartOffset = const Value.absent(),
    this.wordEndOffset = const Value.absent(),
    this.voiceKey = const Value.absent(),
    this.speechRate = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TtsWordTimingCacheTableCompanion.insert({
    this.id = const Value.absent(),
    required int vocabId,
    required int wordStartOffset,
    required int wordEndOffset,
    required String voiceKey,
    required double speechRate,
    required int durationMs,
    required DateTime updatedAt,
  }) : vocabId = Value(vocabId),
       wordStartOffset = Value(wordStartOffset),
       wordEndOffset = Value(wordEndOffset),
       voiceKey = Value(voiceKey),
       speechRate = Value(speechRate),
       durationMs = Value(durationMs),
       updatedAt = Value(updatedAt);
  static Insertable<TtsWordTimingCacheTableData> custom({
    Expression<int>? id,
    Expression<int>? vocabId,
    Expression<int>? wordStartOffset,
    Expression<int>? wordEndOffset,
    Expression<String>? voiceKey,
    Expression<double>? speechRate,
    Expression<int>? durationMs,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vocabId != null) 'vocab_id': vocabId,
      if (wordStartOffset != null) 'word_start_offset': wordStartOffset,
      if (wordEndOffset != null) 'word_end_offset': wordEndOffset,
      if (voiceKey != null) 'voice_key': voiceKey,
      if (speechRate != null) 'speech_rate': speechRate,
      if (durationMs != null) 'duration_ms': durationMs,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TtsWordTimingCacheTableCompanion copyWith({
    Value<int>? id,
    Value<int>? vocabId,
    Value<int>? wordStartOffset,
    Value<int>? wordEndOffset,
    Value<String>? voiceKey,
    Value<double>? speechRate,
    Value<int>? durationMs,
    Value<DateTime>? updatedAt,
  }) {
    return TtsWordTimingCacheTableCompanion(
      id: id ?? this.id,
      vocabId: vocabId ?? this.vocabId,
      wordStartOffset: wordStartOffset ?? this.wordStartOffset,
      wordEndOffset: wordEndOffset ?? this.wordEndOffset,
      voiceKey: voiceKey ?? this.voiceKey,
      speechRate: speechRate ?? this.speechRate,
      durationMs: durationMs ?? this.durationMs,
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
    if (wordStartOffset.present) {
      map['word_start_offset'] = Variable<int>(wordStartOffset.value);
    }
    if (wordEndOffset.present) {
      map['word_end_offset'] = Variable<int>(wordEndOffset.value);
    }
    if (voiceKey.present) {
      map['voice_key'] = Variable<String>(voiceKey.value);
    }
    if (speechRate.present) {
      map['speech_rate'] = Variable<double>(speechRate.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TtsWordTimingCacheTableCompanion(')
          ..write('id: $id, ')
          ..write('vocabId: $vocabId, ')
          ..write('wordStartOffset: $wordStartOffset, ')
          ..write('wordEndOffset: $wordEndOffset, ')
          ..write('voiceKey: $voiceKey, ')
          ..write('speechRate: $speechRate, ')
          ..write('durationMs: $durationMs, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $StudyLogTableTable extends StudyLogTable
    with TableInfo<$StudyLogTableTable, StudyLogTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyLogTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewCountMeta = const VerificationMeta(
    'reviewCount',
  );
  @override
  late final GeneratedColumn<int> reviewCount = GeneratedColumn<int>(
    'review_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newCountMeta = const VerificationMeta(
    'newCount',
  );
  @override
  late final GeneratedColumn<int> newCount = GeneratedColumn<int>(
    'new_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    date,
    reviewCount,
    newCount,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_log_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudyLogTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('review_count')) {
      context.handle(
        _reviewCountMeta,
        reviewCount.isAcceptableOrUnknown(
          data['review_count']!,
          _reviewCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewCountMeta);
    }
    if (data.containsKey('new_count')) {
      context.handle(
        _newCountMeta,
        newCount.isAcceptableOrUnknown(data['new_count']!, _newCountMeta),
      );
    } else if (isInserting) {
      context.missing(_newCountMeta);
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
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  StudyLogTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyLogTableData(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      reviewCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_count'],
      )!,
      newCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StudyLogTableTable createAlias(String alias) {
    return $StudyLogTableTable(attachedDatabase, alias);
  }
}

class StudyLogTableData extends DataClass
    implements Insertable<StudyLogTableData> {
  /// Ngày học, định dạng `'YYYY-MM-DD'` theo giờ local của thiết bị — khóa
  /// chính, mỗi ngày đúng 1 dòng.
  final String date;

  /// Tổng số lượt trả lời (recordAnswer) trong ngày.
  final int reviewCount;

  /// Số từ mới ôn lần đầu trong ngày (từ có `lastReview == null` trước khi
  /// ghi nhận).
  final int newCount;

  /// Lần cập nhật cuối của dòng ngày này.
  final DateTime updatedAt;
  const StudyLogTableData({
    required this.date,
    required this.reviewCount,
    required this.newCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['review_count'] = Variable<int>(reviewCount);
    map['new_count'] = Variable<int>(newCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StudyLogTableCompanion toCompanion(bool nullToAbsent) {
    return StudyLogTableCompanion(
      date: Value(date),
      reviewCount: Value(reviewCount),
      newCount: Value(newCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory StudyLogTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyLogTableData(
      date: serializer.fromJson<String>(json['date']),
      reviewCount: serializer.fromJson<int>(json['reviewCount']),
      newCount: serializer.fromJson<int>(json['newCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'reviewCount': serializer.toJson<int>(reviewCount),
      'newCount': serializer.toJson<int>(newCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StudyLogTableData copyWith({
    String? date,
    int? reviewCount,
    int? newCount,
    DateTime? updatedAt,
  }) => StudyLogTableData(
    date: date ?? this.date,
    reviewCount: reviewCount ?? this.reviewCount,
    newCount: newCount ?? this.newCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StudyLogTableData copyWithCompanion(StudyLogTableCompanion data) {
    return StudyLogTableData(
      date: data.date.present ? data.date.value : this.date,
      reviewCount: data.reviewCount.present
          ? data.reviewCount.value
          : this.reviewCount,
      newCount: data.newCount.present ? data.newCount.value : this.newCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyLogTableData(')
          ..write('date: $date, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('newCount: $newCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, reviewCount, newCount, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyLogTableData &&
          other.date == this.date &&
          other.reviewCount == this.reviewCount &&
          other.newCount == this.newCount &&
          other.updatedAt == this.updatedAt);
}

class StudyLogTableCompanion extends UpdateCompanion<StudyLogTableData> {
  final Value<String> date;
  final Value<int> reviewCount;
  final Value<int> newCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StudyLogTableCompanion({
    this.date = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.newCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudyLogTableCompanion.insert({
    required String date,
    required int reviewCount,
    required int newCount,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       reviewCount = Value(reviewCount),
       newCount = Value(newCount),
       updatedAt = Value(updatedAt);
  static Insertable<StudyLogTableData> custom({
    Expression<String>? date,
    Expression<int>? reviewCount,
    Expression<int>? newCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (reviewCount != null) 'review_count': reviewCount,
      if (newCount != null) 'new_count': newCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudyLogTableCompanion copyWith({
    Value<String>? date,
    Value<int>? reviewCount,
    Value<int>? newCount,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return StudyLogTableCompanion(
      date: date ?? this.date,
      reviewCount: reviewCount ?? this.reviewCount,
      newCount: newCount ?? this.newCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (reviewCount.present) {
      map['review_count'] = Variable<int>(reviewCount.value);
    }
    if (newCount.present) {
      map['new_count'] = Variable<int>(newCount.value);
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
    return (StringBuffer('StudyLogTableCompanion(')
          ..write('date: $date, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('newCount: $newCount, ')
          ..write('updatedAt: $updatedAt, ')
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
  late final $PronunciationSegmentsTableTable pronunciationSegmentsTable =
      $PronunciationSegmentsTableTable(this);
  late final $TtsWordTimingCacheTableTable ttsWordTimingCacheTable =
      $TtsWordTimingCacheTableTable(this);
  late final $StudyLogTableTable studyLogTable = $StudyLogTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vocabularyTable,
    progressTable,
    downloadedTopicsTable,
    pronunciationSegmentsTable,
    ttsWordTimingCacheTable,
    studyLogTable,
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
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vocabulary_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('pronunciation_segments_table', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vocabulary_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('tts_word_timing_cache_table', kind: UpdateKind.delete),
      ],
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
      Value<String?> topicId,
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
      Value<String?> topicId,
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

  static MultiTypedResultKey<
    $PronunciationSegmentsTableTable,
    List<PronunciationSegmentsTableData>
  >
  _pronunciationSegmentsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.pronunciationSegmentsTable,
        aliasName:
            'vocabulary_table__id__pronunciation_segments_table__vocab_id',
      );

  $$PronunciationSegmentsTableTableProcessedTableManager
  get pronunciationSegmentsTableRefs {
    final manager = $$PronunciationSegmentsTableTableTableManager(
      $_db,
      $_db.pronunciationSegmentsTable,
    ).filter((f) => f.vocabId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pronunciationSegmentsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TtsWordTimingCacheTableTable,
    List<TtsWordTimingCacheTableData>
  >
  _ttsWordTimingCacheTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.ttsWordTimingCacheTable,
        aliasName:
            'vocabulary_table__id__tts_word_timing_cache_table__vocab_id',
      );

  $$TtsWordTimingCacheTableTableProcessedTableManager
  get ttsWordTimingCacheTableRefs {
    final manager = $$TtsWordTimingCacheTableTableTableManager(
      $_db,
      $_db.ttsWordTimingCacheTable,
    ).filter((f) => f.vocabId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _ttsWordTimingCacheTableRefsTable($_db),
    );
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

  ColumnFilters<String> get topicId => $composableBuilder(
    column: $table.topicId,
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

  Expression<bool> pronunciationSegmentsTableRefs(
    Expression<bool> Function($$PronunciationSegmentsTableTableFilterComposer f)
    f,
  ) {
    final $$PronunciationSegmentsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pronunciationSegmentsTable,
          getReferencedColumn: (t) => t.vocabId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PronunciationSegmentsTableTableFilterComposer(
                $db: $db,
                $table: $db.pronunciationSegmentsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> ttsWordTimingCacheTableRefs(
    Expression<bool> Function($$TtsWordTimingCacheTableTableFilterComposer f) f,
  ) {
    final $$TtsWordTimingCacheTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ttsWordTimingCacheTable,
          getReferencedColumn: (t) => t.vocabId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TtsWordTimingCacheTableTableFilterComposer(
                $db: $db,
                $table: $db.ttsWordTimingCacheTable,
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

  ColumnOrderings<String> get topicId => $composableBuilder(
    column: $table.topicId,
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

  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

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

  Expression<T> pronunciationSegmentsTableRefs<T extends Object>(
    Expression<T> Function(
      $$PronunciationSegmentsTableTableAnnotationComposer a,
    )
    f,
  ) {
    final $$PronunciationSegmentsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pronunciationSegmentsTable,
          getReferencedColumn: (t) => t.vocabId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PronunciationSegmentsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.pronunciationSegmentsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> ttsWordTimingCacheTableRefs<T extends Object>(
    Expression<T> Function($$TtsWordTimingCacheTableTableAnnotationComposer a)
    f,
  ) {
    final $$TtsWordTimingCacheTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ttsWordTimingCacheTable,
          getReferencedColumn: (t) => t.vocabId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TtsWordTimingCacheTableTableAnnotationComposer(
                $db: $db,
                $table: $db.ttsWordTimingCacheTable,
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
          PrefetchHooks Function({
            bool progressTableRefs,
            bool pronunciationSegmentsTableRefs,
            bool ttsWordTimingCacheTableRefs,
          })
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
                Value<String?> topicId = const Value.absent(),
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
                topicId: topicId,
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
                Value<String?> topicId = const Value.absent(),
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
                topicId: topicId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VocabularyTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                progressTableRefs = false,
                pronunciationSegmentsTableRefs = false,
                ttsWordTimingCacheTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (progressTableRefs) db.progressTable,
                    if (pronunciationSegmentsTableRefs)
                      db.pronunciationSegmentsTable,
                    if (ttsWordTimingCacheTableRefs) db.ttsWordTimingCacheTable,
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
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vocabId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pronunciationSegmentsTableRefs)
                        await $_getPrefetchedData<
                          VocabularyTableData,
                          $VocabularyTableTable,
                          PronunciationSegmentsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$VocabularyTableTableReferences
                              ._pronunciationSegmentsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VocabularyTableTableReferences(
                                db,
                                table,
                                p0,
                              ).pronunciationSegmentsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vocabId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ttsWordTimingCacheTableRefs)
                        await $_getPrefetchedData<
                          VocabularyTableData,
                          $VocabularyTableTable,
                          TtsWordTimingCacheTableData
                        >(
                          currentTable: table,
                          referencedTable: $$VocabularyTableTableReferences
                              ._ttsWordTimingCacheTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VocabularyTableTableReferences(
                                db,
                                table,
                                p0,
                              ).ttsWordTimingCacheTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vocabId == item.id,
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
      PrefetchHooks Function({
        bool progressTableRefs,
        bool pronunciationSegmentsTableRefs,
        bool ttsWordTimingCacheTableRefs,
      })
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
      Value<String?> topicName,
      Value<int> rowid,
    });
typedef $$DownloadedTopicsTableTableUpdateCompanionBuilder =
    DownloadedTopicsTableCompanion Function({
      Value<String> topicId,
      Value<int> downloadedVersion,
      Value<DateTime> downloadedAt,
      Value<String?> topicName,
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

  ColumnFilters<String> get topicName => $composableBuilder(
    column: $table.topicName,
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

  ColumnOrderings<String> get topicName => $composableBuilder(
    column: $table.topicName,
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

  GeneratedColumn<String> get topicName =>
      $composableBuilder(column: $table.topicName, builder: (column) => column);
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
                Value<String?> topicName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadedTopicsTableCompanion(
                topicId: topicId,
                downloadedVersion: downloadedVersion,
                downloadedAt: downloadedAt,
                topicName: topicName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String topicId,
                required int downloadedVersion,
                required DateTime downloadedAt,
                Value<String?> topicName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadedTopicsTableCompanion.insert(
                topicId: topicId,
                downloadedVersion: downloadedVersion,
                downloadedAt: downloadedAt,
                topicName: topicName,
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
typedef $$PronunciationSegmentsTableTableCreateCompanionBuilder =
    PronunciationSegmentsTableCompanion Function({
      Value<int> id,
      required int vocabId,
      required int position,
      required int startOffset,
      required int endOffset,
      required String segmentText,
      required String ipa,
      required String stress,
      required double timingWeight,
    });
typedef $$PronunciationSegmentsTableTableUpdateCompanionBuilder =
    PronunciationSegmentsTableCompanion Function({
      Value<int> id,
      Value<int> vocabId,
      Value<int> position,
      Value<int> startOffset,
      Value<int> endOffset,
      Value<String> segmentText,
      Value<String> ipa,
      Value<String> stress,
      Value<double> timingWeight,
    });

final class $$PronunciationSegmentsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PronunciationSegmentsTableTable,
          PronunciationSegmentsTableData
        > {
  $$PronunciationSegmentsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VocabularyTableTable _vocabIdTable(_$AppDatabase db) =>
      db.vocabularyTable.createAlias(
        'pronunciation_segments_table__vocab_id__vocabulary_table__id',
      );

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

class $$PronunciationSegmentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PronunciationSegmentsTableTable> {
  $$PronunciationSegmentsTableTableFilterComposer({
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

  ColumnFilters<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endOffset => $composableBuilder(
    column: $table.endOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get segmentText => $composableBuilder(
    column: $table.segmentText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ipa => $composableBuilder(
    column: $table.ipa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stress => $composableBuilder(
    column: $table.stress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get timingWeight => $composableBuilder(
    column: $table.timingWeight,
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

class $$PronunciationSegmentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PronunciationSegmentsTableTable> {
  $$PronunciationSegmentsTableTableOrderingComposer({
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

  ColumnOrderings<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endOffset => $composableBuilder(
    column: $table.endOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get segmentText => $composableBuilder(
    column: $table.segmentText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ipa => $composableBuilder(
    column: $table.ipa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stress => $composableBuilder(
    column: $table.stress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get timingWeight => $composableBuilder(
    column: $table.timingWeight,
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

class $$PronunciationSegmentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PronunciationSegmentsTableTable> {
  $$PronunciationSegmentsTableTableAnnotationComposer({
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

  GeneratedColumn<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endOffset =>
      $composableBuilder(column: $table.endOffset, builder: (column) => column);

  GeneratedColumn<String> get segmentText => $composableBuilder(
    column: $table.segmentText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ipa =>
      $composableBuilder(column: $table.ipa, builder: (column) => column);

  GeneratedColumn<String> get stress =>
      $composableBuilder(column: $table.stress, builder: (column) => column);

  GeneratedColumn<double> get timingWeight => $composableBuilder(
    column: $table.timingWeight,
    builder: (column) => column,
  );

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

class $$PronunciationSegmentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PronunciationSegmentsTableTable,
          PronunciationSegmentsTableData,
          $$PronunciationSegmentsTableTableFilterComposer,
          $$PronunciationSegmentsTableTableOrderingComposer,
          $$PronunciationSegmentsTableTableAnnotationComposer,
          $$PronunciationSegmentsTableTableCreateCompanionBuilder,
          $$PronunciationSegmentsTableTableUpdateCompanionBuilder,
          (
            PronunciationSegmentsTableData,
            $$PronunciationSegmentsTableTableReferences,
          ),
          PronunciationSegmentsTableData,
          PrefetchHooks Function({bool vocabId})
        > {
  $$PronunciationSegmentsTableTableTableManager(
    _$AppDatabase db,
    $PronunciationSegmentsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PronunciationSegmentsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PronunciationSegmentsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PronunciationSegmentsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> vocabId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> startOffset = const Value.absent(),
                Value<int> endOffset = const Value.absent(),
                Value<String> segmentText = const Value.absent(),
                Value<String> ipa = const Value.absent(),
                Value<String> stress = const Value.absent(),
                Value<double> timingWeight = const Value.absent(),
              }) => PronunciationSegmentsTableCompanion(
                id: id,
                vocabId: vocabId,
                position: position,
                startOffset: startOffset,
                endOffset: endOffset,
                segmentText: segmentText,
                ipa: ipa,
                stress: stress,
                timingWeight: timingWeight,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int vocabId,
                required int position,
                required int startOffset,
                required int endOffset,
                required String segmentText,
                required String ipa,
                required String stress,
                required double timingWeight,
              }) => PronunciationSegmentsTableCompanion.insert(
                id: id,
                vocabId: vocabId,
                position: position,
                startOffset: startOffset,
                endOffset: endOffset,
                segmentText: segmentText,
                ipa: ipa,
                stress: stress,
                timingWeight: timingWeight,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PronunciationSegmentsTableTableReferences(db, table, e),
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
                                referencedTable:
                                    $$PronunciationSegmentsTableTableReferences
                                        ._vocabIdTable(db),
                                referencedColumn:
                                    $$PronunciationSegmentsTableTableReferences
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

typedef $$PronunciationSegmentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PronunciationSegmentsTableTable,
      PronunciationSegmentsTableData,
      $$PronunciationSegmentsTableTableFilterComposer,
      $$PronunciationSegmentsTableTableOrderingComposer,
      $$PronunciationSegmentsTableTableAnnotationComposer,
      $$PronunciationSegmentsTableTableCreateCompanionBuilder,
      $$PronunciationSegmentsTableTableUpdateCompanionBuilder,
      (
        PronunciationSegmentsTableData,
        $$PronunciationSegmentsTableTableReferences,
      ),
      PronunciationSegmentsTableData,
      PrefetchHooks Function({bool vocabId})
    >;
typedef $$TtsWordTimingCacheTableTableCreateCompanionBuilder =
    TtsWordTimingCacheTableCompanion Function({
      Value<int> id,
      required int vocabId,
      required int wordStartOffset,
      required int wordEndOffset,
      required String voiceKey,
      required double speechRate,
      required int durationMs,
      required DateTime updatedAt,
    });
typedef $$TtsWordTimingCacheTableTableUpdateCompanionBuilder =
    TtsWordTimingCacheTableCompanion Function({
      Value<int> id,
      Value<int> vocabId,
      Value<int> wordStartOffset,
      Value<int> wordEndOffset,
      Value<String> voiceKey,
      Value<double> speechRate,
      Value<int> durationMs,
      Value<DateTime> updatedAt,
    });

final class $$TtsWordTimingCacheTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TtsWordTimingCacheTableTable,
          TtsWordTimingCacheTableData
        > {
  $$TtsWordTimingCacheTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VocabularyTableTable _vocabIdTable(_$AppDatabase db) =>
      db.vocabularyTable.createAlias(
        'tts_word_timing_cache_table__vocab_id__vocabulary_table__id',
      );

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

class $$TtsWordTimingCacheTableTableFilterComposer
    extends Composer<_$AppDatabase, $TtsWordTimingCacheTableTable> {
  $$TtsWordTimingCacheTableTableFilterComposer({
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

  ColumnFilters<int> get wordStartOffset => $composableBuilder(
    column: $table.wordStartOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordEndOffset => $composableBuilder(
    column: $table.wordEndOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voiceKey => $composableBuilder(
    column: $table.voiceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speechRate => $composableBuilder(
    column: $table.speechRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
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

class $$TtsWordTimingCacheTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TtsWordTimingCacheTableTable> {
  $$TtsWordTimingCacheTableTableOrderingComposer({
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

  ColumnOrderings<int> get wordStartOffset => $composableBuilder(
    column: $table.wordStartOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordEndOffset => $composableBuilder(
    column: $table.wordEndOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voiceKey => $composableBuilder(
    column: $table.voiceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speechRate => $composableBuilder(
    column: $table.speechRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
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

class $$TtsWordTimingCacheTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TtsWordTimingCacheTableTable> {
  $$TtsWordTimingCacheTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get wordStartOffset => $composableBuilder(
    column: $table.wordStartOffset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wordEndOffset => $composableBuilder(
    column: $table.wordEndOffset,
    builder: (column) => column,
  );

  GeneratedColumn<String> get voiceKey =>
      $composableBuilder(column: $table.voiceKey, builder: (column) => column);

  GeneratedColumn<double> get speechRate => $composableBuilder(
    column: $table.speechRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

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

class $$TtsWordTimingCacheTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TtsWordTimingCacheTableTable,
          TtsWordTimingCacheTableData,
          $$TtsWordTimingCacheTableTableFilterComposer,
          $$TtsWordTimingCacheTableTableOrderingComposer,
          $$TtsWordTimingCacheTableTableAnnotationComposer,
          $$TtsWordTimingCacheTableTableCreateCompanionBuilder,
          $$TtsWordTimingCacheTableTableUpdateCompanionBuilder,
          (
            TtsWordTimingCacheTableData,
            $$TtsWordTimingCacheTableTableReferences,
          ),
          TtsWordTimingCacheTableData,
          PrefetchHooks Function({bool vocabId})
        > {
  $$TtsWordTimingCacheTableTableTableManager(
    _$AppDatabase db,
    $TtsWordTimingCacheTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TtsWordTimingCacheTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TtsWordTimingCacheTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TtsWordTimingCacheTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> vocabId = const Value.absent(),
                Value<int> wordStartOffset = const Value.absent(),
                Value<int> wordEndOffset = const Value.absent(),
                Value<String> voiceKey = const Value.absent(),
                Value<double> speechRate = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TtsWordTimingCacheTableCompanion(
                id: id,
                vocabId: vocabId,
                wordStartOffset: wordStartOffset,
                wordEndOffset: wordEndOffset,
                voiceKey: voiceKey,
                speechRate: speechRate,
                durationMs: durationMs,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int vocabId,
                required int wordStartOffset,
                required int wordEndOffset,
                required String voiceKey,
                required double speechRate,
                required int durationMs,
                required DateTime updatedAt,
              }) => TtsWordTimingCacheTableCompanion.insert(
                id: id,
                vocabId: vocabId,
                wordStartOffset: wordStartOffset,
                wordEndOffset: wordEndOffset,
                voiceKey: voiceKey,
                speechRate: speechRate,
                durationMs: durationMs,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TtsWordTimingCacheTableTableReferences(db, table, e),
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
                                referencedTable:
                                    $$TtsWordTimingCacheTableTableReferences
                                        ._vocabIdTable(db),
                                referencedColumn:
                                    $$TtsWordTimingCacheTableTableReferences
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

typedef $$TtsWordTimingCacheTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TtsWordTimingCacheTableTable,
      TtsWordTimingCacheTableData,
      $$TtsWordTimingCacheTableTableFilterComposer,
      $$TtsWordTimingCacheTableTableOrderingComposer,
      $$TtsWordTimingCacheTableTableAnnotationComposer,
      $$TtsWordTimingCacheTableTableCreateCompanionBuilder,
      $$TtsWordTimingCacheTableTableUpdateCompanionBuilder,
      (TtsWordTimingCacheTableData, $$TtsWordTimingCacheTableTableReferences),
      TtsWordTimingCacheTableData,
      PrefetchHooks Function({bool vocabId})
    >;
typedef $$StudyLogTableTableCreateCompanionBuilder =
    StudyLogTableCompanion Function({
      required String date,
      required int reviewCount,
      required int newCount,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$StudyLogTableTableUpdateCompanionBuilder =
    StudyLogTableCompanion Function({
      Value<String> date,
      Value<int> reviewCount,
      Value<int> newCount,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$StudyLogTableTableFilterComposer
    extends Composer<_$AppDatabase, $StudyLogTableTable> {
  $$StudyLogTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newCount => $composableBuilder(
    column: $table.newCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudyLogTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StudyLogTableTable> {
  $$StudyLogTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newCount => $composableBuilder(
    column: $table.newCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudyLogTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudyLogTableTable> {
  $$StudyLogTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get newCount =>
      $composableBuilder(column: $table.newCount, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StudyLogTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudyLogTableTable,
          StudyLogTableData,
          $$StudyLogTableTableFilterComposer,
          $$StudyLogTableTableOrderingComposer,
          $$StudyLogTableTableAnnotationComposer,
          $$StudyLogTableTableCreateCompanionBuilder,
          $$StudyLogTableTableUpdateCompanionBuilder,
          (
            StudyLogTableData,
            BaseReferences<
              _$AppDatabase,
              $StudyLogTableTable,
              StudyLogTableData
            >,
          ),
          StudyLogTableData,
          PrefetchHooks Function()
        > {
  $$StudyLogTableTableTableManager(_$AppDatabase db, $StudyLogTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyLogTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyLogTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyLogTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<int> reviewCount = const Value.absent(),
                Value<int> newCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudyLogTableCompanion(
                date: date,
                reviewCount: reviewCount,
                newCount: newCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required int reviewCount,
                required int newCount,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => StudyLogTableCompanion.insert(
                date: date,
                reviewCount: reviewCount,
                newCount: newCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudyLogTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudyLogTableTable,
      StudyLogTableData,
      $$StudyLogTableTableFilterComposer,
      $$StudyLogTableTableOrderingComposer,
      $$StudyLogTableTableAnnotationComposer,
      $$StudyLogTableTableCreateCompanionBuilder,
      $$StudyLogTableTableUpdateCompanionBuilder,
      (
        StudyLogTableData,
        BaseReferences<_$AppDatabase, $StudyLogTableTable, StudyLogTableData>,
      ),
      StudyLogTableData,
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
  $$PronunciationSegmentsTableTableTableManager
  get pronunciationSegmentsTable =>
      $$PronunciationSegmentsTableTableTableManager(
        _db,
        _db.pronunciationSegmentsTable,
      );
  $$TtsWordTimingCacheTableTableTableManager get ttsWordTimingCacheTable =>
      $$TtsWordTimingCacheTableTableTableManager(
        _db,
        _db.ttsWordTimingCacheTable,
      );
  $$StudyLogTableTableTableManager get studyLogTable =>
      $$StudyLogTableTableTableManager(_db, _db.studyLogTable);
}
