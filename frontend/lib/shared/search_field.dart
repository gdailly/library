import 'dart:async';

import 'package:material_ui/material_ui.dart';

/// Search as the user types, 300 ms after the last key.
class SearchField extends StatefulWidget {
  const SearchField({super.key, required this.onChanged, this.hint = 'Titre, auteur, ISBN…'});

  final ValueChanged<String> onChanged;
  final String hint;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search),
        isDense: true,
      ),
      textInputAction: TextInputAction.search,
      onChanged: (text) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () => widget.onChanged(text));
      },
      onSubmitted: (text) {
        _debounce?.cancel();
        widget.onChanged(text);
      },
    );
  }
}
