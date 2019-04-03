import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class SlidingPageView extends StatefulWidget {
  final List<Widget> children;
  SlidingPageView({this.children});
  @override
  _SlidingPageViewState createState() => _SlidingPageViewState();
}

class _SlidingPageViewState extends State<SlidingPageView> with SingleTickerProviderStateMixin {

  int _index = 0;
  PageController _pageController;
  AnimationController _sliderOpacityController;
  Animation<double> _sliderAnimation;

  @override initState() {
    super.initState();
    _pageController = PageController(initialPage: _index);
    _sliderOpacityController = AnimationController(vsync: this, duration: Duration(milliseconds: 1500));
    _sliderAnimation = Tween<double>(begin: 1, end: 0).animate(_sliderOpacityController)..addListener(() { setState(() {}); });
    _sliderOpacityController.forward();
  }

  @override dispose() {
    _pageController.dispose();
    _sliderOpacityController.dispose();
    super.dispose();
  }

  double get _sliderHeight => MediaQuery.of(context).size.height / 7;
  int get _appBarYOffset => Scaffold.of(context).widget.appBar != null ? AppBar().preferredSize.height.toInt() + (Platform.isIOS ? MediaQuery.of(context).size.height > MediaQuery.of(context).size.width ? 21 : 0 : 25) : 0;
  int get _totalHeight => MediaQuery.of(context).size.height.floor() - _appBarYOffset;
  int get _itemCount => widget.children.length;

  double offsetFor(int index) => index <= 0 ? 0 : index >= _itemCount-1 ? _totalHeight-_sliderHeight : (index * (_totalHeight - _sliderHeight) / _itemCount);

  jumpWith(Offset position) {
    _sliderOpacityController.reset();
    var localY = (context.findRenderObject( ) as RenderBox).globalToLocal( position ).dy.round();
    var nextIndex = localY <= _sliderHeight ? 0 : localY >= _totalHeight - _sliderHeight ? _itemCount-1 :  ((localY - _sliderHeight) / ((_totalHeight - (_sliderHeight*2)) / (_itemCount-2))).floor()+1;
    if (_pageController.page != nextIndex) { _pageController.jumpToPage(nextIndex); }
    rebuild(nextIndex);
  }

  rebuild(int index) { if (index != _index) { setState(() { _index = index; }); } }

  @override
  Widget build(BuildContext context) {
    var pageView = Positioned.fill(child: PageView(children: widget.children, scrollDirection: Axis.vertical, controller: _pageController, onPageChanged: (value) {
      _sliderOpacityController.reset();
      rebuild(value);
      _sliderOpacityController.forward();
    },));
    var detector = Positioned(top: 0, bottom: 0, right: 0, width: 44, child: GestureDetector(onTapDown: (details) {
      jumpWith(details.globalPosition);
      _sliderOpacityController.forward();
    }, onVerticalDragUpdate: (details) {
      jumpWith(details.globalPosition);
    }, onVerticalDragEnd: (details) {
      _sliderOpacityController.forward();
    } ));
    var slider = Positioned(top: offsetFor(_index), height: _sliderHeight, right: 2, width: 6, child: Container(decoration: BoxDecoration(color: Colors.white.withOpacity(_sliderAnimation.value), borderRadius: BorderRadius.circular(8))));
    return Stack(children: <Widget>[pageView, slider, detector]);
  }
}