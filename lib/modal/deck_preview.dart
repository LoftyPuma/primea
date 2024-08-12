import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:primea/main.dart';
import 'package:primea/modal/deck_details.dart';
import 'package:primea/modal/deck_import.dart';
import 'package:primea/model/deck/card_type.dart';
import 'package:primea/model/deck/deck.dart';
import 'package:primea/model/deck/deck_model.dart';
import 'package:primea/model/deck/deck_summary.dart';
import 'package:primea/tracker/paragon.dart';
import 'package:vector_graphics/vector_graphics.dart';

class DeckPreview extends StatefulWidget {
  final Deck deck;
  final Function(Deck) onUpdate;
  final Function() onDelete;

  const DeckPreview({
    super.key,
    required this.deck,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<StatefulWidget> createState() => _DeckPreviewState();
}

class _DeckPreviewState extends State<DeckPreview>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final Animation<double> _zoomAnimation;
  late final Animation<double> _filterAnimation;
  late final Animation<double> _parallelOpacityAnimation;
  late final Animation<double> _typeOpacityAnimation;

  late final AnimationController _copyController;
  late final Animation<double> _copyOpacityAnimation;
  late final Animation<double> _copiedOpacityAnimation;

  @override
  void initState() {
    copyDeckHandler = _handleDeckCopy;

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _zoomAnimation = Tween<double>(begin: 3.7, end: 2.5).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeInOut,
      ),
    );

    _filterAnimation = Tween<double>(begin: .35, end: .65).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeInOut,
      ),
    );

    _parallelOpacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeInOut,
      ),
    );

    _typeOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeInOut,
      ),
    );

    _copyController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _copyOpacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _copyController,
        curve: Curves.linear,
      ),
    );

    _copiedOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _copyController,
        curve: Curves.linear,
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _copyController.dispose();
    super.dispose();
  }

  Function()? copyDeckHandler;

  void _handleDeckCopy() async {
    setState(() {
      copyDeckHandler = null;
    });
    await Clipboard.setData(
      ClipboardData(
        text: widget.deck.toCode(),
      ),
    );
    await _copyController.forward();
    await Future.delayed(const Duration(milliseconds: 2500));
    if (context.mounted) {
      await _copyController.reverse();
    }
    setState(() {
      copyDeckHandler = _handleDeckCopy;
    });
  }

  @override
  Widget build(BuildContext context) {
    final paragon = Paragon.fromCardID(
      widget.deck.cards.keys
          .singleWhere(
            (element) => element.cardType == CardType.paragon,
          )
          .id,
    );
    final summary = DeckSummary(
      deck: widget.deck,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onHover: (hovering) {
        if (hovering) {
          _mainController.forward();
        } else {
          _mainController.reverse();
        }
      },
      onTap: () async {
        final updatedDeck = await showDialog<Deck>(
          context: context,
          anchorPoint: MediaQuery.of(context).size.center(Offset.zero),
          builder: (context) => DeckDetails(
            deck: widget.deck,
          ),
        );
        if (updatedDeck != null) {
          widget.onUpdate(updatedDeck);
        }
      },
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: widget.deck.isUniversal
                ? ParallelType.universal.color
                : widget.deck.paragon.parallel.color.withAlpha(100),
            width: 2,
          ),
        ),
        elevation: 4,
        shadowColor: widget.deck.isUniversal
            ? ParallelType.universal.color
            : widget.deck.paragon.parallel.color,
        child: ListenableBuilder(
          listenable: _mainController,
          builder: (context, _) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: const Alignment(0, .3),
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      alignment: Alignment.topCenter,
                      image: AssetImage(paragon.art!),
                      fit: BoxFit.none,
                      filterQuality: FilterQuality.none,
                      scale: _zoomAnimation.value,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(_filterAnimation.value),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _typeOpacityAnimation,
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete,
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Deck"),
                            content: Text(
                              "Are you sure you want to delete ${widget.deck.name}?",
                            ),
                            actions: [
                              TextButton.icon(
                                icon: const Icon(Icons.cancel),
                                label: const Text("Cancel"),
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                              ),
                              FilledButton.icon(
                                icon: const Icon(Icons.delete),
                                label: const Text("Delete"),
                                style: ButtonStyle(
                                  foregroundColor: WidgetStatePropertyAll(
                                    Theme.of(context)
                                        .colorScheme
                                        .onErrorContainer,
                                  ),
                                  backgroundColor: WidgetStatePropertyAll(
                                    Theme.of(context)
                                        .colorScheme
                                        .errorContainer,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await supabase
                              .from(Deck.deckTableName)
                              .delete()
                              .eq('name', widget.deck.name);
                          widget.onDelete();
                        }
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  right: 0,
                  child: FadeTransition(
                    opacity: _typeOpacityAnimation,
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                      ),
                      onPressed: () async {
                        final newDeckModel = await showDialog<DeckModel>(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: DeckImportModal(
                                name: widget.deck.name,
                                code: widget.deck.toCode(),
                                createdAt: widget.deck.createdAt,
                              ),
                            );
                          },
                        );
                        if (newDeckModel != null) {
                          widget.onUpdate(await newDeckModel.toDeck());
                        }
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: FadeTransition(
                    opacity: _typeOpacityAnimation,
                    child: FittedBox(
                      child: RichText(
                        text: TextSpan(
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                            shadows: [
                              const Shadow(
                                color: Colors.black,
                                blurRadius: 25,
                              ),
                            ],
                          ),
                          children: [
                            if (summary.unitCount > 0)
                              TextSpan(
                                text:
                                    "${summary.unitCount.toString().padLeft(2, "0")} units\n",
                              ),
                            if (summary.effectCount > 0)
                              TextSpan(
                                text:
                                    "${summary.effectCount.toString().padLeft(2, "0")} effects\n",
                              ),
                            if (summary.relicCount > 0)
                              TextSpan(
                                text:
                                    "${summary.relicCount.toString().padLeft(2, "0")} relics\n",
                              ),
                            if (summary.upgradeCount > 0)
                              TextSpan(
                                text:
                                    "${summary.upgradeCount.toString().padLeft(2, "0")} upgrades\n",
                              ),
                            if (summary.splitUnitEffectCount > 0)
                              TextSpan(
                                text:
                                    "${summary.splitUnitEffectCount.toString().padLeft(2, "0")} split",
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: _typeOpacityAnimation,
                  // Make this change to show 'copied' when the code is copied
                  child: Stack(
                    children: [
                      FadeTransition(
                        opacity: _copiedOpacityAnimation,
                        child: TextButton.icon(
                          label: const Text("Copied"),
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      FadeTransition(
                        opacity: _copyOpacityAnimation,
                        child: TextButton.icon(
                          label: const Text("Copy Code"),
                          icon: const Icon(Icons.copy),
                          onPressed: copyDeckHandler,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: FadeTransition(
                    opacity: _parallelOpacityAnimation,
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          shadows: [
                            const Shadow(
                              color: Colors.black,
                              blurRadius: 25,
                            ),
                          ],
                        ),
                        children: summary.parallelTypeCount.entries
                            .map(
                              (entry) => TextSpan(
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: SizedBox.square(
                                      dimension: 24,
                                      child: SvgPicture(
                                        width: 24,
                                        height: 24,
                                        AssetBytesLoader(
                                          "assets/parallel_logos/vec/${entry.key.name}.svg.vec",
                                        ),
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcATop,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        entry.value.toString().padLeft(2, "0"),
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const TextSpan(text: "\n"),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: [
                          TextSpan(
                            text: widget.deck.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const TextSpan(text: "\n"),
                          TextSpan(
                            text: paragon.title,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
