import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

void main() {
  runApp(FlashcardApp());
}

class FlashcardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FlashcardHomePage(),
    );
  }
}

class FlashcardHomePage extends StatefulWidget {
  @override
  _FlashcardHomePageState createState() => _FlashcardHomePageState();
}

class _FlashcardHomePageState extends State<FlashcardHomePage> with SingleTickerProviderStateMixin {
  final List<Deck> _decks = [];
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _deckNameController = TextEditingController();
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _animation = ColorTween(
      begin: Colors.blue.shade300,
      end: Colors.purple.shade300,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addFlashcard(String deckName) {
    if (_questionController.text.isNotEmpty && _answerController.text.isNotEmpty) {
      setState(() {
        final deck = _decks.firstWhere((deck) => deck.name == deckName);
        deck.flashcards.add(Flashcard(
          question: _questionController.text,
          answer: _answerController.text,
        ));
        _questionController.clear();
        _answerController.clear();
      });
    }
  }

  void _createNewDeckAndAddCard() {
    if (_deckNameController.text.isNotEmpty && _questionController.text.isNotEmpty && _answerController.text.isNotEmpty) {
      setState(() {
        final newDeck = Deck(name: _deckNameController.text, flashcards: [
          Flashcard(
            question: _questionController.text,
            answer: _answerController.text,
          )
        ]);
        _decks.add(newDeck);
        _deckNameController.clear();
        _questionController.clear();
        _answerController.clear();
      });
    }
  }

  void _showAddFlashcardDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _questionController,
                decoration: InputDecoration(labelText: 'Question'),
              ),
              TextField(
                controller: _answerController,
                decoration: InputDecoration(labelText: 'Answer'),
              ),
              DropdownButtonFormField<String>(
                items: _decks.map((deck) {
                  return DropdownMenuItem<String>(
                    value: deck.name,
                    child: Text(deck.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _addFlashcard(value);
                    Navigator.of(context).pop();
                  }
                },
                decoration: InputDecoration(labelText: 'Select Deck'),
                dropdownColor: Colors.white,
                isExpanded: true,
              ),
              TextButton(
                onPressed: () {
                  _showCreateDeckDialog();
                },
                child: Text('Create New Deck'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateDeckDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create New Deck'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _deckNameController,
                decoration: InputDecoration(labelText: 'Deck Name'),
              ),
              TextButton(
                onPressed: () {
                  _createNewDeckAndAddCard();
                  Navigator.of(context).pop();
                },
                child: Text('Create and Add Card'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openDeck(Deck deck) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeckPage(deck: deck)),
    );
  }

  void _renameDeck(Deck deck) {
    final TextEditingController renameController = TextEditingController(text: deck.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rename Deck'),
          content: TextField(
            controller: renameController,
            decoration: InputDecoration(labelText: 'New Deck Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  deck.name = renameController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteDeck(Deck deck) {
    setState(() {
      _decks.remove(deck);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcard App'),
      ),
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_animation.value!, Colors.red.shade300, Colors.pink.shade300, Colors.green.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: _decks.isEmpty
                ? Center(
                    child: Text(
                      'Create a new deck',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: _decks.length,
                    itemBuilder: (context, index) {
                      final deck = _decks[index];
                      return GestureDetector(
                        onTap: () => _openDeck(deck),
                        child: Card(
                          color: Colors.white.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(deck.name, style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text('${deck.flashcards.length} cards'),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'Rename deck') {
                                      _renameDeck(deck);
                                    } else if (value == 'Delete deck') {
                                      _deleteDeck(deck);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'Rename deck',
                                      child: Text('Rename deck'),
                                    ),
                                    PopupMenuItem(
                                      value: 'Delete deck',
                                      child: Text('Delete deck'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFlashcardDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }
}

class DeckPage extends StatefulWidget {
  final Deck deck;

  DeckPage({required this.deck});

  @override
  _DeckPageState createState() => _DeckPageState();
}

class _DeckPageState extends State<DeckPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _animation = ColorTween(
      begin: Colors.blue.shade300,
      end: Colors.purple.shade300,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddFlashcardDialog(BuildContext context, Deck deck) {
    final TextEditingController questionController = TextEditingController();
    final TextEditingController answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
                    title: Text('Add Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: InputDecoration(labelText: 'Question'),
              ),
              TextField(
                controller: answerController,
                decoration: InputDecoration(labelText: 'Answer'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (questionController.text.isNotEmpty && answerController.text.isNotEmpty) {
                  setState(() {
                    deck.flashcards.add(Flashcard(
                      question: questionController.text,
                      answer: answerController.text,
                    ));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _renameFlashcard(Flashcard flashcard) {
    final TextEditingController renameQuestionController = TextEditingController(text: flashcard.question);
    final TextEditingController renameAnswerController = TextEditingController(text: flashcard.answer);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rename Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: renameQuestionController,
                decoration: InputDecoration(labelText: 'New Question'),
              ),
              TextField(
                controller: renameAnswerController,
                decoration: InputDecoration(labelText: 'New Answer'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  flashcard.question = renameQuestionController.text;
                  flashcard.answer = renameAnswerController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFlashcard(Flashcard flashcard) {
    setState(() {
      widget.deck.flashcards.remove(flashcard);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck.name),
      ),
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_animation.value!, Colors.red.shade300, Colors.pink.shade300, Colors.green.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: widget.deck.flashcards.length,
                  itemBuilder: (context, index) {
                    final flashcard = widget.deck.flashcards[index];
                    return Stack(
                      children: [
                        FlipCard(
                          direction: FlipDirection.HORIZONTAL,
                          front: Card(
                            color: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Center(
                              child: Text(flashcard.question),
                            ),
                          ),
                          back: Card(
                            color: Colors.green.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Center(
                              child: Text(flashcard.answer),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'change card') {
                                _renameFlashcard(flashcard);
                              } else if (value == 'Delete card') {
                                _deleteFlashcard(flashcard);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'change card',
                                child: Text('change card'),
                              ),
                              PopupMenuItem(
                                value: 'Delete card',
                                child: Text('Delete card'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () => _showAddFlashcardDialog(context, widget.deck),
                    child: Icon(Icons.add),
                    backgroundColor: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Deck {
  String name;
  final List<Flashcard> flashcards;

  Deck({required this.name, required this.flashcards});
}

class Flashcard {
  String question;
  String answer;

  Flashcard({required this.question, required this.answer});
}
