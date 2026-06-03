import 'package:flutter/material.dart';
import 'package:groove_app/client_routes.dart';
import 'package:groove_app/api_DTOs/addcart_dto.dart';
import 'package:groove_app/api_DTOs/cart_dto.dart';
import 'package:groove_app/api_DTOs/confirm_purchase_dto.dart';
import 'package:groove_app/api_service/api_cart.dart';
import 'package:groove_app/api_service/cart_provider.dart';
import 'package:groove_app/api_service/shop_service.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/designs/groove_page_styles.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BasketShopPage extends StatefulWidget {
  const BasketShopPage({super.key});

  @override
  State<BasketShopPage> createState() => _BasketShopPageState();
}

class _BasketShopPageState extends State<BasketShopPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  CartDto? cart;
  bool isLoading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: пользователь не найден')),
        );
        setState(() => isLoading = false);
      }
      return;
    }

    _userId = userId;
    final result = await getCart(userId);
    if (!mounted) return;

    if (result != null) {
      final items = <int, int>{
        for (final item in result.items) item.abonementId: item.quantity,
      };
      Provider.of<CartProvider>(context, listen: false).syncFromServer(items);
      setState(() {
        cart = result;
        _nameController.text = '${result.name} ${result.surname}'.trim();
        _emailController.text = result.email;
        _phoneController.text = result.phone;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _changeQuantity(CartItemDto item, int delta) async {
    if (_userId == null) return;
    final dto = AddToCartDto(userId: _userId!, abonementId: item.abonementId);
    final ok = delta > 0 ? await addToCart(dto) : await removeFromCart(dto);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось обновить корзину')),
      );
      return;
    }
    await _fetchCart();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.popAndPushNamed(context, ClientRoutes.shop),
          ),
        ),
        title: Text('Корзина', style: GroovePageStyles.title(context, size: 30)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildUserInfoForm(),
              _buildCartItemsList(),
              _buildTotalSum(),
              _buildPayButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoForm() {
    return Card(
      color: GroovePageStyles.cardBackground(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: Theme.of(context).brightness == Brightness.light
            ? BorderSide(color: context.groove.border)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ваши данные',
                style: GroovePageStyles.title(context, size: 20),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Имя Фамилия',
                  labelStyle: GroovePageStyles.muted(context),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: context.groove.border),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Пожалуйста, введите имя' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: GroovePageStyles.muted(context),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: context.groove.border),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Пожалуйста, введите email' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Номер телефона',
                  labelStyle: GroovePageStyles.muted(context),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: context.groove.border),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Пожалуйста, введите номер телефона' : null,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItemsList() {
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(color: MainPurple)),
      );
    }
    if (cart == null || cart!.items.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Корзина пуста.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16)),
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Ваши товары',
                style: GroovePageStyles.title(context, size: 20),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cart!.items.length,
          itemBuilder: (context, index) => _buildCartItemCard(cart!.items[index]),
        ),
      ],
    );
  }

  Widget _buildCartItemCard(CartItemDto item) {
    return Card(
      color: GroovePageStyles.cardBackground(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: Theme.of(context).brightness == Brightness.light
            ? BorderSide(color: context.groove.border)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.abonementName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${item.price} ₽ за ед.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () => _changeQuantity(item, -1),
                  icon: Icon(Icons.remove_circle_outline, color: Theme.of(context).colorScheme.onSurface),
                ),
                Text(
                  '${item.quantity}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => _changeQuantity(item, 1),
                  icon: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.onSurface),
                ),
                const Spacer(),
                Text(
                  '${item.lineTotal} ₽',
                  style: const TextStyle(
                    color: ProcessYellow,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSum() {
    final int total = cart?.total ?? 0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Итого:',
            style: GroovePageStyles.title(context, size: 20),
          ),
          Text(
            '$total ₽',
            style: GroovePageStyles.body(context, size: 24, color: ProcessYellow)
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ProcessYellow,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () async {
          if (!_formKey.currentState!.validate() || _userId == null) return;

          final dto = ConfirmPurchaseDto(userId: _userId!);
          final success = await confirmPurchase(dto);

          if (!mounted) return;
          if (success) {
            Provider.of<CartProvider>(context, listen: false).clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Оплата прошла успешно!'), duration: Duration(seconds: 2)),
            );
            await _fetchCart();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка при оплате'), duration: Duration(seconds: 2)),
            );
          }
        },
        child: Text(
          'ОПЛАТИТЬ',
          style: GroovePageStyles.body(context, size: 18).copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
