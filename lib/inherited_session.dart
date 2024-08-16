import 'package:flutter/material.dart';
import 'package:primea/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InheritedSession extends InheritedModel<String> {
  final Session? session;

  const InheritedSession({
    super.key,
    required super.child,
    required this.session,
  });

  static InheritedSession? maybeOf(BuildContext context, [String? aspect]) {
    return InheritedModel.inheritFrom<InheritedSession>(
      context,
      aspect: aspect,
    );
  }

  static InheritedSession of(BuildContext context, [String? aspect]) {
    final session = maybeOf(context, aspect);
    assert(session != null, 'No InheritedSession found in context');
    return session!;
  }

  @override
  bool updateShouldNotify(InheritedSession oldWidget) {
    return oldWidget.session != session;
  }

  @override
  bool updateShouldNotifyDependent(
    InheritedSession oldWidget,
    Set<String> dependencies,
  ) {
    return oldWidget.session != session;
  }
}

class InheritedSessionWidget extends StatefulWidget {
  final Widget child;

  const InheritedSessionWidget({
    super.key,
    required this.child,
  });

  @override
  State<InheritedSessionWidget> createState() => _InheritedSessionState();
}

class _InheritedSessionState extends State<InheritedSessionWidget> {
  Session? session = supabase.auth.currentSession;

  handleAuthStateChange(AuthState data) async {
    setState(() {
      session = data.session;
    });
  }

  @override
  void initState() {
    supabase.auth.onAuthStateChange.listen(handleAuthStateChange);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedSession(
      session: session,
      child: widget.child,
    );
  }
}
