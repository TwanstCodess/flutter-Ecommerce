import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../components/mydrawer.dart';

// Add this new ProductDetailPage widget
class ProductDetailPage extends StatelessWidget {
  final dynamic product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['title']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                product['thumbnail'],
                width: double.infinity,
                height: 300,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, size: 100);
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              product['title'],
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              '\$${product['price']}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              'Description:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              product['description'],
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            if (product['rating'] != null)
              Row(
                children: [
                  Text(
                    'Rating: ${product['rating']}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  ),
                ],
              ),
            const SizedBox(height: 10),
            if (product['stock'] != null)
              Text(
                'In stock: ${product['stock']}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
          ],
        ),
      ),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  late Future<List<String>> _categories;
  String selectedCategory = 'smartphones';
  late Future<List<dynamic>> _products;
  bool _isLoadingProducts = false;

  Future<List<String>> fetchCategories() async {
    var url = Uri.parse("https://dummyjson.com/products/category-list");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return List<String>.from(data);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<dynamic>> fetchProductsByCategory(String category) async {
    setState(() {
      _isLoadingProducts = true;
    });
    try {
      var url = Uri.parse("https://dummyjson.com/products/category/$category");
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['products'];
      } else {
        throw Exception('Failed to load products for $category');
      }
    } finally {
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _categories = fetchCategories();
    _products = fetchProductsByCategory(selectedCategory);
  }

  void _onCategorySelected(String category) {
    if (selectedCategory == category) return;
    
    setState(() {
      selectedCategory = category;
      _products = fetchProductsByCategory(category);
    });
  }

  // Add this method to handle product tap
  void _onProductTap(BuildContext context, dynamic product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        centerTitle: true,
        title: const Text(
          "Products",
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: Mydrawer(),
      body: Column(
        children: [
          FutureBuilder<List<String>>(
            future: _categories,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: LinearProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Text("Error loading categories");
              }

              var categories = snapshot.data!;
              return SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    String category = categories[index];
                    return GestureDetector(
                      onTap: () => _onCategorySelected(category),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: selectedCategory == category
                              ? Colors.indigo
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: selectedCategory == category
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const Divider(),
          Expanded(
            child: _isLoadingProducts
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<List<dynamic>>(
                    future: _products,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("No products found"));
                      }

                      var products = snapshot.data!;
                      return ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          var product = products[index];
                          return InkWell(
                            onTap: () => _onProductTap(context, product),
                            child: Card(
                              margin: const EdgeInsets.all(8.0),
                              elevation: 3,
                              child: ListTile(
                                leading: Image.network(
                                  product['thumbnail'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.broken_image);
                                  },
                                ),
                                title: Text(product['title']),
                                subtitle: Text(
                                  product['description'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text("\$${product['price']}"),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}