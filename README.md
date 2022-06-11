# LexoRank

Easily generate lexicographical sort for efficient reordering list item.

## Features

* Easily generate lexicographical rank between two rank
* Easily change of generated rank length with your favorite English letter
* Able to generate a list of rank for re-balancing process or initial ranking
* Have a method to detect if ranking exceed some threshold

## Usage

1. To generate a rank, first create an instance of ```LexoRank``` and call ```getRankBetween``` with defined first and second rank

```dart
const lexoRank = LexoRank();
final rank = lexoRank.getRankBetween(firstRank: 'aaaa', secondRank: 'cccc');
print(rank); //bbbb
```

the first rank should be lower than the second rank, if you are unsure just pass ```reorderPosition``` when creating ```LexoRank``` instance.

2. To generate a list of rank
```dart
final itemsRank = lexoRank.generateInitialRank(sizeOfItems: 100);
```

you can customize it by providing:
* ```sizeOfItems``` indicate number of ranks that must be generated.
* ```rankLength```: specify initial base rank letter size, default to 5.
* ```startRankLetter```: specify start letter to generate the initial the base rank, default is 'a'.
* ```endRankLetter```: specify end letter to generate the initial the base rank, default is 'z'.

3. To check if a list of ranks exceed the limit
```dart
final stats = lexoRank.shouldRebalanced(items, maxRankLength: 5);
print(stats.exceeded);
```

## Issues

Please file any issues, bugs or feature request as an [issue](https://github.com/rebaz94/lexorank/issues) on our GitHub page.

## Contributing

If you would like to contribute to the plugin (_e.g._ by improving the documentation, solving a bug or adding a cool new feature or you'd like an easier or better way to do something), consider opening a [pull request](https://github.com/rebaz94/lexorank/pulls). 

