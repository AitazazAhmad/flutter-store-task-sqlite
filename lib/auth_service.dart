import 'database_helper.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // User authentication methods
  Future<String> signUp(String email, String password) async {
    try {
      await _dbHelper.insertUser(email, password);
      return 'Success';
    } catch (e) {
      return e.toString();
    }
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    bool isValid = await _dbHelper.validateUser(email, password);
    if (isValid) {
      return {'status': 'Success', 'email': email};
    } else {
      // Check if user exists
      final user = await _dbHelper.getUser(email);
      if (user == null) {
        return {'status': 'User not found'};
      } else {
        return {'status': 'Invalid password'};
      }
    }
  }

  // Product management methods
  Future<String> addProduct({
    required String name,
    required double price,
    required String description,
    required String category,
    required String userEmail,
  }) async {
    try {
      final product = Product(
        name: name,
        price: price,
        description: description,
        category: category,
        userEmail: userEmail,
      );

      await _dbHelper.insertProduct(product);
      return 'Success';
    } catch (e) {
      return 'Failed to add product: $e';
    }
  }

  Future<List<Product>> getUserProducts(String userEmail) async {
    try {
      return await _dbHelper.getUserProducts(userEmail);
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<String> updateProduct({
    required int id,
    required String name,
    required double price,
    required String description,
    required String category,
    required String userEmail,
  }) async {
    try {
      final product = Product(
        id: id,
        name: name,
        price: price,
        description: description,
        category: category,
        userEmail: userEmail,
      );

      final rowsAffected = await _dbHelper.updateProduct(product);

      if (rowsAffected > 0) {
        return 'Success';
      } else {
        return 'Product not found or you do not have permission to update it';
      }
    } catch (e) {
      return 'Failed to update product: $e';
    }
  }

  Future<String> deleteProduct(int id, String userEmail) async {
    try {
      final rowsAffected = await _dbHelper.deleteProduct(id, userEmail);

      if (rowsAffected > 0) {
        return 'Success';
      } else {
        return 'Product not found or you do not have permission to delete it';
      }
    } catch (e) {
      return 'Failed to delete product: $e';
    }
  }

  Future<Product?> getProduct(int id, String userEmail) async {
    try {
      return await _dbHelper.getProduct(id, userEmail);
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }
}
