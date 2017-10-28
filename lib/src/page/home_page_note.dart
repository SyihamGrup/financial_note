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

class HomePageNote extends StatefulWidget {
  static const kRouteName = '/home-notes';

  final Config config;
  final String bookId;
  final OnItemTap<Note> onItemTap;
  final OnItemSelect<Note> onItemsSelect;

  HomePageNote({
    Key key,
    @required this.bookId,
    this.onItemTap,
    this.onItemsSelect,
    this.config,
  }) : assert(bookId != null),
       super(key: key);

  @override
  State<StatefulWidget> createState() => new _HomePageNoteState();
}

class _HomePageNoteState extends State<HomePageNote> {
  final List<Note> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return new FirebaseAnimatedList(
      query: Note.getNode(widget.bookId),
      sort: (a, b) {
        final itemA = a.value is Map && a.value.containsKey('updatedAt') ? a.value['updatedAt'] : '';
        final itemB = b.value is Map && b.value.containsKey('updatedAt') ? b.value['updatedAt'] : '';
        return itemB.compareTo(itemA);
      },
      defaultChild: new Center(child: new Text(Lang.of(context).msgEmptyData())),
      itemBuilder: (context, snapshot, animation, index) {
        final item = new Note.fromSnapshot(snapshot);
        return new _ContentNoteItem(
          item: item,
          animation: animation,
          selected: _getSelectedIndex(_selectedItems, item) != -1,
          onTap: () => _onTap(item),
          onLongPress: () => _onLongPress(item),
        );
      }
    );
  }

  void _onTap(Note item) {
    if (_selectedItems.length > 0) {
      final idx = _getSelectedIndex(_selectedItems, item);
      if (idx >= 0) {
        setState(() => _selectedItems.removeAt(idx));
      } else {
        setState(() => _selectedItems.add(item));
      }
      if (widget.onItemsSelect != null) {
        widget.onItemsSelect(_selectedItems, idx);
      }
    } else {
      if (widget.onItemTap != null) {
        widget.onItemTap(item);
      }
    }
  }

  void _onLongPress(Note data) {
    if (_selectedItems.length > 0) return;

    setState(() => _selectedItems.add(data));
    if (widget.onItemsSelect != null) {
      widget.onItemsSelect(_selectedItems, 0);
    }
  }

  int _getSelectedIndex(List<Note> items, Note item) {
    if (items == null) return -1;
    for (int i = 0; i < items.length; i++) {
      if (items[i].id == item.id) return i;
    }
    return -1;
  }

  void clearSelection() {
    setState(() => _selectedItems.clear());
  }
}

class _ContentNoteItem extends StatelessWidget {
  final Note item;
  final Animation animation;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  final bool selected;

  _ContentNoteItem({
    this.item,
    this.animation,
    this.selected,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedBg = new BoxDecoration(color: theme.highlightColor);

    return new SizeTransition(
      sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        decoration: selected ? selectedBg : null,
        child: new ListTile(
          title: new Text(item.title, overflow: TextOverflow.ellipsis),
          subtitle: new Text(item.note, overflow: TextOverflow.ellipsis),
          selected: selected,
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}
