import 'package:flutter/material.dart';
import 'package:lightmeter/data/models/feature.dart';
import 'package:lightmeter/generated/l10n.dart';
import 'package:lightmeter/providers/remote_config_provider.dart';
import 'package:lightmeter/screens/settings/components/lightmeter_pro/components/buy_pro/widget_list_tile_buy_pro.dart';
import 'package:lightmeter/screens/settings/components/shared/settings_section/widget_settings_section.dart';

class LightmeterProSettingsSection extends StatelessWidget {
  const LightmeterProSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: RemoteConfig.isEnabled(context, Feature.unlockProFeaturesText)
          ? S.of(context).proFeatures
          : S.of(context).lightmeterPro,
      children: const [BuyProListTile()],
    );
  }
}
