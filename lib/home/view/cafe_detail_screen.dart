import 'dart:async';
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final image = Image.file(File(cafe['imagePath']));

                      return FutureBuilder<ImageInfo>(
                        future: _getImageInfo(image),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            // Truy cập image từ snapshot.data.image
                            final imageInfo = snapshot.data!;
                            final aspectRatio =
                                imageInfo.image.width / imageInfo.image.height;
                            final fit = aspectRatio > 1
                                ? BoxFit.fitWidth
                                : BoxFit.fitHeight;

                            return Image.file(
                              File(cafe['imagePath']),
                              fit: fit,
                            );
                          } else {
                            return CircularProgressIndicator(); // Hiển thị loading khi đang lấy thông tin ảnh
                          }
                        },
                      );
                    },
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
                                    // Fit image by ratio
                                    // child: LayoutBuilder(
                                    //   builder: (context, constraints) {
                                    //     final image = Image.file(File(imagePaths[index]));
                                    //
                                    //     return FutureBuilder<ImageInfo>(
                                    //       future: _getImageInfo(image),
                                    //       builder: (context, snapshot) {
                                    //         if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                    //           // Truy cập image từ snapshot.data.image
                                    //           final imageInfo = snapshot.data!;
                                    //           final aspectRatio = imageInfo.image.width / imageInfo.image.height;
                                    //           final fit = aspectRatio > 1 ? BoxFit.fitWidth : BoxFit.fitHeight;
                                    //
                                    //           return ClipRRect(
                                    //             borderRadius: BorderRadius.circular(30),
                                    //             child: Image.file(
                                    //               File(imagePaths[index]),
                                    //               fit: fit,
                                    //             ),
                                    //           );
                                    //         } else {
                                    //           return CircularProgressIndicator(); // Hiển thị loading khi đang lấy thông tin ảnh
                                    //         }
                                    //       },
                                    //     );
                                    //   },
                                    // ),

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

Future<ImageInfo> _getImageInfo(Image image) async {
  final completer = Completer<ImageInfo>();
  image.image.resolve(ImageConfiguration()).addListener(
    ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    }),
  );
  return completer.future;
}
