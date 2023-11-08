import 'package:flutter/material.dart';
import 'package:lightmeter/data/models/camera_feature.dart';
import 'package:lightmeter/generated/l10n.dart';
import 'package:lightmeter/providers/user_preferences_provider.dart';
import 'package:lightmeter/screens/settings/components/shared/dialog_switch/widget_dialog_switch.dart';

class CameraFeaturesListTile extends StatelessWidget {
  const CameraFeaturesListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.camera_alt),
      title: Text(S.of(context).cameraFeatures),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => DialogSwitch<CameraFeature>(
            icon: Icons.layers_outlined,
            title: S.of(context).cameraFeatures,
            values: UserPreferencesProvider.cameraConfigOf(context),
            titleAdapter: _toStringLocalized,
            onSave: UserPreferencesProvider.of(context).setCameraFeature,
          ),
        );
      },
    );
  }

  String _toStringLocalized(BuildContext context, CameraFeature feature) {
    switch (feature) {
      case CameraFeature.spotMetering:
        return S.of(context).cameraFeatureSpotMetering;
      case CameraFeature.histogram:
        return S.of(context).cameraFeatureHistogram;
    }
  }
}
