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

class HomePageTransaction {
  static const kRouteName = '/home/transactions';
}

class TransactionAppBar extends StatefulWidget implements PreferredSizeWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<String> onPopupSelected;
  final Size preferredSize;

  TransactionAppBar({DateTime initialDate, this.onDateChanged, this.onPopupSelected})
    : this.initialDate = initialDate ?? new DateTime.now(),
      preferredSize = new Size.fromHeight(kToolbarHeight);

  @override
  State<StatefulWidget> createState() => new _TransactionAppBarState();
}

class _TransactionAppBarState extends State<TransactionAppBar> {

  Future<Null> _selectMonth(BuildContext context) async {
    final DateTime picked = await showMonthPicker(context: context, initialDate: widget.initialDate);
    if (picked == null) return;
    if (widget.onDateChanged != null) widget.onDateChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return new AppBar(
      title: new InkWell(
        onTap: () => _selectMonth(context),
        child: new Container(
          height: kToolbarHeight,
          child: new Row(children: <Widget>[
            new Text(new DateFormat.yMMM().format(widget.initialDate),
                style: Theme.of(context).primaryTextTheme.title),
            new Icon(Icons.arrow_drop_down),
          ]),
        ),
      ),
      actions: <Widget>[
        new IconButton(
          icon: const Icon(Icons.search),
          tooltip: Lang.of(context).menuSearch(),
          onPressed: () => null,
        ),
        new PopupMenuButton<String>(
          onSelected: widget.onPopupSelected,
          itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
            const PopupMenuItem<String>(
              value: 'Toolbar menu',
              child: const Text('Toolbar menu')
            ),
            const PopupMenuItem<String>(
              value: 'Right here',
              child: const Text('Right here')
            ),
            const PopupMenuItem<String>(
              value: 'Hooray!',
              child: const Text('Hooray!')
            ),
          ],
        ),
      ],
    );
  }

}
