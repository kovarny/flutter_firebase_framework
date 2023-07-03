part of flutter_firebase_framework;

const loginGitHub = "loginGitHub";
const loginGoogle = "loginGoogle";
const loginlinkedin = "loginlinkedin";
const loginSSO = "loginSSO";
const loginEmail = "loginEmail";
const loginAnonymous = "loginAnonymous";
const loginFacebook = "loginFacebook";
const loginTwiter = "loginTwitter";
const signupOption = "signupOption";

enum LoginOption {
  GitHub,
  Google,
  Facebook,
  SSO,
  Email,
  Anonymous,
  signupOption,
  Twiter,
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
///
///
///
///

Future<void> initializeFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print('Firebase initialized successfully');
}

class LoginButtonsWidget extends ConsumerWidget {
  final String screenTitle;

  /// This is the function that is called when the Anonymous Login button is pressed.
  /// It is defined in the [LoginConfig] class.
  /// Use it for a follow-up action when the user has logged in anonymously.
  final Function? onLoginAnonymousButtonPressed;

  ///Login Options are set in LoginConfig
  const LoginButtonsWidget({
    required this.screenTitle,
    this.onLoginAnonymousButtonPressed,
    Key? key,
  }) : super(key: key);

  // OAuth 2.0 credentials Linkedin API

  final String client_id = '86huxyar2l3rkb';
  final String redirect_uri = 'https://dev.jobsearch.ninja/auth.html';
  //final String redirect_uri = 'http://localhost:58443/auth.html';

  void checkUserLoggedIn(WidgetRef ref) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // User autenticaticated
      print(
          'checkUserLoggedIn - Authtenticated user (current User): ${currentUser.uid}');

