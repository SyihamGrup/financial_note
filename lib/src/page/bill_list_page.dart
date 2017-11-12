/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

library page_bill_list;

import 'package:financial_note/config.dart';
import 'package:financial_note/data.dart';
import 'package:financial_note/page.dart';
import 'package:financial_note/strings.dart';
import 'package:financial_note/utils.dart';
import 'package:financial_note/widget.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part 'home_page_bill.dart';

class BillListPage extends StatefulWidget {
  static const kRouteName = '/home-bills';

  final Config config;
  final String bookId;
  final OnItemTap<BillGroup> onItemTap;
  final OnItemSelect<BillGroup> onItemsSelect;

  BillListPage({
    Key key,
    @required this.bookId,
    this.onItemTap,
    this.onItemsSelect,
    this.config,
  }) : assert(bookId != null),
       super(key: key);

  @override
  State<StatefulWidget> createState() => new _BillListPageState();
}

class _BillListPageState extends State<BillListPage> with SelectableList<BillGroup> {
  List<BillGroup> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return new FirebaseAnimatedList(
      query: getNode(BillGroup.kNodeName, widget.bookId),
      sort: (a, b) {
        final aDate = a.value is Map && a.value.containsKey('date') ? a.value['date'] : '';
        final bDate = b.value is Map && b.value.containsKey('date') ? b.value['date'] : '';
        return bDate.compareTo(aDate);
      },
      defaultChild: const EmptyBody(),
      itemBuilder: (context, snapshot, animation, index) {
        final item = new BillGroup.fromSnapshot(widget.bookId, snapshot);
        return new _ContentBillItem(
          config: widget.config,
          item: item,
          animation: animation,
          selected: getSelectedIndex(item) != -1,
          currencySymbol: widget.config?.currencySymbol,
          onTap: () => onListTap(item),
          onLongPress: () => onListLongPress(item),
        );
      }
    );
  }

  @override
  int getSelectedIndex(BillGroup item) {
    if (_selectedItems == null) return -1;
    for (int i = 0; i < _selectedItems.length; i++) {
      if (_selectedItems[i].id == item.id) return i;
    }
    return -1;
  }

  @override
  void onSelectionChange(List<BillGroup> items, int index) {
    setState(() => _selectedItems = items);
    if (widget.onItemsSelect != null) widget.onItemsSelect(items, index);
  }

  @override
  void onItemTap(BillGroup item) {
    if (widget.onItemTap != null) widget.onItemTap(item);
  }
}

class _ContentBillItem extends StatelessWidget {
  final Config config;
  final String currencySymbol;
  final BillGroup item;
  final Animation animation;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  final bool selected;

  _ContentBillItem({
    @required this.config,
    @required this.item,
    this.animation,
    this.selected,
    this.onTap,
    this.onLongPress,
    this.currencySymbol,
  }) : assert(config != null), assert(item != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Lang.of(context);
    final dateFormatter = new DateFormat.MMMd();
    final selectedBg = new BoxDecoration(color: Theme.of(context).highlightColor);
    final iconColor = theme.brightness == Brightness.light
                    ? Colors.black54 : Colors.white70;

    return new SizeTransition(
      sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        decoration: selected ? selectedBg : null,
        child: new ListTile(
          leading: new CircleAvatar(
            backgroundColor: item.transType == null ? Colors.grey[600]
               : (item.transType == kIncome ? Colors.green[400] : Colors.orange[300]),
            child: item.totalValue == item.paidValue ? new Icon(Icons.done_all, color: iconColor) :
                   item.paidValue > 0                ? new Icon(Icons.done, color: iconColor)
                                                     : new Icon(Icons.attach_money, color: iconColor)
          ),
          title: new Text(item.title ?? '',
            style: config.getTitleStyle(context, selected: selected),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new Text(
                lang.lblTotal() + ':' +
                (item.paidValue != 0 ? '\n' + lang.lblPaid() + ':' : '')
              ),
              new Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: new Text(
                  formatCurrency(item.totalValue, symbol: currencySymbol) +
                  (item.paidValue != 0
                    ? '\n' + formatCurrency(item.paidValue, symbol: currencySymbol)
                    : ''
                  ),
                ),
              ),
            ],
          ),
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
