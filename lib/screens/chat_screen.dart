import 'package:flutter/material.dart';
import 'dart:async';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final ChatConversation conversation;
  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    AppState.addMessage(widget.conversation.id, text, isMe: true);
    _msgController.clear();
    _scrollToBottom();

    // Simulate smart auto-reply response to feel dynamic!
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        String replyText = "Alright! Let me know if you need any other details about the item.";
        if (text.toLowerCase().contains("avail") || text.toLowerCase().contains("buy")) {
          replyText = "Yes, it is still available! Would you like to meet on campus to check it out?";
        } else if (text.toLowerCase().contains("meet") || text.toLowerCase().contains("where")) {
          replyText = "Let's meet at the Central Library lobby tomorrow at 2:00 PM.";
        } else if (text.toLowerCase().contains("price") || text.toLowerCase().contains("discount")) {
          replyText = "I can go down by \$2.00, but no more since it is in like-new condition!";
        }
        
        AppState.addMessage(widget.conversation.id, replyText, isMe: false);
        _scrollToBottom();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Mark conversation read
    widget.conversation.unreadCount = 0;
    _scrollToBottom();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: AppTheme.bgCard,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 54,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: AppTheme.bgCard, 
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderMedium, width: 1.5),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 14),
              ),
            ),
          ),
        ),
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                gradient: AppTheme.bgHeaderGradient,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                widget.conversation.userName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.userName,
                    style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.2),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.conversation.productTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppTheme.textLight, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.phone_outlined, color: AppTheme.textMedium),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert_rounded, color: AppTheme.textMedium),
          ),
        ],
        shape: Border(bottom: BorderSide(color: AppTheme.borderMedium, width: 1.5)),
      ),
      body: Column(
        children: [
          // Msg Stream
          Expanded(
            child: ValueListenableBuilder<List<ChatMessage>>(
              valueListenable: widget.conversation.messagesNotifier,
              builder: (context, messages, child) {
                _scrollToBottom();
                return ListView.builder(
                  controller: _scrollController,
                  key: ValueKey(messages.length),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          // Input field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgCard, 
              border: Border(top: BorderSide(color: AppTheme.borderMedium, width: 1.5)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Attachment Icon
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderMedium, width: 1.5),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      icon: Icon(Icons.attach_file_rounded, color: AppTheme.textMedium, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Text Area
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.borderMedium, width: 1.5),
                      ),
                      child: TextField(
                        controller: _msgController,
                        minLines: 1,
                        maxLines: 4,
                        onSubmitted: (_) => _sendMessage(),
                        style: TextStyle(color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                          hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.normal),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Send icon
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.shadowSmall,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
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

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: msg.isMe ? AppTheme.primary : Colors.white,
          border: msg.isMe ? null : Border.all(color: AppTheme.borderMedium, width: 1.5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: msg.isMe ? const Radius.circular(20) : Radius.zero,
            bottomRight: msg.isMe ? Radius.zero : const Radius.circular(20),
          ),
          boxShadow: AppTheme.shadowSmall,
        ),
        child: Column(
          crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.message,
              style: TextStyle(
                color: msg.isMe ? Colors.white : AppTheme.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              msg.time,
              style: TextStyle(
                color: msg.isMe ? Colors.white.withOpacity(0.7) : AppTheme.textLight,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
