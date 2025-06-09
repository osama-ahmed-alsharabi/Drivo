import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:drivo_app/core/routes/app_routes.dart';
import 'package:drivo_app/core/service/shared_preferences_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  late VideoPlayerController _controller;
  bool _isCheckingUser = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/splash.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.setLooping(false);

    _controller.addListener(() async {
      if (_controller.value.position >= _controller.value.duration &&
          _controller.value.isInitialized) {
        if (mounted && !_isCheckingUser) {
          _isCheckingUser = true;
          await _checkUserAndNavigate();
        }
      }
    });
  }

  Future<void> _checkUserAndNavigate() async {
    try {
      final userType = await SharedPreferencesService.getUserType();

      if (!mounted) return;

      if (userType == null) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.loginRoute);
      } else {
        switch (userType) {
          case "client":
            Navigator.of(context)
                .pushReplacementNamed(AppRoutes.clientHomeRoute);
            break;
          case "provider":
            Navigator.of(context)
                .pushReplacementNamed(AppRoutes.homeProviderViewRoute);
            break;
          case "delivery":
            Navigator.of(context)
                .pushReplacementNamed(AppRoutes.homeDeliveryViewRoute);
            break;
          default:
            Navigator.of(context).pushReplacementNamed(AppRoutes.loginRoute);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.loginRoute);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
