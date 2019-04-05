import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class SlidingPageView extends StatefulWidget {
  final List<Widget> children;
  SlidingPageView({this.children});
  @override _SlidingPageViewState createState() => _SlidingPageViewState();
}

class _SlidingPageViewState extends State<SlidingPageView> with SingleTickerProviderStateMixin {

  int _index = 0;
  PageView _pageView;
  PageController _pageController;
  AnimationController _sliderOpacityController;
  Animation<double> _sliderAnimation;

  @override initState() {
    super.initState();
    _sliderOpacityController = AnimationController(vsync: this, duration: Duration(milliseconds: 1500));
    _sliderAnimation = Tween<double>(begin: 1, end: 0).animate(_sliderOpacityController)..addListener(() { setState(() {}); });
    _pageController = PageController(initialPage: _index);
    _pageView = PageView(children: widget.children, scrollDirection: Axis.vertical, controller: _pageController, onPageChanged: (value) {
      _sliderOpacityController.reset();
      rebuild(value);
      _sliderOpacityController.forward();
    },);
    _sliderOpacityController.forward();
  }

  @override dispose() {
    _pageController.dispose();
    _sliderOpacityController.dispose();
    super.dispose();
  }

  get _totalHeight => MediaQuery.of(context).size.height.floor() - _yViewInsets;
  get _yViewInsets => Scaffold.of(context).widget.appBar != null ? AppBar().preferredSize.height.toInt() + (Platform.isIOS ? MediaQuery.of(context).size.height > MediaQuery.of(context).size.width ? 21 : 0 : 25) : 0;
  get _itemCount => widget.children.length;
  get _sliderHeight => MediaQuery.of(context).size.height / 7;

  double offsetFor(int index) => index <= 0 ? 0 : index >= _itemCount-1 ? _totalHeight-_sliderHeight : (index * (_totalHeight - _sliderHeight) / _itemCount);

  jumpWith(Offset position) {
    _sliderOpacityController.reset();
    var localY = (context.findRenderObject( ) as RenderBox).globalToLocal( position ).dy.round();
    var nextIndex = localY <= _sliderHeight ? 0 : localY >= _totalHeight - _sliderHeight ? _itemCount-1 :  ((localY - _sliderHeight) / ((_totalHeight - (_sliderHeight*2)) / (_itemCount-2))).round();
    if (_pageController.page != nextIndex) { _pageController.jumpToPage(nextIndex); }
    rebuild(nextIndex);
  }

  rebuild(int index) { if (index != _index) { setState(() { _index = index; }); } }

  @override build(BuildContext context) {
    var pageView = Positioned.fill(child: _pageView);
    var detector = Positioned(top: 0, bottom: 0, right: 0, width: (MediaQuery.of(context).size.width / 9)+MediaQuery.of(context).padding.right, child: GestureDetector(onTapDown: (details) {
      jumpWith(details.globalPosition);
      _sliderOpacityController.forward();
    }, onVerticalDragUpdate: (details) {
      jumpWith(details.globalPosition);
    }, onVerticalDragEnd: (details) {
      _sliderOpacityController.forward();
    }));
    var slider = Positioned(top: offsetFor(_index), height: _sliderHeight, right: MediaQuery.of(context).padding.right+2, width: 6, child: Container(decoration: BoxDecoration(color: Colors.white.withOpacity(_sliderAnimation.value), borderRadius: BorderRadius.circular(8))));
    return Stack(children: <Widget>[pageView, slider, detector]);
  }
}