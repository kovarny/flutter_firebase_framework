import 'package:flutter/material.dart';

PageRouteBuilder Function(RouteSettings settings) generateRoutes(
        Map<String, WidgetBuilder> routes) =>
    (RouteSettings settings) {
      WidgetBuilder builder;
      // print('showing ${settings.name}');
      builder = routes[settings.name]!;
      // switch (settings.name) {
      //   case '/providers':
      //     builder = (BuildContext context) => ProvidersPage();
      //     break;
      //   case '/auth':
      //     builder = (BuildContext context) => AuthPage();
      //     break;
      //   case '/widgets':
      //     builder = (BuildContext context) => WidgetsPage();
      //     break;
      //   default:
      //     throw Exception('Invalid route: ${settings.name}');
      // }

      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return builder(context);
        },
        transitionsBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
          return child;
        },
      );
    };

// PageRouteBuilder generateRoute(RouteSettings settings) {
//   WidgetBuilder builder;
//   // print('showing ${settings.name}');
//   switch (settings.name) {
//     case '/providers':
//       builder = (BuildContext context) => ProvidersPage();
//       break;
//     case '/auth':
//       builder = (BuildContext context) => AuthPage();
//       break;
//     case '/widgets':
//       builder = (BuildContext context) => WidgetsPage();
//       break;
//     default:
//       throw Exception('Invalid route: ${settings.name}');
//   }

//   return PageRouteBuilder(
//     settings: settings,
//     pageBuilder: (BuildContext context, Animation<double> animation,
//         Animation<double> secondaryAnimation) {
//       return builder(context);
//     },
//     transitionsBuilder: (BuildContext context, Animation<double> animation,
//         Animation<double> secondaryAnimation, Widget child) {
//       return child;
//     },
//   );
// }