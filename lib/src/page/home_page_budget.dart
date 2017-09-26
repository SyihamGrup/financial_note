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

class HomePageBudget extends StatefulWidget {
  static const kRouteName = '/home/budgets';

  final Config config;

  const HomePageBudget({this.config});

  @override
  State<StatefulWidget> createState() => new _HomePageBudgetState();
}

class _HomePageBudgetState extends State<HomePageBudget> {

  @override
  Widget build(BuildContext context) {
    return new Container();
  }
}
