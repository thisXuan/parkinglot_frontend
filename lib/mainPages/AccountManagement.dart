import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/RegisterAndLogin/Login.dart';

class accountPage extends StatefulWidget {
  _accountPageState createState() => _accountPageState();
}

// TODO:没有加上用户登录状态管理
class _accountPageState extends State<accountPage> {
  List menuTitles = [
    '我的消息',
    '浏览记录',
    '我的问答',
    '我的活动',
    '邀请好友',
  ];
  List menuIcons = [
    Icons.message,
    Icons.print,
    Icons.phone,
    Icons.send,
    Icons.person,
  ];
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              color: Colors.deepPurple,
             height: 160.0,
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 GestureDetector(
                   child: Container(
                     width: 60.0,
                     height:60.0,
                     decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         border: Border.all(
                           color:Colors.white,
                           width: 2.0,
                         ),
                         image: DecorationImage(
                             image: AssetImage('assets/user.png'),
                             fit: BoxFit.cover
                         )
                     ),
                   ),
                   onTap: (){
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => LoginPage()),
                     );
                   },
                 ),
                 SizedBox(
                   height: 10,
                 ),
                 Text(
                   "点击头像登录",
                   style: TextStyle(color: Colors.white),
                 )
               ],
             ),
            );
          }
          index -= 1;
          return ListTile(
            leading: Icon(menuIcons[index]), //左图标
            title: Text(menuTitles[index]), //中间标题
            trailing: Icon(Icons.arrow_forward_ios),
          );
        },
        separatorBuilder: (context, index) {
          return Divider();
        }, //分隔线
        itemCount: menuTitles.length + 1);
  }

}
