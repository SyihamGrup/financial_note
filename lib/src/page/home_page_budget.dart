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
      sort: (a, b) {
        final aDate = a.value is Map && a.value.containsKey('date') ? a.value['date'] : '';
        final bDate = b.value is Map && b.value.containsKey('date') ? b.value['date'] : '';
        return bDate.compareTo(aDate);
      },
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
    final dateFormatter = new DateFormat.MMMd();
    final selectedBg = new BoxDecoration(color: Theme.of(context).highlightColor);
    return new Container(
      decoration: selected ? selectedBg : null,
      child: new ListTile(
        title: new Text(item.title),
        subtitle: new Text(currFormatter.format(item.value)),
        trailing: new Container(
          alignment: Alignment.topRight,
          margin: const EdgeInsets.only(top: 20.0),
          child: new Text(item.date != null ? dateFormatter.format(item.date) : '',
                          style: Theme.of(context).textTheme.body1.copyWith(fontSize: 12.0)),
        ),
        selected: selected,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
