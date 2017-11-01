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
  final String bookId;
  final OnItemTap<BillGroup> onItemTap;
  final OnItemSelect<BillGroup> onItemsSelect;

  HomePageBill({
    Key key,
    @required this.bookId,
    this.onItemTap,
    this.onItemsSelect,
    this.config,
  }) : assert(bookId != null),
       super(key: key);

  @override
  State<StatefulWidget> createState() => new _HomePageBillState();
}

class _HomePageBillState extends State<HomePageBill> {
  final List<BillGroup> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return new FirebaseAnimatedList(
      query: BillGroup.getNode(widget.bookId),
      sort: (a, b) {
        final aDate = a.value is Map && a.value.containsKey('date') ? a.value['date'] : '';
        final bDate = b.value is Map && b.value.containsKey('date') ? b.value['date'] : '';
        return bDate.compareTo(aDate);
      },
      defaultChild: const EmptyBody(),
      itemBuilder: (context, snapshot, animation, index) {
        final item = new BillGroup.fromSnapshot(snapshot);
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

  void _onTap(BillGroup item) {
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

  void _onLongPress(BillGroup data) {
    if (_selectedItems.length > 0) return;

    setState(() => _selectedItems.add(data));
    if (widget.onItemsSelect != null) {
      widget.onItemsSelect(_selectedItems, 0);
    }
  }

  int _getSelectedIndex(List<BillGroup> items, BillGroup item) {
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
  final BillGroup item;
  final Animation animation;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  final bool selected;

  _ContentBillItem({
    this.item,
    this.animation,
    this.selected,
    this.onTap,
    this.onLongPress,
    this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final currFormatter = new NumberFormat.currency(symbol: currencySymbol, decimalDigits: 0);
    final dateFormatter = new DateFormat.MMMd();
    final selectedBg = new BoxDecoration(color: Theme.of(context).highlightColor);

    return new SizeTransition(
      sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        decoration: selected ? selectedBg : null,
        child: new ListTile(
          leading: new CircleAvatar(
            backgroundColor: item.transType == null ? Colors.grey[600]
               : (item.transType == kIncome ? Colors.green[400] : Colors.orange[300]),
            child: item.transType == null ? null
               : new Icon(item.transType == kIncome ? Icons.add : Icons.remove),
          ),
          title: new Text(item.title, overflow: TextOverflow.ellipsis),
          subtitle: new Text(currFormatter.format(item.totalValue)),
          trailing: new Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.only(top: 20.0),
            child: new Text(item.startDate != null ? dateFormatter.format(item.startDate) : '',
                            style: Theme.of(context).textTheme.body1.copyWith(fontSize: 12.0)),
          ),
          selected: selected,
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}