      print(
          'checkUserLoggedIn Current - userLoggedInState: ${ref.read(userLoggedIn.notifier).value}');
      ref.read(userLoggedIn.notifier).value = true;
      print(
          'checkUserLoggedIn - After current state change to true - userLoggedInState: ${ref.read(userLoggedIn.notifier).value}');
    } else {
      // the user is not authenticated
      print('checkUserLoggedIn - Any user is autenticated');
      print(
          'checkUserLoggedIn Exist Login - userLoggedInState: ${ref.read(userLoggedIn.notifier).value}');
      ref.read(userLoggedIn.notifier).value = false;
      print(
          'checkUserLoggedIn - After Exist Login false - userLoggedInState: ${ref.read(userLoggedIn.notifier).value}');
    }
  }

  Future<void> authenticateLinkedin() async {
    print('Authenticating...');

    final url = 'https://www.linkedin.com/oauth/v2/authorization?'
        'response_type=code&'
        'client_id=$client_id&'
        'redirect_uri=$redirect_uri&'
        'scope=r_liteprofile%20r_emailaddress';

    // Open the authorization URL in a web view and wait for the result
    final result = await FlutterWebAuth2.authenticate(
      url: url,
      callbackUrlScheme: 'http',
    );

    // Extract the authorization code from the result
    final code = await handleAuthResultCodeLinkedin(result);

    // Request an access token using the authorization code
    if (code != null) {
      await requestAccessTokenLinkedin(code);
    }
  }

  // Extracts the authorization code from the callback URL
  Future<String?> handleAuthResultCodeLinkedin(String result) async {
    print("handleAuthResultCodeLinkedin");
    final currentUri = Uri.parse(result);

    if (currentUri.queryParameters.containsKey('code')) {
      final code = currentUri.queryParameters['code'];
      print(code);
      return code;
    }

    return null;
  }

  // Comment: this fuction is client site request
  // // Requests an access token using the authorization code
  // Future<void> requestAccessTokenLinkedin(String code) async {
  //   print('requestAccessTokenLinkedin');
  //   final url = Uri.parse('https://www.linkedin.com/oauth/v2/accessToken');
  //   final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
  //   final body = {
  //     'grant_type': 'authorization_code',
  //     'client_id': client_id,
  //     'client_secret': client_secret,
  //     'code': code,
  //     'redirect_uri': redirect_uri,
  //   };

  //   try {
  //     final response = await http.post(url, headers: headers, body: body);

  //     if (response.statusCode == 200) {
  //       final jsonResponse = jsonDecode(response.body);
  //       final accessToken = jsonResponse['access_token'];

  //       await getLinkedinProfile(accessToken);
  //     } else {
  //       print('Request failed with status: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error requestAccessTokenLinkedin: $e');
  //   }
  // }

  // this is client service request
  // I need to do a http request with the code
  // Requests an access token using the authorization code
  Future<void> requestAccessTokenLinkedin(String code) async {
    final tokenType = 'access_token_linkedin';
    final CLIENT_ID = client_id;
    final REDIRECT_URI = redirect_uri;

    final url = Uri.parse(
        'https://us-central1-jsninja-dev.cloudfunctions.net/custom-token?code=$code&token_type=$tokenType&CLIENT_ID=$CLIENT_ID&REDIRECT_URI=$REDIRECT_URI');
    final response = await http.get(url);
    try {
      if (response.statusCode == 200) {
        final accessToken = response.body;
        print_string_cloud(accessToken);
        await getLinkedinProfile(accessToken);
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getPictureLinkedin: $e');
      print_string_cloud("something went wrong");
    }
  }

  // Cloud Fuction that is trigger

  // def process_access_token_linkedin(request):
  //   CLIENT_ID = request.args.get('CLIENT_ID')
  //   CLIENT_SECRET = os.environ.get('CLIENT_SECRET')
  //   ACCESS_TOKEN_URL = 'https://www.linkedin.com/oauth/v2/accessToken'
  //   AUTH_CODE = request.args.get('code')
  //   REDIRECT_URI = request.args.get('REDIRECT_URI')
  //   print(CLIENT_ID)
  //   print(REDIRECT_URI)

  //   PARAMS = {
  //       'grant_type': 'authorization_code',
  //       'code': AUTH_CODE,
  //       'redirect_uri': REDIRECT_URI,
  //       'client_id': CLIENT_ID,
  //       'client_secret': CLIENT_SECRET
  //   }

  //   try:
  //       response = requests.post(ACCESS_TOKEN_URL, data=PARAMS)
  //       data = response.json()
  //       access_token = data['access_token']
  //       print(access_token)
  //       return access_token
  //   except Exception as e:
  //       return 'Error processing access token: {}'.format(e)

  //just for testing porposes
  Future<void> print_string_cloud(String string_to_print) async {
    final tokenType = string_to_print;

    final url = Uri.parse(
        'https://us-central1-jsninja-dev.cloudfunctions.net/custom-token?token_type=$tokenType');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final response_cloud = response;
      print(response_cloud);
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

// Retrieves the user's profile picture URL using the access token
  Future<String> getPictureLinkedin(String accessToken) async {
    final url = Uri.parse(
        'https://api.linkedin.com/v2/me?projection=(profilePicture(displayImage~:playableStreams))');
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final profilePic = jsonResponse['profilePicture']['displayImage~']
            ['elements'][0]['identifiers'][0]['identifier'];

        return profilePic.toString();
      } else {
        print('Request failed with status: ${response.statusCode}');
        return '${response.statusCode}';
      }
    } catch (e) {
      print('Error getPictureLinkedin: $e');
      return '$e';
    }
  }

  // Requests the user's email address using the access token
  Future<String> getEmailAddressLinkedin(String accessToken) async {
    final url = Uri.parse(
        'https://api.linkedin.com/v2/emailAddress?q=members&projection=(elements*(handle~))');
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final email = jsonResponse['elements'][0]['handle~']['emailAddress'];
        return email.toString();
      } else {
        print('Request failed with status: ${response.statusCode}');
        return '${response.statusCode}';
      }
    } catch (e) {
      print('Error getEmailAddressLinkedin: $e');
      return '$e';
    }
  }

  // fuction that make a request to Linkedin Api to retrive the main values
  Future<void> getLinkedinProfile(String accessToken) async {
    final url = Uri.parse('https://api.linkedin.com/v2/me');
    final headers = {'Authorization': 'Bearer $accessToken'};
    await print_string_cloud("getLinkedinProfile");
    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final pictureURL = await getPictureLinkedin(accessToken);
        final firstName = jsonResponse['firstName']['localized']['es_ES'];
        final lastName = jsonResponse['lastName']['localized']['es_ES'];
        final userId = jsonResponse['id'];
        final email = await getEmailAddressLinkedin(accessToken);
        final userName = firstName + " " + lastName;

        print('userName: $userName');
        print('pictureURL: $pictureURL');
        print('userId: $userId');
        print('email: $email');

        await signinCustomUserFirebase(userId, email, pictureURL, userName);
      } else {
        print('Request failed with status: ${response.statusCode}');
        await print_string_cloud("getLinkedinProfile");
      }
    } catch (e) {
      print('Error getLinkedinProfile: $e');
      await print_string_cloud("getLinkedinProfile");
    }
  }

