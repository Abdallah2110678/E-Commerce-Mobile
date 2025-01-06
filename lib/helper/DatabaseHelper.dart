// lib/utils/db_helper.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/models/category.dart';
import 'package:mobile_project/models/brand.dart';

class DatabaseHelper {
  static Database? _database;

  // Open or create the database
  static Future<Database> getDatabase() async {
    if (_database == null) {
      String path = join(await getDatabasesPath(), 'wishlist.db');
      _database = await openDatabase(path, version: 1, onCreate: (db, version) {
        db.execute(
          '''CREATE TABLE wishlist (
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            thumbnailUrl TEXT,
            imageUrls TEXT,
            price REAL,
            discount REAL,
            stock INTEGER,
            categoryId TEXT,
            brandId TEXT
          )''',
        );
      });
    }
    return _database!;
  }

  // Insert product into wishlist
  static Future<void> insertProduct(Product product) async {
    final db = await getDatabase();
    await db.insert(
      'wishlist',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Remove product from wishlist
  static Future<void> removeProduct(String productId) async {
    final db = await getDatabase();
    await db.delete(
      'wishlist',
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  // Get all wishlist items
  static Future<List<Product>> getWishlistItems(List<Category> categories, List<Brand> brands) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('wishlist');

    List<Product> products = [];
    for (var map in maps) {
      // Find category and brand based on IDs stored in the product
      Category category = categories.firstWhere((cat) => cat.id == map['categoryId']);
      Brand brand = brands.firstWhere((br) => br.id == map['brandId']);
      products.add(Product.fromMap(map, category: category, brand: brand));
    }
    return products;
  }
}
