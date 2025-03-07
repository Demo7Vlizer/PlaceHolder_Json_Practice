# Flutter GetX with JSONPlaceholder API Demo

A Flutter project demonstrating the implementation of GetX state management and REST API integration using JSONPlaceholder API.

## Project Structure

```
lib/
├── models/              # Data models
│   ├── user_model.dart
│   ├── post_model.dart
│   ├── comment_model.dart
│   ├── todo_model.dart
│   └── photo_model.dart
│
├── controllers/         # GetX controllers
│   └── app_controller.dart
│
├── services/           # API and other services
│   └── api_service.dart
│
├── views/             # UI screens
│   ├── home/
│   ├── posts/
│   ├── users/
│   └── todos/
│
└── main.dart         # App entry point
```

## GetX Implementation Guide

### 1. State Management with GetX

#### Reactive State (.obs)
```dart
// In controller
final RxList<Post> posts = <Post>[].obs;
final RxBool isLoading = false.obs;
final RxString searchQuery = ''.obs;

// In view
Obx(() => controller.isLoading.value 
  ? CircularProgressIndicator()
  : YourWidget())
```

#### Controller Setup
```dart
class AppController extends GetxController {
  // Initialize variables
  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  // Computed properties
  List<Post> get filteredPosts => posts.where((post) {
    // Filter logic
  }).toList();
}
```

### 2. Dependency Injection

```dart
// Inject controller
void main() {
  Get.put(AppController());
  runApp(MyApp());
}

// Use controller in views
final controller = Get.find<AppController>();
```

### 3. Navigation

```dart
// Navigate to new screen
Get.to(() => PostsView());

// Show bottom sheet
Get.bottomSheet(YourWidget());

// Show dialog
Get.dialog(AlertDialog());

// Show snackbar
Get.snackbar('Title', 'Message');
```

## API Integration with GetX

### 1. API Service Setup

```dart
class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Post>> getPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      }
      throw Exception('Failed to load posts');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
```

### 2. Controller-Service Integration

```dart
class AppController extends GetxController {
  final ApiService _apiService = ApiService();
  final RxList<Post> posts = <Post>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> fetchPosts() async {
    try {
      isLoading.value = true;
      posts.value = await _apiService.getPosts();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
```

### 3. Model Class Example

```dart
class Post {
  final int id;
  final String title;
  final String body;

  Post({
    required this.id,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}
```

## Key Features Demonstrated

1. **State Management**
   - Reactive state with `.obs`
   - Computed properties
   - State persistence
   - Loading states

2. **API Integration**
   - RESTful API calls
   - Error handling
   - Data modeling
   - JSON parsing

3. **UI Components**
   - List views with cards
   - Search functionality
   - Filtering
   - Bottom sheets
   - Dialogs

4. **GetX Features**
   - Dependency injection
   - Route management
   - Snackbars
   - Dialog boxes
   - Bottom sheets

## Best Practices

1. **File Structure**
   - Separate concerns (models, views, controllers)
   - Keep files focused and small
   - Use proper naming conventions

2. **State Management**
   - Use `.obs` for reactive state
   - Implement computed properties for derived state
   - Keep controllers focused on specific features

3. **API Integration**
   - Centralize API calls in service classes
   - Proper error handling
   - Use models for type safety
   - Cache responses when appropriate

4. **Code Organization**
   - Follow SOLID principles
   - Use dependency injection
   - Keep widgets small and focused
   - Extract reusable widgets

## Getting Started

1. Clone the repository
2. Run `flutter pub get`
3. Run the app with `flutter run`

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  http: ^1.1.0
  cached_network_image: ^3.3.0
```

## Resources

- [GetX Documentation](https://github.com/jonataslaw/getx)
- [JSONPlaceholder API](https://jsonplaceholder.typicode.com/)
- [Flutter Documentation](https://flutter.dev/docs)

## Advanced GetX Concepts

### 1. GetX Controllers Lifecycle
```dart
class AdvancedController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Called when controller is initialized
  }

  @override
  void onReady() {
    super.onReady();
    // Called after onInit, when the widget is rendered
  }

  @override
  void onClose() {
    // Called when controller is deleted from memory
    super.onClose();
  }
}
```

### 2. GetX Bindings
```dart
class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.put(ApiService(), permanent: true);
  }
}

// In routes
GetPage(
  name: '/home',
  page: () => HomeView(),
  binding: HomeBinding(),
)
```

### 3. Advanced State Management

#### Workers
```dart
class WorkerController extends GetxController {
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Called every time count changes
    ever(count, (_) => print('Count changed'));
    
    // Called once when count changes
    once(count, (_) => print('First time only'));
    
    // Called after user stops typing for 1 second
    debounce(
      count,
      (_) => print('Stopped changing'),
      time: Duration(seconds: 1),
    );
    
