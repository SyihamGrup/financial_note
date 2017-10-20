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
      defaultChild: new Center(child: new Text(Lang.of(context).msgLoading())),
      itemBuilder: (context, snapshot, animation, index) {
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
    final theme = Theme.of(context);
    final lang = Lang.of(context);
    final selectedBg = new BoxDecoration(color: theme.highlightColor);

    final value = item.value ?? 0;
    final spent = item.spent ?? 0;
    final currFormatter = new NumberFormat.currency(symbol: currencySymbol,decimalDigits: 0);

    final percentColor = theme.primaryColor;
    final percentBg = theme.highlightColor;

    final dateFormatter = new DateFormat.MMMd();
    final date = item.date != null ? dateFormatter.format(item.date) : '';
    final dateStyle = theme.textTheme.body1.copyWith(fontSize: 12.0);
    final percent = value == 0 ? 0 : (spent / value > 1 ? 1 : spent / value);

    return new SizeTransition(
      sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        decoration: selected ? selectedBg : null,
        child: new ListTile(
          leading: new Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                height: 40.0,
                width: 26.0,
                decoration: new BoxDecoration(color: percentBg, border: new Border.all(color: percentColor)),
              ),
              new Container(
                margin: const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 2.0),
                width: 20.0,
                height: value > 0 ? 36.0 * percent : 0.0,
                decoration: new BoxDecoration(color: percentColor),
              ),
            ]
          ),
          title: new Text(item.title),
          subtitle: new Text(lang.lblTotal() + ': ' + currFormatter.format(value)),
          trailing: new Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.only(top: 20.0),
            child: new Text(date, style: dateStyle),
          ),
          selected: selected,
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}
