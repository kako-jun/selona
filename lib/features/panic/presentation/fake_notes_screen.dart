import 'package:flutter/material.dart';

/// Fake notes screen for panic mode
class FakeNotesScreen extends StatefulWidget {
  final VoidCallback onExit;

  const FakeNotesScreen({
    super.key,
    required this.onExit,
  });

  @override
  State<FakeNotesScreen> createState() => _FakeNotesScreenState();
}

class _FakeNotesScreenState extends State<FakeNotesScreen> {
  final _controller = TextEditingController(
    text: 'Shopping List\n\n- Milk\n- Bread\n- Eggs\n- Butter\n- Coffee\n\nTODO:\n- Call mom\n- Pay bills\n- Clean room',
  );

  // Secret exit: triple tap on title
  int _titleTapCount = 0;
  DateTime? _lastTapTime;

  void _onTitleTap() {
    final now = DateTime.now();
    if (_lastTapTime != null && now.difference(_lastTapTime!).inMilliseconds < 500) {
      _titleTapCount++;
      if (_titleTapCount >= 3) {
        widget.onExit();
        _titleTapCount = 0;
      }
    } else {
      _titleTapCount = 1;
    }
    _lastTapTime = now;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFAE6),
        elevation: 0,
        title: GestureDetector(
          onTap: _onTitleTap,
          child: const Text(
            'Notes',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black54),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _controller,
          maxLines: null,
          expands: true,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            height: 1.5,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Start typing...',
            hintStyle: TextStyle(color: Colors.black38),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFFFFAE6),
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.check_box_outline_blank, color: Colors.black54),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.format_list_bulleted, color: Colors.black54),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.image_outlined, color: Colors.black54),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.mic_none, color: Colors.black54),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
