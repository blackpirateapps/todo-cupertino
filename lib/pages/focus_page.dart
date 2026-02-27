import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../models/task.dart';
import '../services/focus_notification_service.dart';
import '../state/app_state.dart';
import 'focus_task_picker_page.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key, required this.state});

  final AppState state;

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 1;
  bool _isRunning = false;
  bool _isBreak = false;
  int _completedPomodoros = 0;
  int _lastStartNonce = -1;
  int _unpersistedFocusSeconds = 0;

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_handleStateUpdate);
    FocusNotificationService.instance.initialize();
    _lastStartNonce = widget.state.focusStartNonce;
    if (widget.state.focusTask != null && widget.state.focusStartNonce > 0) {
      _startFocusSession(restartCount: false);
    } else {
      _resetFocusTimer();
    }
  }

  @override
  void dispose() {
    widget.state.removeListener(_handleStateUpdate);
    _timer?.cancel();
    widget.state.setFocusRunning(false);
    FocusNotificationService.instance.cancel();
    super.dispose();
  }

  void _handleStateUpdate() {
    if (!mounted) return;
    if (widget.state.focusStartNonce != _lastStartNonce) {
      _lastStartNonce = widget.state.focusStartNonce;
      final task = widget.state.focusTask;
      if (task != null) {
        _startFocusSession(restartCount: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final focusTask = widget.state.focusTask;
    final label = focusTask?.title ?? 'Choose a task';

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Focus'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _pickTask,
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: widget.state,
          builder: (context, _) {
            final progress =
                (_totalSeconds - _remainingSeconds) / _totalSeconds;
            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
              children: [
                const Text(
                  'Current Focus:',
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _pickTask,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: CupertinoColors.label.resolveFrom(context),
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (focusTask != null) ...[
                  const SizedBox(height: 8),
                  _focusDurationRow(context, focusTask),
                ],
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.secondarySystemGroupedBackground
                        .resolveFrom(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 270,
                        height: 270,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size.square(270),
                              painter: _TimerRingPainter(progress: progress),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatClock(_remainingSeconds),
                                  style: const TextStyle(
                                    fontSize: 58,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Pomos: $_completedPomodoros',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: CupertinoButton(
                              color: CupertinoColors.systemGrey5,
                              onPressed: () {
                                if (_isRunning) {
                                  _pause();
                                } else {
                                  _resume();
                                }
                              },
                              child: Icon(
                                _isRunning
                                    ? CupertinoIcons.pause_solid
                                    : CupertinoIcons.play_fill,
                                color: CupertinoColors.label.resolveFrom(
                                  context,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CupertinoButton(
                              color: CupertinoColors.systemGrey5,
                              onPressed: _startBreak,
                              child: Text(
                                'Break',
                                style: TextStyle(
                                  color: CupertinoColors.label.resolveFrom(
                                    context,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CupertinoButton(
                              color: CupertinoColors.systemGrey5,
                              onPressed: _resetFocusTimer,
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  color: CupertinoColors.label.resolveFrom(
                                    context,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.secondarySystemGroupedBackground
                        .resolveFrom(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.time_solid,
                        color: CupertinoColors.systemRed,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Focus Session',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _isRunning
                                  ? 'in progress - ${_remainingSeconds ~/ 60} minutes remaining'
                                  : 'paused',
                              style: const TextStyle(
                                color: CupertinoColors.secondaryLabel,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatClock(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _pickTask() async {
    final selected = await Navigator.of(context).push<String>(
      CupertinoPageRoute<String>(
        builder: (context) => FocusTaskPickerPage(state: widget.state),
      ),
    );

    if (selected != null) {
      widget.state.setFocusTask(selected, requestStart: true);
    }
  }

  Widget _focusDurationRow(BuildContext context, Task task) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(
          context,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        onPressed: () => _pickFocusDuration(task),
        child: Row(
          children: [
            const Icon(CupertinoIcons.timer, size: 18),
            const SizedBox(width: 8),
            const Text('Task focus length'),
            const Spacer(),
            Text(
              '${task.focusDurationMinutes} min',
              style: const TextStyle(color: CupertinoColors.secondaryLabel),
            ),
            const SizedBox(width: 4),
            const Icon(CupertinoIcons.chevron_forward, size: 14),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFocusDuration(Task task) async {
    var selected = task.focusDurationMinutes;
    final result = await showCupertinoModalPopup<int>(
      context: context,
      builder: (context) {
        return Container(
          height: 320,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(selected),
                    child: const Text('Done'),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 36,
                  scrollController: FixedExtentScrollController(
                    initialItem: selected.clamp(0, 500).toInt(),
                  ),
                  onSelectedItemChanged: (value) => selected = value,
                  children: List<Widget>.generate(
                    501,
                    (index) => Center(child: Text('$index min')),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (result == null) return;
    await widget.state.setTaskFocusDuration(task.id, result);
    if (!mounted) return;
    if (!_isRunning && !_isBreak) {
      _resetFocusTimer();
    }
  }

  void _startFocusSession({bool restartCount = false}) {
    _timer?.cancel();
    if (restartCount) _completedPomodoros = 0;
    _isBreak = false;
    final minutes =
        widget.state.focusTask?.focusDurationMinutes ??
        widget.state.pomodoroMinutes;
    _totalSeconds = minutes * 60;
    _remainingSeconds = _totalSeconds;
    if (_totalSeconds == 0) {
      _isRunning = false;
      widget.state.setFocusRunning(false);
      FocusNotificationService.instance.cancel();
      setState(() {});
      return;
    }
    _isRunning = true;
    _unpersistedFocusSeconds = 0;
    widget.state.setFocusRunning(true);
    _startTicker();
    _updateLiveNotification();
    setState(() {});
  }

  void _startBreak() {
    _timer?.cancel();
    _isBreak = true;
    _totalSeconds = widget.state.breakMinutes * 60;
    _remainingSeconds = _totalSeconds;
    _isRunning = true;
    widget.state.setFocusRunning(true);
    _startTicker();
    _updateLiveNotification();
    setState(() {});
  }

  void _resetFocusTimer() {
    _timer?.cancel();
    _isBreak = false;
    _isRunning = false;
    final minutes =
        widget.state.focusTask?.focusDurationMinutes ??
        widget.state.pomodoroMinutes;
    _totalSeconds = minutes * 60;
    _remainingSeconds = _totalSeconds;
    widget.state.setFocusRunning(false);
    FocusNotificationService.instance.cancel();
    setState(() {});
  }

  void _pause() {
    _timer?.cancel();
    widget.state.setFocusRunning(false);
    FocusNotificationService.instance.cancel();
    setState(() => _isRunning = false);
  }

  void _resume() {
    if (_remainingSeconds <= 0) {
      _resetFocusTimer();
      return;
    }
    _isRunning = true;
    widget.state.setFocusRunning(true);
    _startTicker();
    _updateLiveNotification();
    setState(() {});
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 0) {
        timer.cancel();
        widget.state.setFocusRunning(false);
        FocusNotificationService.instance.cancel();
        if (_isBreak) {
          _resetFocusTimer();
        } else {
          _completedPomodoros += 1;
          _startBreak();
        }
        return;
      }
      setState(() {
        _remainingSeconds -= 1;
      });
      if (!_isBreak) {
        _unpersistedFocusSeconds += 1;
        if (_unpersistedFocusSeconds >= 60) {
          _unpersistedFocusSeconds -= 60;
          final taskId = widget.state.focusTaskId;
          if (taskId != null) {
            widget.state.addTaskFocusMinutes(taskId, 1);
          }
        }
      }
      _updateLiveNotification();
    });
  }

  void _updateLiveNotification() {
    if (!_isRunning) return;
    final label = _isBreak
        ? 'Break'
        : (widget.state.focusTask?.title ?? 'Focus');
    FocusNotificationService.instance.showRunning(
      title: '$label running',
      body: '${_formatClock(_remainingSeconds)} remaining',
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  _TimerRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFD9D9DF);

    final active = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF8B93A3);

    final rect = Rect.fromLTWH(5, 5, size.width - 10, size.height - 10);
    canvas.drawArc(rect, 0, 6.283, false, track);
    canvas.drawArc(rect, -1.5708, 6.283 * progress, false, active);
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
