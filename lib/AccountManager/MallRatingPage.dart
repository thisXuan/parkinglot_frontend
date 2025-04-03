import 'package:flutter/material.dart';

class MallRatingPage extends StatefulWidget {
  @override
  _MallRatingPageState createState() => _MallRatingPageState();
}

class _MallRatingPageState extends State<MallRatingPage> {
  int _rating = 5;
  Set<String> _selectedTags = {};
  final TextEditingController _commentController = TextEditingController();

  // 好评标签（4-5星）
  final List<String> _goodTags = [
    '商场环境整洁',
    '卫生间体验好',
    '母婴室体验好',
    '停车体验好',
    '积分方便、有福利',
    '店员服务态度好',
    '保安保洁服务态度',
  ];

  // 差评标签（1-3星）
  final List<String> _badTags = [
    '商场环境差',
    '卫生间体验差',
    '母婴室体验差',
    '停车体验差',
    '积分不方便',
    '店员服务态度差',
    '保安保洁服务态度差',
  ];

  @override
  Widget build(BuildContext context) {
    bool isGoodRating = _rating >= 4;
    List<String> currentTags = isGoodRating ? _goodTags : _badTags;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '商场体验评价',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child:  SingleChildScrollView(
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 总体评价标题和星级
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '商场总体评价',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _rating = index + 1;
                                _selectedTags.clear(); // 清除已选标签
                              });
                            },
                            child: Icon(
                              Icons.star,
                              size: 32,
                              color: index < _rating
                                  ? Color(0xFFFF9966)
                                  : Colors.grey[300],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                // 标签选择区域
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: currentTags.map((tag) {
                      bool isSelected = _selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedTags.remove(tag);
                            } else {
                              _selectedTags.add(tag);
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Color(0xFFFF9966) : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tag,
                                style: TextStyle(
                                  color: isSelected ? Color(0xFFFF9966) : Colors.black87,
                                ),
                              ),
                              if (isSelected) ...[
                                SizedBox(width: 4),
                                Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Color(0xFFFF9966),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // 其他想说的
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    controller: _commentController,
                    maxLength: 100,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: '其他想说的',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            )
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,  // 设置底部区域背景为白色
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                // TODO: 提交评价
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF9966),
                minimumSize: Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(
                '提交',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}