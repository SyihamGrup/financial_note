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

class HomePageBudget extends StatelessWidget {
  static const kRouteName = '/home-budgets';

  final DatabaseReference ref;
  final String bookId;

  HomePageBudget({@required this.bookId})
    : ref = db.reference().child(Budget.kNodeName).child(bookId);

  @override
  Widget build(BuildContext context) {
    return new FirebaseAnimatedList(
      query: ref,
      sort: (a, b) => b.key.compareTo(a.key),
      defaultChild: new _EmptyBody(),
      itemBuilder: (context, snapshot, animation) {
        final data = new Budget.fromSnapshot(snapshot);
        return new _ContentBudgetItem(
          data: data,
          animation: animation,
          onTap: () => _onTap(context, data),
          onLongPress: () => _onLongPress(context, data),
        );
      }
    );
  }

  void _onTap(BuildContext context, Budget data) {
    final params = <String, dynamic>{'bookId': bookId, 'data': data};
    Navigator.pushNamed(context, routeWithParams(BudgetPage.kRouteName, params));
  }

  void _onLongPress(BuildContext context, Budget data) {
  }
}

class _ContentBudgetItem extends StatelessWidget {
  final Budget data;
  final Animation animation;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;

  _ContentBudgetItem({this.data, this.animation, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    var currFormatter = new NumberFormat.currency();

    return new ListTile(
      title: new Text(data.title, style: Theme.of(context).textTheme.subhead),
      subtitle: new Text(currFormatter.format(data.value)),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
