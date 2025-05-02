import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parkinglot_frontend/utils/util.dart';

class Message {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  String _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(
        content: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _messageController.clear();
    _scrollToBottom();

    await _subscription?.cancel();

    final uri = Uri.parse('http://192.168.1.12:5001/api/workstation/agent');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
    };

    final body = jsonEncode({
      'query': text,
      'session_id': _sessionId,
      'history': _messages.map((msg) => {
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.content,
      }).toList(),
    });

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: body,
      );
      print('请求回应为：${response.statusCode}');

      if (response.statusCode == 200) {
        String accumulatedResponse = jsonDecode(response.body)['content'].toString();
        print(accumulatedResponse);
        setState(() {
          _messages.add(Message(
            content: accumulatedResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _messages.add(Message(
          content: "消息发送失败，请稍后再试。",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('智能客服'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    String imageURL = message.isUser?"assets/Client.png":"assets/ChatRobot.png";
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if(!message.isUser)
            Image.asset(
                imageURL,
                width: 50,
                height: 50,
                fit: BoxFit.cover
            ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7, // 限制消息气泡最大宽度
            ),
            decoration: BoxDecoration(
              color: message.isUser ? Colors.blue[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 4.0),
                Text(
                  '${message.timestamp.hour}:${message.timestamp.minute}',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            )
          ),
          if(message.isUser)
            Image.asset(
                imageURL,
                width: 50,
                height: 50,
                fit: BoxFit.cover
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -2),
            blurRadius: 4.0,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '请输入消息...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
              ),
              maxLines: null,
            ),
          ),
          SizedBox(width: 8.0),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                _sendMessage(_messageController.text);
              }
            },
          ),
        ],
      ),
    );
  }
}