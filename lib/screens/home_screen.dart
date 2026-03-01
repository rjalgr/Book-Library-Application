import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../widgets/book_card.dart';
import 'book_form_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'My Library',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${provider.totalBooks} books',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        Row(children: [
                          _StatChip(label: '📖 ${provider.readingBooks} Reading'),
                          const SizedBox(width: 8),
                          _StatChip(label: '✅ ${provider.readBooks} Read'),
                          const SizedBox(width: 8),
                          _StatChip(label: '📚 ${provider.toReadBooks} To Read'),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: theme.scaffoldBackgroundColor,
                child: TabBar(
                  controller: _tabController,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurface.withAlpha(128),
                  indicatorColor: theme.colorScheme.primary,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Reading'),
                    Tab(text: 'To Read'),
                    Tab(text: 'Read'),
                  ],
                  onTap: (index) {
                    final statuses = [
                      null,
                      BookStatus.reading,
                      BookStatus.toRead,
                      BookStatus.read,
                    ];
                    provider.setFilterStatus(statuses[index]);
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search books, authors...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.setSearch('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: provider.setSearch,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _GenreFilterButton(),
                ],
              ),
            ),
          ),
        ],
        body: const _BookList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  const _StatChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // withAlpha(51) ≈ 20% opacity
        color: Colors.white.withAlpha(51),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}

class _GenreFilterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();
    final genres = provider.allGenres;
    final isFiltered = provider.filterGenre.isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => _GenreFilterSheet(genres: genres),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isFiltered
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Icon(
          Icons.filter_list,
          color: isFiltered ? Colors.white : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _GenreFilterSheet extends StatelessWidget {
  final List<String> genres;
  const _GenreFilterSheet({required this.genres});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(
            'Filter by Genre',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('All Genres'),
            leading: Radio<String>(
              value: '',
              groupValue: provider.filterGenre,
              onChanged: (v) {
                provider.setFilterGenre('');
                Navigator.pop(context);
              },
            ),
          ),
          ...genres.map((g) => ListTile(
                title: Text(g),
                leading: Radio<String>(
                  value: g,
                  groupValue: provider.filterGenre,
                  onChanged: (v) {
                    provider.setFilterGenre(g);
                    Navigator.pop(context);
                  },
                ),
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _BookList extends StatelessWidget {
  const _BookList();

  @override
  Widget build(BuildContext context) {
    final books = context.watch<BookProvider>().books;

    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 80,
              // withAlpha(77) ≈ 30% opacity
              color: Theme.of(context).colorScheme.primary.withAlpha(77),
            ),
            const SizedBox(height: 16),
            Text(
              'No books found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                // withAlpha(128) ≈ 50% opacity
                color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first book!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                // withAlpha(102) ≈ 40% opacity
                color: Theme.of(context).colorScheme.onSurface.withAlpha(102),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: books.length,
      itemBuilder: (context, index) => BookCard(book: books[index]),
    );
  }
}