// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_coin_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarCoinCollection on Isar {
  IsarCollection<IsarCoin> get isarCoins => this.collection();
}

const IsarCoinSchema = CollectionSchema(
  name: r'IsarCoin',
  id: -811442212718744781,
  properties: {
    r'coinId': PropertySchema(
      id: 0,
      name: r'coinId',
      type: IsarType.string,
    ),
    r'imageUrl': PropertySchema(
      id: 1,
      name: r'imageUrl',
      type: IsarType.string,
    ),
    r'marketCapRank': PropertySchema(
      id: 2,
      name: r'marketCapRank',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 3,
      name: r'name',
      type: IsarType.string,
    ),
    r'price': PropertySchema(
      id: 4,
      name: r'price',
      type: IsarType.double,
    ),
    r'priceChange24H': PropertySchema(
      id: 5,
      name: r'priceChange24H',
      type: IsarType.double,
    ),
    r'priceChangePercentage24H': PropertySchema(
      id: 6,
      name: r'priceChangePercentage24H',
      type: IsarType.double,
    ),
    r'symbol': PropertySchema(
      id: 7,
      name: r'symbol',
      type: IsarType.string,
    )
  },
  estimateSize: _isarCoinEstimateSize,
  serialize: _isarCoinSerialize,
  deserialize: _isarCoinDeserialize,
  deserializeProp: _isarCoinDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _isarCoinGetId,
  getLinks: _isarCoinGetLinks,
  attach: _isarCoinAttach,
  version: '3.1.0+1',
);

int _isarCoinEstimateSize(
  IsarCoin object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.coinId.length * 3;
  bytesCount += 3 + object.imageUrl.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.symbol.length * 3;
  return bytesCount;
}

void _isarCoinSerialize(
  IsarCoin object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.coinId);
  writer.writeString(offsets[1], object.imageUrl);
  writer.writeLong(offsets[2], object.marketCapRank);
  writer.writeString(offsets[3], object.name);
  writer.writeDouble(offsets[4], object.price);
  writer.writeDouble(offsets[5], object.priceChange24H);
  writer.writeDouble(offsets[6], object.priceChangePercentage24H);
  writer.writeString(offsets[7], object.symbol);
}

IsarCoin _isarCoinDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarCoin();
  object.coinId = reader.readString(offsets[0]);
  object.id = id;
  object.imageUrl = reader.readString(offsets[1]);
  object.marketCapRank = reader.readLong(offsets[2]);
  object.name = reader.readString(offsets[3]);
  object.price = reader.readDouble(offsets[4]);
  object.priceChange24H = reader.readDouble(offsets[5]);
  object.priceChangePercentage24H = reader.readDouble(offsets[6]);
  object.symbol = reader.readString(offsets[7]);
  return object;
}

P _isarCoinDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarCoinGetId(IsarCoin object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarCoinGetLinks(IsarCoin object) {
  return [];
}

void _isarCoinAttach(IsarCollection<dynamic> col, Id id, IsarCoin object) {
  object.id = id;
}

extension IsarCoinQueryWhereSort on QueryBuilder<IsarCoin, IsarCoin, QWhere> {
  QueryBuilder<IsarCoin, IsarCoin, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarCoinQueryWhere on QueryBuilder<IsarCoin, IsarCoin, QWhereClause> {
  QueryBuilder<IsarCoin, IsarCoin, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<IsarCoin, IsarCoin, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterWhereClause> idBetween(
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

extension IsarCoinQueryFilter
    on QueryBuilder<IsarCoin, IsarCoin, QFilterCondition> {
  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> coinIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coinId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> coinIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coinId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> coinIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coinId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> coinIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coinId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> coinIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'coinId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> coinIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'coinId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> coinIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'coinId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> coinIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'coinId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> coinIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coinId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> coinIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'coinId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> idBetween(
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

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> imageUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> imageUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> imageUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> imageUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> imageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> imageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> imageUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> imageUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> imageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> imageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> marketCapRankEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'marketCapRank',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition>
      marketCapRankGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'marketCapRank',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> marketCapRankLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'marketCapRank',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> marketCapRankBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'marketCapRank',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> priceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'price',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> priceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'price',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> priceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'price',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> priceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'price',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> priceChange24HEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priceChange24H',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition>
      priceChange24HGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priceChange24H',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition>
      priceChange24HLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priceChange24H',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> priceChange24HBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priceChange24H',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition>
      priceChangePercentage24HEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priceChangePercentage24H',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition>
      priceChangePercentage24HGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priceChangePercentage24H',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition>
      priceChangePercentage24HLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priceChangePercentage24H',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition>
      priceChangePercentage24HBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priceChangePercentage24H',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> symbolEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> symbolGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> symbolLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> symbolBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'symbol',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> symbolStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> symbolEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> symbolContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> symbolMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'symbol',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> symbolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'symbol',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterFilterCondition> symbolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'symbol',
        value: '',
      ));
    });
  }
}

