import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/todo_model.dart';
import '../models/photo_model.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // Users
  Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    }
    throw Exception('Failed to load users');
  }

  // Posts
  Future<List<Post>> getPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    }
    throw Exception('Failed to load posts');
  }

  // Comments
  Future<List<Comment>> getComments({int? postId}) async {
    final url = postId != null
        ? '$baseUrl/posts/$postId/comments'
        : '$baseUrl/comments';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Comment.fromJson(json)).toList();
    }
    throw Exception('Failed to load comments');
  }

  // Get user by ID
  Future<User> getUserById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$id'));
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load user');
  }

  // Get posts by user ID
  Future<List<Post>> getPostsByUserId(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId/posts'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    }
    throw Exception('Failed to load user posts');
  }

  // Get todos
  Future<List<Todo>> getTodos() async {
    final response = await http.get(Uri.parse('$baseUrl/todos'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Todo.fromJson(json)).toList();
    }
    throw Exception('Failed to load todos');
  }

  // Get todos by user ID
  Future<List<Todo>> getTodosByUserId(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId/todos'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Todo.fromJson(json)).toList();
    }
    throw Exception('Failed to load user todos');
  }

  // Get photos
  Future<List<Photo>> getPhotos() async {
    final response = await http.get(Uri.parse('$baseUrl/photos'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Photo.fromJson(json)).toList();
    }
    throw Exception('Failed to load photos');
  }

  // Get user avatar (returns a random photo for the user)
  Future<String> getUserAvatar(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/photos/$userId'));
      if (response.statusCode == 200) {
        final photo = Photo.fromJson(json.decode(response.body));
        return photo.thumbnailUrl;
      }
      return 'https://via.placeholder.com/150';
    } catch (e) {
      return 'https://via.placeholder.com/150';
    }
  }

  // Get post image (returns a random photo for the post)
  Future<String> getPostImage(int postId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/photos/$postId'));
      if (response.statusCode == 200) {
        final photo = Photo.fromJson(json.decode(response.body));
        return photo.url;
      }
      return 'https://via.placeholder.com/600/92c952';
    } catch (e) {
      return 'https://via.placeholder.com/600/92c952';
    }
  }
}
