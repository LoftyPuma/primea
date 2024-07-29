import 'package:flutter/material.dart';
import 'package:parallel_stats/modal/oauth_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInModal extends StatelessWidget {
  const SignInModal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 450,
      height: 300,
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Center(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      OAuthButton(
                        label: "Sign in with Twitch",
                        icon: "assets/brands/twitch/glitch_flat_purple.png",
                        provider: OAuthProvider.twitch,
                      ),
                      OAuthButton(
                        label: "Sign in with Discord",
                        icon: "assets/brands/discord/blue_mark.png",
                        provider: OAuthProvider.discord,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
