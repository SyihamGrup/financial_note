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

class BudgetPage extends StatefulWidget {
  static const kRouteName = '/budget';

  final String bookId;
  final DatabaseReference ref;

  BudgetPage({@required this.bookId})
    : ref = db.reference().child(Budget.kNodeName).child(bookId);

  @override
  State<StatefulWidget> createState() {
    return new _BudgetPageState();
  }
}

class _BudgetPageState extends State<BudgetPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();

  Budget _data;
  final TextEditingController _titleCtrl;
  final TextEditingController _valueCtrl;

  var _autoValidate = false;
  var _saveNeeded = false;

  _BudgetPageState({Budget data})
    : _data = data ?? new Budget(title: null, date: new DateTime.now(), value: 0.0),
      _titleCtrl = new TextEditingController(text: data?.title),
      _valueCtrl = new TextEditingController(text: data?.value != null ? data.value.toString() : '');

  Future<Null> _handleSubmitted() async {
    final form = _formKey.currentState;
    if (!form.validate()) {
      _autoValidate = true;  // Start validating on every change
      _showInSnackBar(Lang.of(context).msgFormError());
      return;
    }

    form.save();
    widget.ref.push().set(_data.toJson());

    _showInSnackBar(Lang.of(context).msgSaved());
    Navigator.pop(context);
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
    ));
  }

  Widget _buildForm(BuildContext context) {
    final lang = Lang.of(context);

    return new Form(
      key: _formKey,
      autovalidate: _autoValidate,
      onWillPop: () async {
        if (_saveNeeded) _handleSubmitted();
        return true;
      },
      child: new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          // -- title --
          new Container(margin: const EdgeInsets.only(top: 0.0), child: new TextFormField(
            controller: _titleCtrl,
            decoration: new InputDecoration(labelText: lang.lblTitle()),
            onSaved: (String value) => _data.title = value,
            validator: _validateTitle,
          )),

          // -- date --
          new Container(margin: const EdgeInsets.only(top: 8.0), child: new DateFormField(
            label: lang.lblDate(),
            date: _data.date,
            onChanged: (DateTime value) {
              _data.date = value;
              _saveNeeded = true;
            }
          )),

          // -- value --
          new Container(margin: const EdgeInsets.only(top: 8.0), child: new TextFormField(
            controller: _valueCtrl,
            decoration: new InputDecoration(labelText: lang.lblValue()),
            keyboardType: TextInputType.number,
            onSaved: (String value) => _data.value = double.parse(value),
            validator: _validateTitle,
          )),
        ],
      ),
    );
  }

  String _validateTitle(String value) {
    _saveNeeded = true;
    if (value.isEmpty) {
      return Lang.of(context).msgFieldRequired();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Lang.of(context);
    final nav = Navigator.of(context);

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        leading: new IconButton(icon: kIconClose, onPressed: () {
          setState(() => _saveNeeded = false);
          nav.pop();
        }),
        title: new Text(lang.titleAddBudget()),
        actions: <Widget>[
          new FlatButton(
            onPressed: _handleSubmitted,
            child: new Text(lang.btnSave().toUpperCase(), style: theme.primaryTextTheme.button),
          ),
        ],
      ),
      body: _buildForm(context),
    );
  }
}
