import 'package:chat_bot/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];

  bool _isLoading = false;

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
  }

  Future<void> initGeminiModel() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    final userMessage = prompt;

    _controller.clear();
    setState(() {
      _messages.add(Message(message: userMessage, isUser: true));
      _isLoading = true;
    });

    try {
      final model = GenerativeModel(
          model: "gemini-2.5-pro", apiKey: dotenv.env['GOOGLE_API_KEY']!);

      final content = [Content.text(userMessage)];
      final response = await model.generateContent(content);

      setState(() {
        _messages.add(Message(message: response.text ?? "", isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        _messages.add(Message(message: "Error: $e", isUser: false));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                FaIcon(
                  color: Colors.blue[300],
                  FontAwesomeIcons.robot,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text('Chatin',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600)),
              ],
            ),
            IconButton(
                onPressed: _clearChat,
                icon: FaIcon(
                  color: Colors.grey[600],
                  FontAwesomeIcons.trash,
                  size: 18,
                )),
          ],
        ),
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ListTile(
                    title: Align(
                      alignment: message.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: message.isUser
                              ? Colors.blue[300]
                              : Colors.grey[300],
                          borderRadius: message.isUser
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                  bottomLeft: Radius.circular(15),
                                )
                              : const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Text(message.message,
                            style: GoogleFonts.plusJakartaSans(
                                color: message.isUser
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  );
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Color(0xFFE5E7E5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                          hintText: 'Ask anything',
                          hintStyle: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w500),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20)),
                      onSubmitted: (text) => initGeminiModel(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _isLoading
                      ? Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(right: 10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue[300]!),
                          ),
                        )
                      : IconButton(
                          onPressed: initGeminiModel,
                          icon: const FaIcon(
                            FontAwesomeIcons.paperPlane,
                            size: 18,
                          ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
