import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:parallel_stats/parallel/augmentation.dart';
import 'package:parallel_stats/parallel/class.dart';
import 'package:parallel_stats/parallel/expansion.dart';
import 'package:parallel_stats/parallel/faction.dart';
import 'package:parallel_stats/parallel/function.dart';
import 'package:parallel_stats/parallel/state.dart';

const String _echoSuffix = "- echo";
const String _seSuffix = "[se]";
const String _plSuffix = "[pl]";
const String _parallelMasterpieceDelimiter = "//";

class InheritedCard extends InheritedWidget {
  final CardModel card;

  const InheritedCard({
    super.key,
    required this.card,
    required super.child,
  });

  static InheritedCard? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedCard>();
  }

  static InheritedCard of(BuildContext context) {
    var result = context.dependOnInheritedWidgetOfExactType<InheritedCard>();
    assert(result != null, 'No InheritedCard found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(InheritedCard oldWidget) {
    return card != oldWidget.card;
  }
}

class CardModel {
  bool active;
  CardFunction? cardFunction;
  Expansion expansion;
  Faction parallel;
  int artistId;
  int renown;
  Set<CardClass> cardClass;
  String description;
  String name;
  String rarity;
  String state;
  String? designId;
  String? slug;

  CardModel({
    Augmentation augmentLabel = Augmentation.none,
    required int chainId,
    required int id,
    required int tokenId,
    required int totalMinted,
    required String cardClass,
    required String cardState,
    required String contractAddress,
    required String contractName,
    required String imageUrl,
    required String name,
    required String originalImageUrl,
    required this.active,
    required this.artistId,
    required this.description,
    required this.expansion,
    required this.parallel,
    required this.rarity,
    required this.renown,
    required this.state,
    this.cardFunction,
    this.designId,
    this.slug,
  })  : cardClass = {
          CardClass(
            augmentLabel: augmentLabel,
            cardClass: CardClassEnumExtension.fromString(cardClass),
            cardState: CardStateExtension.fromString(state),
            chainId: chainId,
            contractAddress: contractAddress,
            contractName: contractName,
            id: id,
            imageUrl: imageUrl,
            originalImageUrl: originalImageUrl,
            tokenId: tokenId,
            totalMinted: totalMinted,
          )
        },
        name = _parseName(name, CardClassEnumExtension.fromString(cardClass));

  factory CardModel.fromJson(Map<String, dynamic> json) {
    var c = CardModel(
      active: json['active'],
      artistId: json['artistId'],
      augmentLabel: AugmentationExtension.fromString(json['augmentLabel']),
      cardClass: json['cardClass'],
      cardState: json['state'],
      cardFunction: json['cardFunction'],
      chainId: json['chainId'],
      contractAddress: json['contractAddress'],
      contractName: json['contractName'],
      description: json['description'],
      designId: json['designId'],
      expansion: ExpansionExtension.fromString(json['expansion']),
      id: json['id'],
      imageUrl: json['imageUrl'],
      name: json['name'],
      originalImageUrl: json['originalImageUrl'],
      parallel: FactionExtension.fromString(json['parallel']),
      rarity: json['rarity'],
      renown: json['renown'],
      slug: json['slug'],
      state: json['state'],
      tokenId: json['tokenId'],
      totalMinted: json['totalMinted'],
    );
    return c;
  }

  Map<String, dynamic> toJson() {
    return {
      'active': active,
      'artistId': artistId,
      'class': cardClass.map((e) => json.encode(e)),
      'cardFunction': json.encode(cardFunction),
      'description': description,
      'designId': designId,
      'expansion': expansion,
      'name': name,
      'parallel': parallel,
      'rarity': rarity,
      'renown': renown,
      'slug': slug,
      'state': state,
    };
  }

  @override
  String toString() {
    return json.encode(this);
  }

  static String _parseName(String name, CardClassEnum cardClass) {
    switch (cardClass) {
      case CardClassEnum.fe:
        if (name.toLowerCase().endsWith(_echoSuffix)) {
          return name.substring(0, name.length - _echoSuffix.length).trim();
        }
        return name;
      case CardClassEnum.se:
        return name.substring(0, name.length - _seSuffix.length).trim();
      case CardClassEnum.pl:
        return name.substring(0, name.length - _plSuffix.length).trim();
      case CardClassEnum.nlg:
        return name;
      case CardClassEnum.prmv:
        return name;
      case CardClassEnum.mp:
        final nameIndex = name.lastIndexOf(_parallelMasterpieceDelimiter);
        return name
            .substring(nameIndex + _parallelMasterpieceDelimiter.length)
            .trim();
      case CardClassEnum.as:
        return name;
      case CardClassEnum.cb:
        return name;
      case CardClassEnum.ac:
        return name;
      case CardClassEnum.rd:
        return name;
    }
  }

  bool addClass(CardClass cardClass) {
    return this.cardClass.add(cardClass);
  }
}