    // Called every 1 second during changes
    interval(
      count,
      (_) => print('Interval'),
      time: Duration(seconds: 1),
    );
  }
}
```

#### GetBuilder (for memory optimization)
```dart
class LightController extends GetxController {
  int count = 0;

  void increment() {
    count++;
    update(); // Manually notify listeners
  }
}

// In view
GetBuilder<LightController>(
  builder: (controller) => Text('${controller.count}'),
)
```

### 4. GetX Service Pattern
```dart
class StorageService extends GetxService {
  Future<StorageService> init() async {
    await loadSettings();
    return this;
  }
}

// Initialize in main
await Get.putAsync(() => StorageService().init());
```

## Advanced API Integration

### 1. Interceptors with GetX
```dart
class ApiInterceptor extends GetConnect {
  @override
  void onInit() {
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Authorization'] = 'Bearer token';
      return request;
    });

    httpClient.addResponseModifier<dynamic>((request, response) {
      if (response.statusCode == 401) {
        Get.toNamed('/login');
      }
      return response;
    });
  }
}
```

### 2. Caching Strategy
```dart
class CacheService extends GetxService {
  final cache = <String, dynamic>{}.obs;

  Future<T> getCachedData<T>(
    String key,
    Future<T> Function() fetchData,
    Duration expiry,
  ) async {
    if (cache.containsKey(key)) {
      final cachedData = cache[key] as CachedItem<T>;
      if (!cachedData.isExpired()) {
        return cachedData.data;
      }
    }
    
    final data = await fetchData();
    cache[key] = CachedItem(data, expiry);
    return data;
  }
}
```

## Design Patterns with GetX

### 1. Repository Pattern
```dart
abstract class IPostRepository {
  Future<List<Post>> getPosts();
  Future<Post> getPost(int id);
}

class PostRepository implements IPostRepository {
  final ApiService _api;
  
  PostRepository(this._api);
  
  @override
  Future<List<Post>> getPosts() async {
    try {
      return await _api.getPosts();
    } catch (e) {
      throw RepositoryException(e.toString());
    }
  }
}
```

### 2. Service Locator Pattern
```dart
class DependencyInjection {
  static void init() {
    // API
    Get.put(ApiService(), permanent: true);
    
    // Repositories
    Get.put<IPostRepository>(
      PostRepository(Get.find<ApiService>()),
      permanent: true,
    );
    
    // Controllers
    Get.lazyPut(() => PostController(Get.find()));
  }
}
```

### 3. Command Pattern with GetX
```dart
abstract class Command {
  Future<void> execute();
  Future<void> undo();
}

class AddPostCommand implements Command {
  final PostController controller;
  final Post post;

  AddPostCommand(this.controller, this.post);

  @override
  Future<void> execute() async {
    await controller.addPost(post);
  }

  @override
  Future<void> undo() async {
    await controller.removePost(post);
  }
}
```

## Testing with GetX

### 1. Controller Testing
```dart
void main() {
  group('PostController Tests', () {
    late PostController controller;
    late MockPostRepository mockRepository;

    setUp(() {
      mockRepository = MockPostRepository();
      controller = PostController(mockRepository);
    });

    test('should load posts', () async {
      when(mockRepository.getPosts())
          .thenAnswer((_) async => [Post(id: 1, title: 'Test')]);

      await controller.fetchPosts();

      expect(controller.posts.length, 1);
      expect(controller.isLoading.value, false);
    });
  });
}
```

### 2. Widget Testing with GetX
```dart
testWidgets('PostView shows posts', (tester) async {
  final binding = BindingsBuilder(() {
    Get.put<PostController>(PostController(MockPostRepository()));
  });

  await tester.pumpWidget(
    GetMaterialApp(
      home: PostView(),
      initialBinding: binding,
    ),
  );

  expect(find.byType(ListView), findsOneWidget);
});
```

## Performance Optimization

### 1. Memory Management
- Use `GetBuilder` for simple state updates
- Implement `dispose` methods
- Use `permanent: true` only when necessary
- Clear controllers when not needed

### 2. Widget Optimization
```dart
// Use GetView for controller access
class PostView extends GetView<PostController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
      itemCount: controller.posts.length,
      itemBuilder: (context, index) {
        return PostCard(post: controller.posts[index]);
      },
    ));
  }
}

