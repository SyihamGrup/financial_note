enum AppTheme { light, dark }
enum BackupMode { enabled, disabled }

final kRefCounter = 'counter';
final kRefMessages = 'messages';

class Config {
  final AppTheme theme;
  final BackupMode backupMode;
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
    this.debugShowGrid: false,
    this.debugShowSizes: false,
    this.debugShowBaselines: false,
    this.debugShowLayers: false,
    this.debugShowPointers: false,
    this.debugShowRainbow: false,
    this.showPerformanceOverlay: false,
    this.showSemanticsDebugger: false
  });

  Config copyWith({
    AppTheme theme,
    BackupMode backupMode,
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
}
