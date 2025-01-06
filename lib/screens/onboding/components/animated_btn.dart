import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class AnimatedBtn extends StatefulWidget {
  const AnimatedBtn({
    super.key,
    required RiveAnimationController btnAnimationController,
    required this.press,
  }) : _btnAnimationController = btnAnimationController;

  final RiveAnimationController _btnAnimationController;
  final VoidCallback press;

  @override
  // ignore: library_private_types_in_public_api
  _AnimatedBtnState createState() => _AnimatedBtnState();
}

class _AnimatedBtnState extends State<AnimatedBtn> {
  bool _isButtonDisabled = false;

  void _handleTap() {
    if (_isButtonDisabled) return;

    setState(() {
      _isButtonDisabled = true;
    });

    widget.press();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isButtonDisabled = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: SizedBox(
        height: 64,
        width: 236,
        child: Stack(
          children: [
            RiveAnimation.asset(
              "assets/RiveAssets/button.riv",
              controllers: [widget._btnAnimationController],
            ),
            Positioned.fill(
              top: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.arrow_right),
                  const SizedBox(width: 6),
                  Text(
                    "LOG IN",
                    style: Theme.of(context).textTheme.labelLarge,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
