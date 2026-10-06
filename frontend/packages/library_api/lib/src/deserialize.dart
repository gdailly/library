import 'package:library_api/src/model/book_request.dart';
import 'package:library_api/src/model/book_response.dart';
import 'package:library_api/src/model/category_request.dart';
import 'package:library_api/src/model/category_response.dart';
import 'package:library_api/src/model/cover_response.dart';
import 'package:library_api/src/model/isbn_lookup_response.dart';
import 'package:library_api/src/model/library_summary.dart';
import 'package:library_api/src/model/me_response.dart';
import 'package:library_api/src/model/member_request.dart';
import 'package:library_api/src/model/member_response.dart';
import 'package:library_api/src/model/other_reading_response.dart';
import 'package:library_api/src/model/page_response_book_response.dart';
import 'package:library_api/src/model/reading_request.dart';
import 'package:library_api/src/model/reading_response.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

  ReturnType deserialize<ReturnType, BaseType>(dynamic value, String targetType, {bool growable= true}) {
      switch (targetType) {
        case 'String':
          return '$value' as ReturnType;
        case 'int':
          return (value is int ? value : int.parse('$value')) as ReturnType;
        case 'bool':
          if (value is bool) {
            return value as ReturnType;
          }
          final valueString = '$value'.toLowerCase();
          return (valueString == 'true' || valueString == '1') as ReturnType;
        case 'double':
          return (value is double ? value : double.parse('$value')) as ReturnType;
        case 'BookRequest':
          return BookRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BookResponse':
          return BookResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CategoryRequest':
          return CategoryRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CategoryResponse':
          return CategoryResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CoverResponse':
          return CoverResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'IsbnLookupResponse':
          return IsbnLookupResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LibrarySummary':
          return LibrarySummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeResponse':
          return MeResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MemberRequest':
          return MemberRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MemberResponse':
          return MemberResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MetadataSource':
          
          
        case 'OtherReadingResponse':
          return OtherReadingResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PageResponseBookResponse':
          return PageResponseBookResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReadingRequest':
          return ReadingRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReadingResponse':
          return ReadingResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReadingStatus':
          
          
        case 'Role':
          
          
        default:
          RegExpMatch? match;

          if (value is List && (match = _regList.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toList(growable: growable) as ReturnType;
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toSet() as ReturnType;
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
            targetType = match![1]!.trim(); // ignore: parameter_assignments
            return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable)),
            ) as ReturnType;
          }
          break;
    }
    throw Exception('Cannot deserialize');
  }