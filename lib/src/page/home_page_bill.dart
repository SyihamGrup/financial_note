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

class HomePageBill extends StatefulWidget {
  static const kRouteName = '/home-bills';

  final Config config;
  final DatabaseReference ref;
  final String bookId;
  final OnItemTap<Bill> onItemTap;
  final OnItemSelect<Bill> onItemsSelect;

  HomePageBill({Key key, @required this.bookId,
                  this.onItemTap, this.onItemsSelect, this.config})
    : assert(bookId != null),
      ref = Bill.ref(bookId),
      super(key: key);

  @override
  State<StatefulWidget> createState() => new _HomePageBillState();
}

class _HomePageBillState extends State<HomePageBill> {
  final List<Bill> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return new FirebaseAnimatedList(
      query: widget.ref,
      sort: (a, b) => b.key.compareTo(a.key),
      defaultChild: new _EmptyBody(),
      itemBuilder: (context, snapshot, animation) {
        final item = new Bill.fromSnapshot(snapshot);
        return new _ContentBillItem(
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

  void _onTap(Bill item) {
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

  void _onLongPress(Bill data) {
    if (_selectedItems.length > 0) return;

    setState(() => _selectedItems.add(data));
    if (widget.onItemsSelect != null) {
      widget.onItemsSelect(_selectedItems, 0);
    }
  }

  int _getSelectedIndex(List<Bill> items, Bill item) {
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

class _ContentBillItem extends StatelessWidget {
  final String currencySymbol;
  final Bill item;
  final Animation animation;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  final bool selected;

  _ContentBillItem({this.item, this.animation, this.selected,
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
