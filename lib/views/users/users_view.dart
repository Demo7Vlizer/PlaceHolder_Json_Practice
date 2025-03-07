// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../models/todo_model.dart';

class UsersView extends StatelessWidget {
  const UsersView({super.key});

  void _showUserStats(
      BuildContext context, User user, List<Post> posts, List<Todo> todos) {
    final completedTodos = todos.where((todo) => todo.completed).length;
    final pendingTodos = todos.length - completedTodos;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'User Statistics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(
                  icon: Icons.article,
                  title: 'Posts',
                  value: posts.length.toString(),
                  color: Colors.blue,
                ),
                _StatCard(
                  icon: Icons.check_circle,
                  title: 'Completed',
                  value: completedTodos.toString(),
                  color: Colors.green,
                ),
                _StatCard(
                  icon: Icons.pending_actions,
                  title: 'Pending',
                  value: pendingTodos.toString(),
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();

    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                // Implement user search functionality
              },
            ),
          ),
          // Users List
          Expanded(
            child: Obx(
              () => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: controller.users.length,
                      itemBuilder: (context, index) {
                        final user = controller.users[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: Text(user.name[0]),
                            ),
                            title: Text(user.name),
                            subtitle: Text(user.email),
                            children: [
                              ListTile(
                                leading: const Icon(Icons.phone),
                                title: Text(user.phone),
                                onTap: () {
                                  // Launch phone call intent
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.language),
                                title: Text(user.website),
                                onTap: () {
                                  // Launch website
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.business),
                                title: Text(user.company.name),
                                subtitle: Text(user.company.catchPhrase),
                              ),
                              ListTile(
                                leading: const Icon(Icons.location_on),
                                title: Text(
                                    '${user.address.street}, ${user.address.suite}'),
                                subtitle: Text(
                                    '${user.address.city}, ${user.address.zipcode}'),
                                onTap: () {
                                  // Launch maps with coordinates
                                  final lat = user.address.geo.lat;
                                  final lng = user.address.geo.lng;
                                  // Implement map launch
                                },
                              ),
                              ButtonBar(
                                alignment: MainAxisAlignment.spaceAround,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.post_add),
                                    label: const Text('Posts'),
                                    onPressed: () async {
                                      final posts = await controller
                                          .getUserPosts(user.id);
                                      Get.bottomSheet(
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                '${user.name}\'s Posts',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge,
                                              ),
                                              const SizedBox(height: 16),
                                              Expanded(
                                                child: ListView.builder(
                                                  itemCount: posts.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final post = posts[index];
                                                    return Card(
                                                      child: ListTile(
                                                        title: Text(
                                                          post.title,
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        subtitle:
                                                            Text(post.body),
                                                        trailing: IconButton(
                                                          icon: const Icon(
                                                              Icons.comment),
                                                          onPressed: () {
                                                            controller
                                                                .fetchComments(
                                                                    post.id);
                                                            // Show comments in another bottom sheet
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.checklist),
                                    label: const Text('Todos'),
                                    onPressed: () async {
                                      final todos = await controller
                                          .getUserTodos(user.id);
                                      final posts = await controller
                                          .getUserPosts(user.id);
                                      _showUserStats(
                                          context, user, posts, todos);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
