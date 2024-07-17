import 'package:parallel_stats/parallel/augmentation.dart';
import 'package:parallel_stats/parallel/state.dart';

enum CardClassEnum {
  fe,
  se,
  pl,
  nlg,
  prmv,
  mp,
  as,
  cb,
  ac,
  rd,
}

extension CardClassEnumExtension on CardClassEnum {
  String get value {
    switch (this) {
      case CardClassEnum.fe:
        return 'FE';
      case CardClassEnum.se:
        return 'SE';
      case CardClassEnum.pl:
        return 'PL';
      case CardClassEnum.nlg:
        return 'Native Language';
      case CardClassEnum.prmv:
        return 'Prime Variant';
      case CardClassEnum.mp:
        return 'Masterpiece';
      case CardClassEnum.as:
        return 'Asset';
      case CardClassEnum.cb:
        return 'Card Back';
      case CardClassEnum.ac:
        return 'Art Card';
      case CardClassEnum.rd:
        return 'Redeemable';
    }
  }

  static CardClassEnum fromString(String cardClass) {
    switch (cardClass) {
      case 'fe':
        return CardClassEnum.fe;
      case 'se':
        return CardClassEnum.se;
      case 'pl':
        return CardClassEnum.pl;
      case 'nlg':
        return CardClassEnum.nlg;
      case 'prmv':
        return CardClassEnum.prmv;
      case 'mp':
        return CardClassEnum.mp;
      case 'as':
        return CardClassEnum.as;
      case 'cb':
        return CardClassEnum.cb;
      case 'ac':
        return CardClassEnum.ac;
      case 'rd':
        return CardClassEnum.rd;
      default:
        throw Exception('Unknown CardClassEnum: $cardClass');
    }
  }
}

class CardClass {
  Augmentation augmentLabel;
  CardClassEnum cardClass;
  CardState cardState;
  int chainId;
  int id;
  int tokenId;
  int totalMinted;
  String contractAddress;
  String contractName;
  Uri imageUrl;
  Uri originalImageUrl;

  CardClass({
    required String imageUrl,
    required String originalImageUrl,
    required this.augmentLabel,
    required this.cardClass,
    required this.cardState,
    required this.chainId,
    required this.contractAddress,
    required this.contractName,
    required this.id,
    required this.tokenId,
    required this.totalMinted,
  })  : originalImageUrl = Uri.parse(originalImageUrl),
        imageUrl = Uri.parse(imageUrl);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tokenId': tokenId,
      'originalImageUrl': originalImageUrl.toString(),
      'imageUrl': imageUrl.toString(),
      'cardClass': cardClass.value,
      'cardState': cardState.value,
      'augmentation': augmentLabel.value,
      'chainId': chainId,
      'contractAddress': contractAddress,
      'contractName': contractName,
      'totalMinted': totalMinted,
    };
  }
}
