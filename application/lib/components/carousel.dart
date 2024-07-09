import 'package:application/design/styles.dart';
import 'package:flutter/material.dart';

class Carousel extends StatefulWidget {
  final List<dynamic> images;
  final Widget Function(BuildContext, int) imageBuilder;
  final double viewportFraction;

  final double? width;
  final double? height;

  const Carousel({
    super.key,
    required this.images,
    required this.imageBuilder,
    this.width,
    this.height,
    required this.viewportFraction,
  });

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late PageController _pageController;
  var _currentPage = 0;

  @override
  void initState() {
    _pageController = PageController(viewportFraction: widget.viewportFraction);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: PageView.builder(
            onPageChanged: (value) => setState(() => _currentPage = value),
            controller: _pageController,
            itemCount: widget.images.length,
            itemBuilder: widget.imageBuilder,
          ),
        ),
        if (widget.images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: indicators(widget.images.length, _currentPage),
          )
      ],
    );
  }

  List<Widget> indicators(imagesLength, currentIndex) {
    return List<Widget>.generate(imagesLength, (index) {
      return Container(
        margin: const EdgeInsets.all(3),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: currentIndex == index ? Styles.orange : Colors.black26,
          shape: BoxShape.circle,
        ),
      );
    });
  }
}
