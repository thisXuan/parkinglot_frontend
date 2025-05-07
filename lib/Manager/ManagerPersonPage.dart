import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/api/user.dart';
import 'package:parkinglot_frontend/entity/UserMessage.dart';
import 'package:parkinglot_frontend/utils/util.dart';

class ManagerPersonPage extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<ManagerPersonPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserMessage> adminUsers = [];
  List<UserMessage> normalUsers = [];
  bool isLoading = true;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

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

  List<UserMessage> get _filteredNormalUsers {
    if (_searchText.isEmpty) return normalUsers;
    return normalUsers.where((user) => user.name.contains(_searchText) || user.phone.contains(_searchText)).toList();
  }
  List<UserMessage> get _filteredAdminUsers {
    if (_searchText.isEmpty) return adminUsers;
    return adminUsers.where((user) => user.name.contains(_searchText) || user.phone.contains(_searchText)).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('用户管理', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('管理普通用户和下线管理员', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchText = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: '搜索昵称或手机号...',
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddUserDialog();
                    },
                    icon: Icon(Icons.add),
                    label: Text('添加用户'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Color(0xFF2563EB),
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: '普通用户'),
                    Tab(text: '下线管理员'),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildUserTable(_filteredNormalUsers, false),
                          _buildUserTable(_filteredAdminUsers, true),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTable(List<UserMessage> users, bool isAdmin) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildTableHeaderCell('昵称', width: 120),
                  _buildTableHeaderCell('电话号码', width: 150),
                  _buildTableHeaderCell('状态', width: 100),
                  _buildTableHeaderCell('操作', width: 200, alignRight: true),
                ],
              ),
            ),
          ),
          Expanded(
            child: users.isEmpty
                ? Center(child: Text('暂无数据'))
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildTableCell(user.name ?? '', width: 120),
                              _buildTableCell(user.phone, width: 150),
                              Container(
                                width: 100,
                                child: _buildStatusTag(user.status),
                              ),
                              Container(
                                width: 200,
                                child: Wrap(
                                  alignment: WrapAlignment.end,
                                  spacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      icon: Icon(Icons.edit, size: 16),
                                      label: Text('编辑'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Color(0xFF2563EB),
                                        side: BorderSide(color: Color(0xFF2563EB)),
                                        minimumSize: Size(60, 32),
                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                      ),
                                      onPressed: () => _showEditUserDialog(user),
                                    ),
                                    if (user.status == 1)
                                      ElevatedButton.icon(
                                        icon: Icon(Icons.block, size: 16),
                                        label: Text('拉黑'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          minimumSize: Size(60, 32),
                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                        onPressed: () {
                                          // 拉黑逻辑
                                        },
                                      )
                                    else
                                      OutlinedButton.icon(
                                        icon: Icon(Icons.refresh, size: 16),
                                        label: Text('恢复'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.green,
                                          side: BorderSide(color: Colors.green),
                                          minimumSize: Size(60, 32),
                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                        onPressed: () {
                                          // 恢复逻辑
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text, {double width = 100, bool alignRight = false}) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Align(
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {double width = 100}) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 15, color: Colors.black87),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatusTag(int? status) {
    // 1: 正常，0: 已禁用
    if (status == 1) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: Color(0xFFE6F4EA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Color(0xFF34A853), size: 16),
            SizedBox(width: 4),
            Text('正常', style: TextStyle(color: Color(0xFF34A853), fontSize: 13)),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: Color(0xFFFDEAEA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Color(0xFFEA4335), size: 16),
            SizedBox(width: 4),
            Text('已禁用', style: TextStyle(color: Color(0xFFEA4335), fontSize: 13)),
          ],
        ),
      );
    }
  }

  void _showAddUserDialog() {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final emailController = TextEditingController();
    int selectedRole = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
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
        backgroundColor: Colors.white,
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
                decoration: InputDecoration(labelText: '联系方式'),
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
          ElevatedButton.icon(
            onPressed: () async{
              UserMessage new_user = UserMessage(
                  id: user.id,
                  name: usernameController.text,
                  phone: emailController.text,
                  point: user.point,
                  type: selectedRole,
                  status: 1
              );
              Map<String, dynamic> userMap = {
                'id': new_user.id,
                'name': new_user.name,
                'phone': new_user.phone,
                'point':new_user.point,
                'type':new_user.type
              };
              var result = await UserApi().UpdateUsers(userMap);
              if (result != null && result['code'] == 200) {
                Navigator.pop(context);
                _fetchUsers();
                ElToast.info('用户信息更新成功');
              } else {
                ElToast.info(result['msg']);
              }
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
            icon: Icon(Icons.save),
            label: Text('保存'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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