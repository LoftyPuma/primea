import 'package:flutter/material.dart';

class SliverDeckList<T> extends ChangeNotifier {
  final GlobalKey<SliverAnimatedGridState> listKey;
  final Widget Function(
    T item,
    BuildContext context,
    Animation<double> animation,
  ) removedItemBuilder;
  final List<T> _items;

  SliverDeckList({
    required this.listKey,
    required this.removedItemBuilder,
    Iterable<T>? items,
  }) : _items = List.from(items ?? <T>[]);

  SliverAnimatedGridState? get _animatedGrid => listKey.currentState;

  Iterable<T> get items => List.unmodifiable(_items);

  void insert(int index, T item) {
    _items.insert(index, item);
    _animatedGrid?.insertItem(
      index,
      duration: const Duration(milliseconds: 250),
    );
    notifyListeners();
  }

  void insertAll(int index, Iterable<T> items) {
    _items.insertAll(index, items);
    _animatedGrid?.insertAllItems(
      index,
      items.length,
      duration: const Duration(milliseconds: 250),
    );
    notifyListeners();
  }

  T removeAt(int index) {
    final removedItem = _items.removeAt(index);
    _animatedGrid?.removeItem(
      index,
      (BuildContext context, Animation<double> animation) =>
          removedItemBuilder(removedItem, context, animation),
      duration: const Duration(milliseconds: 250),
    );
    notifyListeners();
    return removedItem;
  }

  int get length => _items.length;

  T operator [](int index) => _items[index];
}
