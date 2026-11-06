import 'popular_result.dart';

class RelatedKeyword {
  final String keyword;
  final String link;

  RelatedKeyword({required this.keyword, required this.link});

  factory RelatedKeyword.fromJson(Map<String, dynamic> json) {
    return RelatedKeyword(
      keyword: json['keyword'] ?? '',
      link: json['link'] ?? '',
    );
  }
}

class SearchResponse {
  final String? description;
  final List<PopularResult> popularResults;
  final List<RelatedKeyword> relatedKeywords;

  SearchResponse({
    this.description,
    required this.popularResults,
    required this.relatedKeywords,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      description: json['description'],
      popularResults:
          (json['popular_results'] as List<dynamic>?)
              ?.map((e) => PopularResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      relatedKeywords:
          (json['related_keywords'] as List<dynamic>?)
              ?.map((e) => RelatedKeyword.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
