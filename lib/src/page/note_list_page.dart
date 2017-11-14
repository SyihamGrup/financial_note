/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

library page_note_list;

import 'package:financial_note/config.dart';
import 'package:financial_note/data.dart';
import 'package:financial_note/page.dart';
import 'package:financial_note/strings.dart';
import 'package:financial_note/widget.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part 'home_page_note.dart';

class NoteListPage extends StatefulWidget {
  static const kRouteName = '/home-notes';

  final Config config;
  final String bookId;
  final OnItemTap<Note> onItemTap;
  final OnItemSelect<Note> onItemsSelect;

  NoteListPage({
    Key key,
    @required this.bookId,
    this.onItemTap,
    this.onItemsSelect,
    this.config,
  }) : assert(bookId != null),
       super(key: key);

  @override
  State<StatefulWidget> createState() => new _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> with SelectableList<Note> {
  List<Note> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return new FirebaseAnimatedList(
      query: getNode(Note.kNodeName, widget.bookId),
      sort: (a, b) {
        final itemA = a.value is Map && a.value.containsKey('updatedAt') ? a.value['updatedAt'] : '';
        final itemB = b.value is Map && b.value.containsKey('updatedAt') ? b.value['updatedAt'] : '';
        return itemB.compareTo(itemA);
      },
      defaultChild: const EmptyBody(),
      itemBuilder: (context, snapshot, animation, index) {
        final item = new Note.fromSnapshot(widget.bookId, snapshot);
        return new _ContentNoteItem(
          config: widget.config,
          item: item,
          animation: animation,
          selected: getSelectedIndex(item) != -1,
          onTap: () => onListTap(item),
          onLongPress: () => onListLongPress(item),
        );
      }
    );
  }

  @override
  int getSelectedIndex(Note item) {
    if (_selectedItems == null) return -1;
    for (int i = 0; i < _selectedItems.length; i++) {
      if (_selectedItems[i].id == item.id) return i;
    }
    return -1;
  }

  @override
  void onSelectionChange(List<Note> items, int index) {
    setState(() => _selectedItems = items);
    if (widget.onItemsSelect != null) widget.onItemsSelect(items, index);
  }

  @override
  void onItemTap(Note item) {
    if (widget.onItemTap != null) widget.onItemTap(item);
  }
}

class _ContentNoteItem extends StatelessWidget {
  final Config config;
  final Note item;
  final Animation animation;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  final bool selected;

  _ContentNoteItem({
    @required this.config,
    @required this.item,
    this.animation,
    this.selected,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedBg = new BoxDecoration(color: theme.highlightColor);
    final dateFormatter = new DateFormat.MMMd();
    final date = item.reminder != null ? dateFormatter.format(item.reminder) : '';
    final dateStyle = theme.textTheme.body1.copyWith(fontSize: 12.0);

    return new SizeTransition(
      sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        decoration: selected ? selectedBg : null,
        child: new ListTile(
          title: new Text(item.title,
            style: config.getTitleStyle(context, selected: selected),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: new Text(item.note, overflow: TextOverflow.ellipsis, maxLines: 2),
          trailing: item.reminder != null
            ? new Container(
              alignment: Alignment.topRight,
              margin: const EdgeInsets.only(top: 20.0),
              child: new Text(date, style: dateStyle),
            )
            : null,
          selected: selected,
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}
