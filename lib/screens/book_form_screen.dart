import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';

class BookFormScreen extends StatefulWidget {
  final String? bookId;
  const BookFormScreen({super.key, this.bookId});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _genreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _pagesCtrl = TextEditingController();
  BookStatus _status = BookStatus.toRead;
  String _coverColor = '#6C63FF';
  bool _isEdit = false;

  final List<Map<String, String>> _colorOptions = [
    {'label': 'Purple', 'hex': '#6C63FF'},
    {'label': 'Pink', 'hex': '#FF6584'},
    {'label': 'Teal', 'hex': '#43B89C'},
    {'label': 'Orange', 'hex': '#F7971E'},
    {'label': 'Blue', 'hex': '#2196F3'},
    {'label': 'Red', 'hex': '#E53935'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.bookId != null) {
      _isEdit = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final book = context.read<BookProvider>().getBookById(widget.bookId!);
        if (book != null) {
          _titleCtrl.text = book.title;
          _authorCtrl.text = book.author;
          _genreCtrl.text = book.genre;
          _descCtrl.text = book.description;
          _pagesCtrl.text = book.totalPages > 0 ? book.totalPages.toString() : '';
          setState(() {
            _status = book.status;
            _coverColor = book.coverColor ?? '#6C63FF';
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _genreCtrl.dispose();
    _descCtrl.dispose();
    _pagesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<BookProvider>();

    if (_isEdit) {
      final book = provider.getBookById(widget.bookId!)!;
      provider.updateBook(book.copyWith(
        title: _titleCtrl.text.trim(),
        author: _authorCtrl.text.trim(),
        genre: _genreCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        status: _status,
        totalPages: int.tryParse(_pagesCtrl.text) ?? 0,
        coverColor: _coverColor,
      ));
    } else {
      provider.addBook(
        title: _titleCtrl.text.trim(),
        author: _authorCtrl.text.trim(),
        genre: _genreCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        status: _status,
        totalPages: int.tryParse(_pagesCtrl.text) ?? 0,
        coverColor: _coverColor,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Book' : 'Add Book'),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              'Save',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Cover Color Picker
            Text(
              'Cover Color',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: _colorOptions.map((c) {
                final isSelected = _coverColor == c['hex'];
                return GestureDetector(
                  onTap: () => setState(() => _coverColor = c['hex']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    width: isSelected ? 42 : 36,
                    height: isSelected ? 42 : 36,
                    decoration: BoxDecoration(
                      color: Color(int.parse(c['hex']!.replaceFirst('#', '0xFF'))),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: theme.colorScheme.primary, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? const [BoxShadow(color: Colors.black26, blurRadius: 8)]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            _buildField('Title *', _titleCtrl, required: true),
            const SizedBox(height: 16),
            _buildField('Author *', _authorCtrl, required: true),
            const SizedBox(height: 16),
            _buildField('Genre', _genreCtrl, hint: 'e.g. Fiction, Sci-Fi, Self-Help'),
            const SizedBox(height: 16),
            _buildField('Total Pages', _pagesCtrl,
                keyboardType: TextInputType.number, hint: '0'),
            const SizedBox(height: 16),
            _buildField('Description', _descCtrl,
                maxLines: 4, hint: 'Brief description of the book...'),
            const SizedBox(height: 24),

            Text(
              'Status',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...BookStatus.values.map((status) {
              final record = _statusInfo(status);
              return RadioListTile<BookStatus>(
                value: status,
                groupValue: _status,
                onChanged: (v) => setState(() => _status = v!),
                title: Text('${record.$1} ${record.$2}'),
                subtitle: Text(record.$3),
                contentPadding: EdgeInsets.zero,
              );
            }),

            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _isEdit ? 'Save Changes' : 'Add Book',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  (String, String, String) _statusInfo(BookStatus status) {
    switch (status) {
      case BookStatus.toRead:
        return ('📚', 'To Read', 'Books you want to read');
      case BookStatus.reading:
        return ('📖', 'Reading', 'Currently reading');
      case BookStatus.read:
        return ('✅', 'Read', 'Books you have finished');
    }
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: required
              ? (v) => (v?.trim().isEmpty ?? true) ? 'This field is required' : null
              : null,
        ),
      ],
    );
  }
}