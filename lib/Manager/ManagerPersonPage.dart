import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/api/user.dart';
import 'package:parkinglot_frontend/entity/UserMessage.dart';

class ManagerPersonPage extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<ManagerPersonPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserMessage> adminUsers = [];
  List<UserMessage> normalUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      isLoading = true;
    });
    List<UserMessage> users = [];

    try {
      var result = await UserApi().GetUser();
      if (result != null && result['code'] == 200) {
        users.addAll((result['data'] as List)
            .map((json) => UserMessage.fromJson(json))
            .toList());

        setState(() {
          adminUsers = users.where((user) => user.type == 1).toList();
          normalUsers = users.where((user) => user.type == 0).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取用户列表失败')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发生错误: $e')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Material(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: '管理员'),
                Tab(text: '普通用户'),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUserList(adminUsers, true),
                      _buildUserList(normalUsers, false),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddUserDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserList(List<dynamic> users, bool isAdmin) {
    if (users.isEmpty) {
      return Center(child: Text('暂无${isAdmin ? '管理员' : '普通用户'}'));
    }

    return RefreshIndicator(
      onRefresh: _fetchUsers,
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: users.length,
        itemBuilder: (context, index) {
          UserMessage user = users[index];
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Card(
              color: Colors.white,
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.deepPurple[100],
                      child: Text(
                        user.name?.substring(0, 1).toUpperCase() ?? '?',
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name ?? '未知用户',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            user.phone.isEmpty ? '无电话号' : user.phone,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditUserDialog(user),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteConfirmDialog(user),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddUserDialog() {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final emailController = TextEditingController();
    int selectedRole = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('添加新用户'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: '用户名'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: '密码'),
                obscureText: true,
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: '邮箱'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedRole,
                decoration: InputDecoration(labelText: '用户角色'),
                items: [
                  DropdownMenuItem(value: 0, child: Text('普通用户')),
                  DropdownMenuItem(value: 1, child: Text('管理员')),
                ],
                onChanged: (value) {
                  selectedRole = value!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: (){

            },
            // onPressed: () async {
            //   // 添加用户的API调用
            //   try {
            //     var result = await UserApi().addUser({
            //       'username': usernameController.text,
            //       'password': passwordController.text,
            //       'email': emailController.text,
            //       'role': selectedRole,
            //     });
            //
            //     if (result != null && result['code'] == 200) {
            //       Navigator.pop(context);
            //       _fetchUsers();
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(content: Text('用户添加成功')),
            //       );
            //     } else {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(content: Text('用户添加失败: ${result?['message'] ?? '未知错误'}')),
            //       );
            //     }
            //   } catch (e) {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       SnackBar(content: Text('发生错误: $e')),
            //     );
            //   }
            // },
            child: Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(UserMessage user) {
    final usernameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.phone);
    int selectedRole = user.type ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('编辑用户'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: '用户名'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: '邮箱'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedRole,
                decoration: InputDecoration(labelText: '用户角色'),
                items: [
                  DropdownMenuItem(value: 0, child: Text('普通用户')),
                  DropdownMenuItem(value: 1, child: Text('管理员')),
                ],
                onChanged: (value) {
                  selectedRole = value!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: (){

            },
            // onPressed: () async {
            //   // 更新用户的API调用
            //   try {
            //     var result = await UserApi().updateUser(user['id'], {
            //       'username': usernameController.text,
            //       'email': emailController.text,
            //       'role': selectedRole,
            //     });
            //
            //     if (result != null && result['code'] == 200) {
            //       Navigator.pop(context);
            //       _fetchUsers();
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(content: Text('用户更新成功')),
            //       );
            //     } else {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(content: Text('用户更新失败: ${result?['message'] ?? '未知错误'}')),
            //       );
            //     }
            //   } catch (e) {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       SnackBar(content: Text('发生错误: $e')),
            //     );
            //   }
            // },
            child: Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(UserMessage user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认删除'),
        content: Text('确定要删除用户 "${user.name}" 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: (){

            },
            // onPressed: () async {
            //   // 删除用户的API调用
            //   try {
            //     var result = await UserApi().deleteUser(user['id']);
            //
            //     if (result != null && result['code'] == 200) {
            //       Navigator.pop(context);
            //       _fetchUsers();
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(content: Text('用户删除成功')),
            //       );
            //     } else {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(content: Text('用户删除失败: ${result?['message'] ?? '未知错误'}')),
            //       );
            //     }
            //   } catch (e) {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       SnackBar(content: Text('发生错误: $e')),
            //     );
            //   }
            // },
            child: Text('删除', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(UserMessage user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('用户详情'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('用户名'),
              subtitle: Text(user.name),
            ),
            ListTile(
              title: Text('电话号'),
              subtitle: Text(user.phone),
            ),
            ListTile(
              title: Text('角色'),
              subtitle: Text(user.type == 1 ? '管理员' : '普通用户'),
            ),
            ListTile(
              title: Text('注册时间'),
              subtitle: Text('未知'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('关闭'),
          ),
        ],
      ),
    );
  }
}