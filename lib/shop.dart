import 'package:flutter/material.dart';
import 'package:groove_app/client_routes.dart';
import 'package:groove_app/api_service/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:groove_app/api_DTOs/addcart_dto.dart';
import 'package:groove_app/api_DTOs/shop_dto.dart';
import 'package:groove_app/api_service/api_cart.dart';
import 'package:groove_app/api_service/shop_service.dart';
import 'package:groove_app/basket_shop.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/designs/groove_page_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  late Future<List<Abonement>> _abonements;

  @override
  void initState() {
    super.initState();
    _abonements = fetchAbonements();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncCartFromServer());
  }

  Future<void> _syncCartFromServer() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null || !mounted) return;

    final cartDto = await getCart(userId);
    if (!mounted || cartDto == null) return;

    final items = <int, int>{
      for (final item in cartDto.items) item.abonementId: item.quantity,
    };
    Provider.of<CartProvider>(context, listen: false).syncFromServer(items);
  }

  Future<void> _addToCartAPI(int userId, int abonementId) async {
    final dto = AddToCartDto(userId: userId, abonementId: abonementId);
    final success = await addToCart(dto);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Добавлено в корзину' : 'Не удалось добавить'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _removeFromCartAPI(int userId, int abonementId) async {
    final dto = AddToCartDto(userId: userId, abonementId: abonementId);
    final success = await removeFromCart(dto);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось удалить абонемент')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final selectedIndex = cartProvider.selectedIndex;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.popAndPushNamed(context, ClientRoutes.home),
          ),
        ),
        title: Text('Магазин', style: GroovePageStyles.title(context, size: 30)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_basket, color: Theme.of(context).colorScheme.onSurface),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BasketShopPage(),
                    ),
                  );
                },
              ),
              if (cartProvider.totalItems > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartProvider.totalItems}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildNavigationBar(cartProvider),
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<List<Abonement>>(
                future: _abonements,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Ошибка: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("Нет доступных абонементов"),
                    );
                  } else {
                    final filtered =
                        snapshot.data!
                            .where(
                              (a) =>
                                  selectedIndex == 0
                                      ? !a.isPrivate
                                      : a.isPrivate,
                            )
                            .map((a) => a.toCartItem())
                            .toList();

                    return _buildItemList(filtered, cartProvider);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar(CartProvider cartProvider) {
    final g = context.groove;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: g.border)),
      ),
      child: Row(
        children: [
          _buildTab("Абонементы", 0, cartProvider),
          _buildTab("Персональные занятия", 1, cartProvider),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, CartProvider cartProvider) {
    final g = context.groove;
    final selected = cartProvider.selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => cartProvider.setSelectedIndex(index),
        child: Container(
          decoration: BoxDecoration(
            border: selected
                ? const Border(
                    bottom: BorderSide(color: ProcessYellow, width: 3),
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GroovePageStyles.body(
              context,
              size: 16,
              color: selected ? ProcessYellow : g.onSurfaceSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemList(
    List<Map<String, dynamic>> items,
    CartProvider cartProvider,
  ) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(items[index], cartProvider);
      },
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, CartProvider cartProvider) {
    final title = item['title'];
    final abonementId = item['id'] as int;
    final count = cartProvider.quantityFor(abonementId);

    return Card(
      color: GroovePageStyles.cardBackground(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: Theme.of(context).brightness == Brightness.light
            ? BorderSide(color: context.groove.border)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GroovePageStyles.body(context, size: 18).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item['description'],
              style: GroovePageStyles.muted(context, size: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['price'],
                  style: GroovePageStyles.body(context, size: 20, color: ProcessYellow)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                count == 0
                    ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProcessYellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final userId = prefs.getInt('userId');
                        if (userId == null) {
                          // Не авторизован
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Ошибка: пользователь не найден'),
                            ),
                          );
                          return;
                        }
                        await _addToCartAPI(userId, abonementId);
                        cartProvider.addItem(abonementId);
                      },
                      child: Text(
                        'В корзину',
                        style: GroovePageStyles.body(context).copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final userId = prefs.getInt('userId');
                            if (userId == null) {
                              // Не авторизован
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Ошибка: пользователь не найден',
                                  ),
                                ),
                              );
                              return;
                            }
                            await _removeFromCartAPI(userId, abonementId);
                            cartProvider.removeItem(abonementId);
                          },
                          icon: Icon(Icons.remove, color: Theme.of(context).colorScheme.onSurface),
                        ),
                        Text(
                          count.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final userId = prefs.getInt('userId');
                            if (userId == null) {
                              // Не авторизован
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Ошибка: пользователь не найден',
                                  ),
                                ),
                              );
                              return;
                            }
                            await _addToCartAPI(userId, item['id']);
                            cartProvider.addItem(abonementId);
                          },
                          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ],
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
