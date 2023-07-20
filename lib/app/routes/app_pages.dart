import 'package:get/get.dart';

import '../modules/analyzer_detail/bindings/analyzer_detail_binding.dart';
import '../modules/analyzer_detail/views/analyzer_detail_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/plugin_market/bindings/plugin_market_binding.dart';
import '../modules/plugin_market/views/plugin_market_view.dart';
import '../modules/welcome/bindings/welcome_binding.dart';
import '../modules/welcome/views/welcome_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.WELCOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.WELCOME,
      page: () => const WelcomeView(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: _Paths.PLUGIN_MARKET,
      page: () => const PluginMarketView(),
      binding: PluginMarketBinding(),
    ),
  ];
}
