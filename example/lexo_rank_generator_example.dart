import 'package:lexo_rank_generator/lexo_rank_generator.dart';

void main() {
  const lexoRank = LexoRank();
  final result = lexoRank.getRankBetween(firstRank: 'aaaa', secondRank: 'cccc');
  print(result);

  const lexoRank2 = LexoRank(reorderPosition: true);
  final result2 = lexoRank2.getRankBetween(firstRank: 'cccc', secondRank: 'aaaa');
  print(result2);
  print(result == result2);

  print('generating items from `a` to `z` letter');
  final itemsRank = lexoRank.generateInitialRank(sizeOfItems: 100);
  print('items: $itemsRank');
  print('generatedItems: ${itemsRank.length}');
  print('\n');

  print('generating items from `a` to `c` letter');
  final itemsRank2 = lexoRank.generateInitialRank(
    sizeOfItems: 100,
    startRankLetter: 'a',
    endRankLetter: 'c',
  );
  print('items2: $itemsRank2');
  print('generatedItems2: ${itemsRank2.length}');
  print('\n');

  print('generating items with 3 character length, `a` to `z` letter');
  final itemsRank3 = lexoRank.generateInitialRank(sizeOfItems: 1000, rankLength: 3);
  print('items3: $itemsRank3');
  print('generatedItems3: ${itemsRank3.length}');
  print('\n');

  print('generating items with 3 character length, `a` to `c` letter');
  final itemsRank4 = lexoRank.generateInitialRank(
    sizeOfItems: 1000,
    startRankLetter: 'a',
    endRankLetter: 'c',
    rankLength: 3,
  );
  print('items4: $itemsRank4');
  print('generatedItems4: ${itemsRank4.length}');
  print('\n');
}
