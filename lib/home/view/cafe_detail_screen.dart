import 'dart:io';

import 'package:flutter/material.dart';

import '../../utils/database_helper.dart';

class CafeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> cafe;

  const CafeDetailScreen({super.key, required this.cafe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Ảnh đầu tiên của quán cà phê
            if (cafe['imagePath'] != null && cafe['imagePath'].isNotEmpty)
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    File(cafe['imagePath']),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Icon(
                Icons.image,
                color: Colors.grey,
                size: 40,
              ),
            // Tên quán cà phê
            Expanded(
              child: Text(
                cafe['name'],
                style: TextStyle(fontSize: 18), // Điều chỉnh kích thước chữ nếu cần
                overflow: TextOverflow.ellipsis, // Cắt ngắn nếu tên quá dài
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slide ảnh cho quán cà phê
            FutureBuilder<List<String>>(
              future: DatabaseHelper.instance.getCafeImages(cafe['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error loading images');
                } else {
                  final imagePaths = snapshot.data ?? [];
                  return imagePaths.isNotEmpty
                      ? Column(
                    children: [
                      Container(
                        height: 300,
                        width: 300,
                        child: PageView.builder(
                          itemCount: imagePaths.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.file(
                                  File(imagePaths[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(imagePaths.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue, // Đổi màu nếu ảnh hiện tại được chọn
                            ),
                          );
                        }),
                      )
                    ],
                  )
                      : Icon(Icons.image, size: 150, color: Colors.grey);
                }
              },
            ),
            SizedBox(height: 16),
            // Thông tin quán cà phê
            Text('Address: ${cafe['address']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Description: ${cafe['description']}',
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
