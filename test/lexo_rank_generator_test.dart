import 'package:lexo_rank_generator/lexo_rank_generator.dart';
import 'package:test/test.dart';

void main() {
  group('LexoRank test', () {
    test('should rank correctly between two rank', () {
      final lexo = const LexoRank();
      expect(lexo.getRankBetween(firstRank: 'a', secondRank: 'c'), equals('b'));
      expect(lexo.getRankBetween(firstRank: 'aaa', secondRank: 'ccc'), equals('bbb'));
      expect(lexo.getRankBetween(firstRank: 'ddddd', secondRank: 'fffff'), equals('eeeee'));
      expect(lexo.getRankBetween(firstRank: 'aaaaa', secondRank: 'adjww'), equals('abryl'));
    });

    test('should reorder the rank and generate correctly', () {
      final lexo = const LexoRank(reorderPosition: true);
      expect(lexo.getRankBetween(firstRank: 'c', secondRank: 'a'), equals('b'));
      expect(lexo.getRankBetween(firstRank: 'ccc', secondRank: 'aaa'), equals('bbb'));
      expect(lexo.getRankBetween(firstRank: 'fffff', secondRank: 'ddddd'), equals('eeeee'));
      expect(lexo.getRankBetween(firstRank: 'adjww', secondRank: 'aaaaa'), equals('abryl'));
    });

    test('should make the rank same size', () {
      final lexo = const LexoRank();
      expect(lexo.getRankBetween(firstRank: 'aaa', secondRank: 'c'), equals('baa'));
      expect(lexo.getRankBetween(firstRank: 'a', secondRank: 'ccc'), equals('bbb'));
      expect(lexo.getRankBetween(firstRank: 'ddd', secondRank: 'fffff'), equals('eeecp'));
      expect(lexo.getRankBetween(firstRank: 'a', secondRank: 'adjww'), equals('abryl'));
      expect(lexo.getRankBetween(firstRank: 'aa', secondRank: 'adjww'), equals('abryl'));
    });

    test('should generate a List ordered of rank items', () {
      final lexo = const LexoRank();
      final items = <String>[];
      for (int i = 97; i < 123; i++) {
        final c = String.fromCharCode(i);
        items.add(List.generate(5, (index) => c).join());
      }

      expect(lexo.generateInitialRank(sizeOfItems: 26), containsAll(items));
      expect(lexo.generateInitialRank(sizeOfItems: 100), containsAll(['bviii', 'eeeee', 'akdqq']));
    });

    test('should generate a List ordered of rank items with custom rank length', () {
      final lexo = const LexoRank();
      final items = <String>[];
      for (int i = 97; i < 123; i++) {
        final c = String.fromCharCode(i);
        items.add(List.generate(3, (index) => c).join());
      }

      expect(lexo.generateInitialRank(sizeOfItems: 26, rankLength: 3), containsAll(items));
      expect(lexo.generateInitialRank(sizeOfItems: 1000, rankLength: 3),
          containsAll(['bts', 'btt', 'bug', 'izn']));
    });

    test('should not throw exception when base list has not sufficient items', () {
      final lexo = const LexoRank();

      expect(
        lexo.generateInitialRank(
          sizeOfItems: 1,
          rankLength: 5,
          startRankLetter: 'a',
          endRankLetter: 'c',
        ),
        equals(['aaaaa']),
      );
    });

    test('should return true when ranks need to re-balanced', () {
      final lexo = const LexoRank();
      String secondRank = 'c';
      final items = <String>[];
      for (int i = 0; i < 100; i++) {
        final rank = lexo.getRankBetween(firstRank: 'a', secondRank: secondRank);
        secondRank = rank;
        items.add(rank);
      }
      final stats = lexo.shouldRebalanced(items, maxRankLength: 5);
      expect(stats.exceeded, isTrue);
    });

    test('should return false when ranks does not need to be re-balanced', () {
      final lexo = const LexoRank();
      final items =
          lexo.generateInitialRank(sizeOfItems: 100, startRankLetter: 'd', endRankLetter: 'f');
      final stats = lexo.shouldRebalanced(items, maxRankLength: 5);
      expect(stats.exceeded, isFalse);
    });
  });
}
