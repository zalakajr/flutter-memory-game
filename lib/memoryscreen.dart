import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({Key? key}) : super(key: key);

  @override
  _MemoryGamePageState createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> with SingleTickerProviderStateMixin {
  late List<_CardModel> _cards;
  int? _firstFlippedIndex;
  bool _awaitingFlipBack = false;
  int _moves = 0;
  int _score = 0;
  late AnimationController _animationController;
  final List<String> _emojis = ['🐶', '🐱', '🦊', '🐸', '🐵', '🦁', '🐯', '🐮'];
  bool _gameWon = false;
  bool _initialReveal = false;
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Cards will be initialized when the user clicks Play
  }

  void _initializeCards() {
    // Create a list of emoji pairs and shuffle them
    List<String> emojiPairs = [];
    emojiPairs.addAll(_emojis);
    emojiPairs.addAll(_emojis);
    emojiPairs.shuffle();

    // Create card models
    _cards = emojiPairs.asMap().entries.map((entry) {
      return _CardModel(
        id: entry.key,
        content: entry.value,
        isFlipped: false,
        isMatched: false,
      );
    }).toList();
    
    // Reset game state
    _score = 0;
    _moves = 0;
    _gameWon = false;
    _awaitingFlipBack = false;
    _initialReveal = false;
    _firstFlippedIndex = null;
    
    // Update the UI
    if (mounted) {
      setState(() {});
    }
  }

  void _onCardTap(int index) async {
    if (_awaitingFlipBack || _cards[index].isMatched || _cards[index].isFlipped) {
      return;
    }

    final tappedCard = _cards[index];
    // Remove animation that was causing the shrink effect
    tappedCard.controller.toggleCard();
    tappedCard.isFlipped = true;

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
    } else {
      final firstCard = _cards[_firstFlippedIndex!];

      if (firstCard.content == tappedCard.content) {
        setState(() {
          firstCard.isMatched = true;
          tappedCard.isMatched = true;
          _score += 10;
        });
      } else {
        _awaitingFlipBack = true;
        await Future.delayed(const Duration(milliseconds: 800));
        firstCard.controller.toggleCard();
        tappedCard.controller.toggleCard();
        firstCard.isFlipped = false;
        tappedCard.isFlipped = false;
        _awaitingFlipBack = false;
        _score = _score > 0 ? _score - 1 : 0;
      }

      _firstFlippedIndex = null;
      setState(() => _moves++);
    }

    // Check if all cards are matched
    if (_cards.every((card) => card.isMatched)) {
      _showWinDialog();
    }
  }

  Future<void> _showWinDialog() async {
    setState(() => _gameWon = true);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations! 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You won in $_moves moves!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                'Score: $_score',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeCards();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startGame() async {
    // Reset any previous game state
    _firstFlippedIndex = null;
    _awaitingFlipBack = false;
    _score = 0;
    _moves = 0;
    _gameWon = false;
    
    // Initialize cards for new game
    _initializeCards();
    
    // Set game as started
    if (mounted) {
      setState(() {
        _gameStarted = true;
        _initialReveal = true;
      });
    }
    
    // Wait for the UI to update
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Show all cards for memorization
    for (var i = 0; i < _cards.length; i++) {
      if (!mounted) return;
      
      setState(() {
        _cards[i].controller.toggleCard();
        _cards[i].isFlipped = true;
      });
      
      // Small delay between each card flip for a nice effect
      if (i < _cards.length - 1) {
        await Future.delayed(const Duration(milliseconds: 30));
      }
    }
    
    // Wait for 3 seconds to let the user see the cards
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Flip all cards back
    for (var i = _cards.length - 1; i >= 0; i--) {
      if (!mounted) return;
      
      setState(() {
        _cards[i].controller.toggleCard();
        _cards[i].isFlipped = false;
      });
      
      // Small delay between each card flip for a nice effect
      if (i > 0) {
        await Future.delayed(const Duration(milliseconds: 20));
      }
    }
    
    if (mounted) {
      setState(() {
        _initialReveal = false;
      });
    }
  }

  Widget _buildStartScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F5F5), Color(0xFFE1F5FE)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Memory Game',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6200EE),
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Match the pairs to win!',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6200EE),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFF6200EE).withOpacity(0.5),
                ),
                child: const Text(
                  'PLAY NOW',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Can you beat the game with the fewest moves?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black45,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _gameStarted ? AppBar(
        title: const Text('Memory Game'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6200EE),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _gameStarted = false;
                _initializeCards();
              });
            },
            tooltip: 'Restart Game',
          ),
        ],
      ) : null,
      body: _gameStarted ? Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            color: const Color(0xFF6200EE),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreCard('Score', '$_score', Icons.star),
                _buildScoreCard('Moves', '$_moves', Icons.directions_run),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return GestureDetector(
                    onTap: _initialReveal ? null : () => _onCardTap(index),
                    child: FlipCard(
                      controller: card.controller,
                      flipOnTouch: false,
                      front: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF6200EE),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.help_outline, color: Colors.white, size: 32),
                      ),
                      back: Container(
                        decoration: BoxDecoration(
                          color: card.isMatched ? Colors.green[100] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: card.isMatched
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.check_circle, color: Colors.green, size: 40),
                                )
                              : Center(
                                  child: Text(
                                    card.content,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ) : _buildStartScreen(),
      floatingActionButton: _gameStarted ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _gameStarted = false;
            _initializeCards();
          });
        },
        backgroundColor: const Color(0xFF6200EE),
        child: const Icon(Icons.home, color: Colors.white),
      ) : null,
    );
  }

  Widget _buildScoreCard(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _CardModel {
  final int id;
  final String content;
  bool isFlipped;
  bool isMatched;
  final FlipCardController controller;

  _CardModel({
    required this.id,
    required this.content,
    this.isFlipped = false,
    this.isMatched = false,
    FlipCardController? controller,
  }) : controller = controller ?? FlipCardController();
}
