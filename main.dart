import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Product {
  final String id;
  final String name;
  final double price;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leafe Grocery',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const GroceryApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GroceryApp extends StatefulWidget {
  const GroceryApp({super.key});

  @override
  State<GroceryApp> createState() => _GroceryAppState();
}

class _GroceryAppState extends State<GroceryApp> {
  int _currentIndex = 0;

  // Sample product catalog
  final List<Product> _products = [
    Product(id: 'p1', name: 'Bananas', price: 1.29, category: 'Fruits'),
    Product(id: 'p2', name: 'Apples', price: 2.49, category: 'Fruits'),
    Product(id: 'p3', name: 'Milk', price: 3.19, category: 'Dairy'),
    Product(id: 'p4', name: 'Eggs (12)', price: 2.99, category: 'Dairy'),
    Product(id: 'p5', name: 'Bread', price: 1.99, category: 'Bakery'),
    Product(id: 'p6', name: 'Tomatoes', price: 2.29, category: 'Vegetables'),
    Product(id: 'p7', name: 'Chicken Breast', price: 6.49, category: 'Meat'),
    Product(id: 'p8', name: 'Orange Juice', price: 4.50, category: 'Beverages'),
  ];

  // cart: productId -> qty
  final Map<String, int> _cart = {};

  void _addToCart(String productId) {
    setState(() {
      _cart[productId] = (_cart[productId] ?? 0) + 1;
    });
    final product = _products.firstWhere((p) => p.id == productId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to cart')),
    );
  }

  void _removeFromCart(String productId) {
    setState(() {
      if (_cart.containsKey(productId)) {
        final qty = _cart[productId]!;
        if (qty > 1) {
          _cart[productId] = qty - 1;
        } else {
          _cart.remove(productId);
        }
      }
    });
  }

  void _setQty(String productId, int qty) {
    setState(() {
      if (qty <= 0) {
        _cart.remove(productId);
      } else {
        _cart[productId] = qty;
      }
    });
  }

  double get _cartTotal {
    double total = 0;
    for (final entry in _cart.entries) {
      final product = _products.firstWhere((p) => p.id == entry.key);
      total += product.price * entry.value;
    }
    return total;
  }

  int get _cartItemsCount {
    return _cart.values.fold(0, (a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(
        products: _products,
        onAddToCart: _addToCart,
        cartCount: _cartItemsCount,
      ),
      CartPage(
        products: _products,
        cart: Map.from(_cart),
        onRemove: _removeFromCart,
        onSetQty: _setQty,
        total: _cartTotal,
      ),
      MessagesPage(),
      ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leafe Grocery'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  setState(() {
                    _currentIndex = 1; // go to cart
                  });
                },
              ),
              if (_cartItemsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.red,
                    child: Text(
                      '$_cartItemsCount',
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                // simple mock: add a random item or open filters
                _addToCart(_products.first.id);
              },
              icon: const Icon(Icons.local_offer),
              label: const Text('Daily Deal'),
            )
          : null,
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Product> products;
  final void Function(String) onAddToCart;
  final int cartCount;

  const HomePage({
    super.key,
    required this.products,
    required this.onAddToCart,
    required this.cartCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          // Categories horizontal (simple)
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                CategoryChip(label: 'All', selected: true),
                CategoryChip(label: 'Fruits'),
                CategoryChip(label: 'Vegetables'),
                CategoryChip(label: 'Dairy'),
                CategoryChip(label: 'Bakery'),
                CategoryChip(label: 'Meat'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Product grid
          Expanded(
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final p = products[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Center(
                            child: CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.green[50],
                              child: Text(p.name[0], style: const TextStyle(fontSize: 28, color: Colors.green)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('\$${p.price.toStringAsFixed(2)}', style: TextStyle(color: Colors.green[700])),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => onAddToCart(p.id),
                              icon: const Icon(Icons.add_shopping_cart, size: 18),
                              label: const Text('Add'),
                            ),
                            IconButton(
                              onPressed: () {
                                // simple favorite placeholder
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Favorited ${p.name}')));
                              },
                              icon: const Icon(Icons.favorite_border),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  final List<Product> products;
  final Map<String, int> cart;
  final void Function(String) onRemove;
  final void Function(String, int) onSetQty;
  final double total;

  const CartPage({
    super.key,
    required this.products,
    required this.cart,
    required this.onRemove,
    required this.onSetQty,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final entries = cart.entries.toList();
    if (entries.isEmpty) {
      return const Center(child: Text('Your cart is empty', style: TextStyle(fontSize: 18)));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            separatorBuilder: (_, __) => const Divider(),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final productId = entries[index].key;
              final qty = entries[index].value;
              final product = products.firstWhere((p) => p.id == productId);
              return ListTile(
                leading: CircleAvatar(child: Text(product.name[0])),
                title: Text(product.name),
                subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                trailing: SizedBox(
                  width: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => onRemove(productId),
                      ),
                      Text('$qty', style: const TextStyle(fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => onSetQty(productId, qty + 1),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // simple mock checkout
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Checkout'),
                        content: const Text('This is a mock checkout. Implement your payment flow.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))
                        ],
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text('Proceed to Checkout'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Messages / Support', style: TextStyle(fontSize: 18)));
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 12),
          const Text('Customer Name', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('customer@example.com'),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Orders'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Addresses'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  const CategoryChip({super.key, required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Chip(
        label: Text(label),
        backgroundColor: selected ? Colors.green[100] : Colors.grey[100],
      ),
    );
  }
}