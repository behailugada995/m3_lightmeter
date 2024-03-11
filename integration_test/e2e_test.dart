import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lightmeter/data/models/ev_source_type.dart';
import 'package:lightmeter/data/models/metering_screen_layout_config.dart';
import 'package:lightmeter/data/shared_prefs_service.dart';
import 'package:lightmeter/generated/l10n.dart';
import 'package:lightmeter/screens/metering/components/bottom_controls/components/measure_button/widget_button_measure.dart';
import 'package:lightmeter/screens/metering/components/shared/readings_container/components/equipment_profile_picker/widget_picker_equipment_profiles.dart';
import 'package:lightmeter/screens/metering/components/shared/readings_container/components/film_picker/widget_picker_film.dart';
import 'package:lightmeter/screens/metering/components/shared/readings_container/components/iso_picker/widget_picker_iso.dart';
import 'package:lightmeter/screens/metering/components/shared/readings_container/components/nd_picker/widget_picker_nd.dart';
import 'package:lightmeter/screens/metering/components/shared/readings_container/components/shared/animated_dialog_picker/components/dialog_picker/widget_picker_dialog.dart';
import 'package:m3_lightmeter_resources/m3_lightmeter_resources.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../integration_test/utils/widget_tester_actions.dart';
import 'mocks/paid_features_mock.dart';
import 'utils/expectations.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      /// Metering values
      UserPreferencesService.evSourceTypeKey: EvSourceType.camera.index,
      UserPreferencesService.meteringScreenLayoutKey: json.encode(
        {
          MeteringScreenLayoutFeature.equipmentProfiles: true,
          MeteringScreenLayoutFeature.extremeExposurePairs: true,
          MeteringScreenLayoutFeature.filmPicker: true,
        }.toJson(),
      ),
    });
  });

  testWidgets(
    'e2e',
    (tester) async {
      await tester.pumpApplication();

      /** First launch */

      /// Select some initial settings according to the selected gear and film
      /// Then tale a photo and verify, that exposure pairs range and EV matches the selected settings
      await tester.openPickerAndSelect<EquipmentProfilePicker, EquipmentProfile>(mockEquipmentProfiles[0].name);
      await tester.openPickerAndSelect<FilmPicker, Film>(mockFilms[0].name);
      await tester.openPickerAndSelect<IsoValuePicker, IsoValue>('400');
      expectPickerTitle<EquipmentProfilePicker>(mockEquipmentProfiles[0].name);
      expectPickerTitle<FilmPicker>(mockFilms[0].name);
      expectPickerTitle<IsoValuePicker>('400');
      await tester.takePhoto();
      await _expectMeteringState(
        tester,
        equipmentProfile: mockEquipmentProfiles[0],
        film: mockFilms[0],
        fastest: 'f/1.8 - 1/400',
        slowest: 'f/16 - 1/5',
        iso: '400',
        nd: 'None',
        ev: mockPhotoEv100 + 2,
      );

      /** Changing some settings in the field */

      /// Add ND to shoot another scene
      await tester.openPickerAndSelect<NdValuePicker, NdValue>('2');
      await _expectMeteringStateAndMeasure(
        tester,
        equipmentProfile: mockEquipmentProfiles[0],
        film: mockFilms[0],
        fastest: 'f/1.8 - 1/200',
        slowest: 'f/16 - 1/2.5',
        iso: '400',
        nd: '2',
        ev: mockPhotoEv100 + 2 - 1,
      );

      /// Select another lens without ND
      await tester.openPickerAndSelect<EquipmentProfilePicker, EquipmentProfile>(mockEquipmentProfiles[1].name);
      await tester.openPickerAndSelect<NdValuePicker, NdValue>('None');
      await _expectMeteringStateAndMeasure(
        tester,
        equipmentProfile: mockEquipmentProfiles[1],
        film: mockFilms[0],
        fastest: 'f/3.5 - 1/100',
        slowest: 'f/22 - 1/2.5',
        iso: '400',
        nd: 'None',
        ev: mockPhotoEv100 + 2,
      );

      /// Set another wilm and set the same ISO
      await tester.openPickerAndSelect<IsoValuePicker, IsoValue>('200');
      await tester.openPickerAndSelect<FilmPicker, Film>(mockFilms[1].name);
      await _expectMeteringStateAndMeasure(
        tester,
        equipmentProfile: mockEquipmentProfiles[1],
        film: mockFilms[1],
        fastest: 'f/3.5 - 1/50',
        slowest: 'f/22 - 1/1.3',
        iso: '200',
        nd: 'None',
        ev: mockPhotoEv100 + 1,
      );
    },
  );
}

extension on WidgetTester {
  Future<void> openPickerAndSelect<P extends Widget, V>(String valueToSelect) async {
    await openAnimatedPicker<P>();
    await tapDescendantTextOf<DialogPicker<V>>(valueToSelect);
    await tapSelectButton();
  }
}

Future<void> _expectMeteringState(
  WidgetTester tester, {
  required EquipmentProfile equipmentProfile,
  required Film film,
  required String fastest,
  required String slowest,
  required String iso,
  required String nd,
  required double ev,
  String? reason,
}) async {
  expectPickerTitle<EquipmentProfilePicker>(equipmentProfile.name);
  expectPickerTitle<FilmPicker>(film.name);
  expectExtremeExposurePairs(fastest, slowest);
  expectPickerTitle<IsoValuePicker>(iso);
  expectPickerTitle<NdValuePicker>(nd);
  expectExposurePairsListItem(tester, fastest.split(' - ')[0], fastest.split(' - ')[1]);
  await tester.scrollToTheLastExposurePair(equipmentProfile: equipmentProfile);
  expectExposurePairsListItem(tester, slowest.split(' - ')[0], slowest.split(' - ')[1]);
  expectMeasureButton(ev);
}

Future<void> _expectMeteringStateAndMeasure(
  WidgetTester tester, {
  required EquipmentProfile equipmentProfile,
  required Film film,
  required String fastest,
  required String slowest,
  required String iso,
  required String nd,
  required double ev,
}) async {
  await _expectMeteringState(
    tester,
    equipmentProfile: equipmentProfile,
    film: film,
    fastest: fastest,
    slowest: slowest,
    iso: iso,
    nd: nd,
    ev: ev,
  );
  await tester.takePhoto();
  await _expectMeteringState(
    tester,
    equipmentProfile: equipmentProfile,
    film: film,
    fastest: fastest,
    slowest: slowest,
    iso: iso,
    nd: nd,
    ev: ev,
    reason:
        'Metering screen state must be the same before and after the measurement assuming that the scene is exactly the same.',
  );
}

void expectMeasureButton(double ev) {
  find.descendant(
    of: find.byType(MeteringMeasureButton),
    matching: find.text('${ev.toStringAsFixed(1)}\n${S.current.ev}'),
  );
}
