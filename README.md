# SlidingPageView: Implicit Scrollbar for PageView
![](https://static.wixstatic.com/media/8e69fb_94f12bd5464341d19c1dad243819f7d8~mv2.gif)

## Overview
This is a [contest](https://flutter.dev/create) submission.

There are over 5 million mobile apps. Developers thrive with brevity; a place where programmers can bring ideas to life quickly. Widgets enticed me into working with Flutter because they're fun and expressive.

I created a stateful widget that parents a PageView. On this widget is a scrollbar that can be moved around to jump pages. 

The scrollbar can be tapped to quickly jump to an associated page. Along the greater body, the user can (slowly) turn pages sequentially. The right bar is scrollable and flips pages quickly.
There exists an enlarged hit-box for reaching the first and last page, but pages from (pages.length-2) are jumped to by tapping the appropriate pigeon-holed location.
SlidingPageView is a stack with a PageView on the bottom, a Container (slider) that animates y-direction, and a GestureDetector that is (width of the screen / 8) wide and the height of the screen. 
 
The implicit scrollbar eliminates cartesian confusion. SlidingPageView was built to be a commonly used interface for all platforms, devices, and orientations.

## Build
To create a SlidingPageView, provide a list of pages. No animation, or page controllers needed. Instead that stuff is handled by the widget.

``` dart
List<Widget>[] pages = [Image.asset("images/${pageOne}.png"), Image.asset("images/${pageTwo}.png")];
SlidingPageView(children: pages);
```

## Gestures
The right side has the hidden gesture detector, the slider will show along the top when first entering the screen, but 1.5 secs in the slider disappears from the screen.

#### Taps
After a tap gesture, the slider will jump to the touch location, and the PageView will also jump to the mapped index of the tap location. After jumping, the slider animates off screen.

#### Drags
During a drag gesture, the slider will jump to the associated location, and the PageView will also jump to the mapped index of the tap location; however the slider does not animate off screen.

After a drag gesture ends, the slider animates off screen.

## Dimensions
My goal was to make the first and last page easiest to turn to. But all other pages are still reachable by gesture. 
The size of the scroll container and gesture detector are calculated below.
```
itemCount = 47 // Number of Bart stations in json file (station.json).
sliderWidth = 6; // 6 pixels wide
sliderHeight = MediaQuery.of(context).size.height / 7;  // Calculate size for slider height.
totalWidth = MediaQuery.of(context).size.width; // (context is rebuilt upon orientation change)
yViewInset = Scaffold.of(context).widget.appBar != null ? AppBar().preferredSize.height.toInt() + (Platform.isIOS ? MediaQuery.of(context).size.height > MediaQuery.of(context).size.width ? 21 : 0 : 25) : 0;
totalHeight = MediaQuery.of(context).size.height - (yViewInset); // The SlidingPageView will calculate if the appBar is active and deduct it's size, it also has logic for substracting system specific amounts.
tapScrollView = GestureDetector(x: totalWidth - (totalWidth/8), y: 0, width: (totalWidth/8), height: totalHeight); // A transparent view that is on top of our slider on the stack.
```

#### Example
##### Bart Stations (47 cells)  ( || => pigeonHoleCellHeight )

This model is visual representation of the gesture mappings to the SlidingPageView in this app. But it is meant to size to any PageView with more than 2 children.
Upon orientation change, the cells may grow in the x-direction to counter system UI padding. For example the landscape left cells on an iphone X are a greater width because the SlidingPageView covers the notched area. 
```
gestureDetectorWidth = (MediaQuery.of(context).size.width / 9)+MediaQuery.of(context).padding.right; // 1/9th of the screen size added to the safe area right padding inset.
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

## Coversion: Gesture (tap or drag) to Page Number
When a tap or scroll occurs, a local touch position is computed. This gets turned into a y-value that ranges from 0 to the height of the PageView.

#### Page 1
If a tap with local y-value less than or equal to the slider's height, then page 1 was selected. (index 0)

#### Last Page
If a scroll with local y-value greater than the total height subtracted by the slider's height; then the last page was selected. (index itemCount-1)

#### (1 < n < itemCount) Page
If a tap with local yPosition greater than the slider's height but less than the total height subtracted by the slider's height. Calculate a pigeon holed index.
```dart
int localY = (context.findRenderObject( ) as RenderBox).globalToLocal( position ).dy.round(); // Convert to local y postiion.
int pigeonHoleIndex = ((localY - _sliderHeight) / ((_totalHeight - (_sliderHeight*2)) / (_itemCount-2))).round(); // With 47 pages, there are 45 pigeon holed cells. A sliderHeight of 80 will make the totalPigeonHeight => totalHeight - (80*2);
int nextIndex = localY <= _sliderHeight ? 0 : localY >= _totalHeight - _sliderHeight ? _itemCount-1 :  pigeonHoleIndex;  // Check the top and bottom of the canvas against the touch location. If inside the pigeon, 1 < n < itemCount, use pigeon index.
```

## Conversion: Page Number to Slider Offset 
This method is used by a Positioned widget that parents the slider container. The top parameter is calculated using offSet(currentIndex).

#### Page 1
If at the first page, set the top value to 0. Align the slider along the top.

#### Last Page
If we are at the last page, set the top value to total height subtracted by the slider's height.  Align the slider along the bottom.

#### (1 < n < itemCount) Page
Otherwise we calculate a top value using the pigeon hole.
```dart
double pigeonHoleOffset = (index * (_totalHeight - _sliderHeight) / _itemCount);
double offsetFor(int index) => index <= 0 ? 0 : index >= _itemCount-1 ? _totalHeight-_sliderHeight : pigeonHoleOffset;
```

## Limitations
The SlidingPageView only supports vertical PageView direction, but it could easily support horizontal page flipping if I had the space.
For example, a horizontal SlidingPageView may be a delightful way for users to develop a timeline or reading experience.

##### It was really difficult having less than 5120 bytes of Dart, I rewrote this project 6 times with different implementations and features.

# Creative Acknowledgment
The example app was comprised of wonderful pictures by these people.

Ashby - [Franco Folini](https://www.flickr.com/photos/livenature/)

West Oakland - [Thomas Hawk](https://www.flickr.com/photos/thomashawk/)

12th St. Oakland City Center - [Brian Stokle](https://www.flickr.com/photos/brunoboris/)

16th St. Mission - [Adam Moss](https://www.flickr.com/photos/roadgeek/)

19th St. Oakland - [Victoria Hyde](https://www.flickr.com/photos/soulcookie/)

24th St. Mission - [Stephanie Vacher](https://www.flickr.com/photos/trufflepig/)

Antioch - [Jim Maurer](https://www.flickr.com/photos/schaffner/)

Balboa - [Andrew Nash](https://www.flickr.com/photos/andynash/)

Bay Fair - [Adam Moss](https://www.flickr.com/photos/roadgeek/)

Civic Center/UN Plaza - [telmo32](https://www.flickr.com/photos/telmo32/)

Colma - [cifraser1](https://www.flickr.com/photos/cifraser/)

Coliseum - [Paul Sullivan](https://www.flickr.com/photos/pfsullivan_1056/)

Concord - [jacampos](https://www.flickr.com/photos/jacampos/)

Daly City - [meligrosa](https://www.flickr.com/photos/meligrosa/)

Downtown Berkeley - [Tzuhsun Hsu](https://www.flickr.com/photos/alberth2/)

El Cerrito del Norte - [~dgies](https://www.flickr.com/photos/daniel_gies/)

Dublin/Plesanton - [Eric Fischer](https://www.flickr.com/photos/walkingsf/)

Embarcadero - [tian2992](https://www.flickr.com/photos/tian2992/)

Fremont - [Mike Linksvayer](https://www.flickr.com/photos/mlinksva/)

Fruitvale - [pengrin™](https://www.flickr.com/photos/pengrin/)

Glen Park - [Travis Wise](https://www.flickr.com/photos/photographingtravis/)

Hayward - [wilson](https://www.flickr.com/photos/wung/)

Lafayette - [Franco Folini](https://www.flickr.com/photos/livenature/)

MacArthur - [Melinda * Young](https://www.flickr.com/photos/melystu/)

Millbrae - [Prayitno](https://www.flickr.com/photos/prayitnophotography/)

Montgomery St. - [Markus Spiering](https://www.flickr.com/photos/spierisf/)

North Berkeley - [Romel Jacinto](https://www.flickr.com/photos/37degrees/)

North Concord/Martinez - [rocor](https://www.flickr.com/photos/rocor/)

Orinda - [Mike Linksvayer](https://www.flickr.com/photos/mlinksva/)

Pittsburg Center - [Jim Maurer](https://www.flickr.com/photos/schaffner/)

Pleasant Hill/Contra Costa Centre - [Brian Stokle](https://www.flickr.com/photos/brunoboris/)

Pittsburg/Bay Point - [Jim Maurer](https://www.flickr.com/photos/schaffner/)

El Cerrito Plaza - [Paul Sullivan](https://www.flickr.com/photos/pfsullivan_1056/)

Powell St - [Jeromyu](https://www.flickr.com/photos/jeromyu/)

Richmond - [Don Barrett](https://www.flickr.com/photos/donbrr/)

Rockridge - [Robert MacCloy](https://www.flickr.com/photos/zenned/)

San Leandro - [AC ServiceInfo](https://www.flickr.com/photos/ac_service_info/)

San Bruno - [The West End](https://www.flickr.com/photos/thewestend/)

SF Airport - [inmediahk](https://www.flickr.com/photos/inmediahk/)

South Hayward - [Ferrous Büller](https://www.flickr.com/photos/lumachrome/)

South San Francisco - [Denmark](https://www.flickr.com/photos/tekniks/)

Union City - [Rafael Castillo](https://www.flickr.com/photos/miggslives/)

Warm Springs - [Jim Maurer](https://www.flickr.com/photos/schaffner/)

Walnut Creek - [Paolo Valdemarin](https://www.flickr.com/photos/paolovalde/)

West Dublin/Pleasanton - [Eric Fischer](https://www.flickr.com/photos/walkingsf/)



