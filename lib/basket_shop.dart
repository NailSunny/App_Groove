import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/cart_dto.dart';
import 'package:groove_app/api_DTOs/confirm_purchase_dto.dart';
import 'package:groove_app/api_service/api_cart.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BasketShopPage extends StatefulWidget {
  const BasketShopPage({super.key});

  @override
  State<BasketShopPage> createState() => _BasketShopPageState();
}

class _BasketShopPageState extends State<BasketShopPage> {
  final Color backBlack = BackBlack;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  CartDto? cart;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  void _fetchCart() async {
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
    final result = await getCart(userId); // Замените 1 на ID пользователя
    if (result != null) {
      setState(() {
        cart = result;
        _nameController.text = result.name + ' ' + result.surname;
        _emailController.text = result.email;
        _phoneController.text = result.phone;
        isLoading = false;
      });
    } else {
      // Обработка ошибки
      setState(() {
        isLoading = false;
      });
    }
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
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.popAndPushNamed(context, '/shop'),
          ),
        ),
        title: const Text(
          'Корзина',
          style: TextStyle(
            color: TextWhite,
            fontSize: 30,
            fontFamily: 'RubikMonoOne',
          ),
        ),
        backgroundColor: BackBlack,
        centerTitle: true,
      ),
      body: Container(
        color: BackBlack, // Дополнительно установлен цвет фона для body
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
      color: ElementsPurple,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ваши данные',
                style: TextStyle(
                  color: TextWhite,
                  fontSize: 20,
                  fontFamily: 'RubikMonoOne',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Имя Фамилия',
                  labelStyle: TextStyle(
                    color: PicGrey,
                    fontFamily: 'RubikMonoOne',
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: PicGrey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите имя';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: PicGrey,
                    fontFamily: 'RubikMonoOne',
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: PicGrey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Номер телефона',
                  labelStyle: TextStyle(
                    color: PicGrey,
                    fontFamily: 'RubikMonoOne',
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: PicGrey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите номер телефона';
                  }
                  return null;
                },
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
      return const Center(child: CircularProgressIndicator());
    }
    if (cart == null || cart!.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Корзина пуста.',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Ваши товары',
                style: TextStyle(
                  color: TextWhite,
                  fontSize: 20,
                  fontFamily: 'RubikMonoOne',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cart!.items.length,
          itemBuilder: (context, index) {
            final item = cart!.items[index];
            return _buildCartItemCard(item);
          },
        ),
      ],
    );
  }

  Widget _buildCartItemCard(CartItemDto item) {
    return Card(
      color: ElementsPurple,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.abonementName,
              style: const TextStyle(
                color: TextWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item.price} ₽',
                  style: const TextStyle(color: ProcessYellow, fontSize: 16),
                ),
                Text(
                  '${item.price} ₽',
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Итого:',
            style: TextStyle(
              color: TextWhite,
              fontSize: 20,
              fontFamily: 'RubikMonoOne',
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$total ₽',
            style: const TextStyle(
              color: ProcessYellow,
              fontSize: 24,
              fontFamily: 'RubikMonoOne',
              fontWeight: FontWeight.bold,
            ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
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
            final dto = ConfirmPurchaseDto(
              userId: userId,
            ); // Заменить 1 на актуальный ID пользователя
            final success = await confirmPurchase(dto);

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Оплата прошла успешно!'),
                  duration: Duration(seconds: 2),
                ),
              );
              _fetchCart(); // обновим корзину после оплаты
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ошибка при оплате'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        },
        child: const Text(
          'ОПЛАТИТЬ',
          style: TextStyle(
            color: TextWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
