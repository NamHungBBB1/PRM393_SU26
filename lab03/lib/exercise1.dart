import 'dart:async';

class Product {
  final int id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});

  @override
  String toString() => 'Product(id: $id, name: $name, price: \$$price)';
}

class ProductRepository {
  final List<Product> _products = [
    Product(id: 1, name: 'Apple', price: 1.5),
    Product(id: 2, name: 'Banana', price: 0.5),
    Product(id: 3, name: 'Cherry', price: 3.0),
  ];

  // broadcast() allows multiple listeners at once
  final StreamController<Product> _controller =
      StreamController<Product>.broadcast();

  // Simulate network delay then return all products
  Future<List<Product>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _products;
  }

  // Stream that emits each product added in real-time
  Stream<Product> liveAdded() => _controller.stream;

  void addProduct(Product product) {
    _products.add(product);
    _controller.add(product); // push to stream
  }

  void dispose() => _controller.close();
}

Future<String> runExercise() async {
  final output = StringBuffer();
  final repo = ProductRepository();
  final completer = Completer<void>();

  repo.liveAdded().listen((p) {
    output.writeln('Live update: $p');
    completer.complete();
  });

  final products = await repo.getAll();
  output.writeln('All products:');
  for (final p in products) {
    output.writeln('  $p');
  }

  repo.addProduct(Product(id: 4, name: 'Durian', price: 10.0));
  await completer.future;
  repo.dispose();
  return output.toString();
}

Future<void> main() async {
  final result = await runExercise();
  print(result);
}
