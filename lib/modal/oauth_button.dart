import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:parallel_stats/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OAuthButton extends StatelessWidget {
  final String label;
  final String icon;
  final OAuthProvider provider;

  const OAuthButton({
    super.key,
    required this.label,
    required this.icon,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        supabase.auth.signInWithOAuth(
          provider,
          authScreenLaunchMode: LaunchMode.inAppWebView,
          redirectTo: kIsWeb ? null : "world.primea://auth/callback",
        );
        Navigator.of(context).pop();
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
