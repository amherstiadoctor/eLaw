import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sp_code/utils/widgets/flip_card.dart';
import 'package:sp_code/utils/widgets/header.dart';

class ViewDeckScreen extends StatefulWidget {
  final String deckId;
  const ViewDeckScreen({super.key, required this.deckId});

  @override
  State<ViewDeckScreen> createState() => _ViewDeckScreenState();
}

class _ViewDeckScreenState extends State<ViewDeckScreen> {
  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final CarouselSliderController _carouselController =
        CarouselSliderController();
    var _currentCarouselPage = 1;

    return Scaffold(
      body: StreamBuilder(
        stream: _firestore.collection("decks").doc(widget.deckId).snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final currentDeck = snapshot.data as DocumentSnapshot;
          if (!currentDeck.exists) {
            return Center(child: Text("No deck found."));
          }
          return Column(
            children: [
              Header(title: currentDeck['title'], hasBackButton: true),
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: CarouselSlider(
                  carouselController: _carouselController,
                  items:
                      currentDeck['cards'].map<Widget>((i) {
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
              SizedBox(height: 5),
              Visibility(
                visible: currentDeck['cards'].isNotEmpty,
                child: Center(
                  child: Text(
                    "$_currentCarouselPage/${currentDeck['cards'].length}",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
