import 'package:flutter/material.dart';
import 'package:marker_seek_bar_poc_application/models/marker_model.dart';

class MarkerSeekBar extends StatefulWidget {
  const MarkerSeekBar({
    super.key,
    required this.duration,
    required this.position,
    required this.markers,
    required this.onSeek,
  });

  final Duration duration;
  final Duration position;
  final List<MarkerModel> markers;
  final ValueChanged<Duration> onSeek;

  @override
  State<MarkerSeekBar> createState() => _MarkerSeekBarState();
}

class _MarkerSeekBarState extends State<MarkerSeekBar> {
  static const double segmentGap = 3.0;
  static const double segmentHeight = 6.0;

  bool isScrubbing = false;
  double scrubMilliseconds = 0;

  List<Duration> get _segmentBounds => [
    Duration.zero,
    ...widget.markers
      .map((e) => e.time)
      .where((element) => element > Duration.zero && element < widget.duration)
      .toSet()
      .toList()
    ..sort(),
    widget.duration
  ];

  @override
  Widget build(BuildContext context) {
    final bounds = _segmentBounds;
    final totalMilliseconds = widget.duration.inMilliseconds.toDouble();
    final currentMilliseconds = (widget.position > widget.duration ? widget.duration : widget.position)
        .inMilliseconds.toDouble();
    final cursorMilliseconds = isScrubbing ? scrubMilliseconds : currentMilliseconds;

    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (totalMilliseconds <= 0 || bounds.length < 2) return SizedBox();

              final segmentCount = bounds.length -1;
              final usableWidth = constraints.maxWidth - segmentGap * (segmentCount - 1);
              var left = 0.0;

              return SizedBox(
                height: segmentHeight,
                child: Stack(
                  children: List.generate(segmentCount, (index) {
                    final startMilliseconds = bounds[index].inMilliseconds;
                    final endMilliseconds = bounds[index+1].inMilliseconds;
                    final width = usableWidth * (endMilliseconds - startMilliseconds) / totalMilliseconds;
                    final fillRatio = cursorMilliseconds <= startMilliseconds
                        ? 0.0
                        : cursorMilliseconds >= endMilliseconds
                          ? 1.0
                          : (cursorMilliseconds - startMilliseconds) / (endMilliseconds - startMilliseconds);

                    final x = left;
                    left += width + segmentGap;

                    return Positioned(
                      left: x,
                      top: 0,
                      child: Container(
                        width: width,
                        height: segmentHeight,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(color: Colors.white),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: fillRatio,
                          heightFactor: 1.0,
                          child: ColoredBox(color: Colors.red),
                        ),
                      ),
                    );
                  })
                ),
              );
            },
          ),
        ),
        Opacity(
          opacity: 0.001,
          child: Slider(
            min: 0,
            max: totalMilliseconds > 0 ? totalMilliseconds : 1,
            value: cursorMilliseconds,
            onChangeStart: (value) => setState(() => isScrubbing = true),
            onChanged: (value) => setState(() => scrubMilliseconds = value),
            onChangeEnd: (value) {
              setState(() => isScrubbing = false);
              widget.onSeek(Duration(milliseconds: value.round()));
            },
          ),
        )
      ],
    );
  }
}
