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
  static const kRouteName = '/home/budgets';

  final String bookId;

  const HomePageBudget({@required this.bookId});

  @override
  Widget build(BuildContext context) {
    return new FirebaseAnimatedList(
      query: ref(Budget.kNodeName, subNode: bookId),
      sort: (a, b) => b.key.compareTo(a.key),
      padding: new EdgeInsets.all(8.0),
      defaultChild: new _EmptyBody(),
      itemBuilder: (context, snapshot, animation) {
        return new _ContentBudgetItem(snapshot: snapshot, animation: animation);
      }
    );
  }
}

class _ContentBudgetItem extends StatelessWidget {
  final DataSnapshot snapshot;
  final Animation animation;

  _ContentBudgetItem({this.snapshot, this.animation});

  @override
  Widget build(BuildContext context) {
    var currFormatter = new NumberFormat.currency();
    var data = new Budget.fromSnapshot(snapshot);

    return new SizeTransition(
      sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(data.title, style: Theme.of(context).textTheme.subhead),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: new Text(currFormatter.format(data.value)),
            ),
          ],
        ),
      ),
    );
  }
}
