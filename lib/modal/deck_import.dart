import 'package:flutter/material.dart';
import 'package:parallel_stats/model/deck/deck.dart';

class DeckImportModal extends StatefulWidget {
  final Function onImport;

  const DeckImportModal({super.key, required this.onImport});

  @override
  State<DeckImportModal> createState() => _DeckImportModalState();
}

class _DeckImportModalState extends State<DeckImportModal> {
  final TextEditingController _deckNameController = TextEditingController();
  final TextEditingController _deckCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Create New Deck"),
          SizedBox(
            width: 350,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _deckNameController,
                decoration: const InputDecoration(
                  labelText: "Deck Name",
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextFormField(
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Deck Code",
              ),
              validator: (value) => Deck.deckCodePattern.hasMatch(value ?? "")
                  ? null
                  : "Invalid deck code",
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _deckCodeController,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final deck = await Deck.fromString(
                _deckNameController.text,
                _deckCodeController.text,
              );
              if (context.mounted) {
                Navigator.of(context).pop(deck);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}
