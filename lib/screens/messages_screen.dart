import 'package:flutter/material.dart';

import '../data/demo_media.dart';
import '../services/local_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/instagram_image.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  static const _conversations = [
    ('austin.life', 'Sent a photo', '2m', true),
    ('travel.diary', 'That reel is amazing 🔥', '18m', true),
    ('daily.escape', 'Let’s shoot this weekend', '1h', false),
    ('maria', 'You: see you soon ✨', '3h', false),
    ('vinijr', '😂😂😂', '5h', true),
    ('alhilal', 'Matchday tomorrow!', '1d', true),
  ];

  List<(String, String, String, bool)> get _filtered {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _conversations;
    return _conversations
        .where((item) => item.$1.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Text(
              DemoMedia.profileUsername,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AppColors.ink,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'New message',
            onPressed: () => _toast('New message composer'),
            icon: const Icon(Icons.edit_square, size: 22),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AnimatedBuilder(
        animation: LocalAppState.instance,
        builder: (context, _) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search messages',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 21,
                    color: AppColors.muted,
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.muted,
                          ),
                        ),
                ),
              ),
            ),
            _notesRow(),
            const SizedBox(height: 8),
            const Divider(),
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No messages found',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 10, 16, 8),
                          child: Text('MESSAGES', style: AppTheme.sectionLabel),
                        ),
                        for (final conversation in _filtered)
                          _conversationRow(conversation),
                        const SizedBox(height: 24),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notesRow() {
    const notes = [
      ('Your note', 'New note 🌙', true),
      ('vinijr', 'Matchday ⚽️', false),
      ('maria', 'Coffee ☕️', false),
      ('travel.diary', 'On my way', false),
      ('leomessi', '💫', false),
      ('alhilal', 'Let’s go', false),
    ];
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: notes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final note = notes[index];
          return SizedBox(
            width: 70,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    InstagramAvatar(
                      url: note.$3
                          ? DemoMedia.profileAvatarSmall
                          : DemoMedia.avatar(index + 1),
                      size: 58,
                      showRing: note.$3,
                    ),
                    if (note.$3)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.6),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  note.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.inkSoft,
                  ),
                ),
                Text(
                  note.$3 ? 'Your note' : note.$1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.faint,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _conversationRow((String, String, String, bool) conversation) {
    final messages = LocalAppState.instance.messagesByUser[conversation.$1];
    final lastMessage = messages != null && messages.isNotEmpty
        ? 'You: ${messages.last}'
        : conversation.$2;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(username: conversation.$1)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            Stack(
              children: [
                InstagramAvatar(
                  url: DemoMedia.avatarFor(conversation.$1, size: 120),
                  size: 50,
                  showRing: false,
                  isVerified: conversation.$4,
                ),
                if (conversation.$4)
                  Positioned(
                    right: 3,
                    bottom: 3,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.6),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          conversation.$1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      if (conversation.$4)
                        const Padding(
                          padding: EdgeInsets.only(left: 3),
                          child: Icon(
                            Icons.verified_rounded,
                            color: AppColors.blue,
                            size: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: messages != null && messages.isNotEmpty
                          ? AppColors.inkSoft
                          : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  conversation.$3,
                  style: const TextStyle(fontSize: 10.5, color: AppColors.faint),
                ),
                const SizedBox(height: 7),
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 18,
                  color: AppColors.inkSoft,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toast(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.username});

  final String username;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<String> get _messages =>
      LocalAppState.instance.messagesByUser[widget.username] ?? const [];

  Future<void> _send() async {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    LocalAppState.instance.sendMessage(widget.username, value);
    _controller.clear();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
        ),
        title: Row(
          children: [
            InstagramAvatar(
              url: DemoMedia.avatarFor(widget.username, size: 120),
              size: 34,
              showRing: false,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.username,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 3),
                      child: Icon(
                        Icons.verified_rounded,
                        color: AppColors.blue,
                        size: 13,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Active now',
                  style: TextStyle(fontSize: 10.5, color: AppColors.green),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _toast('Audio call'),
            icon: const Icon(Icons.call_outlined, size: 21),
          ),
          IconButton(
            onPressed: () => _toast('Video call'),
            icon: const Icon(Icons.videocam_outlined, size: 22),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: LocalAppState.instance,
              builder: (context, _) => ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                children: [
                  Center(
                    child: ClipOval(
                      child: SizedBox(
                        width: 76,
                        height: 76,
                        child: InstagramImage(
                          url: DemoMedia.avatarFor(widget.username, size: 200),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      widget.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Instagram · 1.2K followers',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text(
                      'Today',
                      style: TextStyle(fontSize: 10.5, color: AppColors.faint),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _Bubble(
                    text: 'Hey! How are you?',
                    mine: false,
                    avatarUrl: '',
                  ),
                  for (final message in _messages)
                    _Bubble(
                      text: message,
                      mine: true,
                      avatarUrl: DemoMedia.profileAvatarSmall,
                    ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.camera_alt_outlined,
                            size: 21,
                            color: AppColors.ink,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _send(),
                              decoration: const InputDecoration(
                                hintText: 'Message…',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: AppColors.blue,
                      size: 23,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toast(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
  );

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.mine,
    required this.avatarUrl,
  });

  final String text;
  final bool mine;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: mine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InstagramAvatar(
                url: avatarUrl.isEmpty ? null : avatarUrl,
                size: 28,
                showRing: false,
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: mine ? AppGradients.brand : null,
                color: mine ? null : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(mine ? 18 : 4),
                  bottomRight: Radius.circular(mine ? 4 : 18),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  color: mine ? Colors.white : AppColors.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
