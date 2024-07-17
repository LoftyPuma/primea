import 'package:flutter/material.dart';
import 'package:parallel_stats/parallel/card_display.dart';
import 'package:parallel_stats/parallel/card_model.dart';

class CardList extends StatelessWidget {
  final Future<List<CardModel>> cards;

  const CardList({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: cards,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasError) {
              throw snapshot.error!;
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('No data'));
            }
            // SliverGrid.extent(maxCrossAxisExtent: maxCrossAxisExtent)
            return GridView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 350,
                crossAxisSpacing: 4,
                mainAxisSpacing: 8,
                childAspectRatio: 4 / 5,
              ),
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                final card = snapshot.data?.elementAt(index);
                if (card == null) {
                  return const SizedBox();
                }
                return InheritedCard(
                  card: snapshot.data!.elementAt(index),
                  child: const CardDisplay(),
                );
              },
            );
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
