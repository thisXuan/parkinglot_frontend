import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:parkinglot_frontend/api/data.dart';
import 'package:parkinglot_frontend/api/user.dart';
import 'dart:convert'; // Add this import for json.decode
import 'package:intl/intl.dart'; // Add this import at the top of the file

class ReviewData {
  final String reviewer;
  final int rating;
  final List<String> tags;
  final String comment;
  final String time;

  ReviewData({
    required this.reviewer,
    required this.rating,
    required this.tags,
    required this.comment,
    required this.time,
  });

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    List<String> parsedTags = [];
    if (json['tags'] != null) {
      try {
        List<dynamic> tagsList = jsonDecode(json['tags']);
        parsedTags = tagsList.map((tag) => tag.toString()).toList();
      } catch (e) {
        print('Error parsing tags: ${e.toString()}');
        parsedTags = [];
      }
    }

    return ReviewData(
      reviewer: json['reviewer'],
      rating: json['rating'],
      tags: parsedTags,
      comment: json['comment'],
      time: json['time'],
    );
  }
}

class ManagerReviewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ManagerReviewPageState();
}

class ManagerReviewPageState extends State<ManagerReviewPage> {
  double averageRating = 0;
  Map<String, int> ratingDistribution = {
    '5': 0,
    '4': 0,
    '3': 0,
    '2': 0,
    '1': 0,
  };
  List<ReviewData> reviews = [];

  @override
  void initState() {
    super.initState();
    initReviewData();
  }

  void initReviewData() async {
    var result = await UserApi().GetReview();
    if (result != null) {
      var code = result['code'];
      if (code == 200) {
        setState(() {
          averageRating = result['data']['overallRating']['average'];

          var distribution = result['data']['ratingDistribution'];
          ratingDistribution = {
            '5': distribution['5'],
            '4': distribution['4']??0,
            '3': distribution['3']??0,
            '2': distribution['2']??0,
            '1': distribution['1']??0,
          };

          reviews = (result['data']['reviews'] as List)
              .map((review) => ReviewData.fromJson(review))
              .toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('商场评价', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverallRating(),
            SizedBox(height: 20),
            _buildRatingDistribution(),
            SizedBox(height: 20),
            _buildReviewsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallRating() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('总体评分', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < averageRating.floor()
                              ? Icons.star
                              : index < averageRating
                              ? Icons.star_half
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                    Text(
                      '${reviews.length}条评价',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDistribution() {
    int maxCount = ratingDistribution.values
        .reduce((value, element) => value > element ? value : element);

    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('评分分布', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ...List.generate(5, (index) {
              int stars = 5 - index;
              int count = ratingDistribution[stars.toString()] ?? 0;
              double percentage = maxCount > 0 ? count / maxCount : 0;

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text('$stars星'),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: percentage,
                            child: Container(
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text('$count'),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('评价列表', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ...reviews.map((review) => _buildReviewItem(review)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(ReviewData review) {
    // Format the time string
    String formattedTime = '';
    try {
      DateTime dateTime = DateTime.parse(review.time);
      formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } catch (e) {
      print('Error parsing date: ${e.toString()}');
      formattedTime = review.time;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                child: Text(review.reviewer[0]),
                backgroundColor: Colors.blue[100],
              ),
              SizedBox(width: 8),
              Text(
                review.reviewer,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: review.tags.map((tag) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 8),
          Text(review.comment),
          SizedBox(height: 4),
          Text(
            formattedTime,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}