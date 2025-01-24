import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'article_detailsPage.dart';
import 'ui_helper/article_card.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> articles = [];
  List<dynamic> filteredArticles = [];
  bool isLoading = true;
  String errorMessage = '';
  String selectedCategory = 'News';
  final Color primaryColor = const Color(0xFFFF5733);

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.newspaper, 'label': 'News', 'query': 'news'},
    {'icon': Icons.movie, 'label': 'Entertainment', 'query': 'entertainment'},
    {'icon': Icons.sports_basketball, 'label': 'Sports', 'query': 'sports'},
    {'icon': Icons.attach_money, 'label': 'Business', 'query': 'business'},
    {'icon': Icons.gavel, 'label': 'Crime', 'query': 'crime'},
  ];

  Future<void> fetchNews() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    var query = categories
        .firstWhere((cat) => cat['label'] == selectedCategory)['query'];

    DateTime currentDate = DateTime.now();
    DateTime oneMonthAgo =
        DateTime(currentDate.year, currentDate.month - 1, currentDate.day);

    String formattedDate = DateFormat('yyyy-MM-dd').format(oneMonthAgo);

    var url =
        "https://newsapi.org/v2/everything?q=$query&from=$formattedDate&sortBy=publishedAt&apiKey=374ef460d0874ddab7fef23f69746042";

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        setState(() {
          articles = jsonData['articles'] ?? [];
          filteredArticles = articles;
          isLoading = false;
        });
        print(articles);
      } else {
        setState(() {
          errorMessage = 'Failed to load news';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error connecting to the server';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  void filterData(String query) {
    if (query.isEmpty) {
      setState(() => filteredArticles = articles);
      return;
    }

    setState(() {
      filteredArticles = articles
          .where((article) => article['title']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
      searchController.clear();
    });
    fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'NEWS',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, y').format(DateTime.now()),
                    style: const TextStyle(
                        fontFamily: 'PTSerif',
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Hey, James!',
                style: TextStyle(
                    color: Color.fromARGB(255, 126, 126, 126),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Discover Latest News',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 254, 254),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 1,
                            offset: const Offset(2, 1),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: filterData,
                        decoration: InputDecoration(
                          hintText: 'Search news...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        filterData(searchController.text);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategory == category['label'];
                    return GestureDetector(
                      onTap: () => selectCategory(category['label']),
                      child: Container(
                        width: 74,
                        margin: const EdgeInsets.only(right: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor:
                                  isSelected ? primaryColor : Colors.grey[200],
                              child: Icon(
                                category['icon'],
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[600],
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category['label'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey[600],
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 36),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage.isNotEmpty
                        ? Center(child: Text(errorMessage))
                        : RefreshIndicator(
                            onRefresh: fetchNews,
                            child: filteredArticles.isEmpty
                                ? const Center(child: Text('No articles found'))
                                : ListView.builder(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    itemCount: filteredArticles.length,
                                    itemBuilder: (context, index) {
                                      var article = filteredArticles[index];
                                      return article['urlToImage'] != null &&
                                              article['title'] != null &&
                                              article['publishedAt'] != null
                                          ? GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ArticleDetailsPage(
                                                      article: article,
                                                      value: searchController
                                                          .value.text,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: ArticleCard(
                                                image: article['urlToImage'],
                                                title: article['title'],
                                                date: article['publishedAt'],
                                              ),
                                            )
                                          : const SizedBox.shrink();
                                    },
                                  ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
