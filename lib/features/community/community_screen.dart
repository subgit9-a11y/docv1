import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:doctro/theme/ayureze_theme.dart';
import 'package:doctro/theme/app_motion.dart';
import 'package:doctro/widgets/osler_button.dart';
import 'package:doctro/widgets/osler_card.dart';
import 'package:doctro/widgets/osler_input.dart';
import 'package:doctro/widgets/osler_tag.dart';
import 'package:doctro/features/community/community_controller.dart';
import 'package:doctro/features/community/community_filter.dart';
import 'package:doctro/features/community/models/community_post.dart';
import 'package:doctro/features/community/models/workshop.dart';

class CommunityScreen extends StatefulWidget {
  final CommunityController controller;

  const CommunityScreen({super.key, required this.controller});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  CommunityPostCategory? _category;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AyurezeTheme.canvas,
        appBar: AppBar(
          backgroundColor: AyurezeTheme.canvas,
          elevation: 0,
          foregroundColor: AyurezeTheme.textPrimary,
          title: const Text('Health Community & Resource'),
          bottom: TabBar(
            labelColor: AyurezeTheme.healingGreen100,
            unselectedLabelColor: AyurezeTheme.textSecondary,
            indicatorColor: AyurezeTheme.healingGreenFill,
            tabs: const [
              Tab(text: 'Community'),
              Tab(text: 'Resource'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AyurezeTheme.healingGreenFill,
          onPressed: () => _showAddPostSheet(context),
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedAdd01, color: Colors.white),
          label:
              const Text('Add New Post', style: TextStyle(color: Colors.white)),
        ),
        body: TabBarView(
          children: [
            _CommunityFeedTab(
              controller: widget.controller,
              category: _category,
              onCategorySelected: (category) =>
                  setState(() => _category = category),
            ),
            _ResourceTab(workshops: widget.controller.workshops),
          ],
        ),
      ),
    );
  }

  void _showAddPostSheet(BuildContext context) {
    final contentController = TextEditingController();
    var category = CommunityPostCategory.health;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AyurezeTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AyurezeTheme.radius2xl)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: AyurezeTheme.spaceXl,
            right: AyurezeTheme.spaceXl,
            top: AyurezeTheme.spaceXl,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom +
                AyurezeTheme.spaceXl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add New Post',
                  style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: AyurezeTheme.spaceLg),
              Wrap(
                spacing: AyurezeTheme.spaceSm,
                children: [
                  for (final option in CommunityPostCategory.values)
                    ChoiceChip(
                      label: Text(_categoryLabel(option)),
                      selected: category == option,
                      onSelected: (_) => setSheetState(() => category = option),
                    ),
                ],
              ),
              const SizedBox(height: AyurezeTheme.spaceLg),
              OslerInput(
                label: 'Post Content',
                hint: "What's on your mind?",
                controller: contentController,
              ),
              const SizedBox(height: AyurezeTheme.space2xl),
              OslerButton(
                text: 'Continue',
                onPressed: () {
                  if (contentController.text.trim().isEmpty) return;
                  widget.controller.addPost(
                    authorName: 'You',
                    content: contentController.text.trim(),
                    category: category,
                  );
                  Navigator.of(sheetContext).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _categoryLabel(CommunityPostCategory category) {
  switch (category) {
    case CommunityPostCategory.disease:
      return 'Disease';
    case CommunityPostCategory.health:
      return 'Health';
    case CommunityPostCategory.doctor:
      return 'Doctor';
    case CommunityPostCategory.workshop:
      return 'Workshop';
  }
}

class _CommunityFeedTab extends StatelessWidget {
  final CommunityController controller;
  final CommunityPostCategory? category;
  final ValueChanged<CommunityPostCategory?> onCategorySelected;

  const _CommunityFeedTab({
    required this.controller,
    required this.category,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final posts = filterCommunityPosts(controller.posts, category: category);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AyurezeTheme.spaceLg),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final option in CommunityPostCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(right: AyurezeTheme.spaceSm),
                    child: ChoiceChip(
                      label: Text(_categoryLabel(option)),
                      selected: category == option,
                      onSelected: (_) => onCategorySelected(
                          category == option ? null : option),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: posts.isEmpty
              ? Center(
                  child: Text(
                    'No posts yet in this category.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AyurezeTheme.textSecondary),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                      AyurezeTheme.spaceXl, 0, AyurezeTheme.spaceXl, 96),
                  itemCount: posts.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AyurezeTheme.spaceSm),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return ScreenEntrance(
                      index: index,
                      child: _PostCard(
                        post: post,
                        liked: controller.isLiked(post.id),
                        onLike: () => controller.toggleLike(post.id),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPost post;
  final bool liked;
  final VoidCallback onLike;

  const _PostCard({
    required this.post,
    required this.liked,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return OslerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AyurezeTheme.healingGreen10,
                child: Text(
                  post.authorName.isNotEmpty ? post.authorName[0] : '?',
                  style: const TextStyle(color: AyurezeTheme.healingGreen100),
                ),
              ),
              const SizedBox(width: AyurezeTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      _timeAgo(post.postedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AyurezeTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              OslerTag(label: _categoryLabel(post.category)),
            ],
          ),
          const SizedBox(height: AyurezeTheme.spaceMd),
          Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AyurezeTheme.spaceMd),
          Row(
            children: [
              GestureDetector(
                onTap: onLike,
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedFavourite,
                      color: liked
                          ? AyurezeTheme.remoteRed50
                          : AyurezeTheme.iconPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text('${post.likes}'),
                  ],
                ),
              ),
              const SizedBox(width: AyurezeTheme.spaceLg),
              HugeIcon(
                icon: HugeIcons.strokeRoundedComment01,
                color: AyurezeTheme.iconPrimary,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text('${post.comments}'),
              const Spacer(),
              HugeIcon(
                icon: HugeIcons.strokeRoundedBookmark01,
                color: AyurezeTheme.iconPrimary,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _ResourceTab extends StatelessWidget {
  final List<Workshop> workshops;

  const _ResourceTab({required this.workshops});

  @override
  Widget build(BuildContext context) {
    if (workshops.isEmpty) {
      return Center(
        child: Text(
          'No workshops available right now.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AyurezeTheme.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AyurezeTheme.spaceXl),
      itemCount: workshops.length,
      separatorBuilder: (_, __) => const SizedBox(height: AyurezeTheme.spaceSm),
      itemBuilder: (context, index) {
        final workshop = workshops[index];
        return ScreenEntrance(
          index: index,
          child: OslerCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WorkshopDetailScreen(workshop: workshop),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AyurezeTheme.caringViolet10,
                    shape: BoxShape.circle,
                  ),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedUserGroup,
                    color: AyurezeTheme.caringViolet100,
                  ),
                ),
                const SizedBox(width: AyurezeTheme.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(workshop.title,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        'By ${workshop.hostName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AyurezeTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${workshop.entryPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WorkshopDetailScreen extends StatelessWidget {
  final Workshop workshop;

  const WorkshopDetailScreen({super.key, required this.workshop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AyurezeTheme.canvas,
      appBar: AppBar(
        backgroundColor: AyurezeTheme.canvas,
        elevation: 0,
        foregroundColor: AyurezeTheme.textPrimary,
        title: const Text('Workshop Detail'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AyurezeTheme.spaceXl),
        children: [
          Text(workshop.title,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AyurezeTheme.spaceSm),
          Text(
            'By ${workshop.hostName}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AyurezeTheme.textSecondary),
          ),
          const SizedBox(height: AyurezeTheme.spaceLg),
          Text('Workshop Overview',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AyurezeTheme.spaceSm),
          Text(workshop.overview, style: Theme.of(context).textTheme.bodyLarge),
          if (workshop.agenda.isNotEmpty) ...[
            const SizedBox(height: AyurezeTheme.spaceLg),
            Text('Agenda', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AyurezeTheme.spaceSm),
            for (final item in workshop.agenda)
              Padding(
                padding: const EdgeInsets.only(bottom: AyurezeTheme.spaceXs),
                child: Text('- $item',
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
          ],
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AyurezeTheme.spaceXl),
        child: OslerButton(
          text: 'Entry Price \$${workshop.entryPrice.toStringAsFixed(2)}',
          onPressed: null,
        ),
      ),
    );
  }
}
