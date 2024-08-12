import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:primea/modal/deck_import.dart';
import 'package:primea/model/deck/card_type.dart';
import 'package:primea/model/deck/deck.dart';
import 'package:primea/model/deck/deck_model.dart';
import 'package:primea/model/deck/deck_summary.dart';
import 'package:primea/model/deck/card_function.dart';
import 'package:primea/painters/stacked_line_graph.dart';
import 'package:primea/tracker/paragon.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:collection/collection.dart';

class DeckDetails extends StatefulWidget {
  final Deck deck;
  const DeckDetails({
    super.key,
    required this.deck,
  });

  @override
  State<StatefulWidget> createState() => _DeckDetailsState();
}

class _DeckDetailsState extends State<DeckDetails> {
  late final Paragon paragon;
  late final DeckSummary summary;
  late final List<MapEntry<CardFunction, int>> cards;

  final Map<Iterable<MapEntry<CardFunction, int>>, bool> _states = {};

  @override
  void initState() {
    super.initState();

    paragon = Paragon.fromCardID(
      widget.deck.cards.keys
          .singleWhere(
            (element) => element.cardType == CardType.paragon,
          )
          .id,
    );
    summary = DeckSummary(
      deck: widget.deck,
    );

    cards = widget.deck.cards.entries
        .where((card) => card.key.cardType != CardType.paragon)
        .sorted((a, b) => a.key.cost.compareTo(b.key.cost));

    for (var cardType in [
      CardType.unit,
      CardType.effect,
      CardType.upgrade,
      CardType.relic,
      CardType.splitUnitEffect,
    ]) {
      final filteredCards =
          cards.where((card) => card.key.cardType == cardType);
      if (filteredCards.isNotEmpty) {
        _states[filteredCards] = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deckColor = widget.deck.isUniversal
        ? ParallelType.universal.color
        : paragon.parallel.color.withAlpha(100);
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        shadowColor: deckColor,
        surfaceTintColor: deckColor,
        elevation: 20,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: deckColor,
            width: 2,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(24),
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  children: [
                    Container(
                      constraints:
                          BoxConstraints.loose(const Size.fromWidth(150)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 3.25 / 4,
                          child: Transform.scale(
                            scale: 1.5,
                            child: Image(
                              fit: BoxFit.cover,
                              alignment: const Alignment(0, -1.5),
                              image: AssetImage(paragon.art!),
                            ),
                          ),
                        ),
                      ),
                    ),
                    FittedBox(
                      child: Container(
                        constraints: BoxConstraints.loose(Size.fromWidth(
                          MediaQuery.of(context).size.width - 200,
                        )),
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Tooltip(
                              message: widget.deck.name,
                              preferBelow: false,
                              child: Text(
                                widget.deck.name,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            Text(
                              paragon.title,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            if (paragon.description != null &&
                                paragon.description!.isNotEmpty)
                              Text(
                                paragon.description!,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: paragon.parallel.color),
                              ),
                            ...summary.parallelTypeCount.entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox.square(
                                      dimension: 24,
                                      child: SvgPicture(
                                        AssetBytesLoader(
                                          "assets/parallel_logos/vec/${entry.key.name}.svg.vec",
                                        ),
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcATop,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      entry.value.toString().padLeft(2, "0"),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Wrap(
                  verticalDirection: VerticalDirection.up,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.hardEdge,
                      constraints: const BoxConstraints(
                        maxWidth: 400,
                      ),
                      child: ExpansionPanelList(
                        dividerColor: Colors.transparent,
                        materialGapSize: 0,
                        expansionCallback: (panelIndex, isExpanded) {
                          setState(() {
                            _states[_states.keys.elementAt(panelIndex)] =
                                isExpanded;
                          });
                        },
                        children: _states.entries.map((element) {
                          final cardType = element.key.first.key.cardType.title;
                          final cardCount =
                              element.key.fold(0, (acc, cardEntry) {
                            return acc + cardEntry.value;
                          });
                          return ExpansionPanel(
                            isExpanded: element.value,
                            canTapOnHeader: true,
                            headerBuilder: (context, isExpanded) => ListTile(
                              title: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Icon(
                                        Icons.circle,
                                        size: 16,
                                        color: element
                                            .key.first.key.cardType.color,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " $cardType ($cardCount)",
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            body: Column(
                              children: element.key.map((cardEntry) {
                                return Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: [
                                        cardEntry.key.parallel.color
                                            .withAlpha(150),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(16),
                                      ),
                                    ),
                                    leadingAndTrailingTextStyle:
                                        Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                      shadows: [
                                        const Shadow(
                                          color: Colors.black,
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                    leading: Text(
                                      cardEntry.key.cost.toString(),
                                    ),
                                    title: Text(
                                      cardEntry.key.title,
                                      style: const TextStyle(
                                        shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            offset: Offset(1, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    subtitle: Text(
                                      cardEntry.key.rarity.title,
                                      style: const TextStyle(
                                        shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            offset: Offset(1, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: Text(
                                      cardEntry.value.toString(),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      height: 200,
                      child: CustomPaint(
                        painter: StackedLineGraph(
                          cards: widget.deck.cards,
                          textStyle: Theme.of(context).textTheme.labelLarge!,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit"),
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
                      if (context.mounted) {
                        Navigator.of(context).pop<Deck>(
                          await newDeckModel.toDeck(),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
