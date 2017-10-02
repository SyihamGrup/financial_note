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

enum TransType { income, expense }

class TransactionPage extends StatefulWidget {
  static const kRouteName = '/transaction';

  final TransType transType;

  const TransactionPage({this.transType: TransType.expense});

  @override
  State<StatefulWidget> createState() {
    return new _TransactionPageState(transType: this.transType);
  }
}

class _TransactionPageState extends State<TransactionPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();

  TransType _transType;
  var _trans = new Transaction();

  var _autoValidate = false;
//  var _isCancelled = false;
  var _formWasEdited = false;
  var _saveNeeded = false;

  _TransactionPageState({TransType transType: TransType.expense})
    : _transType = transType;

  //  var person = new PersonData();
//  final _passwordFieldKey = new GlobalKey<FormFieldState<String>>();
//  final _phoneNumberFormatter = new _UsNumberTextInputFormatter();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
    ));
  }

  void _handleSubmitted() {
    final form = _formKey.currentState;
    if (!form.validate()) {
      _autoValidate = true;  // Start validating on every change
      showInSnackBar(Lang.of(context).msgFixFormError());
    } else {
      form.save();
      showInSnackBar(Lang.of(context).msgSaved());
    }
  }

  // TODO: Menyimpan data disini
  Future<bool> _warnInvalidData() async {
    final form = _formKey.currentState;
    if (form == null || !_formWasEdited || form.validate()) return true;

    final lang = Lang.of(context);
    final nav = Navigator.of(context);

    return await showDialog<bool>(
      context: context,
      child: new AlertDialog(
        title: new Text(lang.msgFormHasError()),
        content: new Text(lang.msgConfirmLeave()),
        actions: <Widget> [
          new FlatButton(
            child: new Text(lang.btnYes().toUpperCase()),
            onPressed: () => nav.pop(true),
          ),
          new FlatButton(
            child: new Text(lang.btnNo().toUpperCase()),
            onPressed: () => nav.pop(false),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final lang = Lang.of(context);
    final nav = Navigator.of(context);

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        leading: new IconButton(icon: const Icon(Icons.close), onPressed: () {
          nav.pop();
        }),
        title: new Text(lang.titleAddTransaction()),
        actions: <Widget>[
          new FlatButton(
            onPressed: _handleSubmitted,
            child: new Text(lang.btnSave().toUpperCase(),
                style: theme.primaryTextTheme.button),
          ),
        ],
      ),
      body: _buildForm(context),
    );
  }

  void _onTransTypeChange(TransType type) {
    _saveNeeded = true;
    setState(() => _transType = type);
  }

  String _validateTitle(String value) {
    _saveNeeded = true;
    if (value.isEmpty) {
      return Lang.of(context).msgFieldRequired();
    }
    return null;
  }

  String _validateValue(String value) {
//    _saveNeeded = true;
//    if (value.isEmpty) {
//      return Lang.of(context).msgFieldRequired();
//    }
    return null;
  }

  Widget _buildForm(BuildContext context) {
    final lang = Lang.of(context);

    return new Form(
      key: _formKey,
      autovalidate: _autoValidate,
      onWillPop: _warnInvalidData,
      child: new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          new Row(children: <Widget>[
            new Radio(
              value: TransType.income,
              groupValue: _transType,
              onChanged: (TransType value) => _onTransTypeChange(value),
            ),
            new Container(
              child: new GestureDetector(
                child: new Text(lang.lblIncome()),
                onTap: () => _onTransTypeChange(TransType.income),
              ),
              margin: const EdgeInsets.only(right: 8.0),
            ),
            new Radio(
              value: TransType.expense,
              groupValue: _transType,
              onChanged: (TransType value) => _onTransTypeChange(value),
            ),
            new GestureDetector(
              child: new Text(lang.lblExpense()),
              onTap: () => _onTransTypeChange(TransType.expense),
            ),
          ]),

          new InputDecorator(
            decoration: new InputDecoration(labelText: lang.lblBudget()),
            isEmpty: _trans.budgetId == null,
            child: new DropdownButtonHideUnderline(child: new DropdownButton<String>(
              value: _trans.budgetId,
              isDense: true,
              onChanged: (String newValue) {
                setState(() => _trans.budgetId = newValue == '' ? null : newValue);
              },
              items: <DropdownMenuItem<String>>[
                new DropdownMenuItem<String>(value: '', child: new Text('None')),
                new DropdownMenuItem<String>(value: '1', child: new Text('Hiking')),
                new DropdownMenuItem<String>(value: '2', child: new Text('Swimming')),
                new DropdownMenuItem<String>(value: '3', child: new Text('Boating')),
                new DropdownMenuItem<String>(value: '4', child: new Text('Fishing')),
              ],
            )),
          ),

          new Row(children: <Widget>[
            new Expanded(child: new InputDecorator(
              decoration: new InputDecoration(labelText: lang.lblBill()),
              isEmpty: _trans.billId == null,
              child: new DropdownButtonHideUnderline(child: new DropdownButton<String>(
                value: _trans.billId,
                isDense: true,
                onChanged: (String newValue) {
                  setState(() => _trans.billId = newValue == '' ? null : newValue);
                },
                items: <DropdownMenuItem<String>>[
                  new DropdownMenuItem<String>(value: '', child: new Text('None')),
                  new DropdownMenuItem<String>(value: '1', child: new Text('Hiking')),
                  new DropdownMenuItem<String>(value: '2', child: new Text('Swimming')),
                  new DropdownMenuItem<String>(value: '3', child: new Text('Boating')),
                  new DropdownMenuItem<String>(value: '4', child: new Text('Fishing')),
                ],
              )),
            )),

            new Container(width: 8.0),

            new Expanded(child: new InputDecorator(
              decoration: new InputDecoration(labelText: lang.lblBillPeriod()),
              isEmpty: _trans.billId == null,
              child: new DropdownButtonHideUnderline(child: new DropdownButton<String>(
                value: _trans.billId,
                isDense: true,
                onChanged: (String newValue) {
                  setState(() => _trans.billId = newValue == '' ? null : newValue);
                },
                items: <DropdownMenuItem<String>>[
                  new DropdownMenuItem<String>(value: '', child: new Text('None')),
                  new DropdownMenuItem<String>(value: '1', child: new Text('Hiking')),
                  new DropdownMenuItem<String>(value: '2', child: new Text('Swimming')),
                  new DropdownMenuItem<String>(value: '3', child: new Text('Boating')),
                  new DropdownMenuItem<String>(value: '4', child: new Text('Fishing')),
                ],
              )),
            )),
          ]),

          new TextFormField(
            decoration: new InputDecoration(labelText: lang.lblTitle()),
            onSaved: (String value) => setState(() => _trans.title = value),
            validator: _validateTitle,
          ),

          new TextFormField(
            controller: new TextEditingController(text: '0'),
            decoration: new InputDecoration(labelText: lang.lblValue()),
            keyboardType: TextInputType.number,
            onSaved: (String value) => setState(() => _trans.value = double.parse(value)),
            validator: _validateValue,
          ),

//          new TextFormField(
//            decoration: const InputDecoration(
//              icon: const Icon(Icons.person),
//              hintText: 'What do people call you?',
//              labelText: 'Name *',
//            ),
//            onSaved: (String value) { person.name = value; },
//            validator: _validateName,
//          ),
//          new TextFormField(
//            decoration: const InputDecoration(
//              icon: const Icon(Icons.phone),
//              hintText: 'Where can we reach you?',
//              labelText: 'Phone Number *',
//              prefixText: '+1'
//            ),
//            keyboardType: TextInputType.phone,
//            onSaved: (String value) { person.phoneNumber = value; },
//            validator: _validatePhoneNumber,
//            // TextInputFormatters are applied in sequence.
//            inputFormatters: <TextInputFormatter> [
//              WhitelistingTextInputFormatter.digitsOnly,
//              // Fit the validating format.
//              _phoneNumberFormatter,
//            ],
//          ),
//          new TextFormField(
//            decoration: const InputDecoration(
//              hintText: 'Tell us about yourself',
//              helperText: 'Keep it short, this is just a demo',
//              labelText: 'Life story',
//            ),
//            maxLines: 3,
//          ),
//          new TextFormField(
//            keyboardType: TextInputType.number,
//            decoration: const InputDecoration(
//              labelText: 'Salary',
//              prefixText: '\$',
//              suffixText: 'USD',
//              suffixStyle: const TextStyle(color: Colors.green)
//            ),
//            maxLines: 1,
//          ),
//          new Row(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: <Widget>[
//              new Expanded(
//                child: new TextFormField(
//                  key: _passwordFieldKey,
//                  decoration: const InputDecoration(
//                    hintText: 'How do you log in?',
//                    labelText: 'New Password *',
//                  ),
//                  obscureText: true,
//                  onSaved: (String value) { person.password = value; },
//                ),
//              ),
//              const SizedBox(width: 16.0),
//              new Expanded(
//                child: new TextFormField(
//                  decoration: const InputDecoration(
//                    hintText: 'How do you log in?',
//                    labelText: 'Re-type Password *',
//                  ),
//                  obscureText: true,
//                  validator: _validatePassword,
//                ),
//              ),
//            ],
//          ),
//          new Container(
//            padding: const EdgeInsets.all(20.0),
//            alignment: const FractionalOffset(0.5, 0.5),
//            child: new RaisedButton(
//              child: const Text('SUBMIT'),
//              onPressed: _handleSubmitted,
//            ),
//          ),
//          new Container(
//            padding: const EdgeInsets.only(top: 20.0),
//            child: new Text('* indicates required field', style: Theme.of(context).textTheme.caption),
//          ),
        ],
      ),
    );
  }

}
