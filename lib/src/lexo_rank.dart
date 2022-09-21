import 'dart:math';

import 'package:lexo_rank_generator/lexo_rank_generator.dart';

/// A LexoRank for generating lexicographical sort for efficient reordering list between to rank
class LexoRank {
  /// Create a LexoRank instance that can be used to generate rank using specified [alphabetSize]
  ///
  /// The [reorderPosition] indicate that when generating rank,
  /// the first rank should be lower rank or based on the rank decide to become the lower.
  ///
  /// Note: for now, only english alphabet supported
  const LexoRank({
    this.alphabetSize = 26,
    this.reorderPosition = false,
  });

  /// The size of all letters used to generate the rank
  ///
  /// english letter is 26 which is default
  final int alphabetSize;

  /// This indicate that if first rank must be lower that second or not.
  /// if true then it will swap first with the second rank so that the first rank will lower rank
  /// if false then the first rank should be lower than the second rank otherwise throw exception
  ///
  /// default is false
  final bool reorderPosition;

  /// Generate a lexo rank between two rank.
  ///
  /// the [firstRank] should be lower than the [secondRank] unless the [reorderPosition] is true
  // inspired by https://medium.com/whisperarts/lexorank-what-are-they-and-how-to-use-them-for-efficient-list-sorting-a48fc4e7849f
  String getRankBetween(
      {required String firstRank, required String secondRank}) {
    final firstPositionIsLower = firstRank.compareTo(secondRank) < 0;
    if (!firstPositionIsLower) {
      if (reorderPosition) {
        final f = firstRank;
        firstRank = secondRank;
        secondRank = f;
      } else {
        throw LexoRankException(
          'First position must be lower than second. '
          'Got firstRank $firstRank and second rank $secondRank',
        );
      }
    }

    /// Make positions equal
    while (firstRank.length != secondRank.length) {
      if (firstRank.length > secondRank.length) {
        secondRank += "a";
      } else {
        firstRank += "a";
      }
    }
    var firstPositionCodes = [];
    firstPositionCodes.addAll(firstRank.codeUnits);
    var secondPositionCodes = [];
    secondPositionCodes.addAll(secondRank.codeUnits);
    num difference = 0;
    for (int index = firstPositionCodes.length - 1; index >= 0; index--) {
      /// Codes of the elements of positions
      var firstCode = firstPositionCodes[index];
      var secondCode = secondPositionCodes[index];

      /// i.e. ' a < b '
      if (secondCode < firstCode) {
        /// ALPHABET_SIZE = 26 for now
        secondCode += alphabetSize;
        secondPositionCodes[index - 1] -= 1;
      }

      /// formula: x = a * size^0 + b * size^1 + c * size^2
      final powRes = pow(alphabetSize, firstRank.length - index - 1);
      difference += (secondCode - firstCode) * powRes;
    }
    var newElement = "";
    if (difference <= 1) {
      /// add middle char from alphabet
      newElement = firstRank +
          String.fromCharCode('a'.codeUnits.first + alphabetSize ~/ 2);
    } else {
      difference ~/= 2;
      var offset = 0;
      for (int index = 0; index < firstRank.length; index++) {
        /// formula: x = difference / (size^place - 1) % size;
        /// i.e. difference = 110, size = 10, we want place 2 (middle),
        /// then x = 100 / 10^(2 - 1) % 10 = 100 / 10 % 10 = 11 % 10 = 1
        final diffInSymbols =
            difference ~/ pow(alphabetSize, index) % (alphabetSize);
        var newElementCode =
            firstRank.codeUnitAt(secondRank.length - index - 1) +
                diffInSymbols +
                offset;
        offset = 0;

        /// if newElement is greater then 'z'
        if (newElementCode > 'z'.codeUnits.first) {
          offset++;
          newElementCode -= alphabetSize;
        }

        newElement += String.fromCharCode(newElementCode);
      }
      newElement = newElement.split('').reversed.join();
    }
    return newElement;
  }

