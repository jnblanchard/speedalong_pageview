# Speed PageView - Implicit Scrollbar
![](https://static.wixstatic.com/media/8e69fb_94f12bd5464341d19c1dad243819f7d8~mv2.gif)

## Overview
Developers are responsible for solving a wide scope of issues, one sticky problem is nested scrollable-containers. Often developers are presented with a design that requires page turning. 
PageView does this stuff for you, but it does not feature page surfing. In UIKit a collection-view may come with a nested scroll bar. The implicit scrollbar eliminates cartesian confusion. 
My app shows off an implicit scrollbar that works with a PageView. The scrollbar can be tapped to quickly jump to a corresponding page. Along the greater body, the user can (slowly) turn pages sequentially. The right bar is scrollable and flips pages quickly.
There exists an enlarged hit-box for reaching the first and last page, but pages from (pages.length-2) are jumped to by tapping the appropriate pigeon-holed location.
SlidingPageView is a stack with a PageView on the bottom, a Container (slider) that animates y-direction, and a GestureDetector that is (width of the screen / 8) wide and the height of the screen. 

## Jumping Pages
The right side has the hidden gesture detector, the slider will show along the top when first entering the screen, but after 1.5 secs of idling the slider disappears from the screen.
After a tap gesture, the slider will jump to the touch location, and the PageView will also jump to the mapped index of the tap location. After slider animates off screen.
During a drag gesture, the slider will jump to the location, and the PageView will also jump to the mapped index of the tap location; does not animate the slider off screen.
After a drag gesture ends, starts animating the slider off screen.

## Dimensions
Take the relative tap or scroll position and associate the gesture with a page movement. (mapping gestures to page indices)
My goal was to make the first and last page easiest to turn to. But all other pages are still reachable by gesture. 
The size of the scroll container and gesture detector are calculated below.
```
itemCount = 47 // Number of Bart stations in json file (station.json).
sliderWidth = 6;
sliderHeight = MediaQuery.of(context).size.height / 7;
totalWidth = MediaQuery.of(context).size.width; // (context is rebuilt upon orientation change)
totalHeight = MediaQuery.of(context).size.height - (yOffset); // The SlidingPageView will calculate if the appBar is active and deduct it's size, it also has logic for substracting system specific amounts.
tapScrollView = GestureDetector(x: totalWidth - (totalWidth/8), y: 0, width: (totalWidth/8), height: totalHeight); // A transparent view that is on top of our slider on the stack.
```

#### Bart Stations (47 cells)  ( || => pigeonHoleCellHeight )
This model is visual representation of the gesture mappings to the SlidingPageView in this app. But it is meant to size to any PageView with more than 2 children.
Upon orientation change, the cells may grow in the x-direction to counter system UI padding. For example the landscape left cells on an iphone X are a greater width because the SlidingPageView covers the notched area. 
```
pigeonHoleCellHeight = ((_totalHeight - (_sliderHeight*2)) / (_itemCount-2))).round();  // The pigeon cell height is the (total height - padding area) divided by the number of pigeoned cells (itemCount - 2). Where 2 is the number of padded cells (first and last).

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
int localY = (context.findRenderObject( ) as RenderBox).globalToLocal( position ).dy.round();
int pigeonHoleIndex = ((localY - _sliderHeight) / ((_totalHeight - (_sliderHeight*2)) / (_itemCount-2))).round();
int nextIndex = localY <= _sliderHeight ? 0 : localY >= _totalHeight - _sliderHeight ? _itemCount-1 :  pigeonHoleIndex;
```

## Page number to yOffset 
This method is used by a Position widget that parents the slider container. The top parameter is calculated using offSet(currentIndex).
If at the first page, set the top value to 0. Align the slider along the top.
If we are at the last page, set the top value to total height subtracted by the slider's height.  Align the slider along the bottom.
Otherwise we calculate a top value using the pigeon hole.
```dart
double pigeonHoleOffset = (index * (_totalHeight - _sliderHeight) / _itemCount);
double offsetFor(int index) => index <= 0 ? 0 : index >= _itemCount-1 ? _totalHeight-_sliderHeight : pigeonHoleOffset;
```

## Limitations
The SlidingPageView only supports vertical PageView direction, but it could be written to support horizontal page flipping.
The horizontal SlidingPageView may be delightful way for app user's to experience a timeline or reading experience.
It was really difficult having less than 5120 bytes of Dart, I rewrote this project 6 times with different implementations and features.

[John Blanchard](https://jnblanchard.com)


