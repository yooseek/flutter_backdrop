import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'app_backdrop.dart';

part 'pop_router_on_over_scroll.dart';

class BackDropScreen extends StatelessWidget {
  final Widget backgroundChild;
  final Widget bottomChild;
  final double topPadding;

  const BackDropScreen({
    required this.bottomChild,
    required this.backgroundChild,
    this.topPadding = 500,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            TopContent(child: backgroundChild),
            BottomList(
              topPadding: topPadding,
              deviceSize: size,
              child: bottomChild,
            ),
          ],
        ),
      ),
    );
  }
}

class TopContent extends StatelessWidget {
  final Widget child;

  const TopContent({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class BottomList extends StatefulWidget {
  final double topPadding;
  final Widget child;
  final Size deviceSize;

  const BottomList({
    required this.topPadding,
    required this.child,
    required this.deviceSize,
    Key? key,
  }) : super(key: key);

  @override
  State<BottomList> createState() => _BottomListState();
}

class _BottomListState extends State<BottomList> {
  late final ScrollController _scroller = ScrollController()
    ..addListener(_handleScrollChanged);
  final _scrollPos = ValueNotifier(0.0);
  bool isBackdropFilter = true;

  void _handleScrollChanged() {
    _scrollPos.value = _scroller.position.pixels;
  }

  @override
  void dispose() {
    _scroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopRouterOnOverScroll(
      controller: _scroller,
      child: LayoutBuilder(builder: (_, constraints) {
        return AnimatedBuilder(
          animation: _scroller,
          builder: (_, __) {
            bool showBackdrop = true;
            double backdropAmt = 0;
            if (_scroller.hasClients) {
              double blurStart = 50;
              double maxScroll = 150;
              double scrollPx = _scroller.position.pixels - blurStart;
              // Normalize scroll position to a value between 0 and 1
              backdropAmt =
                  (_scroller.position.pixels - blurStart).clamp(0, maxScroll) /
                      maxScroll;
              // Disable backdrop once it is offscreen for an easy perf win
              showBackdrop =
                  (scrollPx + (widget.deviceSize.height - widget.topPadding) <=
                      widget.deviceSize.height);
            }
            return Stack(
              children: [
                if (showBackdrop) ...[
                  AppBackdrop(
                    strength: backdropAmt,
                    child: IgnorePointer(
                      child: Container(
                        color: Colors.grey.withOpacity(backdropAmt * .6),
                      ),
                    ),
                  ),
                ],
                // disableByScroll(),
                _bottomListContent(),
              ],
            );
          },
        );
      }),
    );
  }

  // 스크롤에 따라서 사라지는 위젯
  ValueListenableBuilder<double> disableByScroll() {
    return ValueListenableBuilder<double>(
      valueListenable: _scrollPos,
      builder: (_, value, child) {
        // get some value between 0 and 1, based on the amt scrolled
        double opacity = (1 - value / 150).clamp(0, 1);
        return Opacity(opacity: opacity, child: child);
      },
      child: Container(
        height: 50,
        width: 50,
        color: Colors.teal,
      ),
    );
  }

  Widget _bottomListContent() {
    Container buildHandle() {
      return Container(
        width: 35,
        height: 5,
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(99)),
      );
    }

    return SingleChildScrollView(
      controller: _scroller,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          IgnorePointer(
            child: Container(
              height: widget.topPadding,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                buildHandle(),
                SizedBox(height: 15,),
                widget.child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
