// chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For clipboard copy
import 'ai_service.dart';

/// Chat message model
class ChatMessage {
  final String role;
  String content;
  final DateTime timestamp;
  bool isFavorite;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.isFavorite = false,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  bool _isSearching = false;
  String _searchQuery = "";
  List<ChatMessage> get _filteredMessages {
    if (!_isSearching || _searchQuery.isEmpty) return _messages;
    return _messages
        .where((msg) => msg.content.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  /// Send the message to the AI and add the response
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _addMessage(ChatMessage(role: 'user', content: text));
    _controller.clear();

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await AIService.sendMessageToAI(text);
      _addMessage(ChatMessage(role: 'assistant', content: response));
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = "Error: $e";
      });
      _addMessage(ChatMessage(
        role: 'assistant',
        content: "Sorry, we couldn't get a valid response. Please try again.",
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  /// Add a new message and scroll to the bottom
  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  /// Scroll the list to the bottom
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Show options for a long-pressed message
  void _showMessageOptions(ChatMessage message, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Message'),
              onTap: () {
                setState(() {
                  _messages.removeAt(index);
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Message'),
              onTap: () {
                Navigator.pop(context);
                _editMessage(message, index);
              },
            ),
            ListTile(
              leading: Icon(message.isFavorite ? Icons.star : Icons.star_border),
              title: Text(message.isFavorite ? 'Unfavorite' : 'Favorite Message'),
              onTap: () {
                setState(() {
                  message.isFavorite = !message.isFavorite;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Message'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.content));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.forward),
              title: const Text('Forward Message'),
              onTap: () {
                Navigator.pop(context);
                // You could integrate an external sharing mechanism here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message forwarded')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text('Save Message'),
              onTap: () {
                Navigator.pop(context);
                // Implement saving to a local database or favorites
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message saved')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply to Message'),
              onTap: () {
                Navigator.pop(context);
                // Place reply text in the input field
                _controller.text = "Replying to: ${message.content}\n";
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Resend Message'),
              onTap: () {
                Navigator.pop(context);
                if (message.role == 'user') {
                  _sendMessage();
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Edit an existing message
  void _editMessage(ChatMessage message, int index) {
    final editController = TextEditingController(text: message.content);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Message'),
          content: TextField(
            controller: editController,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Type your edited message...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  message.content = editController.text.trim();
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Start a new conversation (clear current chat)
  void _newConversation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Conversation'),
          content: const Text(
              'Are you sure you want to start a new conversation? The current chat will be cleared.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _messages.clear();
                });
                Navigator.pop(context);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  /// Clear all messages
  void _clearConversation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Chat'),
          content: const Text('Are you sure you want to delete all messages?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _messages.clear();
                });
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Start searching messages
  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  /// Stop searching and reset the message list
  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = "";
    });
  }

  /// Build UI for each chat message
  Widget _buildMessageItem(ChatMessage message) {
    final bool isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            CircleAvatar(
              backgroundColor: Colors.teal[700],
              child: const Icon(Icons.android, color: Colors.white),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: isUser ? Colors.teal[100] : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isUser ? const Radius.circular(12) : const Radius.circular(0),
                  bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                  if (message.isFavorite)
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              backgroundColor: Colors.teal[700],
              child: const Icon(Icons.person, color: Colors.white),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search messages...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        )
            : const Text('AI Assistant'),
        backgroundColor: Colors.teal[700],
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              if (_isSearching) {
                _stopSearch();
              } else {
                _startSearch();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear Chat',
            onPressed: _clearConversation,
          ),
          IconButton(
            icon: const Icon(Icons.note_add),
            tooltip: 'New Conversation',
            onPressed: _newConversation,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _filteredMessages.length,
              itemBuilder: (context, index) {
                final message = _filteredMessages[index];
                return GestureDetector(
                  onLongPress: () {
                    final originalIndex = _messages.indexOf(message);
                    _showMessageOptions(message, originalIndex);
                  },
                  child: _buildMessageItem(message),
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(width: 10),
                  Text('Please wait...')
                ],
              ),
            ),
          if (_hasError)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                    padding: const EdgeInsets.all(14),
                  ),
                  onPressed: _isLoading ? null : _sendMessage,
                  child: const Icon(Icons.send, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
