import 'package:flutter/material.dart';
import 'dart:async';

class StorePaymentPage extends StatefulWidget {
  final double amount; // 接收支付金额参数

  const StorePaymentPage({Key? key, required this.amount}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<StorePaymentPage> {
  String selectedPayment = 'alipay'; // 默认选择支付宝支付
  double discount = 15.39; // 自定义的折扣金额
  Timer? _timer;
  int _timeLeft = 15 * 60; // 15分钟，以秒为单位

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          timer.cancel();
          showTimeoutDialog();
        }
      });
    });
  }

  void showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Text(
          '支付时间已超过15分钟，请重新下单',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.only(
          top: 20,
          bottom: 10,
          left: 24,
          right: 24,
        ),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // 关闭对话框
                      Navigator.pop(context); // 返回上一页
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      minimumSize: Size(0, 44),
                    ),
                    child: Text(
                      '确定',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // 添加确认退出的方法
  Future<bool> _showExitConfirmDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          '确定要退出支付吗？',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.only(
          top: 20,
          bottom: 10,
          left: 24,
          right: 24,
        ),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.deepOrange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      minimumSize: Size(0, 44),
                    ),
                    child: Text(
                      '取消',
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      minimumSize: Size(0, 44),
                    ),
                    child: Text(
                      '确认',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () async {
            if (await _showExitConfirmDialog()) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text('订单', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 订单金额显示
                      Container(
                        padding: EdgeInsets.all(16),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Text(
                              '¥${widget.amount/100}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '交易将在剩余时间 ${formatTime(_timeLeft)}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1),
                      // 支付方式列表
                      Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('支付方式', style: TextStyle(fontSize: 16)),
                            ),
                            // 支付宝支付选项
                            _buildPaymentOption(
                              'alipay',
                              '支付宝支付',
                              'assets/alipay_icon.png',
                              '招商银行储蓄卡(1285)',
                            ),
                            Divider(height: 1, indent: 16, endIndent: 16),
                            _buildPaymentOption(
                              'wechat',
                              '微信支付',
                              'assets/wechat_icon.png',
                              '微信支付(快捷支付)',
                            ),
                            Divider(height: 1, indent: 16, endIndent: 16),
                            // 数字人民币选项
                            _buildPaymentOption(
                              'dcep',
                              '数字人民币',
                              'assets/dcep_icon.png',
                              '招商银行(1285)',
                            ),
                          ],
                        ),
                      ),

                      // 优惠信息
                      Container(
                        margin: EdgeInsets.only(top: 12),
                        padding: EdgeInsets.all(16),
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('限一件优惠商品，本单立减'),
                            Text(
                              '-¥${discount.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ),
            ),
          ),

          // 底部确认支付按钮
          Container(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                // 处理支付逻辑
                _handlePayment();
              },
              child: Text('确认交易', 
                style: TextStyle(color: Colors.white)
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
      String value, String title, String iconPath, String subtitle) {
    return ListTile(
      leading: Image.asset(iconPath, width: 24, height: 24),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Radio(
        value: value,
        groupValue: selectedPayment,
        onChanged: (String? newValue) {
          setState(() {
            selectedPayment = newValue!;
          });
        },
      ),
      onTap: () {
        setState(() {
          selectedPayment = value;
        });
      },
    );
  }

  void _handlePayment() {
    // 实现支付逻辑
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('支付确认'),
        content: Text('确认支付 ¥${(widget.amount - discount).toStringAsFixed(2)}？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 这里添加实际的支付处理逻辑
              Navigator.pop(context);
              // 支付成功后的处理
            },
            child: Text('确认'),
          ),
        ],
      ),
    );
  }
}
