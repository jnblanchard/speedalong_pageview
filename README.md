# Speed PageView - Implicit Scrollbar

![](https://static.wixstatic.com/media/8e69fb_94f12bd5464341d19c1dad243819f7d8~mv2.gif)

## Overview
Developers are responsible for solving a wide scope of issues, one sticky problem is nested scrollable-containers. Often developers are presented with a design that requires page turning. 
PageView does this stuff for you, but it does not feature page surfing. In UIKit a collection-view may come with a nested scroll bar. Implicit scrollbars eliminate cartesian confusion. 
My app shows off an implicit scrollbar that works with a PageView. The scrollbar can be tapped to quickly jump to a corresponding page. Along the greater body, the user can (slowly) turn pages sequentially. The right bar is scrollable and flips pages quickly.
There exists an enlarged hit-box for reaching the first and last page, but pages from (pages.length-2) can be jumped to by tapping the appropriate pigeon-holed height.
SlidingPageView is stack with a PageView on the bottom, a Container (slider) that animates y-direction, and a GestureDetector that is 44 pixels wide and the height of the screen.

## Jumping Pages
The right side has the hidden gesture detector, the slider will show along the top when first entering the screen, but after 1.5 secs idling the slider disappears from the screen.
After a tap gesture, the slider will jump to the location, and the PageView will also jump to the mapped index of the tap location. After slider animates off screen.
During a drag gesture, the slider will jump to the location, and the PageView will also jump to the mapped index of the tap location; does not animate the slider off screen.
After a drag gesture ends, starts animating the slider off screen.

## Notes
The SlidingPageView only supports vertical PageView direction, but it could be written to support horizontal page flipping.
A horizontal SlidingPageView may be delightful way to implement a timeline or reading experience.
It was really difficult having less than 5120 bytes of Dart, I rewrote this project 5-6 times with different implementations and features.


## Gesture Dimensions

Scroll Gesture Detector Cell Spacing (mapping to page indices)
The goal is to make the first and last page easiest to turn to.
Bart Stations (47 cells)  (|| => pigeonHoleCellHeight)

```
Appbar or Top
__________________
|   || page 1    |
|   || page 1    |
|   || page 1    ||
|   || page 2    |
|   || page 3    |
|   ...          |
|   ...          |
|   ...          |
|   ...          |
|   || page 46   |          
|   || page 47   |
|   || page 47   |
|   || page 47   |
------------------

Nav Bar or Bottom
```


## Gesture details to page number
When a tap or scroll occurs, the gestureDetail create a local touch position. This gives us a touch location that ranges from 0 to the height of the PageView.
If a tap with local yPosition less than or equal to the slider's height, then page 1 was selected. (index 0)
If a scroll with local yPostion greater than total height subtracted by the slider's height; the last page was selected. (index itemCount-1)
If a tap with local yPosition greater than the slider's height but less than the total height subtracted by the slider's height; we calculate a pigeon holed index.
```dart
var pigeonHoleIndex = ((localY - _sliderHeight) / ((_totalHeight - (_sliderHeight*2)) / (_itemCount-2))).floor()+1;
int localY = (context.findRenderObject( ) as RenderBox).globalToLocal( position ).dy.round();
int nextIndex = localY <= _sliderHeight ? 0 : localY >= _totalHeight - _sliderHeight ? _itemCount-1 :  pigeonHoleIndex;
```

## Page number to yOffset 
This method is used by a Position widget that parents the slider container. The top parameter is calculated using offSet(currentIndex).
If at the first page, set the top value to 0. Align the slider along the top.
If we are at the last page, set the top value to total height subtracted by the slider's height.  Align the slider along the bottom.
Otherwise we calculate a top value using the pigeon hole.
```dart
var pigeonHoleOffset = (index * (_totalHeight - _sliderHeight) / _itemCount);
double offsetFor(int index) => index <= 0 ? 0 : index >= _itemCount-1 ? _totalHeight-_sliderHeight : pigeonHoleOffset;
```

[John Blanchard](https://jnblanchard.com)


