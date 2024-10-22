import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lightmeter/screens/film_edit/event_film_edit.dart';
import 'package:lightmeter/screens/film_edit/state_film_edit.dart';
import 'package:m3_lightmeter_resources/m3_lightmeter_resources.dart';

class FilmEditBloc extends Bloc<FilmEditEvent, FilmEditState> {
  final FilmExponential _originalFilm;
  FilmExponential _newFilm;

  FilmEditBloc(FilmExponential film)
      : _originalFilm = film,
        _newFilm = film,
        super(
          FilmEditState(
            name: film.name,
            isoValue: IsoValue.values.firstWhere((element) => element.value == film.iso),
            exponent: film.exponent,
            canSave: false,
          ),
        ) {
    on<FilmEditEvent>(
      (event, emit) {
        switch (event) {
          case final FilmEditNameChangedEvent e:
            _onNameChanged(e, emit);
          case final FilmEditIsoChangedEvent e:
            _onIsoChanged(e, emit);
          case final FilmEditExpChangedEvent e:
            _onExpChanged(e, emit);
          case FilmEditSaveEvent():
            _onSave(event, emit);
        }
      },
    );
  }

  Future<void> _onNameChanged(FilmEditNameChangedEvent event, Emitter emit) async {
    _newFilm = _newFilm.copyWith(name: event.name);
    emit(
      FilmEditState(
        name: event.name,
        isoValue: state.isoValue,
        exponent: state.exponent,
        canSave: _canSave(event.name, state.exponent),
      ),
    );
  }

  Future<void> _onIsoChanged(FilmEditIsoChangedEvent event, Emitter emit) async {
    _newFilm = _newFilm.copyWith(iso: event.iso.value);
    emit(
      FilmEditState(
        name: state.name,
        isoValue: event.iso,
        exponent: state.exponent,
        canSave: _canSave(state.name, state.exponent),
      ),
    );
  }

  Future<void> _onExpChanged(FilmEditExpChangedEvent event, Emitter emit) async {
    if (event.exponent != null) {
      _newFilm = _newFilm.copyWith(exponent: event.exponent);
    }
    emit(
      FilmEditState(
        name: state.name,
        isoValue: state.isoValue,
        exponent: event.exponent,
        canSave: _canSave(state.name, event.exponent),
      ),
    );
  }

  Future<void> _onSave(FilmEditSaveEvent _, Emitter emit) async {}

  bool _canSave(String name, double? exponent) {
    return name.isNotEmpty && exponent != null && _newFilm != _originalFilm;
  }
}
