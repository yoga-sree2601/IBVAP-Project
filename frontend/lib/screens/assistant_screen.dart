import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class _ChatMessage {
  final String text;
  final bool isUser;
  bool animated;
  _ChatMessage({required this.text, required this.isUser, this.animated = false});
}

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      text: "Hello Operator. I am IBVAP Assistant. Ask me about cameras, alerts, or the perimeter fence.",
      isUser: false,
    ));
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _sending = true;
    });
    _controller.clear();
    _scrollToBottom();
    try {
      final api = context.read<ApiService>();
      final reply = await api.assistantChat(text);
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: reply, isUser: false));
        _sending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: "Connection error. Please check the backend link.", isUser: false));
        _sending = false;
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    return Column(children: [
      Expanded(
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _messages.length,
          itemBuilder: (context, i) {
            final m = _messages[i];
            return _MessageBubble(message: m, c: c);
          },
        ),
      ),
      if (_sending)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            const SizedBox(width: 16),
            SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: c.teal)),
            const SizedBox(width: 8),
            Text('Assistant is typing...', style: AppFonts.mono(context, size: 10.5, color: c.textFaint)),
          ]),
        ),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: c.bgElev, border: Border(top: BorderSide(color: c.border))),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: AppFonts.body(context, color: c.text),
              decoration: InputDecoration(
                hintText: 'Ask about cameras, alerts, fence status...',
                filled: true,
                fillColor: c.bg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: c.border)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _sending ? null : _send,
            style: IconButton.styleFrom(backgroundColor: c.teal),
            icon: Icon(Icons.send, size: 18, color: const Color(0xFF06110E)),
          ),
        ]),
      ),
    ]);
  }
}

class _MessageBubble extends StatefulWidget {
  final _ChatMessage message;
  final AppColors c;
  const _MessageBubble({required this.message, required this.c});

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  String _displayed = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.message.isUser || widget.message.animated) {
      _displayed = widget.message.text;
    } else {
      _animateText();
    }
  }

  void _animateText() {
    int i = 0;
    final full = widget.message.text;
    _timer = Timer.periodic(const Duration(milliseconds: 14), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      i++;
      setState(() => _displayed = full.substring(0, i.clamp(0, full.length)));
      if (i >= full.length) {
        t.cancel();
        widget.message.animated = true;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUser;
    final c = widget.c;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(radius: 12, backgroundColor: c.teal, child: Icon(Icons.smart_toy, size: 13, color: const Color(0xFF06110E))),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: isUser ? c.teal.withOpacity(0.15) : c.surface,
                border: Border.all(color: isUser ? c.teal.withOpacity(0.4) : c.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_displayed, style: AppFonts.body(context, size: 13, color: c.text)),
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }
}
