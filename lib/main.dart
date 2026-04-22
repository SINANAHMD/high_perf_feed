import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fiytjcbtrqjcjtzypesd.supabase.co',
    anonKey: 'sb_publishable_91lkwsqPUezby6MxygvZvQ_fYoJmUbh',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FeedScreen(),
    );
  }
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final supabase = Supabase.instance.client;
  final ScrollController scrollController = ScrollController();

  List posts = [];
  int page = 0;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        loadMore();
      }
    });
  }

  Future<void> fetchPosts() async {
    if (isLoading) return;

    isLoading = true;

    final data = await supabase
        .from('posts')
        .select()
        .order('created_at', ascending: false)
        .range(page * 10, page * 10 + 9);

    for (var item in data) {
      item['is_liked'] = false;
    }

    if (data.isEmpty) {
      hasMore = false;
    } else {
      setState(() {
        posts.addAll(data);
        page++;
      });
    }

    isLoading = false;
  }

  Future<void> refreshFeed() async {
    page = 0;
    posts.clear();
    hasMore = true;
    await fetchPosts();
  }

  void loadMore() {
    if (!hasMore || isLoading) return;
    fetchPosts();
  }

  Future<void> toggleLike(int index) async {
    final post = posts[index];

    if (post['is_liked'] == true) return;

    final oldCount = post['like_count'];

    setState(() {
      post['is_liked'] = true;
      post['like_count'] = oldCount + 1;
    });

    try {
      await supabase.rpc('toggle_like', params: {
        'p_post_id': post['id'],
        'p_user_id': 'user_123',
      });
    } catch (e) {
      setState(() {
        post['is_liked'] = false;
        post['like_count'] = oldCount;
      });
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 176, 176),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 2, 68),
        title: const Text(
          "Feed",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refreshFeed,
              child: ListView.builder(
                controller: scrollController,
                itemCount: posts.length + 1,
                itemBuilder: (context, index) {
                  if (index < posts.length) {
                    final post = posts[index];

                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: RepaintBoundary(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 235, 101, 101),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 25,
                                color: const Color.fromARGB(255, 224, 221, 221).withOpacity(0.1),
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onDoubleTap: () => toggleLike(index),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DetailScreen(post: post),
                                    ),
                                  );
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Hero(
                                      tag: post['id'],
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(20)),
                                        child: Image.network(
                                          post['media_thumb_url'],
                                          cacheWidth: 300,
                                          width: double.infinity,
                                          height: 220,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    if (post['is_liked'] == true)
                                      const Icon(
                                        Icons.favorite,
                                        color: Colors.white,
                                        size: 80,
                                      )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => toggleLike(index),
                                      icon: Icon(
                                        Icons.favorite,
                                        color: post['is_liked']
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      "${post['like_count']}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return hasMore
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                                child: CircularProgressIndicator()),
                          )
                        : const SizedBox();
                  }
                },
              ),
            ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final dynamic post;

  const DetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: Hero(
          tag: post['id'],
          child: Image.network(post['media_mobile_url']),
        ),
      ),
    );
  }
}