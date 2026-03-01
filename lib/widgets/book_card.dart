import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../screens/book_detail_screen.dart';

class BookCard extends StatelessWidget {
  final Book book;
  const BookCard({super.key, required this.book});

  Color get coverColor {
    if (book.coverColor == null) return const Color(0xFF6C63FF);
    return Color(int.parse(book.coverColor!.replaceFirst('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = coverColor;

    return Dismissible(
      key: Key(book.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Book'),
            content: Text('Delete "${book.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => context.read<BookProvider>().deleteBook(book.id),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: book.id)),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Color spine
              Container(
                width: 8,
                height: 100,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                ),
              ),
              // Mini cover
              Container(
                width: 60,
                height: 84,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(38),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withAlpha(77)),
                ),
                child: Center(
                  child: Text(
                    book.title
                        .substring(0, book.title.length > 2 ? 2 : book.title.length)
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        book.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        book.author,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (book.genre.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          book.genre,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(128),
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      if (book.totalPages > 0)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: book.readingProgress,
                            minHeight: 4,
                            // withAlpha(38) ≈ 15% opacity
                            backgroundColor: color.withAlpha(38),
                            color: color,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Status icon + rating
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _statusIcon(book.status, color),
                    const SizedBox(height: 6),
                    if (book.rating > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                          Text(
                            book.rating.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusIcon(BookStatus status, Color color) {
    const icons = {
      BookStatus.toRead: Icons.bookmark_outline,
      BookStatus.reading: Icons.auto_stories,
      BookStatus.read: Icons.check_circle,
    };
    return Icon(icons[status], color: color, size: 22);
  }
}