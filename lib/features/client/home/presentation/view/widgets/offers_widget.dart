import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:drivo_app/features/service_provider/add_offer/data/model/offer_model.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OffersWidget extends StatefulWidget {
  final List<OfferModel>? offerModel;
  final String? errorMessage;
  const OffersWidget({super.key, this.offerModel, this.errorMessage});

  @override
  State<OffersWidget> createState() => _OffersWidgetState();
}

class _OffersWidgetState extends State<OffersWidget> {
  int _currentCarouselIndex = 0;

  final List<Map<String, dynamic>> _offers = [
    {
      'color': Colors.red,
      'icon': Icons.discount,
      'title': "لايوجد عروض بعد",
      'subtitle': ""
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.offerModel?.length ?? _offers.length,
          options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            autoPlayInterval: const Duration(seconds: 5),
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            return widget.offerModel?.isEmpty ?? true
                ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: _offers[index]['color'],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            _offers[index]['icon'],
                            size: 50,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _offers[index]['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _offers[index]['subtitle'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: widget.offerModel![index].imageUrl,
                        fit: BoxFit.fill,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                                Theme.of(context).primaryColor),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  );
          },
        ),
        const SizedBox(height: 10),
        AnimatedSmoothIndicator(
          activeIndex: _currentCarouselIndex,
          count: widget.offerModel?.length ?? _offers.length,
          effect: WormEffect(
            activeDotColor: Theme.of(context).primaryColor,
            dotHeight: 8,
            dotWidth: 8,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
