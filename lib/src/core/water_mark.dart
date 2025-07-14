import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class WatermarkAnimation extends StatefulWidget {
  final String watermarkText;
  final String? logoUrl;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final Duration movementInterval;
  final Duration animationDuration;

  const WatermarkAnimation({
    Key? key,
    required this.watermarkText,
    this.logoUrl,
    this.backgroundColor = const Color.fromARGB(255, 47, 89, 151),
    this.textColor = Colors.redAccent,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w500,
    this.movementInterval = const Duration(seconds: 3),
    this.animationDuration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<WatermarkAnimation> createState() => _WatermarkAnimationState();
}

class _WatermarkAnimationState extends State<WatermarkAnimation>
    with TickerProviderStateMixin {
  double top = 0;
  double left = 16;
  Timer? _moveTimer;
  final Random _random = Random();

  late AnimationController _animationController;

  int _currentMovementPattern = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );



    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.repeat(reverse: true);
        _setupRandomWatermarkMovement();
      }
    });
  }

  void _setupRandomWatermarkMovement() {
    _moveTimer?.cancel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        if (screenWidth > 0 && screenHeight > 0) {
          setState(() {
            top = _random.nextDouble() * (screenHeight - 60);
            left = _random.nextDouble() * (screenWidth - 160);
          });
        }
      }
    });

    _moveTimer = Timer.periodic(widget.movementInterval, (_) {
      if (mounted) {
        _moveWatermark();
      }
    });
  }

  void _moveWatermark() {
    if (!mounted) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (screenWidth <= 0 || screenHeight <= 0) return;

    _currentMovementPattern = (_currentMovementPattern + 1) % 4;

    setState(() {
      switch (_currentMovementPattern) {
        case 0: // Random position
          top = _random.nextDouble() * (screenHeight - 60);
          left = _random.nextDouble() * (screenWidth - 160);
          break;
        case 1: // Corner positions
          final corners = [
            [20.0, 20.0], // Top-left
            [screenHeight - 80, 20.0], // Bottom-left
            [20.0, screenWidth - 180], // Top-right
            [screenHeight - 80, screenWidth - 180], // Bottom-right
          ];
          final corner = corners[_random.nextInt(corners.length)];
          top = corner[0];
          left = corner[1];
          break;
        case 2: // Edge positions
          if (_random.nextBool()) {
            top = _random.nextBool() ? 20 : screenHeight - 80;
            left = _random.nextDouble() * (screenWidth - 160);
          } else {
            left = _random.nextBool() ? 20 : screenWidth - 180;
            top = _random.nextDouble() * (screenHeight - 60);
          }
          break;
        case 3: // Center area with offset
          final centerX = screenWidth / 2;
          final centerY = screenHeight / 2;
          final offsetRange = 100.0;
          top = centerY + (_random.nextDouble() - 0.5) * offsetRange;
          left = centerX + (_random.nextDouble() - 0.5) * offsetRange;
          break;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _moveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated watermark text
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return AnimatedPositioned(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              top: top,
              left: left,
              child: IgnorePointer(
                ignoring: true,
                child: Opacity(
                  opacity: 0.4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.backgroundColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 0.4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.watermarkText,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: widget.fontSize,
                        fontWeight: widget.fontWeight,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Logo watermark (if provided)
        if (widget.logoUrl != null)
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: true,
              child: Center(
                child: Opacity(
                  opacity: 0.1,
                  child: Image.network(
                    widget.logoUrl!,
                    height: 80,
                    width: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Alternative movement patterns for different use cases
enum WatermarkMovementPattern {
  random,
  bouncing,
  continuous,
  corners,
  edges,
}

class AdvancedWatermarkAnimation extends StatefulWidget {
  final String watermarkText;
  final String? logoUrl;
  final WatermarkMovementPattern movementPattern;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;

  const AdvancedWatermarkAnimation({
    Key? key,
    required this.watermarkText,
    this.logoUrl,
    this.movementPattern = WatermarkMovementPattern.random,
    this.backgroundColor = const Color.fromARGB(255, 47, 89, 151),
    this.textColor = Colors.redAccent,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w500,
  }) : super(key: key);

  @override
  State<AdvancedWatermarkAnimation> createState() => _AdvancedWatermarkAnimationState();
}

class _AdvancedWatermarkAnimationState extends State<AdvancedWatermarkAnimation>
    with TickerProviderStateMixin {
  double top = 0;
  double left = 16;
  Timer? _moveTimer;
  final Random _random = Random();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // For bouncing movement
  double velocityX = 2.0;
  double velocityY = 1.5;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupMovementPattern();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.2,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.repeat(reverse: true);
  }

  void _setupMovementPattern() {
    _moveTimer?.cancel();

    switch (widget.movementPattern) {
      case WatermarkMovementPattern.random:
        _setupRandomMovement();
        break;
      case WatermarkMovementPattern.bouncing:
        _setupBouncingMovement();
        break;
      case WatermarkMovementPattern.continuous:
        _setupContinuousMovement();
        break;
      case WatermarkMovementPattern.corners:
        _setupCornerMovement();
        break;
      case WatermarkMovementPattern.edges:
        _setupEdgeMovement();
        break;
    }
  }

  void _setupRandomMovement() {
    _moveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        if (screenWidth > 0 && screenHeight > 0) {
          setState(() {
            top = _random.nextDouble() * (screenHeight - 60);
            left = _random.nextDouble() * (screenWidth - 160);
          });
        }
      }
    });
  }

  void _setupBouncingMovement() {
    _moveTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;

      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      if (screenWidth <= 0 || screenHeight <= 0) return;

      setState(() {
        left += velocityX;
        top += velocityY;

        if (left <= 0 || left >= screenWidth - 160) {
          velocityX = -velocityX;
        }
        if (top <= 0 || top >= screenHeight - 60) {
          velocityY = -velocityY;
        }

        left = left.clamp(0.0, screenWidth - 160);
        top = top.clamp(0.0, screenHeight - 60);
      });
    });
  }

  void _setupContinuousMovement() {
    _moveTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;

      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      if (screenWidth <= 0 || screenHeight <= 0) return;

      setState(() {
        final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
        top = (screenHeight / 2) + sin(time * 0.5) * 100;
        left = (screenWidth / 2) + cos(time * 0.3) * 150;
      });
    });
  }

  void _setupCornerMovement() {
    final corners = [
      [20.0, 20.0],
      [20.0, 160.0],
      [80.0, 20.0],
      [80.0, 160.0],
    ];
    int currentCorner = 0;

    _moveTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;

      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      if (screenWidth <= 0 || screenHeight <= 0) return;

      setState(() {
        final adjustedCorners = [
          [20.0, 20.0],
          [screenHeight - 80, 20.0],
          [20.0, screenWidth - 180],
          [screenHeight - 80, screenWidth - 180],
        ];
        final corner = adjustedCorners[currentCorner];
        top = corner[0];
        left = corner[1];
        currentCorner = (currentCorner + 1) % adjustedCorners.length;
      });
    });
  }

  void _setupEdgeMovement() {
    _moveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;

      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      if (screenWidth <= 0 || screenHeight <= 0) return;

      setState(() {
        if (_random.nextBool()) {
          top = _random.nextBool() ? 20 : screenHeight - 80;
          left = _random.nextDouble() * (screenWidth - 160);
        } else {
          left = _random.nextBool() ? 20 : screenWidth - 180;
          top = _random.nextDouble() * (screenHeight - 60);
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _moveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return AnimatedPositioned(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              top: top,
              left: left,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _animationController.value * 0.1,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.backgroundColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 0.4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.watermarkText,
                          style: TextStyle(
                            color: widget.textColor,
                            fontSize: widget.fontSize,
                            fontWeight: widget.fontWeight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.logoUrl != null)
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: true,
              child: Center(
                child: Opacity(
                  opacity: 0.1,
                  child: Image.network(
                    widget.logoUrl!,
                    height: 80,
                    width: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}