// Fuction that autenticate custom Provider (Linkedin, seek, Indeed)

  Future<void> signinCustomUserFirebase(
      userId, String email, String pictureURL, userName) async {
    //Generate custom user
    await print_string_cloud("signinCustomUserFirebase");

    final customToken = await generateCustomToken(userId);

    final signinfirebase = await signInWithCustomToken(customToken as String);

    if (signinfirebase) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;
        print('signInWithCustomToken - userID: $uid'); // Is it same?
        if (userId == uid) {
          // Check if the user exists in the database
          bool userExists = await checkCustomUserExists(uid);

          if (userExists) {
            // User exists in the database,
            print('User exists in the database');
          } else {
            // User doesn't exist in the database, create a new user, save data, and perform login
            print('User does not exist in the database');
            //Save data of user in database
            await saveDataFirebase(uid, email, pictureURL, userName);
          }
        } else {
          print("Authentication Failed - something went wrong");
          // Authentication failed
        }
      }
    }
  }

  // It is require to enable IAM Service Account Credentials API
  // in cloud console Creates short-lived credentials
  // for impersonating IAM service accounts
  // http request with userID in this case linkedin ID user
  // Finally get response with a custome token, this allow to sign in
  // new client who is intending sign in in our app

  Future<String?> generateCustomToken(String userID) async {
    try {
      await initializeFirebase();
      print("generateCustomToken - Init App Firebase");

      final tokenType =
          'generate_custom_token'; // Replace with the desired token type

      final url = Uri.parse(
          'https://us-central1-jsninja-dev.cloudfunctions.net/custom-token?userID=$userID&token_type=$tokenType');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final customToken = response.body;
        print('Custom Token: $customToken');
        return customToken;
      } else {
        print(
            'Failed to fetch custom token. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Failed to authenticate user: $e');
      return null;
    }
  }

  // After generate a custom token is require verify if the customer already
  // exists in our database and finish login therwise is created, save data
  // and login to the app
  Future<bool> signInWithCustomToken(String customToken) async {
    print('signInWithCustomToken');
    try {
      await FirebaseAuth.instance.signInWithCustomToken(customToken);
      print('signInWithCustomToken -- no error yet');
      return true;
    } catch (e) {
      print('Authentication with custom token Error: $e');
      return false;
    }
  }

  Future<bool> checkCustomUserExists(String uid) async {
    try {
      final DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();
      return snapshot.exists; //true
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  // Save the user data based
  Future<void> saveDataFirebase(
      String uid, String email, String pictureURL, String userName) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('user').doc(uid);

      await userRef.set({
        'email': email,
        'pictureURL': pictureURL,
        'userName': userName,
      });

      print('User created with UID: $uid');
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider
        .addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    try {
      final result =
          await FirebaseAuth.instance.signInWithPopup(googleProvider);
      print("Authentication successful");

      //determine if the user exists if not save custom data in the data base
      await checkUserExists(result);
    } catch (e) {
      // Handle authentication error
      print('Failed to sign in with GitHub: $e');
    }
  }

  // Auth page: https://github.com/settings/applications
  Future<void> signInWithGitHub() async {
    GithubAuthProvider githubAuthProvider = GithubAuthProvider();
    try {
      final result =
          await FirebaseAuth.instance.signInWithPopup(githubAuthProvider);
      print("Authentication successful");

      //determine if the user exists if not save custom data in the data base
      await checkUserExists(result);
    } catch (e) {
      // Handle authentication error
      print('Failed to sign in with GitHub: $e');
    }
  }

  //https://developer.twitter.com/en/portal/projects/1672405934805745666/apps/27364500/settings
  Future<void> signInWithFacebook() async {
    FacebookAuthProvider facebookAuthProvider = FacebookAuthProvider();
    try {
      print("Starting Facebook authentication");
      final result =
          await FirebaseAuth.instance.signInWithPopup(facebookAuthProvider);
      print("Authentication successful");
      //determine if the user exists if not save custom data in the data base
      await checkUserExists(result);
    } catch (e) {
      // Handle authentication error
      print('Failed to sign in with Facebook: $e');
    }
  }

  Future<void> signInWithTwitter() async {
    TwitterAuthProvider twitterAuthProvider = TwitterAuthProvider();
    try {
      if (kIsWeb) {
        print("Starting twitter authentication");
        final result =
            await FirebaseAuth.instance.signInWithPopup(twitterAuthProvider);
        await checkUserExists(result);
      } else {
        final result =
            await FirebaseAuth.instance.signInWithProvider(twitterAuthProvider);
        await checkUserExists(result);
      }
      print("Authentication successful");
      //determine if the user exists if not save custom data in the data base
    } catch (e) {
      // Handle authentication error
      print('Failed to sign in with Twitter: $e');
    }
  }

  Future<void> checkUserExists(UserCredential result) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Access the signed-in user's information
      final user = result.user;
      final displayName = user?.displayName;
      final email = user?.email;
      final photoURL = user?.photoURL;

      // Retrieve additional user data using GitHub APIs
      // Make API calls using the 'accessToken'

      // print("Current User:  ${currentUser.uid}");
      // print("User data:  $user");
      // print("Display Name: $displayName");
      // print("Email: $email");
      // print("Photo URL: $photoURL");

      // Deteremine if the user exits
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (userSnapshot.exists) {
        // User already exists in the database
        print("User already exists");
      } else {
        // User does not exist, save user data to Firebase
        await saveDataFirebase(
            currentUser.uid, email!, photoURL!, displayName!);
        print("User data saved to Firebase");
      }
    } else {
      print("current user is null");
    }
  }

  ElevatedButton imageButton(
      String title, String imageName, VoidCallback callback) {
    return ElevatedButton(
        key: Key(title),
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
        ));
  }

  ElevatedButton iconButton(
      String title, IconData iconData, VoidCallback callback) {
    return ElevatedButton(
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
    );
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

    final ElevatedButton googleButton =
        imageButton("Log in with Google", "google_logo", () {
      signInWithGoogle().whenComplete(() {
        ref.read(userLoggedIn.notifier).value = true;
      });
    });

    final ElevatedButton linkedinButton =
        imageButton("Log in with Linkedin", "linkedin_logo", () {
      ref.read(showLoading.notifier).value = true;
      authenticateLinkedin().whenComplete(() {
        checkUserLoggedIn(ref);
        ref.read(showLoading.notifier).value = false;
      });
    });

    final ElevatedButton githubButton =
        imageButton("Log in with Github", "github_logo", () async {
      ref.read(showLoading.notifier).value = true;
      signInWithGitHub().whenComplete(() {
        ref.read(userLoggedIn.notifier).value = true;
        ref.read(showLoading.notifier).value = false;
      });
    });

    final ElevatedButton facebookButton =
        imageButton("Log in with facebook", "facebook_logo", () async {
      ref.read(showLoading.notifier).value = true;
      signInWithFacebook().whenComplete(() {
        ref.read(userLoggedIn.notifier).value = true;
        ref.read(showLoading.notifier).value = false;
      });
    });

    final ElevatedButton twitterButton =
        imageButton("Log in with twiter", "twitter_logo", () async {
      ref.read(showLoading.notifier).value = true;
      signInWithTwitter().whenComplete(() {
        ref.read(userLoggedIn.notifier).value = true;
        ref.read(showLoading.notifier).value = false;
      });
    });

    final ElevatedButton ssoButton =
        iconButton("Log in with SSO", Icons.key, () {});

    final ElevatedButton emailButton =
        iconButton("Log in with Email", Icons.mail, () {});

    final ElevatedButton anonymousButton =
        iconButton("Log in Anonymous", Icons.account_circle, () async {
      FirebaseAuth.instance.signInAnonymously().then((a) => {
            if (onLoginAnonymousButtonPressed != null)
              onLoginAnonymousButtonPressed!()
          });
    });

    List<Widget> widgets = [
      Expanded(
        flex: isWideScreen ? 1 : 0,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 340,
              ),
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
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
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
                    visible: AuthConfig.enableLinkedinOption,
                    child: Column(
                      children: [
                        const Gap(50),
                        SizedBox(width: double.infinity, child: linkedinButton),
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
                    visible: AuthConfig.enableFacebookOption,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Gap(50),
                        SizedBox(width: double.infinity, child: facebookButton),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: AuthConfig.enableTwitterOption,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Gap(50),
                        SizedBox(width: double.infinity, child: twitterButton),
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
                        SizedBox(
                            width: double.infinity, child: anonymousButton),
                      ],
                    ),
                  ),
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
                                style: TextStyle(
                                    fontSize: 18, color: Colors.blueGrey),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap(50),
                ],
              ),
            ),
          ),
        ),
      )
    ];

    return isWideScreen
        ? Flex(direction: Axis.horizontal, children: widgets)
        : SingleChildScrollView(
            child: Flex(
                direction: Axis.vertical, children: widgets.reversed.toList()));
  }
}
