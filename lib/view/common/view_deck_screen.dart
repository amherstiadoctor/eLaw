import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/flashcard_deck.dart';
import 'package:sp_code/utils/widgets/flip_card.dart';
import 'package:sp_code/utils/widgets/header.dart';

class ViewDeckScreen extends StatefulWidget {
  final FlashcardDeck deck;
  const ViewDeckScreen({super.key, required this.deck});

  @override
  State<ViewDeckScreen> createState() => _ViewDeckScreenState();
}

class _ViewDeckScreenState extends State<ViewDeckScreen> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  var _currentCarouselPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryTint,
      body: Column(
        children: [
          Header(
            title: widget.deck.title,
            hasBackButton: true,
            color: AppTheme.white,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: CarouselSlider(
              carouselController: _carouselController,
              items:
                  widget.deck.cards.map<Widget>((i) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      child: FlipCard(isView: true, cardInfo: i),
                    );
                  }).toList(),
              options: CarouselOptions(
                viewportFraction: 1,
                padEnds: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentCarouselPage = index;
                  });
                },
                height: 500,
                enableInfiniteScroll: false,
              ),
            ),
          ),
          SizedBox(height: 10),
          Visibility(
            visible: widget.deck.cards.isNotEmpty,
            child: Center(
              child: Text(
                "${_currentCarouselPage + 1}/${widget.deck.cards.length}",
                style: TextStyle(fontSize: 24, color: AppTheme.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
