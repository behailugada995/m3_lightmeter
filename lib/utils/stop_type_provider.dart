import 'package:flutter/material.dart';
import 'package:m3_lightmeter_resources/m3_lightmeter_resources.dart';
import 'package:provider/provider.dart';

class StopTypeProvider extends StatefulWidget {
  final Widget? child;

  const StopTypeProvider({this.child, super.key});

  static StopTypeProviderState of(BuildContext context) {
    return context.findAncestorStateOfType<StopTypeProviderState>()!;
  }

  @override
  State<StopTypeProvider> createState() => StopTypeProviderState();
}

class StopTypeProviderState extends State<StopTypeProvider> {
  StopType _stopType = StopType.third;

  StopType get stopType => _stopType;

  void set(StopType type) {
    setState(() {
      _stopType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: _stopType,
      child: widget.child,
    );
  }
}
