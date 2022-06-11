class LexoRankItemsStat {
  const LexoRankItemsStat({
    required this.maxRankLength,
    required this.maxThreshold,
    required this.exceedSize,
    required this.exceededItems,
    required this.exceededPercent,
    required this.exceeded,
  });

  final int maxRankLength;
  final double maxThreshold;
  final int exceedSize;
  final List<String> exceededItems;
  final double exceededPercent;
  final bool exceeded;

  @override
  String toString() {
    return 'LexoRankItemsStat{maxRankLength: $maxRankLength, maxThreshold: $maxThreshold, '
        'exceedSize: $exceedSize, exceededItems: $exceededItems, exceededPercent: $exceededPercent, exceeded: $exceeded}';
  }
}
