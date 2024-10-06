import 'package:m3_lightmeter_resources/m3_lightmeter_resources.dart';

class IAPStorageService {
  const IAPStorageService(Object _);

  String get selectedEquipmentProfileId => '';
  set selectedEquipmentProfileId(String id) {}

  List<EquipmentProfile> get equipmentProfiles => [];
  set equipmentProfiles(List<EquipmentProfile> profiles) {}

  Film get selectedFilm => const FilmStub();
  set selectedFilm(Film value) {}

  List<Film> get filmsInUse => [];
  set filmsInUse(List<Film> profiles) {}
}
