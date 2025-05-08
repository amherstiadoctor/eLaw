import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sp_code/model/flashcard_deck.dart';

class ViewDeckScreen extends StatefulWidget {
  final String deckId;
  const ViewDeckScreen({super.key, required this.deckId});

  @override
  State<ViewDeckScreen> createState() => _ViewDeckScreenState();
}

class _ViewDeckScreenState extends State<ViewDeckScreen> {
  late FlashcardDeck currentDeck;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: StreamBuilder(
      //   stream:
      //       FirebaseFirestore.instance
      //           .collection('decks')
      //           .where("id", isEqualTo: widget.deckId)
      //           .snapshots(),
      //   builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      //     final fetchedDocs = snapshot.data?.docs;
      //     final currentDeck = fetchedDocs?[0].data() as Map<String, dynamic>;
      //     return Text(currentDeck['title']);
      //   },
      // ),
    );
  }
}