  /// Generate a list of initial rank for re-balancing items
  ///
  /// [sizeOfItems] indicate number of ranks that must be generated
  /// [rankLength] specify initial base rank letter size, default to 5
  /// [startRankLetter] specify start letter to generate the initial the base rank, default is 'a'
  /// [endRankLetter] specify end letter to generate the initial the base rank, default is 'z'
  List<String> generateInitialRank({
    required int sizeOfItems,
    int rankLength = 5,
    String startRankLetter = 'a',
    String endRankLetter = 'z',
  }) {
    final startRandPos = startRankLetter.codeUnits.first;
    final endRankPos = endRankLetter.codeUnits.first;

    if (startRandPos < 'a'.codeUnits.first ||
        endRankPos > 'z'.codeUnits.first) {
      throw LexoRankException('Only support letter from `a` to `z`');
    }

    final items = <String>[];
    for (int i = startRandPos; i < endRankPos + 1; i++) {
      final c = String.fromCharCode(i);
      items.add(List.generate(rankLength, (index) => c).join());
    }

    while (items.length < sizeOfItems) {
      final newList = _generateBetweenTupleItems(items);
      items.addAll(newList);
      items.sort();
    }
    return items.toSet().take(sizeOfItems).toList();
  }

  /// Generate id between each two item in the list.
  ///
  /// for example a list of ['aaaa','bbbb','cccc', 'dddd'] will generate
  /// items between the following ['aaaa', 'bbbb'], ['cccc','dddd']
  List<String> _generateBetweenTupleItems(List<String> lastList) {
    if (lastList.length < 2) {
      throw LexoRankException('It should has minimum of two items');
    }
    final items = <String>[];
    for (int i = 1; i < lastList.length; i = i + 2) {
      items.add(
          getRankBetween(firstRank: lastList[i - 1], secondRank: lastList[i]));
    }

    return items;
  }

  /// Check if a list should be re-balanced or not depend on max rank length
  /// that exceed the [maxThreshold] of total items.
  LexoRankItemsStat shouldRebalanced(
    List<String> items, {
    required int maxRankLength,
    double maxThreshold = 0.5,
  }) {
    final exceedItems = items.where((e) => e.length > maxRankLength).toList();
    final exceededSize = exceedItems.length;
    final exceededPercent = exceededSize / items.length;
    return LexoRankItemsStat(
      maxRankLength: maxRankLength,
      maxThreshold: maxThreshold,
      exceedSize: exceededSize,
      exceededItems: exceedItems,
      exceededPercent: exceededPercent,
      exceeded: exceededPercent > maxThreshold,
    );
  }

/*List<String> getDefaultRank({required int forNumOfTasks}) {
    final taskForProjectLimitTotal = forNumOfTasks;
    final startPos = 'aaa';
    final endPos = 'zzz';
    final startCode = startPos.codeUnits.first;
    final endCode = endPos.codeUnits.first;
    final diffInOneSymb = endCode - startCode;

    /// x = a + b * size + c * size^2
    final totalDiff =
        diffInOneSymb + diffInOneSymb * alphabetSize + diffInOneSymb * alphabetSize * alphabetSize;

    /// '~/' – div without remainder
    final diffForOneItem = totalDiff ~/ (taskForProjectLimitTotal + 1);

    /// x = difference / size^(place - 1) % size
    final List<int> diffForSymbols = [
      diffForOneItem % alphabetSize,
      diffForOneItem ~/ alphabetSize % alphabetSize,
      diffForOneItem ~/ (pow(alphabetSize, 2)) % alphabetSize
    ];
    List<String> positions = [];
    var lastAddedElement = startPos;
    for (int ind = 0; ind < forNumOfTasks; ind++) {
      var offset = 0;
      var newElement = "";
      for (int index = 0; index < 3; index++) {
        final diffInSymbols = diffForSymbols[index];
        var newElementCode = lastAddedElement.codeUnitAt(2 - index) + diffInSymbols;
        if (offset != 0) {
          newElementCode += 1;
          offset = 0;
        }

        /// 'z' code is 122 if 'll be needed
        if (newElementCode > 'z'.codeUnitAt(0)) {
          offset += 1;
          newElementCode -= alphabetSize;
        }
        final symbol = String.fromCharCode(newElementCode);
        newElement += symbol;
      }

      /// reverse element cuz we are calculating from the end
      newElement = newElement.split('').reversed.join();
      positions.add(newElement);
      lastAddedElement = newElement;
    }
    positions.sort();
    return positions;
  }*/
}

extension LexoListExt<T> on List<T> {
  Map<T, int> duplicatedKeys() {
    final stats = <T, int>{};
    for (final k in this) {
      stats[k] = (stats[k] ?? 0) + 1;
    }
    return stats;
  }
}
