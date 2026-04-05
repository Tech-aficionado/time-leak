// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_session.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFocusSessionCollection on Isar {
  IsarCollection<FocusSession> get focusSessions => this.collection();
}

const FocusSessionSchema = CollectionSchema(
  name: r'FocusSession',
  id: 7529488139707530527,
  properties: {
    r'actualDurationMs': PropertySchema(
      id: 0,
      name: r'actualDurationMs',
      type: IsarType.long,
    ),
    r'blockedPackages': PropertySchema(
      id: 1,
      name: r'blockedPackages',
      type: IsarType.stringList,
    ),
    r'endTime': PropertySchema(
      id: 2,
      name: r'endTime',
      type: IsarType.dateTime,
    ),
    r'isSuccessful': PropertySchema(
      id: 3,
      name: r'isSuccessful',
      type: IsarType.bool,
    ),
    r'plannedDurationMs': PropertySchema(
      id: 4,
      name: r'plannedDurationMs',
      type: IsarType.long,
    ),
    r'startTime': PropertySchema(
      id: 5,
      name: r'startTime',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _focusSessionEstimateSize,
  serialize: _focusSessionSerialize,
  deserialize: _focusSessionDeserialize,
  deserializeProp: _focusSessionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _focusSessionGetId,
  getLinks: _focusSessionGetLinks,
  attach: _focusSessionAttach,
  version: '3.1.0+1',
);

int _focusSessionEstimateSize(
  FocusSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.blockedPackages.length * 3;
  {
    for (var i = 0; i < object.blockedPackages.length; i++) {
      final value = object.blockedPackages[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _focusSessionSerialize(
  FocusSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.actualDurationMs);
  writer.writeStringList(offsets[1], object.blockedPackages);
  writer.writeDateTime(offsets[2], object.endTime);
  writer.writeBool(offsets[3], object.isSuccessful);
  writer.writeLong(offsets[4], object.plannedDurationMs);
  writer.writeDateTime(offsets[5], object.startTime);
}

FocusSession _focusSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FocusSession();
  object.actualDurationMs = reader.readLongOrNull(offsets[0]);
  object.blockedPackages = reader.readStringList(offsets[1]) ?? [];
  object.endTime = reader.readDateTimeOrNull(offsets[2]);
  object.id = id;
  object.isSuccessful = reader.readBool(offsets[3]);
  object.plannedDurationMs = reader.readLong(offsets[4]);
  object.startTime = reader.readDateTime(offsets[5]);
  return object;
}

P _focusSessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _focusSessionGetId(FocusSession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _focusSessionGetLinks(FocusSession object) {
  return [];
}

void _focusSessionAttach(
    IsarCollection<dynamic> col, Id id, FocusSession object) {
  object.id = id;
}

extension FocusSessionQueryWhereSort
    on QueryBuilder<FocusSession, FocusSession, QWhere> {
  QueryBuilder<FocusSession, FocusSession, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FocusSessionQueryWhere
    on QueryBuilder<FocusSession, FocusSession, QWhereClause> {
  QueryBuilder<FocusSession, FocusSession, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<FocusSession, FocusSession, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterWhereClause> idBetween(
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
}

extension FocusSessionQueryFilter
    on QueryBuilder<FocusSession, FocusSession, QFilterCondition> {
  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      actualDurationMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'actualDurationMs',
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      actualDurationMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'actualDurationMs',
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      actualDurationMsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actualDurationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      actualDurationMsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actualDurationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      actualDurationMsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actualDurationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      actualDurationMsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actualDurationMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      blockedPackagesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockedPackages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      blockedPackagesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'blockedPackages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      blockedPackagesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'blockedPackages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      blockedPackagesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'blockedPackages',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      blockedPackagesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'blockedPackages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      blockedPackagesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'blockedPackages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      blockedPackagesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'blockedPackages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      blockedPackagesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'blockedPackages',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      blockedPackagesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockedPackages',
        value: '',
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      blockedPackagesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'blockedPackages',
        value: '',
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      blockedPackagesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedPackages',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      blockedPackagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedPackages',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      blockedPackagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedPackages',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      blockedPackagesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedPackages',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      blockedPackagesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedPackages',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      blockedPackagesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedPackages',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      endTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      endTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      endTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      endTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      endTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      endTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition> idBetween(
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

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      isSuccessfulEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSuccessful',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      plannedDurationMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'plannedDurationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      plannedDurationMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'plannedDurationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      plannedDurationMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'plannedDurationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      plannedDurationMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'plannedDurationMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      startTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      startTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      startTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterFilterCondition>
      startTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FocusSessionQueryObject
    on QueryBuilder<FocusSession, FocusSession, QFilterCondition> {}

extension FocusSessionQueryLinks
    on QueryBuilder<FocusSession, FocusSession, QFilterCondition> {}

extension FocusSessionQuerySortBy
    on QueryBuilder<FocusSession, FocusSession, QSortBy> {
  QueryBuilder<FocusSession, FocusSession, QAfterSortBy>
      sortByActualDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDurationMs', Sort.asc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy>
      sortByActualDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDurationMs', Sort.desc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy> sortByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy> sortByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy> sortByIsSuccessful() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSuccessful', Sort.asc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy>
      sortByIsSuccessfulDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSuccessful', Sort.desc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy>
      sortByPlannedDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDurationMs', Sort.asc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy>
      sortByPlannedDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDurationMs', Sort.desc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy> sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy> sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension FocusSessionQuerySortThenBy
    on QueryBuilder<FocusSession, FocusSession, QSortThenBy> {
  QueryBuilder<FocusSession, FocusSession, QAfterSortBy>
      thenByActualDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDurationMs', Sort.asc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy>
      thenByActualDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDurationMs', Sort.desc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy> thenByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy> thenByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy> thenByIsSuccessful() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSuccessful', Sort.asc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy>
      thenByIsSuccessfulDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSuccessful', Sort.desc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy>
      thenByPlannedDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDurationMs', Sort.asc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy>
      thenByPlannedDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDurationMs', Sort.desc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy> thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<FocusSession, FocusSession, QAfterSortBy> thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension FocusSessionQueryWhereDistinct
    on QueryBuilder<FocusSession, FocusSession, QDistinct> {
  QueryBuilder<FocusSession, FocusSession, QDistinct>
      distinctByActualDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actualDurationMs');
    });
  }

  QueryBuilder<FocusSession, FocusSession, QDistinct>
      distinctByBlockedPackages() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockedPackages');
    });
  }

  QueryBuilder<FocusSession, FocusSession, QDistinct> distinctByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endTime');
    });
  }

  QueryBuilder<FocusSession, FocusSession, QDistinct> distinctByIsSuccessful() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSuccessful');
    });
  }

  QueryBuilder<FocusSession, FocusSession, QDistinct>
      distinctByPlannedDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'plannedDurationMs');
    });
  }

  QueryBuilder<FocusSession, FocusSession, QDistinct> distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }
}

extension FocusSessionQueryProperty
    on QueryBuilder<FocusSession, FocusSession, QQueryProperty> {
  QueryBuilder<FocusSession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FocusSession, int?, QQueryOperations>
      actualDurationMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actualDurationMs');
    });
  }

  QueryBuilder<FocusSession, List<String>, QQueryOperations>
      blockedPackagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockedPackages');
    });
  }

  QueryBuilder<FocusSession, DateTime?, QQueryOperations> endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endTime');
    });
  }

  QueryBuilder<FocusSession, bool, QQueryOperations> isSuccessfulProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSuccessful');
    });
  }

  QueryBuilder<FocusSession, int, QQueryOperations>
      plannedDurationMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'plannedDurationMs');
    });
  }

  QueryBuilder<FocusSession, DateTime, QQueryOperations> startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }
}
