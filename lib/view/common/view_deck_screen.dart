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
  String help = "";
  // late FlashcardDeck currentDeck = FlAS;

  Future<void> _fetchDeck() async {
    DocumentReference doc_ref = FirebaseFirestore.instance
        .collection('decks')
        .doc(widget.deckId);

    DocumentSnapshot docSnap = await doc_ref.get();
    var currentDoc = docSnap.data();

    print(currentDoc);

    setState(() {
      // help = currentDoc!['cards'][0]['frontInfo'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchDeck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
