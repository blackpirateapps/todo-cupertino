import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../state/app_state.dart';

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

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_handleStateUpdate);
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
    final selected = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) {
        final tasks = widget.state
            .sortedTasks()
            .where((t) => !t.isCompleted)
            .toList();
        return CupertinoActionSheet(
          title: const Text('Choose Focus Task'),
          actions: [
            for (final task in tasks)
              CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop(task.id),
                child: Text(task.title),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );

    if (selected != null) {
      widget.state.setFocusTask(selected, requestStart: true);
    }
  }

  void _startFocusSession({bool restartCount = false}) {
    _timer?.cancel();
    if (restartCount) _completedPomodoros = 0;
    _isBreak = false;
    _totalSeconds = widget.state.pomodoroMinutes * 60;
    _remainingSeconds = _totalSeconds;
    _isRunning = true;
    _startTicker();
    setState(() {});
  }

  void _startBreak() {
    _timer?.cancel();
    _isBreak = true;
    _totalSeconds = widget.state.breakMinutes * 60;
    _remainingSeconds = _totalSeconds;
    _isRunning = true;
    _startTicker();
    setState(() {});
  }

  void _resetFocusTimer() {
    _timer?.cancel();
    _isBreak = false;
    _isRunning = false;
    _totalSeconds = widget.state.pomodoroMinutes * 60;
    _remainingSeconds = _totalSeconds;
    setState(() {});
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resume() {
    if (_remainingSeconds <= 0) {
      _resetFocusTimer();
      return;
    }
    _isRunning = true;
    _startTicker();
    setState(() {});
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 0) {
        timer.cancel();
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
    });
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
