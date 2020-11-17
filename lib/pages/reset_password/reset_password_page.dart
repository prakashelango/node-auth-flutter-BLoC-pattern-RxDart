import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_disposebag/flutter_disposebag.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:node_auth/domain/usecases/reset_password_use_case.dart';
import 'package:node_auth/domain/usecases/send_reset_password_email_use_case.dart';
import 'package:node_auth/pages/reset_password/input_token/input_token_and_reset_password.dart';
import 'package:node_auth/pages/reset_password/send_email/send_email.dart';
import 'package:rxdart/rxdart.dart';

class ResetPasswordPage extends StatefulWidget {
  static const routeName = '/reset_password_page';

  const ResetPasswordPage({Key key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with SingleTickerProviderStateMixin<ResetPasswordPage>, DisposeBagMixin {
  final requestEmailS = StreamController<void>(sync: true);

  AnimationController animationController;
  Animation<Offset> animationPosition;
  Animation<double> animationScale;
  Animation<double> animationOpacity;
  Animation<double> animationTurns;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    animationPosition = Tween(
      begin: Offset(2.0, 0),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
    );
    animationScale = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    animationOpacity = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    animationTurns = Tween<double>(
      begin: 0.5,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
    );

    /// Stream of bool values.
    /// Emits true if current page is request email page.
    /// Otherwise, it is reset password page.
    requestEmailS.stream
        .scan((acc, e, _) => !acc, true)
        .listen((requestEmailPage) => requestEmailPage
            ? animationController.reverse()
            : animationController.forward())
        .disposedBy(bag);
    requestEmailS.disposedBy(bag);
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  void onToggle() => requestEmailS.add(null);

  @override
  Widget build(BuildContext context) {
    final sendResetPasswordEmail =
        Provider.of<SendResetPasswordEmailUseCase>(context);
    final resetPassword = Provider.of<ResetPasswordUseCase>(context);

    final sendEmailPage = BlocProvider<SendEmailBloc>(
      initBloc: () => SendEmailBloc(sendResetPasswordEmail),
      child: SendEmailPage(toggle: onToggle),
    );

    final resetPasswordPage = BlocProvider<InputTokenAndResetPasswordBloc>(
      initBloc: () => InputTokenAndResetPasswordBloc(resetPassword),
      child: InputTokenAndResetPasswordPage(toggle: onToggle),
    );

    return Stack(
      children: <Widget>[
        Positioned.fill(child: sendEmailPage),
        Positioned.fill(
          child: RotationTransition(
            child: SlideTransition(
              position: animationPosition,
              child: ScaleTransition(
                scale: animationScale,
                child: FadeTransition(
                  opacity: animationOpacity,
                  child: resetPasswordPage,
                ),
              ),
            ),
            turns: animationTurns,
          ),
        )
      ],
    );
  }
}
