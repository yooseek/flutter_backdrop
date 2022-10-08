part of 'backdrop_screen.dart';

class AppBackdrop extends StatelessWidget {
  const AppBackdrop({
    Key? key,
    this.strength = 1,
    this.child,
  }) : super(key: key);

  final double strength;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final double normalStrength = clampDouble(strength, 0, 1);

    return BackdropFilter(
      filter: ImageFilter.blur(
          sigmaX: normalStrength * 5.0, sigmaY: normalStrength * 5.0),
      child: child ?? const SizedBox.expand(),
    );
  }
}
