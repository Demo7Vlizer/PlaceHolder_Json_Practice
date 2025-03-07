import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../models/user_model.dart';
import '../../models/todo_model.dart';

class TodosView extends StatelessWidget {
  const TodosView({super.key});

  void _showUserDetails(BuildContext context, User user) {
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
            ListTile(
              leading: CircleAvatar(
                child: Text(user.name[0]),
              ),
              title: Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(user.email),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(user.phone),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(user.website),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: Text(user.company.name),
              subtitle: Text(user.company.catchPhrase),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text('${user.address.street}, ${user.address.suite}'),
              subtitle: Text('${user.address.city}, ${user.address.zipcode}'),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();

    return Scaffold(
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search todos...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  onChanged: controller.setSearchQuery,
                ),
                const SizedBox(height: 8),
                // Filter Options
                Row(
                  children: [
                    // Filter by Status
                    Obx(() => FilterChip(
                          label: const Text('Completed'),
                          selected: controller.showCompleted.value,
                          onSelected: (_) => controller.toggleShowCompleted(),
                        )),
                    const SizedBox(width: 8),
                    Obx(() => FilterChip(
                          label: const Text('Incomplete'),
                          selected: controller.showIncomplete.value,
                          onSelected: (_) => controller.toggleShowIncomplete(),
                        )),
                    const SizedBox(width: 8),
                    // User Filter Dropdown
                    Expanded(
                      child: Obx(() => DropdownButton<User?>(
                            isExpanded: true,
                            hint: const Text('Filter by user'),
                            value: controller.selectedUser.value,
                            items: [
                              const DropdownMenuItem<User?>(
                                value: null,
                                child: Text('All Users'),
                              ),
                              ...controller.users.map((user) {
                                return DropdownMenuItem<User>(
                                  value: user,
                                  child: Text(
                                    user.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                            ],
                            onChanged: controller.setSelectedUser,
                          )),
                    ),
                  ],
                ),
                // Clear Filters Button
                TextButton.icon(
                  onPressed: controller.clearFilters,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Filters'),
                ),
              ],
            ),
          ),
          // Todos List
          Expanded(
            child: Obx(
              () => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: controller.filteredTodos.length,
                      itemBuilder: (context, index) {
                        final todo = controller.filteredTodos[index];
                        return Dismissible(
                          key: Key(todo.id.toString()),
                          background: Container(
                            color: Colors.green,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.check, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              // Delete functionality would go here in a real app
                              Get.snackbar('Todo Deleted', 'Todo was removed');
                            } else {
                              controller.toggleTodo(
                                controller.todos.indexOf(todo),
                              );
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: Checkbox(
                                value: todo.completed,
                                onChanged: (_) => controller.toggleTodo(
                                  controller.todos.indexOf(todo),
                                ),
                              ),
                              title: Text(
                                todo.title,
                                style: TextStyle(
                                  decoration: todo.completed
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              trailing: FutureBuilder<User>(
                                future: controller.getUserById(todo.userId),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return GestureDetector(
                                      onTap: () => _showUserDetails(
                                          context, snapshot.data!),
                                      child: Chip(
                                        label: Text(snapshot.data!.name),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      // Add new todo button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.dialog(
            AlertDialog(
              title: const Text('Add New Todo'),
              content: TextField(
                decoration: const InputDecoration(
                  hintText: 'Enter todo title',
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    // In a real app, you would make an API call to create the todo
                    final newTodo = Todo(
                      id: controller.todos.length + 1,
                      userId: controller.selectedUser.value?.id ?? 1,
                      title: value,
                      completed: false,
                    );
                    controller.todos.add(newTodo);
                    Get.back();
                    Get.snackbar('Success', 'New todo added');
                  }
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