// Use const constructors
class PostCard extends StatelessWidget {
  const PostCard({Key? key, required this.post}) : super(key: key);
  final Post post;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(post.title),
      ),
    );
  }
}
```

## Error Handling and Logging

### 1. Global Error Handling
```dart
class ErrorHandler extends GetxController {
  void handleError(dynamic error) {
    if (error is NetworkException) {
      Get.snackbar('Network Error', error.message);
    } else if (error is ValidationException) {
      Get.dialog(ErrorDialog(error: error));
    } else {
      Get.snackbar('Error', 'An unexpected error occurred');
    }
  }
}
```

### 2. Custom Exception Handling
```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}
```

## Additional Learning Resources

- [GetX Patterns and Best Practices](https://github.com/kauemurakami/getx_pattern)
- [Advanced Flutter State Management](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options)
- [Clean Architecture with Flutter](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Testing Guide](https://flutter.dev/docs/testing)

## Contributing

Feel free to submit issues and enhancement requests!

## Flutter & GetX for Beginners

### What is GetX? 🤔
GetX is like a Swiss Army knife for Flutter - it helps you:
- Manage your app's data (State Management)
- Move between screens (Navigation)
- Show pop-ups and messages (Dialog & Snackbar)
- Keep your code organized (Dependency Injection)

### Basic Concepts Explained Simply 📚

#### 1. State Management (How to store and update data)
```dart
// Think of this like a box that holds your data
final count = 0.obs;  // .obs means "observable" - GetX watches this value

// When you want to change the value
count.value = 1;  // GetX automatically updates your screen!

// To show it on screen
Obx(() => Text('Count: ${count.value}'))  // Updates whenever count changes
```

#### 2. Navigation (Moving between screens)
```dart
// Go to a new screen
Get.to(() => SecondScreen());  // Like turning to a new page in a book

// Go back
Get.back();  // Like pressing the back button

// Show a message
Get.snackbar(
  'Hello!',  // Title
  'This is a message',  // Message
);  // Shows a pop-up message at the top of the screen
```

#### 3. Simple Controller Example
```dart
// A controller is like a manager for your screen
class SimpleController extends GetxController {
  // Store data
  final items = <String>[].obs;
  
  // Add an item
  void addItem(String item) {
    items.add(item);  // Automatically updates the screen
  }
  
  // Remove an item
  void removeItem(String item) {
    items.remove(item);
  }
}
```

### Common Tasks Made Easy 🛠️

#### 1. Loading Data from the Internet
```dart
// In your controller
final isLoading = false.obs;
final data = <String>[].obs;

Future<void> loadData() async {
  isLoading.value = true;  // Show loading spinner
  try {
    final result = await ApiService().getData();
    data.value = result;  // Update the data
  } catch (e) {
    Get.snackbar('Error', 'Could not load data');
  }
  isLoading.value = false;  // Hide loading spinner
}
```

#### 2. Building a Simple List
```dart
Obx(() => ListView.builder(
  itemCount: controller.items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(controller.items[index]),
      onTap: () => print('Tapped item $index'),
    );
  },
))
```

### Tips for Beginners 💡

1. **Start Small**
   - Begin with simple state management
   - Add features one at a time
   - Don't try to use every GetX feature at once

2. **Common Patterns**
   - Put related data in controllers
   - Use `.obs` for data that changes
   - Keep UI code in separate files from logic

3. **Debugging Tips**
   - Use `print` statements to track changes
   - Check if `.obs` variables are updating
   - Make sure controllers are initialized

### Step-by-Step Project Setup 🚀

1. **Create a New Project**
   ```bash
   flutter create my_app
   cd my_app
   ```

2. **Add GetX to pubspec.yaml**
   ```yaml
   dependencies:
     get: ^4.6.6
   ```

3. **Basic App Structure**
   ```dart
   // main.dart
   void main() {
     runApp(
       GetMaterialApp(  // Use GetMaterialApp instead of MaterialApp
         home: HomePage(),
       ),
     );
   }
   ```

4. **Create Your First Screen**
   ```dart
   class HomePage extends StatelessWidget {
     final controller = Get.put(SimpleController());  // Add controller
     
     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: Text('My First GetX App')),
         body: Center(
           child: Obx(() => Text('Items: ${controller.items.length}')),
         ),
       );
     }
   }
   ```

### Learning Path 📝

1. **Day 1-2**: Basic State Management
   - Learn about `.obs` variables
   - Create simple controllers
   - Update UI with Obx

2. **Day 3-4**: Navigation
   - Move between screens
   - Show dialogs and snackbars
   - Pass data between screens

3. **Day 5-7**: API Integration
   - Make HTTP requests
   - Show loading states
   - Handle errors

4. **Week 2+**: Advanced Features
   - Dependency injection
   - Route management
   - Complex state management

### Need Help? 🆘

- Check the [GetX documentation](https://github.com/jonataslaw/getx/blob/master/README.md)
- Join Flutter Discord communities
- Practice with small example projects
- Don't be afraid to ask questions!

Remember: Everyone starts somewhere! Take your time to understand each concept before moving to the next one. Happy coding! 🎉
