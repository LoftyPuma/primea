import 'dart:convert';

import 'package:http/http.dart' show get;
import 'package:html/parser.dart';

import 'package:parallel_stats/parallel/card_model.dart';
import 'package:parallel_stats/parallel/function.dart';

class Parallel {
  Future<List<CardModel>> fetchCards() async {
    final url = Uri.parse('https://parallel.life/cards');
    final content =
        parse((await get(url)).body).getElementById('__NEXT_DATA__');
    final json = jsonDecode(content!.innerHtml);

    // Extract the card functions from the JSON
    final cardFunctionsData = json['props']['pageProps']['cardFunctions'];
    final Map<int, CardFunction> cardFunctions = {};
    for (var element in cardFunctionsData) {
      cardFunctions[element['id']] = CardFunction.fromJson(element);
    }

    // Extract the cards from the JSON
    final cards = json['props']['pageProps']['initialCards'];
    final Map<String, CardModel> result = {};
    for (var element in cards) {
      element['cardFunction'] = cardFunctions[element['cardFunctionId']];
      final card = CardModel.fromJson(element);
      if (result.containsKey(card.name)) {
        // print('Duplicate card: ${card.name}');
        if (!result[card.name]!.addClass(card.cardClass.first)) {
          print('Failed to add class to card: ${card.name}');
        }
      } else {
        result[card.name] = card;
      }
    }
    return result.values.toList();
  }
}
