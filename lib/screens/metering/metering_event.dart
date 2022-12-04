import 'package:lightmeter/models/iso_value.dart';
import 'package:lightmeter/models/nd_value.dart';

abstract class MeteringEvent {
  const MeteringEvent();
}

class IsoChangedEvent extends MeteringEvent {
  final IsoValue isoValue;

  const IsoChangedEvent(this.isoValue);
}

class NdChangedEvent extends MeteringEvent {
  final NdValue ndValue;

  const NdChangedEvent(this.ndValue);
}

class MeasureEvent extends MeteringEvent {
  const MeasureEvent();
}
