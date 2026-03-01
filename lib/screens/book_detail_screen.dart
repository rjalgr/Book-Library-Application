import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import 'book_form_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final String bookId;
  const BookDetailScreen({super.key, required this.bookId});

  Color _parseColor(String? hex) {
    if (hex == null) return const Color(0xFF6C63FF);
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    final book = context.watch<BookProvider>().getBookById(bookId);

    if (book == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Book not found')),
      );
    }

    final coverColor = _parseColor(book.coverColor);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        // withAlpha(179) ≈ 70% opacity
                        colors: [coverColor, coverColor.withAlpha(179)],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          width: 100,
                          height: 140,
                          decoration: BoxDecoration(
                            // withAlpha(230) ≈ 90% opacity
                            color: Colors.white.withAlpha(230),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 20,
                                offset: Offset(4, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              book.title
                                  .substring(
                                    0,
                                    book.title.length > 2 ? 2 : book.title.length,
                                  )
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: coverColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _StatusBadge(status: book.status),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookFormScreen(bookId: bookId)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${book.author}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (book.genre.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        // withAlpha(26) ≈ 10% opacity
                        color: coverColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                        // withAlpha(77) ≈ 30% opacity
                        border: Border.all(color: coverColor.withAlpha(77)),
                      ),
                      child: Text(
                        book.genre,
                        style: TextStyle(color: coverColor, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Reading Progress
                  if (book.totalPages > 0) ...[
                    _SectionTitle('Reading Progress'),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: book.readingProgress,
                            minHeight: 12,
                            // withAlpha(38) ≈ 15% opacity
                            backgroundColor: coverColor.withAlpha(38),
                            color: coverColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(book.readingProgress * 100).toInt()}%',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      '${book.currentPage} / ${book.totalPages} pages',
                      style: theme.textTheme.bodySmall?.copyWith(
                        // withAlpha(153) ≈ 60% opacity
                        color: theme.colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ProgressUpdater(book: book),
                    const SizedBox(height: 20),
                  ],

                  // Status
                  _SectionTitle('Status'),
                  const SizedBox(height: 8),
                  _StatusSelector(book: book),
                  const SizedBox(height: 20),

                  // Rating
                  _SectionTitle('Rating'),
                  const SizedBox(height: 8),
                  _RatingSelector(book: book),
                  const SizedBox(height: 20),

                  // Description
                  if (book.description.isNotEmpty) ...[
                    _SectionTitle('Description'),
                    const SizedBox(height: 8),
                    Text(
                      book.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        // withAlpha(204) ≈ 80% opacity
                        color: theme.colorScheme.onSurface.withAlpha(204),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Details
                  _SectionTitle('Details'),
                  const SizedBox(height: 8),
                  _DetailRow(
                    'Added',
                    '${book.addedDate.day}/${book.addedDate.month}/${book.addedDate.year}',
                  ),
                  if (book.totalPages > 0)
                    _DetailRow('Total Pages', '${book.totalPages}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<BookProvider>().deleteBook(bookId);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  // withAlpha(153) ≈ 60% opacity
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    const labels = {
      BookStatus.toRead: '📚 To Read',
      BookStatus.reading: '📖 Reading',
      BookStatus.read: '✅ Read',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        // withAlpha(51) ≈ 20% opacity
        color: Colors.white.withAlpha(51),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        labels[status]!,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final Book book;
  const _StatusSelector({required this.book});

  @override
  Widget build(BuildContext context) {
    const labels = {
      BookStatus.toRead: 'To Read',
      BookStatus.reading: 'Reading',
      BookStatus.read: 'Read',
    };
    return Row(
      children: BookStatus.values.map((status) {
        final isSelected = book.status == status;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor:
                    isSelected ? Theme.of(context).colorScheme.primary : null,
                foregroundColor:
                    isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onPressed: () =>
                  context.read<BookProvider>().updateStatus(book.id, status),
              child: Text(labels[status]!, style: const TextStyle(fontSize: 12)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RatingSelector extends StatelessWidget {
  final Book book;
  const _RatingSelector({required this.book});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final star = i + 1;
        return GestureDetector(
          onTap: () =>
              context.read<BookProvider>().updateRating(book.id, star.toDouble()),
          child: Icon(
            book.rating >= star ? Icons.star_rounded : Icons.star_outline_rounded,
            color: Colors.amber,
            size: 36,
          ),
        );
      }),
    );
  }
}

class _ProgressUpdater extends StatefulWidget {
  final Book book;
  const _ProgressUpdater({required this.book});

  @override
  State<_ProgressUpdater> createState() => _ProgressUpdaterState();
}

class _ProgressUpdaterState extends State<_ProgressUpdater> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.book.currentPage.toString());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Current page',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: () {
            final page = int.tryParse(_ctrl.text) ?? 0;
            context.read<BookProvider>().updateReadingProgress(widget.book.id, page);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Progress updated!')),
            );
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}