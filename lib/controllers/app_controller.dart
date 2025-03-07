import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/todo_model.dart';
import '../models/photo_model.dart';
import '../services/api_service.dart';

class AppController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxList<User> users = <User>[].obs;
  final RxList<Post> posts = <Post>[].obs;
  final RxList<Comment> comments = <Comment>[].obs;
  final RxList<Todo> todos = <Todo>[].obs;
  final RxList<Photo> photos = <Photo>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentIndex = 0.obs;

  // Cache for avatars and post images
  final RxMap<int, String> userAvatars = <int, String>{}.obs;
  final RxMap<int, String> postImages = <int, String>{}.obs;

  // Search and filter
  final RxString searchQuery = ''.obs;
  final RxString postSearchQuery = ''.obs;
  final RxBool showCompleted = true.obs;
  final RxBool showIncomplete = true.obs;
  final Rx<User?> selectedUser = Rx<User?>(null);

  // Computed lists
  List<Todo> get filteredTodos => todos.where((todo) {
        // Filter by completion status
        if (!showCompleted.value && todo.completed) return false;
        if (!showIncomplete.value && !todo.completed) return false;

        // Filter by selected user
        if (selectedUser.value != null &&
            todo.userId != selectedUser.value!.id) {
          return false;
        }

        // Filter by search query
        if (searchQuery.isNotEmpty) {
          return todo.title
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());
        }

        return true;
      }).toList();

  List<Post> get filteredPosts => posts.where((post) {
        // Filter by selected user
        if (selectedUser.value != null &&
            post.userId != selectedUser.value!.id) {
          return false;
        }

        // Filter by search query
        if (postSearchQuery.isNotEmpty) {
          return post.title
                  .toLowerCase()
                  .contains(postSearchQuery.value.toLowerCase()) ||
              post.body
                  .toLowerCase()
                  .contains(postSearchQuery.value.toLowerCase());
        }

        return true;
      }).toList();

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    fetchPosts();
    fetchTodos();
    fetchPhotos();
  }

  Future<String> getUserAvatar(int userId) async {
    if (!userAvatars.containsKey(userId)) {
      userAvatars[userId] = await _apiService.getUserAvatar(userId);
    }
    return userAvatars[userId]!;
  }

  Future<String> getPostImage(int postId) async {
    if (!postImages.containsKey(postId)) {
      postImages[postId] = await _apiService.getPostImage(postId);
    }
    return postImages[postId]!;
  }

  Future<void> fetchPhotos() async {
    try {
      photos.value = await _apiService.getPhotos();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load photos');
    }
  }

  void setPostSearchQuery(String query) {
    postSearchQuery.value = query;
  }

  void toggleTodo(int index) {
    final todo = todos[index];
    final updatedTodo = Todo(
      id: todo.id,
      userId: todo.userId,
      title: todo.title,
      completed: !todo.completed,
    );
    todos[index] = updatedTodo;
    Get.snackbar(
      'Todo Updated',
      updatedTodo.completed ? 'Task completed!' : 'Task marked as incomplete',
      duration: const Duration(seconds: 1),
    );
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void toggleShowCompleted() {
    showCompleted.value = !showCompleted.value;
  }

  void toggleShowIncomplete() {
    showIncomplete.value = !showIncomplete.value;
  }

  void setSelectedUser(User? user) {
    selectedUser.value = user;
  }

  void clearFilters() {
    searchQuery.value = '';
    postSearchQuery.value = '';
    showCompleted.value = true;
    showIncomplete.value = true;
    selectedUser.value = null;
  }

  Future<void> createPost(String title, String body) async {
    try {
      // In a real app, you would make an API call here
      final newPost = Post(
        id: posts.length + 1,
        userId: selectedUser.value?.id ?? 1,
        title: title,
        body: body,
      );
      posts.insert(0, newPost); // Add to beginning of list
      Get.back();
      Get.snackbar(
        'Success',
        'Post created successfully',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to create post');
    }
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      users.value = await _apiService.getUsers();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load users');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPosts() async {
    try {
      isLoading.value = true;
      posts.value = await _apiService.getPosts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load posts');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchComments(int postId) async {
    try {
      isLoading.value = true;
      comments.value = await _apiService.getComments(postId: postId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load comments');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Post>> getUserPosts(int userId) async {
    try {
      return await _apiService.getPostsByUserId(userId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user posts');
      return [];
    }
  }

  Future<void> fetchTodos() async {
    try {
      isLoading.value = true;
      todos.value = await _apiService.getTodos();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load todos');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Todo>> getUserTodos(int userId) async {
    try {
      return await _apiService.getTodosByUserId(userId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user todos');
      return [];
    }
  }

  Future<User> getUserById(int id) async {
    try {
      return await _apiService.getUserById(id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user');
      throw Exception('Failed to load user');
    }
  }
}
