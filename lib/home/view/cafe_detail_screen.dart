import 'dart:io';
import 'package:flutter/material.dart';
import 'full_size_image_screen.dart'; // Thêm import cho màn hình fullsize
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
            Expanded(
              child: Text(
                cafe['name'],
                style: TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
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
                            SizedBox(
                              height: 350,
                              width: 350,
                              child: PageView.builder(
                                itemCount: imagePaths.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      // Chuyển sang màn hình hiển thị fullsize khi bấm vào ảnh
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FullSizeImageScreen(
                                            imageUrl: imagePaths[index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: Image.file(
                                          File(imagePaths[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  List.generate(imagePaths.length, (index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  width: 8.0,
                                  height: 8.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey,
                                  ),
                                );
                              }),
                            )
                          ],
                        )
                      : Center(
                          child:
                              Icon(Icons.image, size: 300, color: Colors.grey),
                        );
                }
              },
            ),
            SizedBox(height: 16),
            //Cafe information
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
