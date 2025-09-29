class Item {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String category;

  Item({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
  });

  factory Item.fromMap(Map<String, dynamic> m) => Item(
        id: m['id'],
        name: m['name'],
        description: m['description'],
        price: m['price'],
        category: m['category'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
    };
  }
}