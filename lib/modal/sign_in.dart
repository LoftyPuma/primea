import 'package:flutter/material.dart';
import 'package:parallel_stats/main.dart';
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          await supabase.auth.signInWithOAuth(
                            OAuthProvider.twitch,
                          );
                        },
                        icon: Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                              top: 8,
                              bottom: 8,
                            ),
                            child: Image.asset(
                              'assets/brands/twitch/glitch_flat_purple.png',
                              width: 24,
                            )),
                        label: const Text('Sign in with Twitch'),
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
