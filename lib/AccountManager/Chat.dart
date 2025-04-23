import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_uikit/tencent_cloud_chat_uikit.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';

class Chat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TIMUIKitChat(
      conversation: V2TimConversation(
        conversationID: "c2c_test",
        // 单聊："c2c_${对方的userID}" ； 群聊："group_${groupID}"
        userID: "test",
        // 仅单聊需要此字段，对方userID
        groupID: "",
        // 仅群聊需要此字段，群groupID
        showName: "客服",
        // 顶部 AppBar 显示的标题
        type: 1, // 单聊传1，群聊传2
        // 以上是最简化最基础的必要配置，您还可在此指定更多参数配置，根据 V2TimConversation 的注释
      ),
      // ......其他 TIMUIKitChat 的配置参数
    );
  }
}