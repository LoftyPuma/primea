import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:primea/main.dart';
import 'package:primea/modal/oauth_button.dart';
import 'package:primea/util/analytics.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInModal extends StatefulWidget {
  static final _emailRegex = RegExp(
    r'^[\w\.\/\\!+!%-]+@\w+(\.\w+)+$',
    caseSensitive: false,
  );
  static final _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).*$',
    caseSensitive: true,
  );

  const SignInModal({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SignInModalState();
}

class SignInModalState extends State<SignInModal> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool obscurePassword = true;
  bool _isSigningIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildForm(BuildContext context) => Form(
        key: _formKey,
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
            Padding(
              padding: const EdgeInsets.only(
                left: 32,
                right: 32,
                top: 8,
              ),
              child: TextFormField(
                controller: _emailController,
                autofillHints: const [AutofillHints.email],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your email';
                  } else if (!SignInModal._emailRegex.hasMatch(value)) {
                    return "Enter a valid email";
                  } else {
                    return null;
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 32,
                right: 32,
                top: 8,
                bottom: 8,
              ),
              child: TextFormField(
                controller: _passwordController,
                obscureText: obscurePassword,
                autofillHints: const [AutofillHints.password],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  } else if (!SignInModal._passwordRegex.hasMatch(value)) {
                    return 'Password must contain a lowercase letter, an uppercase letter, and a number';
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorMaxLines: 3,
                  suffixIcon: obscurePassword
                      ? IconButton(
                          icon: const Icon(Icons.visibility_off_rounded),
                          onPressed: () => setState(() {
                            obscurePassword = !obscurePassword;
                          }),
                        )
                      : IconButton(
                          icon: const Icon(Icons.visibility_rounded),
                          onPressed: () => setState(() {
                            obscurePassword = !obscurePassword;
                          }),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 32,
                right: 32,
                top: 16,
                bottom: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.email_rounded),
                    label: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontVariations: [FontVariation('wght', 600)],
                      ),
                    ),
                    onPressed: () async {
                      if (!(_formKey.currentState?.validate() ?? false)) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error'),
                            content: const Text(
                                'Please enter a valid email and password to sign up'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      try {
                        setState(() {
                          _isSigningIn = true;
                        });
                        await supabase.auth.signUp(
                          password: _passwordController.text,
                          email: _emailController.text,
                          emailRedirectTo: kIsWeb ? null : "world.primea://",
                        );
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                'Successfully Created an Account!',
                              ),
                              content: const Text(
                                "Check your email for a verification link to sign in.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      } on AuthException catch (e) {
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Error'),
                              content: Text(e.message),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      } finally {
                        setState(() {
                          _isSigningIn = false;
                        });
                      }
                    },
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.email_rounded),
                    label: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontVariations: [FontVariation('wght', 600)],
                      ),
                    ),
                    onPressed: () async {
                      if (!(_formKey.currentState?.validate() ?? false)) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error'),
                            content: const Text(
                                'Please enter a valid email and password to sign up'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      try {
                        setState(() {
                          _isSigningIn = true;
                        });
                        await supabase.auth.signInWithPassword(
                          password: _passwordController.text,
                          email: _emailController.text,
                        );
                        Analytics.instance.trackEvent("signIn", {
                          "provider": "email",
                        });
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      } on AuthException catch (e) {
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Error'),
                              content: Text(e.message),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      } finally {
                        setState(() {
                          _isSigningIn = false;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 450,
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _isSigningIn
                    ? const SizedBox.square(
                        dimension: 120,
                        child: CircularProgressIndicator(),
                      )
                    : _buildForm(context),
              ),
              const Divider(
                indent: 8,
                endIndent: 8,
                thickness: 2,
              ),
              const Padding(
                padding: EdgeInsets.only(
                  top: 16,
                  bottom: 16,
                ),
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
