import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  // withAlpha(77) ≈ 30% opacity
                  backgroundColor: Colors.white.withAlpha(77),
                  child: const Icon(Icons.person, size: 36, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Book Reader',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider.totalBooks} books in library',
                      // withAlpha(204) ≈ 80% opacity
                      style: TextStyle(color: Colors.white.withAlpha(204)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats
          Text(
            'Reading Statistics',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatCard('Total', provider.totalBooks.toString(), Icons.menu_book,
                  theme.colorScheme.primary),
              const SizedBox(width: 12),
              _StatCard('Read', provider.readBooks.toString(), Icons.check_circle, Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatCard('Reading', provider.readingBooks.toString(), Icons.auto_stories,
                  Colors.orange),
              const SizedBox(width: 12),
              _StatCard('To Read', provider.toReadBooks.toString(), Icons.bookmark, Colors.blue),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            'Preferences',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Switch between light and dark theme'),
                  secondary: Icon(provider.isDarkTheme ? Icons.dark_mode : Icons.light_mode),
                  value: provider.isDarkTheme,
                  onChanged: (_) => provider.toggleTheme(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.filter_list_off),
                  title: const Text('Clear All Filters'),
                  subtitle: const Text('Reset search and genre filters'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    provider.clearFilters();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filters cleared!')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'About',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  trailing: Text('1.0.0', style: TextStyle(color: Colors.grey)),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.code),
                  title: Text('Built with Flutter & Provider'),
                  subtitle: Text('Multi-screen • State Management'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // withAlpha(26) ≈ 10% opacity
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          // withAlpha(51) ≈ 20% opacity
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
                ),
                Text(
                  label,
                  // withAlpha(204) ≈ 80% opacity
                  style: TextStyle(color: color.withAlpha(204), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}