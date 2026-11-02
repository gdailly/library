/// "Une aventure d'Astérix · tome 3", or the series alone.
String seriesLabel(String series, int? number) => number == null ? series : '$series · tome $number';

/// Route of a series' page.
String seriesLocation(String series) => '/series/books?name=${Uri.encodeQueryComponent(series)}';

/// Volume numbers in short: [1, 2, 3, 5, 7, 8] → "1 à 3, 5, 7, 8".
String volumeRanges(List<int> numbers) {
  final sorted = [...numbers]..sort();
  final parts = <String>[];
  var index = 0;
  while (index < sorted.length) {
    var end = index;
    while (end + 1 < sorted.length && sorted[end + 1] == sorted[end] + 1) {
      end++;
    }
    if (end - index >= 2) {
      parts.add('${sorted[index]} à ${sorted[end]}');
    } else {
      for (var i = index; i <= end; i++) {
        parts.add('${sorted[i]}');
      }
    }
    index = end + 1;
  }
  return parts.join(', ');
}

/// "1 album", "3 albums".
String albumCount(int count) => count <= 1 ? '$count album' : '$count albums';
