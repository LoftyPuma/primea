import 'package:flutter/material.dart';
import 'package:primea/model/deck/deck.dart';
import 'package:primea/model/deck/deck_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeckImportModal extends StatefulWidget {
  final String? name;
  final String? code;
  final String? id;

  const DeckImportModal({
    super.key,
    this.name,
    this.code,
    this.id,
  });

  @override
  State<DeckImportModal> createState() => _DeckImportModalState();
}

class _DeckImportModalState extends State<DeckImportModal> {
  final TextEditingController _deckNameController = TextEditingController();
  final TextEditingController _deckCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _deckNameController.text = widget.name ?? "";
    _deckCodeController.text = widget.code ?? "";
  }

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
              try {
                final deckModel = await DeckModel.fromCode(
                  _deckNameController.text,
                  _deckCodeController.text,
                  id: widget.id,
                );
                if (context.mounted) {
                  Navigator.of(context).pop<DeckModel>(deckModel);
                }
              } on PostgrestException catch (e, stackTrace) {
                String message;
                switch (e.code) {
                  case "23505":
                    message =
                        "You already have a deck with that name, choose a different one.";
                    break;
                  case "23514":
                    message = "Deck name must have at least 1 character";
                    break;
                  default:
                    message =
                        "There was an error saving the deck, ensure the deck code is correct";
                }
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      icon: const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                      title: const Text("Error saving deck"),
                      content: Text(message),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
                FlutterError.reportError(
                  FlutterErrorDetails(
                    exception: e,
                    stack: stackTrace,
                    context: ErrorDescription(
                        "Error saving deck (name: '${_deckNameController.text}', code: '${_deckCodeController.text}')"),
                  ),
                );
              } on FormatException catch (e, stackTrace) {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      icon: const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                      title: const Text("Error saving deck"),
                      content: Text("${e.message} (${e.source})"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
                FlutterError.reportError(
                  FlutterErrorDetails(
                    exception: e,
                    stack: stackTrace,
                    context: ErrorDescription(
                        "Error saving deck (name: '${_deckNameController.text}', code: '${_deckCodeController.text}')"),
                  ),
                );
              } catch (e, stackTrace) {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      icon: const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                      title: const Text("Error saving deck"),
                      content: const Text(
                          "There was an error saving the deck, ensure the deck code is correct and you don't already have a deck with that name."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }

                FlutterError.reportError(
                  FlutterErrorDetails(
                    exception: e,
                    stack: stackTrace,
                    context: ErrorDescription(
                        "Error saving deck (name: '${_deckNameController.text}', code: '${_deckCodeController.text}')"),
                  ),
                );
              }
            },
            child: Text(widget.name == null ? "Create" : "Update"),
          ),
        ],
      ),
    );
  }
}
