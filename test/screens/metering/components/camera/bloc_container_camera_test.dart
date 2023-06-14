import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lightmeter/interactors/metering_interactor.dart';
import 'package:lightmeter/screens/metering/communication/bloc_communication_metering.dart';
import 'package:lightmeter/screens/metering/communication/event_communication_metering.dart'
    as communication_events;
import 'package:lightmeter/screens/metering/communication/state_communication_metering.dart'
    as communication_states;
import 'package:lightmeter/screens/metering/components/camera_container/bloc_container_camera.dart';
import 'package:lightmeter/screens/metering/components/camera_container/event_container_camera.dart';
import 'package:lightmeter/screens/metering/components/camera_container/models/camera_error_type.dart';
import 'package:lightmeter/screens/metering/components/camera_container/state_container_camera.dart';
import 'package:mocktail/mocktail.dart';

class _MockMeteringCommunicationBloc extends MockBloc<
    communication_events.MeteringCommunicationEvent,
    communication_states.MeteringCommunicationState> implements MeteringCommunicationBloc {}

class _MockMeteringInteractor extends Mock implements MeteringInteractor {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockMeteringInteractor meteringInteractor;
  late _MockMeteringCommunicationBloc communicationBloc;
  late CameraContainerBloc bloc;

  const cameraMethodChannel = MethodChannel('plugins.flutter.io/camera');
  const cameraIdMethodChannel = MethodChannel('flutter.io/cameraPlugin/camera1');
  const availableCameras = [
    {
      "name": "front",
      "lensFacing": "front",
      "sensorOrientation": 0,
    },
    {
      "name": "back",
      "lensFacing": "back",
      "sensorOrientation": 0,
    },
  ];
  Future<Object?>? cameraMethodCallSuccessHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case "availableCameras":
        return availableCameras;
      case "create":
        return {"cameraId": 1};
      case "initialize":
        await cameraIdMethodChannel.invokeMockMethod("initialized", {
          'cameraId': 1,
          'previewWidth': 2160.0,
          'previewHeight': 3840.0,
          'exposureMode': 'auto',
          'exposurePointSupported': true,
          'focusMode': 'auto',
          'focusPointSupported': true,
        });
        return {};
      case "setFlashMode":
        return null;
      case "getMinZoomLevel":
        return 0.67;
      case "getMaxZoomLevel":
        return 7.0;
      case "getMinExposureOffset":
        return -4.0;
      case "getMaxExposureOffset":
        return 4.0;
      case "getExposureOffsetStepSize":
        return 0.1666666;
      default:
        return null;
    }
  }

  setUpAll(() {
    meteringInteractor = _MockMeteringInteractor();
    communicationBloc = _MockMeteringCommunicationBloc();
  });

  setUp(() {
    bloc = CameraContainerBloc(
      meteringInteractor,
      communicationBloc,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group(
    '`RequestPermissionEvent` tests',
    () {
      blocTest<CameraContainerBloc, CameraContainerState>(
        'Request denied',
        build: () => bloc,
        setUp: () {
          when(() => meteringInteractor.requestPermission()).thenAnswer((_) async => false);
        },
        act: (bloc) => bloc.add(const RequestPermissionEvent()),
        verify: (_) {
          verify(() => meteringInteractor.requestPermission()).called(1);
        },
        expect: () => [
          isA<CameraErrorState>()
              .having((state) => state.error, "error", CameraErrorType.permissionNotGranted),
        ],
      );

      blocTest<CameraContainerBloc, CameraContainerState>(
        'Request granted -> check denied',
        build: () => bloc,
        setUp: () {
          when(() => meteringInteractor.requestPermission()).thenAnswer((_) async => true);
          when(() => meteringInteractor.checkCameraPermission()).thenAnswer((_) async => false);
        },
        act: (bloc) => bloc.add(const RequestPermissionEvent()),
        verify: (_) {
          verify(() => meteringInteractor.requestPermission()).called(1);
          verify(() => meteringInteractor.checkCameraPermission()).called(1);
        },
        expect: () => [
          isA<CameraLoadingState>(),
          isA<CameraErrorState>()
              .having((state) => state.error, "error", CameraErrorType.permissionNotGranted),
        ],
      );

      blocTest<CameraContainerBloc, CameraContainerState>(
        'Request granted -> check granted',
        build: () => bloc,
        setUp: () {
          when(() => meteringInteractor.requestPermission()).thenAnswer((_) async => true);
          when(() => meteringInteractor.checkCameraPermission()).thenAnswer((_) async => true);
        },
        act: (bloc) => bloc.add(const RequestPermissionEvent()),
        verify: (_) {
          verify(() => meteringInteractor.requestPermission()).called(1);
          verify(() => meteringInteractor.checkCameraPermission()).called(1);
        },
        expect: () => [
          isA<CameraLoadingState>(),
          // Proceed to `InitializeEvent` tests from here
        ],
      );
    },
  );

  group(
    '`InitializeEvent`/`DeinitializeEvent` tests',
    () {
      blocTest<CameraContainerBloc, CameraContainerState>(
        'No cameras detected error',
        setUp: () {
          when(() => meteringInteractor.checkCameraPermission()).thenAnswer((_) async => true);
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            cameraMethodChannel,
            (methodCall) async {
              switch (methodCall.method) {
                case "availableCameras":
                  return const [];
                default:
                  return null;
              }
            },
          );
        },
        tearDown: () {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(cameraMethodChannel, null);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const InitializeEvent()),
        verify: (_) {
          verify(() => meteringInteractor.checkCameraPermission()).called(1);
        },
        expect: () => [
          isA<CameraLoadingState>(),
          isA<CameraErrorState>()
              .having((state) => state.error, "error", CameraErrorType.noCamerasDetected),
        ],
      );

      blocTest<CameraContainerBloc, CameraContainerState>(
        'Catch other initialization errors',
        setUp: () {
          when(() => meteringInteractor.checkCameraPermission()).thenAnswer((_) async => true);
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            cameraMethodChannel,
            (methodCall) async {
              switch (methodCall.method) {
                case "availableCameras":
                  return availableCameras;
                default:
                  return null;
              }
            },
          );
        },
        tearDown: () {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(cameraMethodChannel, null);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const InitializeEvent()),
        verify: (_) {
          verify(() => meteringInteractor.checkCameraPermission()).called(1);
        },
        expect: () => [
          isA<CameraLoadingState>(),
          isA<CameraErrorState>().having((state) => state.error, "error", CameraErrorType.other),
        ],
      );
      
      blocTest<CameraContainerBloc, CameraContainerState>(
        'appLifecycleStateObserver',
        setUp: () {
          when(() => meteringInteractor.checkCameraPermission()).thenAnswer((_) async => true);
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(cameraMethodChannel, cameraMethodCallSuccessHandler);
        },
        tearDown: () {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(cameraMethodChannel, null);
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(cameraIdMethodChannel, null);
        },
        build: () => bloc,
        act: (bloc) async {
          bloc.add(const InitializeEvent());
          await Future.delayed(Duration.zero);
          TestWidgetsFlutterBinding.instance
              .handleAppLifecycleStateChanged(AppLifecycleState.detached);
          TestWidgetsFlutterBinding.instance
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        },
        verify: (_) {
          verify(() => meteringInteractor.checkCameraPermission()).called(2);
        },
        expect: () => [
          isA<CameraLoadingState>(),
          isA<CameraInitializedState>(),
          isA<CameraActiveState>()
              .having((state) => state.zoomRange, 'zoomRange', const RangeValues(1.0, 7.0))
              .having((state) => state.currentZoom, 'currentZoom', 1.0)
              .having(
                (state) => state.exposureOffsetRange,
                'exposureOffsetRange',
                const RangeValues(-4.0, 4.0),
              )
              .having((state) => state.exposureOffsetStep, 'exposureOffsetStep', 0.1666666)
              .having((state) => state.currentExposureOffset, 'currentExposureOffset', 0.0),
          isA<CameraLoadingState>(),
          isA<CameraInitializedState>(),
          isA<CameraActiveState>()
              .having((state) => state.zoomRange, 'zoomRange', const RangeValues(1.0, 7.0))
              .having((state) => state.currentZoom, 'currentZoom', 1.0)
              .having(
                (state) => state.exposureOffsetRange,
                'exposureOffsetRange',
                const RangeValues(-4.0, 4.0),
              )
              .having((state) => state.exposureOffsetStep, 'exposureOffsetStep', 0.1666666)
              .having((state) => state.currentExposureOffset, 'currentExposureOffset', 0.0),
        ],
      );
    },
  );
}

extension _MethodChannelMock on MethodChannel {
  Future<void> invokeMockMethod(String method, dynamic arguments) async {
    final data = const StandardMethodCodec().encodeMethodCall(MethodCall(method, arguments));
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      name,
      data,
      (ByteData? data) {},
    );
  }
}
