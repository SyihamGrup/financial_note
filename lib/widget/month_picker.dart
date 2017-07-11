import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<DateTime> showMonthPicker({
  @required BuildContext context, @required DateTime initialDate,
}) async {
  return await showDialog(
    context: context,
    child: new _MonthPickerDialog(
      initialDate: initialDate,
    )
  );
}

class _MonthPickerDialog extends StatefulWidget {
  final DateTime initialDate;

  const _MonthPickerDialog({ Key key, this.initialDate }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = new DateTime(widget.initialDate.year, widget.initialDate.month, 1);
  }

  Widget _buildMonth(int month, {bool selected: false}) {
    // TODO: Mendapatkan dari list nama bulan sesuai locale?
    final monthName = new DateFormat.MMM().format(new DateTime(_selectedDate.year, month));

    final textStyle = new TextStyle(
      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      color: selected ? Theme.of(context).accentColor : null,
    );
    return new FlatButton(
      child: new Text(monthName, textAlign: TextAlign.center, style: textStyle),
      onPressed: () => _setMonth(month),
    );
  }

  void _incrementYear() {
    setState(() {
      _selectedDate = new DateTime(_selectedDate.year - 1, _selectedDate.month);
     });
  }

  void _decrementYear() {
    setState(() {
      _selectedDate = new DateTime(_selectedDate.year + 1, _selectedDate.month);
    });
  }

  void _setMonth(int month) {
    _selectedDate = new DateTime(_selectedDate.year, month, 1);
    Navigator.pop(context, _selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return new Dialog(child: new OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return new Container(
          padding: const EdgeInsets.all(8.0),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[

            new Row(
             children: <Widget>[
               new IconButton(icon: const Icon(Icons.chevron_left), onPressed: _incrementYear),
               new Expanded(child: new Text(
                 "${_selectedDate.year}",
                 textAlign: TextAlign.center,
                 style: const TextStyle(fontWeight: FontWeight.bold),
               )),
               new IconButton(icon: const Icon(Icons.chevron_right), onPressed: _decrementYear),
             ]
            ),

            new GridView.count(
              crossAxisCount: orientation == Orientation.portrait ? 3 : 4,
              shrinkWrap: true,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              padding: const EdgeInsets.only(top: 8.0),
              childAspectRatio: orientation == Orientation.portrait ? 1.5 : 2.0,
              children: <Widget>[
                _buildMonth(1,  selected: _selectedDate.month == 1),
                _buildMonth(2,  selected: _selectedDate.month == 2),
                _buildMonth(3,  selected: _selectedDate.month == 3),
                _buildMonth(4,  selected: _selectedDate.month == 4),
                _buildMonth(5,  selected: _selectedDate.month == 5),
                _buildMonth(6,  selected: _selectedDate.month == 6),
                _buildMonth(7,  selected: _selectedDate.month == 7),
                _buildMonth(8,  selected: _selectedDate.month == 8),
                _buildMonth(9,  selected: _selectedDate.month == 9),
                _buildMonth(10, selected: _selectedDate.month == 10),
                _buildMonth(11, selected: _selectedDate.month == 11),
                _buildMonth(12, selected: _selectedDate.month == 12),
              ]
            )
          ]
        ));
      }
    ));
  }
}
