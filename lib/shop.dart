import 'package:flutter/material.dart';
import 'package:groove_app/api_service/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:groove_app/api_DTOs/addcart_dto.dart';
import 'package:groove_app/api_DTOs/shop_dto.dart';
import 'package:groove_app/api_service/shop_service.dart';
import 'package:groove_app/basket_shop.dart';
import 'package:groove_app/designs/colors.dart';
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
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.popAndPushNamed(context, '/home'),
          ),
        ),
        title: const Text(
          'Магазин',
          style: TextStyle(
            color: TextWhite,
            fontSize: 30,
            fontFamily: 'RubikMonoOne',
          ),
        ),
        backgroundColor: BackBlack,
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_basket, color: Colors.white),
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
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartProvider.totalItems}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
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
              color: BackBlack,
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
    final selectedIndex = cartProvider.selectedIndex;

    return Container(
      height: 50,
      color: BackBlack,
      child: Row(
        children: [
          _buildTab("Абонементы", 0, cartProvider),
          _buildTab("Персональные занятия", 1, cartProvider),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, CartProvider cartProvider) {
    return Expanded(
      child: GestureDetector(
        onTap: () => cartProvider.setSelectedIndex(index),
        child: Container(
          decoration: BoxDecoration(
            border:
                cartProvider.selectedIndex == index
                    ? const Border(
                      bottom: BorderSide(color: ProcessYellow, width: 3),
                    )
                    : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color:
                  cartProvider.selectedIndex == index ? ProcessYellow : PicGrey,
              fontSize: 16,
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
    final count = cartProvider.cart[title] ?? 0;

    return Card(
      color: ElementsPurple,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: TextWhite,
                fontSize: 18,
                fontFamily: 'RubicMonoOne',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item['description'],
              style: TextStyle(color: PicGrey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['price'],
                  style: const TextStyle(
                    color: ProcessYellow,
                    fontSize: 20,
                    fontFamily: 'RubicMonoOne',
                    fontWeight: FontWeight.bold,
                  ),
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
                        await _addToCartAPI(userId, item['id']);
                        cartProvider.addItem(title);
                      },
                      child: const Text(
                        'В корзину',
                        style: TextStyle(
                          color: TextWhite,
                          fontFamily: 'RubicMonoOne',
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
                            await _removeFromCartAPI(userId, item['id']);
                            cartProvider.removeItem(title);
                          },
                          icon: const Icon(Icons.remove, color: TextWhite),
                        ),
                        Text(
                          count.toString(),
                          style: const TextStyle(
                            color: TextWhite,
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
                            cartProvider.addItem(title);
                          },
                          icon: const Icon(Icons.add, color: TextWhite),
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
