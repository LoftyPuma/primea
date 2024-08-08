import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:parallel_stats/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OAuthProviderData {
  final String label;
  final String icon;

  const OAuthProviderData({
    required this.label,
    required this.icon,
  });
}

class OAuthButton extends StatelessWidget {
  final String label;
  final String icon;
  final OAuthProvider provider;

  static const Map<OAuthProvider, OAuthProviderData> providers = {
    OAuthProvider.discord: OAuthProviderData(
      label: "Discord",
      icon: "assets/brands/discord/blue_mark.png",
    ),
    OAuthProvider.twitch: OAuthProviderData(
      label: "Twitch",
      icon: "assets/brands/twitch/glitch_flat_purple.png",
    ),
  };

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
        await supabase.auth.signInWithOAuth(
          provider,
          redirectTo:
              kIsWeb ? "/auth/callback" : "world.primea://auth/callback",
        );
        if (context.mounted) {
          Navigator.of(context).pop();
        }
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
