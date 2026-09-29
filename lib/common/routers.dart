import 'package:go_router/go_router.dart';
import 'package:syafarapp/domain/quotation/entities/quotation_args.dart';
import 'package:syafarapp/presentation/pages/saved_quotation_page.dart';
import 'package:syafarapp/presentation/pages/search_page.dart';
import 'package:syafarapp/presentation/pages/result_page.dart';
import 'package:syafarapp/presentation/pages/quotation_page.dart';
import 'package:syafarapp/presentation/bloc/search/search_state.dart';

const String SEARCH_ROUTE = '/';
const String RESULT_ROUTE = '/result';
const String QUOTATION_ROUTE = '/quotation';
const String SAVED_QUOTATION_ROUTE = '/saved';

final GoRouter routers = GoRouter(
  initialLocation: SEARCH_ROUTE,
  routes: [
    GoRoute(
      path: SEARCH_ROUTE,
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: RESULT_ROUTE,
      builder: (context, state) {
        final searchState = state.extra as SearchLoaded;
        return ResultPage(searchData: searchState);
      },
    ),
    GoRoute(
      path: QUOTATION_ROUTE,
      builder: (context, state) {
        final args = state.extra as QuotationArgs;
        return QuotationPage(args: args);
      },
    ),
    GoRoute(
      path: SAVED_QUOTATION_ROUTE,
      builder: (context, state) => const SavedQuotationPage(),
    ),
  ],
);
