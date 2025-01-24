import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailsPage extends StatelessWidget {
  final Map<String, dynamic> article;
  final String value;

  const ArticleDetailsPage(
      {super.key, required this.article, required this.value});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF5733);
    final DateTime publishedDate = DateTime.parse(article['publishedAt']);
    final formattedDate = DateFormat('MMM d, yyyy').format(publishedDate);

    final String titleFirstLetter = article['title'][0].toUpperCase();

    RichText _buildHighlightedTitle() {
      final String title = article['title'];
      final String searchValue = value.toLowerCase();

      // Split the title into parts
      final parts = title.toLowerCase().split(searchValue);
      final List<TextSpan> textSpans = [];

      for (int i = 0; i < parts.length; i++) {
        // Add normal text
        if (parts[i].isNotEmpty) {
          textSpans.add(TextSpan(
            text: title.substring(title.toLowerCase().indexOf(parts[i]),
                title.toLowerCase().indexOf(parts[i]) + parts[i].length),
            style: const TextStyle(
              fontFamily: 'PTSerif',
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ));
        }

        // Add highlighted text
        if (i < parts.length - 1) {
          final highlightStart = title.toLowerCase().indexOf(
              searchValue,
              i > 0
                  ? title.toLowerCase().indexOf(parts[i]) + parts[i].length
                  : 0);
          textSpans.add(TextSpan(
            text: title.substring(
                highlightStart, highlightStart + searchValue.length),
            style: const TextStyle(
              fontFamily: 'PTSerif',
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              decoration: TextDecoration.underline,
              decorationColor: Colors.red,
              decorationThickness: 2,
            ),
          ));
        }
      }

      return RichText(
        text: TextSpan(
          children: textSpans,
        ),
      );
    }

    Future<void> launchUrlToBrowser(String url) async {
      try {
        final Uri uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch URL: $e')),
        );
      }
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: primaryColor,
                      child: Text(
                        titleFirstLetter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 2,
                      height: 45,
                      color: Colors.black,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 129, 129, 129)),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              article['source']['name'] ?? 'Unknown Source',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 26,
                ),
                value.isNotEmpty &&
                        article['title']
                            .toLowerCase()
                            .contains(value.toLowerCase())
                    ? _buildHighlightedTitle()
                    : Text(
                        article['title'],
                        style: const TextStyle(
                          fontFamily: 'PTSerif',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  article['description'] ?? 'No description available',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 46, 46, 46),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => launchUrlToBrowser(article['url']),
                          child: const Text(
                            'Read Story',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 3,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Share.share(
                          "Check Out This Article! ${article['url']}",
                          subject: article['title'],
                        );
                      },
                      child: const Text(
                        'Share Now',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                article['urlToImage'] != null
                    ? ClipRRect(
                        child: Image.network(
                          article['urlToImage'],
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 250,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.image_not_supported),
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        height: 250,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Text('No image available'),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    article['content'] ?? 'No content available',
                    style: const TextStyle(
                      fontSize: 20,
                      height: 1.6,
                      color: Color.fromARGB(255, 51, 51, 51),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
