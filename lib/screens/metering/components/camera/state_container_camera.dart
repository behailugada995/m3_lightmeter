import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

abstract class CameraContainerState {
  const CameraContainerState();
}

class CameraInitState extends CameraContainerState {
  const CameraInitState();
}

class CameraLoadingState extends CameraContainerState {
  const CameraLoadingState();
}

class CameraInitializedState extends CameraContainerState {
  final CameraController controller;

  const CameraInitializedState(this.controller);
}

class CameraActiveState extends CameraContainerState {
  final RangeValues zoomRange;
  final double currentZoom;
  final RangeValues exposureOffsetRange;
  final double? exposureOffsetStep;
  final double currentExposureOffset;

  const CameraActiveState({
    required this.zoomRange,
    required this.currentZoom,
    required this.exposureOffsetRange,
    required this.exposureOffsetStep,
    required this.currentExposureOffset,
  });
}

class CameraErrorState extends CameraContainerState {
  const CameraErrorState();
}
