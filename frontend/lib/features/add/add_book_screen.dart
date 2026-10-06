import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'add_book_panel.dart';

/// Opens the camera and returns the scanned ISBN ('' to type it, null when closed).
Future<String?> scanIsbn(BuildContext context) => context.push<String>('/scan');

/// Adding a book on a phone: a page of its own.
class AddBookScreen extends StatelessWidget {
  const AddBookScreen({super.key, this.isbn});

  final String? isbn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un livre')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: AddBookPanel(
          initialIsbn: isbn,
          onAdded: (book) => context.pushReplacement('/books/${book.id}'),
          onScan: () => scanIsbn(context),
        ),
      ),
    );
  }
}

/// Adding a book on a wide screen: a modal window over the library (Web · Ajout).
Future<void> showAddBookDialog(BuildContext context) => showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 18, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Ajouter un livre', style: Theme.of(dialogContext).textTheme.headlineSmall),
                    ),
                    IconButton(
                      tooltip: 'Fermer',
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                  child: AddBookPanel(
                    onAdded: (book) {
                      Navigator.of(dialogContext).pop();
                      context.push('/books/${book.id}');
                    },
                    onScan: () => scanIsbn(dialogContext),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
