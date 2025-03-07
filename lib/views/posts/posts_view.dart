import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/app_controller.dart';
import '../../models/user_model.dart';
// import '../../models/post_model.dart';

class PostsView extends StatelessWidget {
  const PostsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController bodyController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('JSONPlaceholder Demo'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search posts...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  onChanged: controller.setPostSearchQuery,
                ),
                const SizedBox(height: 12),
                // User Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Obx(() => FilterChip(
                              label: const Text('All Posts'),
                              selected: controller.selectedUser.value == null,
                              onSelected: (_) =>
                                  controller.setSelectedUser(null),
                              showCheckmark: false,
                              selectedColor:
                                  Theme.of(context).colorScheme.primary,
                              labelStyle: TextStyle(
                                color: controller.selectedUser.value == null
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            )),
                      ),
                      ...controller.users.map((user) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Obx(() => FilterChip(
                                  avatar: CircleAvatar(
                                    backgroundColor:
                                        controller.selectedUser.value?.id ==
                                                user.id
                                            ? Colors.white
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.2),
                                    child: Text(
                                      user.name[0],
                                      style: TextStyle(
                                        color:
                                            controller.selectedUser.value?.id ==
                                                    user.id
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                      ),
                                    ),
                                  ),
                                  label: Text(user.name),
                                  selected: controller.selectedUser.value?.id ==
                                      user.id,
                                  onSelected: (_) =>
                                      controller.setSelectedUser(user),
                                  showCheckmark: false,
                                  selectedColor:
                                      Theme.of(context).colorScheme.primary,
                                  labelStyle: TextStyle(
                                    color: controller.selectedUser.value?.id ==
                                            user.id
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                )),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Posts List
          Expanded(
            child: Obx(
              () => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: controller.filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = controller.filteredPosts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Author Info
                              ListTile(
                                leading: FutureBuilder<User>(
                                  future: controller.getUserById(post.userId),
                                  builder: (context, snapshot) {
                                    return CircleAvatar(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      child: Text(
                                        snapshot.hasData
                                            ? snapshot.data!.name[0]
                                            : '?',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    );
                                  },
                                ),
                                title: FutureBuilder<User>(
                                  future: controller.getUserById(post.userId),
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.hasData
                                          ? snapshot.data!.name
                                          : 'Loading...',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    );
                                  },
                                ),
                                subtitle: Text(
                                  post.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              // Post Content
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Text(
                                  post.body,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              // Action Buttons
                              ButtonBar(
                                alignment: MainAxisAlignment.spaceAround,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.comment_outlined),
                                    label: const Text('Comments'),
                                    onPressed: () {
                                      _showComments(
                                          context, post.id, post.title);
                                    },
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.share_outlined),
                                    label: const Text('Share'),
                                    onPressed: () {
                                      Get.snackbar(
                                        'Share',
                                        'Sharing "${post.title}"',
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        duration: const Duration(seconds: 2),
                                      );
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePostDialog(
            context, titleController, bodyController, controller),
        icon: const Icon(Icons.add),
        label: const Text('New Post'),
      ),
    );
  }

  void _showComments(BuildContext context, int postId, String postTitle) {
    final controller = Get.find<AppController>();
    controller.fetchComments(postId);

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Comments',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              postTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(
                () => controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: controller.comments.length,
                        itemBuilder: (context, index) {
                          final comment = controller.comments[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        child: Text(
                                          comment.name[0].toUpperCase(),
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              comment.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              comment.email,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    comment.body,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  void _showCreatePostDialog(
    BuildContext context,
    TextEditingController titleController,
    TextEditingController bodyController,
    AppController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Create New Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter post title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(
                labelText: 'Content',
                hintText: 'Enter post content',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  bodyController.text.isNotEmpty) {
                controller.createPost(
                    titleController.text, bodyController.text);
                titleController.clear();
                bodyController.clear();
              } else {
                Get.snackbar(
                  'Error',
                  'Please fill in all fields',
                  backgroundColor: Colors.red.shade100,
                );
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}
