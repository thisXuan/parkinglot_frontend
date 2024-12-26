import 'package:flutter/material.dart';
import 'package:parkinglot_frontend/CarSearch/FindMyCar.dart';
import 'package:parkinglot_frontend/CarSearch/Payment.dart';
import 'package:parkinglot_frontend/Navigation/IndoorNavigation.dart';
import 'dart:async';
import 'package:parkinglot_frontend/api/parking.dart';
import 'package:parkinglot_frontend/Tabs.dart';
import 'package:parkinglot_frontend/utils/util.dart';
import 'package:intl/intl.dart';
import 'package:parkinglot_frontend/api/parking.dart';

class CarPage extends StatefulWidget {
  @override
  _CarPageState createState() => _CarPageState();
}

class _CarPageState extends State<CarPage> {
  final List<TextEditingController> _controllers = List.generate(8, (index) => TextEditingController());
  bool _isNewEnergy = false; // 标识是否为新能源车
  String _errorText = '';

  final PageController _pageController = PageController(initialPage: 1000);
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // 自动轮播图片，确保始终从右往左滑动
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300), // 动画时长
          curve: Curves.easeInOut,              // 动画曲线
        );
      }
    });
  }

  // 校验车牌号
  bool isValidPlate(String plate, bool isNewEnergy) {
    final normalPlateRegex = RegExp(
        r'^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵青藏川宁琼使][A-Z][A-HJ-NP-Z0-9]{5}$');
    final newEnergyPlateRegex = RegExp(
        r'^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵青藏川宁琼使][A-Z][A-HJ-NP-Z0-9]{6}$');
    return isNewEnergy
        ? newEnergyPlateRegex.hasMatch(plate)
        : normalPlateRegex.hasMatch(plate);
  }

  List<Widget> _buildCarPlateInput() {
    final plateLength = _isNewEnergy ? 8 : 7;
    List<Widget> inputs = [];

    for (int i = 0; i < plateLength; i++) {
      inputs.add(_buildSquareInput(i));
      if (i == 1) {
        // 在第二个和第三个之间添加点号
        inputs.add(
          Text(
            '·',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        );
      }
    }
    return inputs;
  }

  Widget _buildSquareInput(int index) {
    return SizedBox(
      width: 40.0,
      height: 50.0,
      child: TextField(
        controller: _controllers[index],
        maxLength: 1,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          counterText: '',
        ),
        onChanged: (value) {
          if (value.length == 1 && index < (_isNewEnergy ? 7 : 6)) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }

  void handleConfirm() async{
    FocusScope.of(context).unfocus();

    final plateLength = _isNewEnergy ? 8 : 7;
    final plate = _controllers
        .take(plateLength)
        .map((c) => c.text.trim())
        .join();

    if (!isValidPlate(plate, _isNewEnergy)) {
      setState(() {
        _errorText = '请输入有效的中国车牌号';
      });
      return;
    }

    var result = await ParkingApi().GetParkingTimeAndLocation(plate);

    if(result!=null){
      var code = result['code'];
      var message = result['data'];
      var msg = result['msg'];
      if (code == 200) {
        var parkingTime = message['parkingTime'];
        var location = message['location'];

        DateTime parsedTime = DateTime.parse(parkingTime);
        String formattedTime = DateFormat('yyyy年MM月dd日 HH:mm:ss').format(parsedTime);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("停车信息"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("进场时间: $formattedTime"),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text("停车位置: $location"),
                    SizedBox(width: 8,),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Tabs(location: location),
                          ),
                        );
                      },
                      child: Text(
                        "到这去",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("确定"),
              ),
            ],
          ),
        );
      } else {
        ElToast.info(msg.toString());
      }
    }

  }

  void showParkingRules(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '会员停车权益说明',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '[龙湖重庆源著天街停车场营业期间停车规定]\n'
                        '1.燃油及新能源车：2元/小时，进场后前15分钟免费，超过15分钟按1小时为1个计时单位，不足1小时按照1小时收取，24小时内封顶10元，24小时后重新计时。\n'
                        '2.缴费后离场时间超过30分钟将重新开始计费，为避免再次计费，请在支付成功30分钟内离场。\n'
                        '3.如机器故障，离场时无法识别车辆信息，可用出口缴费机对讲按钮联系停车场工作人员。\n'
                        '4.停车发票：龙湖天街程序缴费-停车-开具发票\n'
                        '5.具体停车收费标准，以商场官方公告为准。在法律允许范围内，商场保留最终解释权。',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            // 添加关闭按钮
            Positioned(
              top: 8.0,
              right: 8.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context); // 关闭底部弹窗
                },
                child: Icon(
                  Icons.close,
                  size: 24.0,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconWithLabel(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // 点击触发回调
      child: Column(
        children: [
          Center(
            child: Icon(
              icon,
              color: Colors.black,
              size: 25,
            ),
          ),
          SizedBox(height: 6), // 图标和文字的间距
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> ifPayment() async {
    var result = await ParkingApi().GetPayment();
    if(result!=null){
      var code = result['code'];
      var msg = result['msg'];
      var data = result['data'];
      if(code==200){
        if(data.isEmpty){
          ElToast.info("未找到缴费记录");
          return;
        }else{
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentPage(),
            ),
          );
        }
      }else{
        ElToast.info(msg);
        return;
      }
    }
  }

  Future<void> ifHasCar() async {
    var result = await ParkingApi().GetMyCar();
    if(result!=null){
      var code = result['code'];
      var msg = result['msg'];
      var data = result['data'];
      if(code==200){
        if(data.isEmpty){
          ElToast.info("未找到车辆绑定记录");
          return;
        }else{
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FindmycarPage(),
            ),
          );
        }
      }else{
        ElToast.info(msg);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 轮播图部分
              SizedBox(
                height: 150.0,
                child: PageView.builder(
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    // 模拟无限循环，通过索引取模
                    final imageIndex = index % 2;
                    return Image.asset(
                      'assets/regularImage/IMG${imageIndex + 1}.jpg', // 替换为你的图片路径
                      fit: BoxFit.fill,
                    );
                  },
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                '请输入车牌号：',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Checkbox(
                    value: _isNewEnergy,
                    onChanged: (value) {
                      setState(() {
                        _isNewEnergy = value!;
                        // 重置所有输入框
                        for (var controller in _controllers) {
                          controller.clear();
                        }
                      });
                    },
                  ),
                  Text('新能源车'),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _buildCarPlateInput(),
              ),
              if (_errorText.isNotEmpty) ...[
                SizedBox(height: 8.0),
                Text(
                  _errorText,
                  style: TextStyle(color: Colors.red),
                ),
              ],
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: handleConfirm,
                  child: Text('查询'),
                ),
              ),
              SizedBox(height: 8,),
              Center(
                child: GestureDetector(
                  onTap: () => showParkingRules(context),
                  child: Text(
                    '会员停车权益说明>',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildIconWithLabel('缴费记录', Icons.receipt_long,(){
                    ifPayment();
                  }),
                  _buildIconWithLabel('我的车辆', Icons.directions_car,(){
                    ifHasCar();
                  }),
                  _buildIconWithLabel('开具发票', Icons.receipt,(){
                    ElToast.info("敬请期待");
                  }),
                  _buildIconWithLabel('月租办理', Icons.calendar_today,(){
                    ElToast.info("敬请期待");
                  }),
                  _buildIconWithLabel('免密支付', Icons.lock_open,(){
                    ElToast.info("敬请期待");
                  }),
                ],
              ),
            ],
          ),
        )
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
    _timer.cancel();
    _pageController.dispose();
  }
}