import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_api/library_api.dart';

import '../../core/api.dart';

/// Categories of the library, by name, with their number of books.
final categoriesProvider = FutureProvider.autoDispose<List<CategoryResponse>>((ref) async {
  final response = await ref.watch(libraryApiProvider).getCategoriesApi().listCategories();
  return response.data!;
});

/// Members of the library, owners first.
final membersProvider = FutureProvider.autoDispose<List<MemberResponse>>((ref) async {
  final response = await ref.watch(libraryApiProvider).getMembersApi().listMembers();
  return response.data!;
});

/// Colors offered for categories, from the cover palette (all readable under white text).
const categoryColors = [
  '#3E6B48',
  '#2D5D7B',
  '#6B4E8C',
  '#8C3B2E',
  '#8A5F1C',
  '#7A2E4A',
  '#4F5D2F',
  '#2F4858',
];
