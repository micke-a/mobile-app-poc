import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/add_product_screen.dart';
import '../screens/favourites_screen.dart';
import '../screens/home_screen.dart';
import '../screens/order_detail_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/products_by_shop_screen.dart';
import '../screens/products_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: '/products',
        builder: (_, _) => const ProductsScreen(),
        routes: [
          GoRoute(
            path: 'shop/:shopId',
            builder: (_, state) => ProductsByShopScreen(
              shopId: int.parse(state.pathParameters['shopId']!),
            ),
          ),
          GoRoute(
            path: 'favourites',
            builder: (_, _) => const FavouritesScreen(),
          ),
          GoRoute(
            path: 'add',
            builder: (_, _) => const AddProductScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/product/:id',
        builder: (_, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/orders', builder: (_, _) => const OrdersScreen()),
      GoRoute(
        path: '/order/:id',
        builder: (_, state) =>
            OrderDetailScreen(orderId: state.pathParameters['id']!),
      ),
    ],
  );
});
