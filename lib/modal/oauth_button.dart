import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:parallel_stats/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OAuthButton extends StatelessWidget {
  final String label;
  final String icon;

  const OAuthButton({
    super.key,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        await supabase.auth.signInWithOAuth(
          OAuthProvider.twitch,
          authScreenLaunchMode: LaunchMode.inAppWebView,
          redirectTo: kIsWeb ? null : "io.github.loftypuma://auth/callback",
        );
      },
      icon: Padding(
        padding: const EdgeInsets.only(
          left: 8,
          top: 8,
          bottom: 8,
        ),
        child: Image.asset(
          icon,
          width: 24,
          height: 24,
        ),
      ),
      label: Text(label),
    );
  }
}
