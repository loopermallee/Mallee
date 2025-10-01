import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ArticleApp());
}

class Article {
  final String title;
  final String description;
  final String content;

  const Article({
    required this.title,
    required this.description,
    required this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] as String,
      description: json['description'] as String,
      content: json['content'] as String,
    );
  }
}

class ArticleRepository {
  const ArticleRepository();

  Future<List<Article>> fetchArticles() async {
    final rawJson = await rootBundle.loadString('assets/articles.json');
    final List<dynamic> data = jsonDecode(rawJson) as List<dynamic>;
    return data
        .map((dynamic item) =>
            Article.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

class ArticleApp extends StatelessWidget {
  const ArticleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Article App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ArticleListScreen(),
    );
  }
}

class ArticleListScreen extends StatefulWidget {
  const ArticleListScreen({super.key});

  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  late final Future<List<Article>> _articlesFuture;
  final ArticleRepository _repository = const ArticleRepository();

  @override
  void initState() {
    super.initState();
    _articlesFuture = _repository.fetchArticles();
  }

  void _openArticle(BuildContext context, Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(article: article),
      ),
    );
  }

  Future<void> _startSearch(BuildContext context, List<Article> articles) async {
    final Article? selectedArticle = await showSearch<Article?>(
      context: context,
      delegate: ArticleSearchDelegate(articles),
    );

    if (!mounted || selectedArticle == null) return;

    _openArticle(context, selectedArticle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
      ),
      body: FutureBuilder<List<Article>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Something went wrong while loading the articles.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final articles = snapshot.data;

          if (articles == null || articles.isEmpty) {
            return const Center(child: Text('No articles available.'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () => _startSearch(context, articles),
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: articles.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return ListTile(
                      title: Text(article.title),
                      subtitle: Text(article.description),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openArticle(context, article),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ArticleSearchDelegate extends SearchDelegate<Article?> {
  ArticleSearchDelegate(this.articles)
      : super(searchFieldLabel: 'Search articles');

  final List<Article> articles;

  Iterable<Article> _filter(String query) {
    return articles.where(
      (article) => article.title.toLowerCase().contains(query.toLowerCase()),
    );
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredArticles = _filter(query);

    if (query.isEmpty) {
      return const Center(
        child: Text('Start typing to search through the articles.'),
      );
    }

    if (filteredArticles.isEmpty) {
      return const Center(child: Text('No results found.'));
    }

    return ListView.builder(
      itemCount: filteredArticles.length,
      itemBuilder: (context, index) {
        final article = filteredArticles.elementAt(index);
        return ListTile(
          title: Text(article.title),
          subtitle: Text(article.description),
          onTap: () => close(context, article),
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredArticles = _filter(query);

    if (filteredArticles.isEmpty) {
      return const Center(child: Text('No results found.'));
    }

    return ListView.builder(
      itemCount: filteredArticles.length,
      itemBuilder: (context, index) {
        final article = filteredArticles.elementAt(index);
        return ListTile(
          title: Text(article.title),
          subtitle: Text(article.description),
          onTap: () => close(context, article),
        );
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    if (query.isEmpty) {
      return null;
    }

    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }
}

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            article.content,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