extension IsarCoinQueryObject
    on QueryBuilder<IsarCoin, IsarCoin, QFilterCondition> {}

extension IsarCoinQueryLinks
    on QueryBuilder<IsarCoin, IsarCoin, QFilterCondition> {}

extension IsarCoinQuerySortBy on QueryBuilder<IsarCoin, IsarCoin, QSortBy> {
  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> sortByCoinId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coinId', Sort.asc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> sortByCoinIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coinId', Sort.desc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> sortByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> sortByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> sortByMarketCapRank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketCapRank', Sort.asc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> sortByMarketCapRankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketCapRank', Sort.desc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> sortByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.asc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> sortByPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.desc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> sortByPriceChange24H() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceChange24H', Sort.asc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> sortByPriceChange24HDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceChange24H', Sort.desc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy>
      sortByPriceChangePercentage24H() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceChangePercentage24H', Sort.asc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy>
      sortByPriceChangePercentage24HDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceChangePercentage24H', Sort.desc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> sortBySymbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.asc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> sortBySymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.desc);
    });
  }
}

extension IsarCoinQuerySortThenBy
    on QueryBuilder<IsarCoin, IsarCoin, QSortThenBy> {
  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> thenByCoinId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coinId', Sort.asc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> thenByCoinIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coinId', Sort.desc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> thenByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> thenByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> thenByMarketCapRank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketCapRank', Sort.asc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> thenByMarketCapRankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketCapRank', Sort.desc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> thenByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.asc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> thenByPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.desc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> thenByPriceChange24H() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceChange24H', Sort.asc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> thenByPriceChange24HDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceChange24H', Sort.desc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy>
      thenByPriceChangePercentage24H() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceChangePercentage24H', Sort.asc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy>
      thenByPriceChangePercentage24HDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceChangePercentage24H', Sort.desc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> thenBySymbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.asc);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QAfterSortBy> thenBySymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.desc);
    });
  }
}

extension IsarCoinQueryWhereDistinct
    on QueryBuilder<IsarCoin, IsarCoin, QDistinct> {
  QueryBuilder<IsarCoin, IsarCoin, QDistinct> distinctByCoinId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coinId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QDistinct> distinctByImageUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QDistinct> distinctByMarketCapRank() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'marketCapRank');
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QDistinct> distinctByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'price');
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QDistinct> distinctByPriceChange24H() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priceChange24H');
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QDistinct>
      distinctByPriceChangePercentage24H() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priceChangePercentage24H');
    });
  }

  QueryBuilder<IsarCoin, IsarCoin, QDistinct> distinctBySymbol(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'symbol', caseSensitive: caseSensitive);
    });
  }
}

extension IsarCoinQueryProperty
    on QueryBuilder<IsarCoin, IsarCoin, QQueryProperty> {
  QueryBuilder<IsarCoin, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarCoin, String, QQueryOperations> coinIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coinId');
    });
  }

  QueryBuilder<IsarCoin, String, QQueryOperations> imageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageUrl');
    });
  }

  QueryBuilder<IsarCoin, int, QQueryOperations> marketCapRankProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'marketCapRank');
    });
  }

  QueryBuilder<IsarCoin, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<IsarCoin, double, QQueryOperations> priceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'price');
    });
  }

  QueryBuilder<IsarCoin, double, QQueryOperations> priceChange24HProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priceChange24H');
    });
  }

  QueryBuilder<IsarCoin, double, QQueryOperations>
      priceChangePercentage24HProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priceChangePercentage24H');
    });
  }

  QueryBuilder<IsarCoin, String, QQueryOperations> symbolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'symbol');
    });
  }
}
