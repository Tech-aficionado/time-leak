// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_stats.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyStatsCollection on Isar {
  IsarCollection<DailyStats> get dailyStats => this.collection();
}

const DailyStatsSchema = CollectionSchema(
  name: r'DailyStats',
  id: -7592871651347013517,
  properties: {
    r'date': PropertySchema(
      id: 0,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'totalMicroLeaksTimeMs': PropertySchema(
      id: 1,
      name: r'totalMicroLeaksTimeMs',
      type: IsarType.long,
    ),
    r'totalScreenTimeMs': PropertySchema(
      id: 2,
      name: r'totalScreenTimeMs',
      type: IsarType.long,
    ),
    r'unlockCount': PropertySchema(
      id: 3,
      name: r'unlockCount',
      type: IsarType.long,
    )
  },
  estimateSize: _dailyStatsEstimateSize,
  serialize: _dailyStatsSerialize,
  deserialize: _dailyStatsDeserialize,
  deserializeProp: _dailyStatsDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _dailyStatsGetId,
  getLinks: _dailyStatsGetLinks,
  attach: _dailyStatsAttach,
  version: '3.1.0+1',
);

int _dailyStatsEstimateSize(
  DailyStats object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _dailyStatsSerialize(
  DailyStats object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeLong(offsets[1], object.totalMicroLeaksTimeMs);
  writer.writeLong(offsets[2], object.totalScreenTimeMs);
  writer.writeLong(offsets[3], object.unlockCount);
}

DailyStats _dailyStatsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyStats();
  object.date = reader.readDateTime(offsets[0]);
  object.id = id;
  object.totalMicroLeaksTimeMs = reader.readLong(offsets[1]);
  object.totalScreenTimeMs = reader.readLong(offsets[2]);
  object.unlockCount = reader.readLong(offsets[3]);
  return object;
}

P _dailyStatsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyStatsGetId(DailyStats object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyStatsGetLinks(DailyStats object) {
  return [];
}

void _dailyStatsAttach(IsarCollection<dynamic> col, Id id, DailyStats object) {
  object.id = id;
}

extension DailyStatsByIndex on IsarCollection<DailyStats> {
  Future<DailyStats?> getByDate(DateTime date) {
    return getByIndex(r'date', [date]);
  }

  DailyStats? getByDateSync(DateTime date) {
    return getByIndexSync(r'date', [date]);
  }

  Future<bool> deleteByDate(DateTime date) {
    return deleteByIndex(r'date', [date]);
  }

  bool deleteByDateSync(DateTime date) {
    return deleteByIndexSync(r'date', [date]);
  }

  Future<List<DailyStats?>> getAllByDate(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndex(r'date', values);
  }

  List<DailyStats?> getAllByDateSync(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'date', values);
  }

  Future<int> deleteAllByDate(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'date', values);
  }

  int deleteAllByDateSync(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'date', values);
  }

  Future<Id> putByDate(DailyStats object) {
    return putByIndex(r'date', object);
  }

  Id putByDateSync(DailyStats object, {bool saveLinks = true}) {
    return putByIndexSync(r'date', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDate(List<DailyStats> objects) {
    return putAllByIndex(r'date', objects);
  }

  List<Id> putAllByDateSync(List<DailyStats> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'date', objects, saveLinks: saveLinks);
  }
}

extension DailyStatsQueryWhereSort
    on QueryBuilder<DailyStats, DailyStats, QWhere> {
  QueryBuilder<DailyStats, DailyStats, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension DailyStatsQueryWhere
    on QueryBuilder<DailyStats, DailyStats, QWhereClause> {
  QueryBuilder<DailyStats, DailyStats, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterWhereClause> dateEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterWhereClause> dateNotEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterWhereClause> dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterWhereClause> dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DailyStatsQueryFilter
    on QueryBuilder<DailyStats, DailyStats, QFilterCondition> {
  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      totalMicroLeaksTimeMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalMicroLeaksTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      totalMicroLeaksTimeMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalMicroLeaksTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      totalMicroLeaksTimeMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalMicroLeaksTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      totalMicroLeaksTimeMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalMicroLeaksTimeMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      totalScreenTimeMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalScreenTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      totalScreenTimeMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalScreenTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      totalScreenTimeMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalScreenTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      totalScreenTimeMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalScreenTimeMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      unlockCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      unlockCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      unlockCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterFilterCondition>
      unlockCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DailyStatsQueryObject
    on QueryBuilder<DailyStats, DailyStats, QFilterCondition> {}

extension DailyStatsQueryLinks
    on QueryBuilder<DailyStats, DailyStats, QFilterCondition> {}

extension DailyStatsQuerySortBy
    on QueryBuilder<DailyStats, DailyStats, QSortBy> {
  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy>
      sortByTotalMicroLeaksTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMicroLeaksTimeMs', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy>
      sortByTotalMicroLeaksTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMicroLeaksTimeMs', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> sortByTotalScreenTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalScreenTimeMs', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy>
      sortByTotalScreenTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalScreenTimeMs', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> sortByUnlockCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockCount', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> sortByUnlockCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockCount', Sort.desc);
    });
  }
}

extension DailyStatsQuerySortThenBy
    on QueryBuilder<DailyStats, DailyStats, QSortThenBy> {
  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy>
      thenByTotalMicroLeaksTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMicroLeaksTimeMs', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy>
      thenByTotalMicroLeaksTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMicroLeaksTimeMs', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenByTotalScreenTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalScreenTimeMs', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy>
      thenByTotalScreenTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalScreenTimeMs', Sort.desc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenByUnlockCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockCount', Sort.asc);
    });
  }

  QueryBuilder<DailyStats, DailyStats, QAfterSortBy> thenByUnlockCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockCount', Sort.desc);
    });
  }
}

extension DailyStatsQueryWhereDistinct
    on QueryBuilder<DailyStats, DailyStats, QDistinct> {
  QueryBuilder<DailyStats, DailyStats, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<DailyStats, DailyStats, QDistinct>
      distinctByTotalMicroLeaksTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalMicroLeaksTimeMs');
    });
  }

  QueryBuilder<DailyStats, DailyStats, QDistinct>
      distinctByTotalScreenTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalScreenTimeMs');
    });
  }

  QueryBuilder<DailyStats, DailyStats, QDistinct> distinctByUnlockCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockCount');
    });
  }
}

extension DailyStatsQueryProperty
    on QueryBuilder<DailyStats, DailyStats, QQueryProperty> {
  QueryBuilder<DailyStats, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyStats, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<DailyStats, int, QQueryOperations>
      totalMicroLeaksTimeMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalMicroLeaksTimeMs');
    });
  }

  QueryBuilder<DailyStats, int, QQueryOperations> totalScreenTimeMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalScreenTimeMs');
    });
  }

  QueryBuilder<DailyStats, int, QQueryOperations> unlockCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockCount');
    });
  }
}
