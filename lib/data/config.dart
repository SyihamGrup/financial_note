// Copyright (c) 2017. All rights reserved.
//
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//
// Written by:
//   - Adi Sayoga <adisayoga@gmail.com>


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const firebaseHost = 'us-central1-financialnote-d6d95.cloudfunctions.net';
const firebaseUriScheme = 'https';

const openingBalancePath = '/getOpeningBalance';

enum AppTheme { light, dark }
enum BackupMode { enabled, disabled }

class Config {
  final AppTheme theme;
  final BackupMode backupMode;

  final String bookId;

  final bool debugShowGrid;
  final bool debugShowSizes;
  final bool debugShowBaselines;
  final bool debugShowLayers;
  final bool debugShowPointers;
  final bool debugShowRainbow;
  final bool showPerformanceOverlay;
  final bool showSemanticsDebugger;

  Config({
    this.theme: AppTheme.light,
    this.backupMode: BackupMode.enabled,

    this.bookId,

    this.debugShowGrid: false,
    this.debugShowSizes: false,
    this.debugShowBaselines: false,
    this.debugShowLayers: false,
    this.debugShowPointers: false,
    this.debugShowRainbow: false,
    this.showPerformanceOverlay: false,
    this.showSemanticsDebugger: false
  });

  Config.fromPrefs(SharedPreferences prefs)
    : theme = (prefs.getString('theme') ?? 'light') == 'light' ? AppTheme.light : AppTheme.dark,
      backupMode = (prefs.getBool('backupMode') ?? true) ? BackupMode.enabled : BackupMode.disabled,

      bookId = prefs.getString('bookId'),

      debugShowGrid = prefs.getBool('debugShowGrid') ?? false,
      debugShowSizes = prefs.getBool('debugShowSizes') ?? false,
      debugShowBaselines = prefs.getBool('debugShowBaselines') ?? false,
      debugShowLayers = prefs.getBool('debugShowLayers') ?? false,
      debugShowPointers = prefs.getBool('debugShowPointers') ?? false,
      debugShowRainbow = prefs.getBool('debugShowRainbow') ?? false,
      showPerformanceOverlay = prefs.getBool('showPerformanceOverlay') ?? false,
      showSemanticsDebugger = prefs.getBool('showSemanticsDebugger') ?? false;

  ThemeData get themeData {
    switch (theme) {
      case AppTheme.light:
        return new ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.teal,
          primaryColor: Colors.teal[700],
          accentColor: Colors.orangeAccent[700],
        );
      case AppTheme.dark:
        return new ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.teal,
          accentColor: Colors.tealAccent[700],
        );
    }
    return null;
  }

  Config copyWith({
    AppTheme theme,
    BackupMode backupMode,

    String bookId,

    bool debugShowGrid,
    bool debugShowSizes,
    bool debugShowBaselines,
    bool debugShowLayers,
    bool debugShowPointers,
    bool debugShowRainbow,
    bool showPerformanceOverlay,
    bool showSemanticsDebugger
  }) {
    return new Config(
      theme: theme ?? this.theme,
      backupMode: backupMode ?? this.backupMode,

      bookId: bookId ?? this.bookId,

      debugShowGrid: debugShowGrid ?? this.debugShowGrid,
      debugShowSizes: debugShowSizes ?? this.debugShowSizes,
      debugShowBaselines: debugShowBaselines ?? this.debugShowBaselines,
      debugShowLayers: debugShowLayers ?? this.debugShowLayers,
      debugShowPointers: debugShowPointers ?? this.debugShowPointers,
      debugShowRainbow: debugShowRainbow ?? this.debugShowRainbow,
      showPerformanceOverlay: showPerformanceOverlay ?? this.showPerformanceOverlay,
      showSemanticsDebugger: showSemanticsDebugger ?? this.showSemanticsDebugger
    );
  }

  Future flushTheme() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', theme == AppTheme.light ? 'light' : 'dark');
  }

  Future flushBackupMode() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('backupMode', backupMode == BackupMode.enabled);
  }

  Future flushBookId() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('bookId', bookId);
  }

  Future flushDebugShowGrid() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('debugShowGrid', debugShowGrid);
  }

  Future flushDebugShowSizes() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('debugShowSizes', debugShowSizes);
  }

  Future flushDebugShowBaselines() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('debugShowBaselines', debugShowBaselines);
  }

  Future flushDebugShowLayers() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('debugShowLayers', debugShowLayers);
  }

  Future flushDebugShowPointers() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('debugShowPointers', debugShowPointers);
  }

  Future flushDebugShowRainbow() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('debugShowRainbow', debugShowRainbow);
  }

  Future flushShowPerformanceOverlay() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('showPerformanceOverlay', showPerformanceOverlay);
  }

  Future flushShowSemanticsDebugger() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('showSemanticsDebugger', showSemanticsDebugger);
  }
}
