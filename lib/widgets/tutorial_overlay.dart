import 'package:flutter/material.dart';

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const TutorialOverlay({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialStep> _steps = [
    TutorialStep(
      title: 'Match Blocks',
      description: 'Connect 3 or more blocks of the same color that are adjacent to each other. The more blocks you match, the higher your score multiplier!',
      icon: Icons.grid_view_rounded,
    ),
    TutorialStep(
      title: 'Mega Star Blocks',
      description: 'Look out for special blocks with a star icon! When matched, they will destroy all blocks of the same color on the board for massive points!',
      icon: Icons.stars_rounded,
    ),
    TutorialStep(
      title: 'Level Goals',
      description: 'Each level has a target score. Match blocks strategically to reach the target and advance to the next level.',
      icon: Icons.emoji_events_rounded,
    ),
    TutorialStep(
      title: 'Game Over',
      description: 'The game ends when no more matches are possible. Use mega stars wisely to clear the board and keep playing!',
      icon: Icons.warning_amber_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color.fromARGB(180, 255, 255, 255),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'How to Play',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Montserrat',
                      color: Color(0xFF185A9D),
                      letterSpacing: 2,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF185A9D),
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Tutorial content
              Flexible(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 300,
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemCount: _steps.length,
                            itemBuilder: (context, index) {
                              final step = _steps[index];
                              return SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF43CEA2).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          step.icon,
                                          size: 60,
                                          color: const Color(0xFF43CEA2),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        step.title,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'Montserrat',
                                          color: Color(0xFF185A9D),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        step.description,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Montserrat',
                                          height: 1.5,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? const Color(0xFF43CEA2)
                          : Colors.grey[300],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              // Navigation buttons
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  children: [
                    if (_currentPage > 0)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: OutlinedButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF185A9D),
                            side: const BorderSide(color: Color(0xFF185A9D)),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Previous',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage < _steps.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            widget.onClose();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF43CEA2),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage < _steps.length - 1 ? 'Next' : 'Start',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentPage < _steps.length - 1
                                  ? Icons.arrow_forward_rounded
                                  : Icons.play_arrow_rounded,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;

  TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
  });
} 