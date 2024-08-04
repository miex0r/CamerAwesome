import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/src/widgets/filters/awesome_filter_name_indicator.dart';
import 'package:camerawesome/src/widgets/filters/awesome_filter_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum FilterListPosition {
  aboveButton,
  belowButton,
}

class AwesomeFilterWidget extends StatefulWidget {
  final CameraState state;
  final FilterListPosition filterListPosition;
  final EdgeInsets? filterListPadding;
  final Widget indicator;
  final Widget? spacer;
  final Curve animationCurve;
  final Duration animationDuration;

  AwesomeFilterWidget({
    required this.state,
    super.key,
    this.filterListPosition = FilterListPosition.belowButton,
    this.filterListPadding,
    Widget? indicator,
    this.spacer = const SizedBox(height: 8),
    this.animationCurve = Curves.easeInOut,
    this.animationDuration = const Duration(milliseconds: 400),
  }) : indicator = Builder(
          builder: (context) => Container(
            color: AwesomeThemeProvider.of(context)
                .theme
                .bottomActionsBackgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: const Center(
              child: SizedBox(
                height: 6,
                width: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        );

  @override
  State<AwesomeFilterWidget> createState() => _AwesomeFilterWidgetState();
}

class _AwesomeFilterWidgetState extends State<AwesomeFilterWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = AwesomeThemeProvider.of(context).theme;
    final children = [
      SizedBox(
        height: theme.buttonTheme.iconSize +
            theme.buttonTheme.padding.top +
            theme.buttonTheme.padding.bottom,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: StreamBuilder<bool>(
                stream: widget.state.filterSelectorOpened$,
                builder: (_, snapshot) {
                  return AnimatedSwitcher(
                    duration: widget.animationDuration,
                    switchInCurve: widget.animationCurve,
                    switchOutCurve: widget.animationCurve.flipped,
                    child: snapshot.data == true
                        ? Align(
                            key: const ValueKey("NameIndicator"),
                            alignment: widget.filterListPosition ==
                                    FilterListPosition.belowButton
                                ? Alignment.bottomCenter
                                : Alignment.topCenter,
                            child:
                                AwesomeFilterNameIndicator(state: widget.state),
                          )
                        : (!kIsWeb &&
                                Platform
                                    .isAndroid) // FIXME this should not be here and makes the code ugly
                            ? Center(
                                key: const ValueKey("ZoomIndicator"),
                                child: AwesomeZoomSelector(state: widget.state),
                              )
                            : Center(
                                key: const ValueKey("SensorTypeSelector"),
                                child: AwesomeSensorTypeSelector(
                                    state: widget.state),
                              ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ];
    return Column(
      children: widget.filterListPosition == FilterListPosition.belowButton
          ? children
          : children.reversed.toList(),
    );
  }
}
