part of flutter_firebase_framework;

const loginGitHub = "loginGitHub";
const loginGoogle = "loginGoogle";
const loginSSO = "loginSSO";
const loginEmail = "loginEmail";
const loginAnonymous = "loginAnonymous";
const signupOption = "signupOption";

enum LoginOption {
  GitHub,
  Google,
  Facebook,
  SSO,
  Email,
  Anonymous,
  signupOption,
}

const borderColor = Color.fromARGB(255, 208, 208, 208);
const borderDecor = BoxDecoration(
  border: Border(
    right: BorderSide(
      color: borderColor,
    ),
  ),
);

final userLoggedIn = StateNotifierProvider<AuthStateNotifier<bool>, bool>(
    (ref) => AuthStateNotifier<bool>(false));

final showLoading = StateNotifierProvider<AuthStateNotifier<bool>, bool>(
    (ref) => AuthStateNotifier<bool>(false));

/// LoginButtonsWidget is a widget that displays the login buttons.
/// Each button is a [ElevatedButton] that calls the appropriate login function.
/// The login functions are defined in the [LoginConfig] class.
///
/// Example:
/// LoginButtonsWidget(
///  screenTitle: 'Login',
/// onLoginAnonymousButtonPressed: () {
///  print('Login Anonymously');
/// },
///
class LoginButtonsWidget extends ConsumerWidget {
  final String screenTitle;
  final double buttonWidth;

  /// This is the function that is called when the Anonymous Login button is pressed.
  /// It is defined in the [LoginConfig] class.
  /// Use it for a follow-up action when the user has logged in anonymously.
  final Function? onLoginAnonymousButtonPressed;

  ///Login Options are set in LoginConfig
  const LoginButtonsWidget({
    required this.screenTitle,
    this.onLoginAnonymousButtonPressed,
    this.buttonWidth = 150,
    Key? key,
  }) : super(key: key);

  Future signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider
        .addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // if (kIsWeb) {
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
    // } else {
    //   // Or use signInWithRedirect
    //   await FirebaseAuth.instance.signInWithRedirect(googleProvider);
    // }
  }

  Widget imageButton(String title, String imageName, VoidCallback callback) {
    return SizedBox(
        width: buttonWidth,
        child: ElevatedButton(
            onPressed: callback,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: borderDecor,
                  margin: const EdgeInsets.only(right: 70),
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    child: SvgPicture.asset('/assets/$imageName.svg',
                        package: 'auth', width: 30, height: 30),
                  ),
                ),
                SizedBox(width: 180, child: Text(title)),
              ],
            )));
  }

  Widget iconButton(String title, IconData iconData, VoidCallback callback) {
    return SizedBox(
        width: buttonWidth,
        child: ElevatedButton(
          onPressed: callback,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
                height: 50,
                width: 50,
                decoration: borderDecor,
                margin: const EdgeInsets.only(right: 70),
                child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    child: Icon(
                      iconData,
                      size: 30,
                      color: Colors.black,
                    ))),
            SizedBox(width: 180, child: Text(title))
          ]),
        ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(showLoading)) {
      return Center(
        child: Container(
          alignment: const Alignment(0.0, 0.0),
          child: const CircularProgressIndicator(),
        ),
      );
    }
    List<String> configFlags = [];

    bool isWideScreen = MediaQuery.of(context).size.width >= 800;

    final Widget googleButton =
        imageButton("Log in with Google", "google_logo", () {
      signInWithGoogle().whenComplete(() {
        ref.read(userLoggedIn.notifier).value = true;
      });
    });

    final Widget githubButton =
        imageButton("Log in with Github", "github_logo", () async {
      ref.read(showLoading.notifier).value = true;
      await FirebaseAuth.instance.signInAnonymously().then((a) => {
            ref.read(userLoggedIn.notifier).value = true,
            ref.read(showLoading.notifier).value = false,
          });
    });

    final Widget ssoButton = iconButton("Log in with SSO", Icons.key, () {});

    final Widget emailButton =
        iconButton("Log in with Email", Icons.mail, () {});

    final Widget anonymousButton =
        iconButton("Log in Anonymous", Icons.account_circle, () async {
      FirebaseAuth.instance.signInAnonymously().then((a) => {
            if (onLoginAnonymousButtonPressed != null)
              onLoginAnonymousButtonPressed!()
          });
    });

    return ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: 400, maxHeight: 400, minHeight: 400, minWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                screenTitle,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Visibility(
              visible: AuthConfig.enableGoogleAuth,
              child: Column(
                children: [
                  const Gap(25),
                  SizedBox(width: double.infinity, child: googleButton),
                ],
              ),
            ),
            Visibility(
              visible: AuthConfig.enableGithubAuth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Gap(50),
                  SizedBox(width: double.infinity, child: githubButton),
                ],
              ),
            ),
            Visibility(
                visible: AuthConfig.enableSsoAuth,
                child: Column(
                  children: [
                    const Gap(50),
                    SizedBox(width: double.infinity, child: ssoButton),
                  ],
                )),
            Visibility(
              visible: AuthConfig.enableEmailAuth,
              child: Column(
                children: [
                  const Gap(50),
                  SizedBox(width: double.infinity, child: emailButton)
                ],
              ),
            ),
            Visibility(
              visible: AuthConfig.enableAnonymousAuth,
              child: Column(
                children: [
                  const Gap(50),
                  SizedBox(width: double.infinity, child: anonymousButton),
                ],
              ),
            ),
            Divider(),
            Visibility(
              visible: AuthConfig.enableSignupOption,
              child: Column(
                children: [
                  const Gap(50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Don't have an account ? ",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                      InkWell(
                        //onTap: () => {print("Clicked")},
                        child: Text(
                          " Sign up",
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 18, color: Colors.blueGrey),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const Gap(50),
          ],
        ));

    // return isWideScreen
    //     ? Flex(direction: Axis.horizontal, children: widgets)
    //     : SingleChildScrollView(
    //         child: Flex(
    //             direction: Axis.vertical, children: widgets.reversed.toList()));
  }
}
