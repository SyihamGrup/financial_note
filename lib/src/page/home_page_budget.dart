/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

part of page;

class HomePageBudget extends StatefulWidget {
  static const kRouteName = '/home-budgets';

  final Config config;
  final DatabaseReference ref;
  final String bookId;
  final OnItemTap<Budget> onItemTap;
  final OnItemSelect<Budget> onItemsSelect;

  HomePageBudget({Key key, @required this.bookId,
                  this.onItemTap, this.onItemsSelect, this.config})
    : assert(bookId != null),
      ref = Budget.ref(bookId),
      super(key: key);

  @override
  State<StatefulWidget> createState() => new _HomePageBudgetState();
}

class _HomePageBudgetState extends State<HomePageBudget> {
  final List<Budget> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return new FirebaseAnimatedList(
      query: widget.ref,
      sort: (a, b) => b.key.compareTo(a.key),
      defaultChild: new _EmptyBody(),
      itemBuilder: (context, snapshot, animation) {
        final item = new Budget.fromSnapshot(snapshot);
        return new _ContentBudgetItem(
          item: item,
          animation: animation,
          selected: _getSelectedIndex(_selectedItems, item) != -1,
          currencySymbol: widget.config?.currencySymbol,
          onTap: () => _onTap(item),
          onLongPress: () => _onLongPress(item),
        );
      }
    );
  }

  void _onTap(Budget item) {
    if (_selectedItems.length > 0) {
      final idx = _getSelectedIndex(_selectedItems, item);
      if (idx >= 0) {
        setState(() => _selectedItems.removeAt(idx));
      } else {
        setState(() => _selectedItems.add(item));
      }
      if (widget.onItemsSelect != null) {
        widget.onItemsSelect(_selectedItems, idx);
      }
    } else {
      if (widget.onItemTap != null) {
        widget.onItemTap(item);
      }
    }
  }

  void _onLongPress(Budget data) {
    if (_selectedItems.length > 0) return;

    setState(() => _selectedItems.add(data));
    if (widget.onItemsSelect != null) {
      widget.onItemsSelect(_selectedItems, 0);
    }
  }

  int _getSelectedIndex(List<Budget> items, Budget item) {
    if (items == null) return -1;
    for (int i = 0; i < items.length; i++) {
      if (items[i].id == item.id) return i;
    }
    return -1;
  }

  void clearSelection() {
    setState(() => _selectedItems.clear());
  }
}

class _ContentBudgetItem extends StatelessWidget {
  final String currencySymbol;
  final Budget item;
  final Animation animation;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  final bool selected;

  _ContentBudgetItem({this.item, this.animation, this.selected,
                      this.onTap, this.onLongPress, this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    final currFormatter = new NumberFormat.currency(symbol: currencySymbol);
    final selectedBg = new BoxDecoration(color: Theme.of(context).highlightColor);
    return new Container(
      decoration: selected ? selectedBg : null,
      child: new ListTile(
        title: new Text(item.title),
        subtitle: new Text(currFormatter.format(item.value)),
        selected: selected,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}

class AppBarBudget extends StatefulWidget implements PreferredSizeWidget {
  final Size preferredSize;
  final OnActionTap<List<Budget>> onActionModeTap;
  final VoidCallback onExitActionMode;

  AppBarBudget({Key key, this.onActionModeTap, this.onExitActionMode})
    : preferredSize = new Size.fromHeight(kToolbarHeight),
      super(key: key);

  @override
  State<StatefulWidget> createState() => new _AppBarBudgetState();
}

class _AppBarBudgetState extends State<AppBarBudget> {
  var _isActionMode = false;
  var _items = <Budget>[];

  void showActionMode(List<Budget> items) {
    setState(() {
      _isActionMode = true;
      _items = items;
    });
  }

  void exitActionMode() {
    setState(() => _isActionMode = false);
    if (widget.onExitActionMode != null) widget.onExitActionMode();
  }

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];
    if (_isActionMode) {
      if (_items.length == 1) {
        actions.add(new IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            if (widget.onActionModeTap != null) {
              widget.onActionModeTap('edit', _items);
            }
          },
        ));
      }
      actions.add(new IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          if (widget.onActionModeTap != null) {
            widget.onActionModeTap('delete', _items);
          }
        },
      ));
    }
    return new AppBar(
      backgroundColor: _isActionMode ? kBgActionMode : null,
      leading: _isActionMode ? new IconButton(icon: kIconBack, onPressed: () {
        exitActionMode();
      }) : null,
      title: new Text(
        _isActionMode ? _items.length.toString() : Lang.of(context).titleBudget()
      ),
      actions: actions,
    );
  }
}
