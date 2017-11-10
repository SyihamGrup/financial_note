/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

abstract class SelectableList<T> {
  final List<T> _selectedItems = [];

  int getSelectedIndex(T item);

  void onSelectionChange(List<T> items, int index);

  void onItemTap(T item);

  void onListTap(T item) {
    if (_selectedItems.length > 0) {
      final idx = getSelectedIndex(item);
      if (idx >= 0) {
        _selectedItems.removeAt(idx);
      } else {
       _selectedItems.add(item);
      }
      onSelectionChange(_selectedItems, idx);
    } else {
      onItemTap(item);
    }
  }

  void onListLongPress(T item) {
    if (_selectedItems.length > 0) return;
    _selectedItems.add(item);
    onSelectionChange(_selectedItems, getSelectedIndex(item));
  }

  void clearSelection() {
    _selectedItems.clear();
    onSelectionChange(_selectedItems, -1);
  }
}
