import 'package:flutter/material.dart';
import 'banner_m.dart';

import '../../../constants.dart';

class BannerMStyle1 extends StatefulWidget {
  const BannerMStyle1({
    super.key,
    this.images = const ["assets/images/banner_m_default.png"],
    required this.text,
    required this.press,
  });
  final List<String> images;
  final String text;
  final VoidCallback press;

  @override
  State<BannerMStyle1> createState() => _BannerMStyle1State();
}

class _BannerMStyle1State extends State<BannerMStyle1> {
  int _currentImageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BannerM(
      image: widget.images[_currentImageIndex],
      press: widget.press,
      children: [
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    fontFamily: grandisExtendedFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                "Shop now",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                width: 64,
                child: Divider(
                  color: Colors.white,
                  thickness: 2,
                ),
              ),
              const Spacer(),
              if (widget.images.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.images.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(
                          right: index == (widget.images.length - 1)
                              ? 0
                              : defaultPadding / 4),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        child: CircleAvatar(
                          radius: 4,
                          backgroundColor: Colors.white.withOpacity(
                              index == _currentImageIndex ? 1 : 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }
}



