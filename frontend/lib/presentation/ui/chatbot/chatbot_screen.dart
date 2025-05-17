import 'package:app/services/network/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  String _selectedLanguage = 'en';

  final Map<String, Map<String, String>> translations = {
    'en': {
      'title': '👨🏾‍🌾 Farmer Chatbot',
      'hint': 'Enter your message...',
      'copy': 'Copy',
      'copied': 'Copied to clipboard',
      'edit': 'Edit',
      'delete': 'Delete',
      'edit_message': 'Edit Message',
      'edit_hint': 'Edit your message...',
      'cancel': 'Cancel',
      'save': 'Save',
    },
    'am': {
      'title': '👨🏾‍🌾 የገበሬ ቻትቦት',
      'hint': 'መልእክት ያስገቡ...',
      'copy': 'ቅዳ',
      'copied': 'ወደ ቅዳ ተቀዳጁት ተቀምጧል',
      'edit': 'አርትዕ',
      'delete': 'ሰርዝ',
      'edit_message': 'መልእክት አርትዕ',
      'edit_hint': 'መልእክትህን አርትዕ...',
      'cancel': 'አቋርጥ',
      'save': 'አስቀምጥ',
    },
    'om': {
      'title': '👨🏾‍🌾 Gargaarsa Qonnaan Bultoota',
      'hint': 'Ergaa barreessi...',
      'copy': 'Dubbisi',
      'copied': 'Clipboard irratti dubbifama',
      'edit': 'Gulaali',
      'delete': 'Haquu',
      'edit_message': 'Ergaa gulaali',
      'edit_hint': 'Ergaa keessan gulaali...',
      'cancel': 'Haquu',
      'save': 'Qusadhu',
    },
    'ti': {
      'title': '👨🏾‍🌾 የሰብ ሓረስተኛ ቻትቦት',
      'hint': 'መልእኽቲ ኣእትዉ...',
      'copy': 'ቅዳጅ',
      'copied': 'ናብ ቅዳጅ ተኣቲሩ ኣሎ',
      'edit': 'ስራሕ',
      'delete': 'ሰርዝ',
      'edit_message': 'መልእኽቲ ውጢ',
      'edit_hint': 'መልእኽቲኻ ስራሕ...',
      'cancel': 'ሕጸብ',
      'save': 'ቀምጥ',
    }
  };

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': message});
      _controller.clear();
    });

    try {
      final dio = DioClient.getDio();
      final response = await dio.post(
        '/chatbot',
        data: {
          'message': message,
          'language': _selectedLanguage,
        },
      );

      if (response.statusCode == 200) {
        final botText = (response.data['response'] ?? '').toString();
        setState(() {
          _messages.add({'sender': 'bot', 'text': botText});
        });
      } else {
        setState(() {
          _messages.add({
            'sender': 'bot',
            'text': 'Server error: ${response.statusCode}'
          });
        });
      }
    } on DioException catch (e) {
      final errorMsg = e.response != null
          ? 'Error ${e.response!.statusCode}'
          : 'Failed to connect to backend';
      setState(() {
        _messages.add({'sender': 'bot', 'text': errorMsg});
      });
    }
  }

  void _showMessageOptions(int index, BuildContext context) {
    final message = _messages[index];
    final isUser = message['sender'] == 'user';
    final lang = translations[_selectedLanguage]!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuButton(
              icon: Icons.content_copy,
              text: lang['copy']!,
              onTap: () {
                Clipboard.setData(ClipboardData(text: message['text'] ?? ''));
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(lang['copied']!)));
              },
            ),
            if (isUser)
              _buildMenuButton(
                icon: Icons.edit,
                text: lang['edit']!,
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(index);
                },
              ),
            _buildMenuButton(
              icon: Icons.delete,
              text: lang['delete']!,
              onTap: () {
                setState(() => _messages.removeAt(index));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [Icon(icon), const SizedBox(width: 16), Text(text)]),
        ),
      );

  void _showEditDialog(int index) {
    final lang = translations[_selectedLanguage]!;
    final editController =
        TextEditingController(text: _messages[index]['text']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(lang['edit_message']!),
        content: TextField(
          controller: editController,
          maxLines: 3,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: lang['edit_hint']!,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang['cancel']!),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _messages[index]['text'] = editController.text);
              Navigator.pop(context);
            },
            child: Text(lang['save']!),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = translations[_selectedLanguage]!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text(
          lang['title']!,
          style: GoogleFonts.notoSansEthiopic(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).focusColor,
            fontSize: 16,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButton<String>(
              value: _selectedLanguage,
              dropdownColor: Theme.of(context).indicatorColor,
              icon: Icon(Icons.language, color: Theme.of(context).focusColor),
              underline: const SizedBox(),
              onChanged: (v) => setState(() => _selectedLanguage = v!),
              items: [
                DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(color: Theme.of(context).focusColor))),
                DropdownMenuItem(value: 'am', child: Text('አማርኛ', style: TextStyle(color: Theme.of(context).focusColor))),
                DropdownMenuItem(value: 'om', child: Text('Afaan Oromoo', style: TextStyle(color: Theme.of(context).focusColor))),
                DropdownMenuItem(value: 'ti', child: Text('ትግርኛ', style: TextStyle(color: Theme.of(context).focusColor))),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['sender'] == 'user';
                  return GestureDetector(
                    onSecondaryTap: () => _showMessageOptions(index, context),
                    onLongPress: () => _showMessageOptions(index, context),
                    child: Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 0),
                            bottomRight: Radius.circular(isUser ? 0 : 16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            )
                          ],
                        ),
                        child: Text(
                          message['text'] ?? '',
                          style: GoogleFonts.notoSansEthiopic(fontSize: 16, color: Theme.of(context).focusColor),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.green[100],
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: GoogleFonts.notoSansEthiopic(),
                      decoration: InputDecoration(
                        hintText: lang['hint'],
                        hintStyle: GoogleFonts.notoSansEthiopic(),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
