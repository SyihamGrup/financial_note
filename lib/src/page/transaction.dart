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

class TransactionPage extends StatefulWidget {
  static const kRouteName = '/transaction';
  final Config _config;

  const TransactionPage(this._config);

  @override
  State<StatefulWidget> createState() => new _TransactionPageState(_config);
}

class _TransactionPageState extends State<TransactionPage> {
  bool _isCancelled = false;
  final Config _config;

  _TransactionPageState(this._config);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton(icon: const Icon(Icons.close), onPressed: () {
          _isCancelled = true;
          Navigator.of(context).maybePop();
        }),
        title: new Text(Lang.of(context).titleAddTransaction()),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: new Text(Lang.of(context).btnSave().toUpperCase(),
              style: theme.primaryTextTheme.button),
          ),
        ],
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return new ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: <Widget>[
        new TextFormField(
          decoration: const InputDecoration(
            hintText: 'Tell us about yourself',
            helperText: 'Keep it short, this is just a demo',
            labelText: 'Life story',
          ),
          maxLines: 3,
        ),
        new TextFormField(
          keyboardType: TextInputType.number,
          decoration: new InputDecoration(
            labelText: 'Salary',
            prefixText: 'Rp ',
            suffixText: 'IDR',
            suffixStyle: new TextStyle(color: Theme.of(context).accentColor),
          ),
          maxLines: 1,
        ),
        new Container(
          padding: const EdgeInsets.all(20.0),
          alignment: const FractionalOffset(0.5, 0.5),
          child: new RaisedButton(
            child: new Text(Lang.of(context).btnSave()),
            onPressed: () => null,
          ),
        ),
        new Container(
          padding: const EdgeInsets.only(top: 20.0),
          child: new Text('* indicates required field', style: Theme.of(context).textTheme.caption),
        ),
      ],
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    if (!_isCancelled) save();
  }

  Future<Null> save() async {

  }
}
