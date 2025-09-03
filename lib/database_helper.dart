import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Product {
  final int? id;
  final String name;
  final double price;
  final String description;
  final String category;
  final String userEmail;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.userEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'user_email': userEmail,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      description: map['description'],
      category: map['category'],
      userEmail: map['user_email'],
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'grocery_store.db');
    return await openDatabase(
      path,
      version: 2, // Increased version for schema changes
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');

    // Create products table
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT,
        category TEXT,
        user_email TEXT NOT NULL,
        FOREIGN KEY (user_email) REFERENCES users (email) ON DELETE CASCADE
      )
    ''');

    // Create index for better performance when querying user products
    await db.execute('''
      CREATE INDEX idx_products_user_email ON products (user_email)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Upgrade from version 1 to 2: Add products table
      await db.execute('''
        CREATE TABLE products(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          price REAL NOT NULL,
          description TEXT,
          category TEXT,
          user_email TEXT NOT NULL,
          FOREIGN KEY (user_email) REFERENCES users (email) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE INDEX idx_products_user_email ON products (user_email)
      ''');
    }
  }

  // User management methods
  Future<int> insertUser(String email, String password) async {
    final db = await database;
    try {
      return await db.insert('users', {
        'email': email,
        'password': password,
      }, conflictAlgorithm: ConflictAlgorithm.fail);
    } catch (e) {
      throw Exception('User already exists');
    }
  }

  Future<Map<String, dynamic>?> getUser(String email) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<bool> validateUser(String email, String password) async {
    final user = await getUser(email);
    if (user != null && user['password'] == password) {
      return true;
    }
    return false;
  }

  // Product management methods
  Future<int> insertProduct(Product product) async {
    final db = await database;
    try {
      return await db.insert(
        'products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } catch (e) {
      throw Exception('Failed to insert product: $e');
    }
  }

  Future<List<Product>> getUserProducts(String userEmail) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'user_email = ?',
      whereArgs: [userEmail],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ? AND user_email = ?',
      whereArgs: [product.id, product.userEmail],
    );
  }

  Future<int> deleteProduct(int id, String userEmail) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ? AND user_email = ?',
      whereArgs: [id, userEmail],
    );
  }

  Future<Product?> getProduct(int id, String userEmail) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'products',
      where: 'id = ? AND user_email = ?',
      whereArgs: [id, userEmail],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return Product.fromMap(results.first);
    }
    return null;
  }

  // Close the database connection
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
