import 'package:drivo_app/core/helpers/price_converter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:drivo_app/features/service_provider/product/data/model/product_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'drivo.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE addresses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        address TEXT,
        latitude REAL,
        longitude REAL,
        isDefault INTEGER DEFAULT 0,
        additionalInfo TEXT
      )
    ''');
    await _createFavoritesTable(db);
  }

  Future<int> insertAddress(Map<String, dynamic> address) async {
    final db = await database;
    return await db.insert('addresses', address);
  }

  Future<List<Map<String, dynamic>>> getAddresses() async {
    final db = await database;
    return await db.query('addresses', orderBy: 'isDefault DESC');
  }

  Future<int> updateAddress(Map<String, dynamic> address) async {
    final db = await database;
    return await db.update(
      'addresses',
      address,
      where: 'id = ?',
      whereArgs: [address['id']],
    );
  }

  Future<int> deleteAddress(int id) async {
    final db = await database;
    return await db.delete(
      'addresses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> setDefaultAddress(int id) async {
    final db = await database;
    await db.update('addresses', {'isDefault': 0});
    return await db.update(
      'addresses',
      {'isDefault': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

extension FavoriteDatabase on DatabaseService {
  Future<void> _createFavoritesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorites(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        exchange REAL,
        imageUrl TEXT,
        category TEXT,
        productData TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertFavorite(ProductModel product) async {
    final db = await database;
    return await db.insert(
      'favorites',
      {
        'id': product.id ?? '',
        'name': product.name,
        'price': PriceConverter.convertToYemeni(
            saudiPrice: product.exchangeRate ?? 1, exchangeRate: product.price),
        'imageUrl': product.imageUrl,
        'category': product.category,
        'exchange': product.exchangeRate ?? 1,
        'productData': product.toJsonString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> removeFavorite(String productId) async {
    final db = await database;
    return await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<List<ProductModel>> getFavoriteProducts() async {
    final db = await database;
    final favorites = await db.query('favorites');
    return favorites.map((e) {
      try {
        return ProductModel.fromJsonString(e['productData'] as String);
      } catch (error) {
        print('Error parsing favorite product: $error');
        return ProductModel(
          id: e['id'] as String? ?? '',
          name: e['name'] as String? ?? 'Unknown',
          price: e['price'] as double? ?? 0.0,
          isAvailable: false,
          restaurantId: '',
          imageUrl: e['imageUrl'] as String?,
          category: e['category'] as String?,
        );
      }
    }).toList();
  }

  Future<void> clearFavorites() async {
    final db = await database;
    await db.delete('favorites');
  }

  Future<bool> isFavorite(String productId) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [productId],
    );
    return result.isNotEmpty;
  }
}
