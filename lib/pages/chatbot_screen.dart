import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:rescuein/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  late final GenerativeModel _model;
  late ChatSession _chatSession;
  final List<ChatMessage> _allMessages = [];
  final List<ChatMessage> _contextMessages = []; // Messages sent to API
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _apiKeyAvailable = false;
  
  // Token optimization settings
  static const int maxContextMessages = 20; // Maximum messages to send to API
  static const int maxHistoryMessages = 100; // Maximum messages to store locally
  static const String storageKey = 'sigap_chat_history';

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // 1. Load chat history from storage
    await _loadHistory();

    // 2. Get API Key
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? 'API_KEY_NOT_FOUND';

    if (apiKey.isEmpty) {
      if (mounted) setState(() => _apiKeyAvailable = false);
      return;
    }

    if (mounted) setState(() => _apiKeyAvailable = true);

    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      systemInstruction: Content.system(
        'Anda adalah Asisten P3K virtual dari aplikasi SIGAP. '
        'Berikan jawaban singkat, padat, dan akurat tentang pertolongan pertama dan kesehatan. '
        'Selalu sertakan disclaimer: "Ini bukan pengganti konsultasi dokter. Untuk darurat, hubungi 112." '
        'Tolak sopan pertanyaan di luar topik kesehatan/P3K. '
        'Maksimal 3 paragraf per jawaban.'
      ),
    );

    // 3. Initialize context for API (only recent messages)
    _updateContextMessages();
    
    // 4. Start chat session with limited context
    _chatSession = _model.startChat(
      history: _contextMessages
          .map((msg) => Content(
              msg.isUser ? 'user' : 'model', 
              [TextPart(msg.text)]
            ))
          .toList(),
    );

    // 5. Add welcome message if no history
    if (_allMessages.isEmpty) {
      final welcomeMessage = ChatMessage(
        text: 'Halo! Saya asisten P3K virtual SIGAP. Ada yang bisa saya bantu terkait pertolongan pertama atau kesehatan?',
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      setState(() {
        _allMessages.add(welcomeMessage);
      });
      await _saveHistory();
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessageText = _controller.text.trim();
    _controller.clear();

    // Add user message
    final userMessage = ChatMessage(
      text: userMessageText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _allMessages.add(userMessage);
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // Update context before sending
      _updateContextMessages();
      
      // Create new session with updated context to ensure token efficiency
      _chatSession = _model.startChat(
        history: _contextMessages
            .map((msg) => Content(
                msg.isUser ? 'user' : 'model',
                [TextPart(msg.text)]
              ))
            .toList(),
      );

      final response = await _chatSession.sendMessage(Content.text(userMessageText));
      final responseText = response.text ?? 'Maaf, saya tidak bisa memberikan respons saat ini.';

      // Add bot response
      final botMessage = ChatMessage(
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _allMessages.add(botMessage);
        _isLoading = false;
      });

      await _saveHistory();
      _scrollToBottom();

    } catch (e) {
      final errorMessage = ChatMessage(
        text: 'Maaf, terjadi kesalahan. Pastikan koneksi internet stabil dan coba lagi.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _allMessages.add(errorMessage);
        _isLoading = false;
      });

      await _saveHistory();
      _scrollToBottom();
    }
  }

  // Update context messages for API (token optimization)
  void _updateContextMessages() {
    _contextMessages.clear();
    
    // Get recent messages for context (excluding welcome message if it's the only one)
    List<ChatMessage> recentMessages = _allMessages
        .where((msg) => !(msg.text.contains('Halo! Saya asisten') && _allMessages.length > 1))
        .toList();

    // Take only the most recent messages to stay within token limits
    if (recentMessages.length > maxContextMessages) {
      recentMessages = recentMessages.sublist(recentMessages.length - maxContextMessages);
    }

    _contextMessages.addAll(recentMessages);
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Limit stored messages to prevent storage bloat
      List<ChatMessage> messagesToSave = _allMessages;
      if (_allMessages.length > maxHistoryMessages) {
        // Keep welcome message + recent messages
        final welcomeMsg = _allMessages.first;
        final recentMessages = _allMessages.sublist(_allMessages.length - maxHistoryMessages + 1);
        messagesToSave = [welcomeMsg, ...recentMessages];
        
        // Update current messages list
        setState(() {
          _allMessages.clear();
          _allMessages.addAll(messagesToSave);
        });
      }
      
      final List<String> historyJson = messagesToSave
          .map((m) => jsonEncode(m.toJson()))
          .toList();
      
      await prefs.setStringList(storageKey, historyJson);
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? historyJson = prefs.getStringList(storageKey);
      
      if (historyJson != null && historyJson.isNotEmpty) {
        final messages = historyJson
            .map((json) => ChatMessage.fromJson(jsonDecode(json)))
            .toList();
        
        setState(() {
          _allMessages.addAll(messages);
        });
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  Future<void> _clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(storageKey);
      
      setState(() {
        _allMessages.clear();
        _contextMessages.clear();
      });
      
      // Add welcome message back
      final welcomeMessage = ChatMessage(
        text: 'Halo! Saya asisten P3K virtual SIGAP. Ada yang bisa saya bantu terkait pertolongan pertama atau kesehatan?',
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      setState(() {
        _allMessages.add(welcomeMessage);
      });
      
      await _saveHistory();
      
      // Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Riwayat chat berhasil dihapus'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }

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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chatbot SIGAP'),
            if (_allMessages.length > 1)
              Text(
                '${_allMessages.length - 1} pesan tersimpan',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        elevation: 2,
        actions: [
          if (_allMessages.length > 1)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear') {
                  _showClearHistoryDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline),
                      SizedBox(width: 8),
                      Text('Hapus Riwayat'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: !_apiKeyAvailable
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'API Key Gemini belum diatur.\nHarap tambahkan GEMINI_API_KEY ke dalam file .env Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _allMessages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isLoading && index == _allMessages.length) {
                        return _buildTypingIndicator();
                      }
                      final message = _allMessages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
                ),
                _buildInputField(),
              ],
            ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat Chat'),
        content: const Text('Apakah Anda yakin ingin menghapus semua riwayat percakapan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearHistory();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: primaryColor,
              child: const Icon(Icons.support_agent, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: message.isUser ? primaryColor : cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: largeRadius.topLeft,
                  topRight: largeRadius.topRight,
                  bottomLeft: Radius.circular(message.isUser ? 12 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 12),
                ),
                boxShadow: [lightShadow],
              ),
              child: MarkdownBody(
                data: message.text,
                selectable: true,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: bodyMediumTextStyle.copyWith(
                    color: message.isUser ? whiteColor : textPrimaryColor,
                  ),
                  listBullet: bodyMediumTextStyle.copyWith(
                    color: message.isUser ? whiteColor : textPrimaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, boxShadow: [strongShadow]),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: bodyMediumTextStyle,
                decoration: InputDecoration(
                  hintText: 'Ketik pertanyaan kesehatan Anda...',
                  hintStyle: bodyMediumTextStyle.copyWith(color: textTertiaryColor),
                  border: OutlineInputBorder(
                    borderRadius: largeRadius,
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: largeRadius,
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: largeRadius,
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: backgroundLight,
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _isLoading ? null : _sendMessage(),
                enabled: !_isLoading,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _isLoading ? null : _sendMessage,
              icon: const Icon(Icons.send),
              style: IconButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: whiteColor,
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.all(12),
              ),
              tooltip: 'Kirim pesan',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: primaryColor,
            child: const Icon(Icons.support_agent, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: largeRadius,
                boxShadow: [lightShadow],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Asisten sedang mengetik...', style: bodySmallTextStyle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json['text'],
        isUser: json['isUser'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

