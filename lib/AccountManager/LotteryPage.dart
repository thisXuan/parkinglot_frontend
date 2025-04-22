import 'dart:math';
import 'package:flutter/material.dart';

class LotteryPage extends StatefulWidget {
  const LotteryPage({Key? key}) : super(key: key);

  @override
  State<LotteryPage> createState() => _LuckyDrawPageState();
}

class _LuckyDrawPageState extends State<LotteryPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isSpinning = false;
  final List<String> prizes = ['666现金', '神秘奖品', '幸运号码', '积分6', '积分9', '现金券', '积分5', '积分3'];
  int selectedPrize = 0;
  int highlightedPrize = 0; // 当前高亮的奖品索引

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isSpinning = false;
        });
        _showPrizeDialog(prizes[highlightedPrize]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('幸运抽奖', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // 顶部标题和图片
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '每日幸运抽奖',
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.orange[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            '最高赢666现金',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // 转盘和指针
              Stack(
                alignment: Alignment.center,
                children: [
                  // 旋转的背景层
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _animation.value,
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            painter: BackgroundPainter(prizes, highlightedPrize),
                          ),
                        ),
                      );
                    },
                  ),
                  // 固定的转盘层
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: CustomPaint(
                      painter: WheelPainter(prizes),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // 抽奖按钮
              Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[700]!, Colors.orange[900]!],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isSpinning ? null : startSpin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    isSpinning ? '抽奖中...' : '点击抽奖',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // 底部按钮
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBottomButton('更多机会', Icons.add_circle_outline),
                    _buildBottomButton('我的奖品', Icons.card_giftcard),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  void startSpin() {
    if (!isSpinning) {
      setState(() {
        isSpinning = true;
        selectedPrize = Random().nextInt(prizes.length);
        highlightedPrize = selectedPrize;
        
        final double targetAngle = -2 * pi * 5 - (2 * pi / prizes.length) * selectedPrize;

        _animation = Tween<double>(
          begin: 0,
          end: targetAngle,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));
      });

      _controller.forward(from: 0);
    }
  }

  void _showPrizeDialog(String prize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('恭喜中奖！'),
        content: Text('您获得了: $prize'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class WheelPainter extends CustomPainter {
  final List<String> prizes;

  WheelPainter(this.prizes);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 绘制外圈
    final borderPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;
    canvas.drawCircle(center, radius - 7.5, borderPaint);

    // 绘制文字
    for (int i = 0; i < prizes.length; i++) {
      final startAngle = -pi / 2 + i * 2 * pi / prizes.length;
      final sweepAngle = 2 * pi / prizes.length;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(startAngle + sweepAngle / 2);

      final textPainter = TextPainter(
        text: TextSpan(
          text: prizes[i],
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.layout();

      canvas.translate(radius * 0.6, 0);
      canvas.rotate(-startAngle - sweepAngle / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }

    // 绘制中心圆
    final centerPaint = Paint()..color = Colors.orange[900]!;
    canvas.drawCircle(center, 30, centerPaint);

    // 绘制中心文字
    final centerTextPainter = TextPainter(
      text: const TextSpan(
        text: '幸运大转盘',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    centerTextPainter.layout();
    centerTextPainter.paint(
      canvas,
      Offset(
        center.dx - centerTextPainter.width / 2,
        center.dy - centerTextPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BackgroundPainter extends CustomPainter {
  final List<String> prizes;
  final int highlightedPrize;

  BackgroundPainter(this.prizes, this.highlightedPrize);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 绘制扇形区域
    final sectorPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < prizes.length; i++) {
      final startAngle = -pi / 2 + i * 2 * pi / prizes.length;
      final sweepAngle = 2 * pi / prizes.length;

      sectorPaint.color = i == ((prizes.length - highlightedPrize) % prizes.length) 
          ? Colors.orange[100]! 
          : Colors.orange[300]!;

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        true,
        sectorPaint,
      );
    }

    // 绘制小圆点装饰
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < prizes.length * 3; i++) {
      final angle = i * 2 * pi / (prizes.length * 3);
      final x = center.dx + (radius - 15) * cos(angle);
      final y = center.dy + (radius - 15) * sin(angle);
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}