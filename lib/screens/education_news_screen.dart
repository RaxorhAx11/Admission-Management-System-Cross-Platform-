import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:admission_management/core/theme/app_theme.dart';
import 'package:admission_management/widgets/app_card.dart';
import 'package:admission_management/widgets/loading_widget.dart';

/// Education News / Updates: fetch from public API, show in ListView.
class EducationNewsScreen extends StatefulWidget {
  const EducationNewsScreen({super.key});

  @override
  State<EducationNewsScreen> createState() => _EducationNewsScreenState();
}

class _EducationNewsScreenState extends State<EducationNewsScreen> {
  static const String _url = 'https://jsonplaceholder.typicode.com/posts';

  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse(_url)).timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Request timed out'),
          );
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          _posts = list
              .map((e) => (e as Map<String, dynamic>).map(
                    (k, v) => MapEntry(k.toString(), v),
                  ))
              .toList();
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _loading = false;
          _error = 'Failed to load (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Education News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _fetchPosts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading && _posts.isEmpty
          ? const LoadingWidget()
          : _error != null && _posts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchPosts,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    final title = post['title']?.toString() ?? '';
                    final body = post['body']?.toString() ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              body,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
