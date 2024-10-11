import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/comment_bloc.dart';
import '../bloc/comment_event.dart';
import '../bloc/comment_state.dart';
import 'full_size_image_screen.dart';
import '../../utils/database_helper.dart';
import '../../utils/session_manager.dart';

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
                            return const CircularProgressIndicator();
                          }
                        },
                      );
                    },
                  ),
                ),
              )
            else
              const Icon(
                Icons.image,
                color: Colors.grey,
                size: 40,
              ),
            Expanded(
              child: Text(
                cafe['name'],
                style: const TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: BlocProvider(
        create: (context) => CommentBloc(DatabaseHelper.instance)
          ..add(FetchComments(cafe['id'])), // Fetch comments for the cafe
        child: CafeDetailBody(cafe: cafe),
      ),
    );
  }
}

class CafeDetailBody extends StatefulWidget {
  final Map<String, dynamic> cafe;

  const CafeDetailBody({super.key, required this.cafe});

  @override
  _CafeDetailBodyState createState() => _CafeDetailBodyState();
}

class _CafeDetailBodyState extends State<CafeDetailBody> {
  bool _isAddingComment = false;
  late int userId;
  String userFullName = 'User';
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    final sessionManager = SessionManager();
    final userInfo = await sessionManager.getUserInfo();

    setState(() {
      userId = userInfo?['id'] ?? 0;
      userFullName = userInfo?['name'] ?? 'User';
      isAdmin = (userInfo?['isAdmin'] ?? 0) == 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<String>>(
              future: DatabaseHelper.instance.getCafeImages(widget.cafe['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error loading images');
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
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  List.generate(imagePaths.length, (index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  width: 8.0,
                                  height: 8.0,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey,
                                  ),
                                );
                              }),
                            )
                          ],
                        )
                      : const Center(
                          child:
                              Icon(Icons.image, size: 300, color: Colors.grey),
                        );
                }
              },
            ),
            const SizedBox(height: 16),
            Text('Address: ${widget.cafe['address']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Description: ${widget.cafe['description']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Comments',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            BlocBuilder<CommentBloc, CommentState>(
              builder: (context, state) {
                if (state is CommentLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CommentLoaded) {
                  if (state.comments.isNotEmpty) {
                    return Column(
                      children: [
                        if (_isAddingComment)
                          AddCommentForm(
                            cafeId: widget.cafe['id'],
                            onSubmitSuccess: () {
                              setState(() {
                                _isAddingComment = false;
                              });
                            },
                            onCancel: () {
                              setState(() {
                                _isAddingComment = false;
                              });
                            },
                            userId: userId,
                          ),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: state.comments.length,
                          itemBuilder: (context, index) {
                            final comment = state.comments[index];
                            final userName = comment['userName'] ?? 'Anonymous';
                            final timestamp = comment['timestamp'];

                            final formattedTime = timestamp != null
                                ? DateFormat('dd/MM/yyyy')
                                    .format(DateTime.parse(timestamp))
                                : '';

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$userName - $formattedTime',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: Text(comment['commentText']),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        if (!_isAddingComment)
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isAddingComment = true;
                                });
                              },
                              child: const Text('Add a comment'),
                            ),
                          ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        const Text('No comments available.'),
                        const SizedBox(height: 8),
                        if (_isAddingComment)
                          AddCommentForm(
                            cafeId: widget.cafe['id'],
                            onSubmitSuccess: () {
                              setState(() {
                                _isAddingComment = false;
                              });
                            },
                            onCancel: () {
                              setState(() {
                                _isAddingComment = false;
                              });
                            },
                            userId: userId,
                          ),
                        if (!_isAddingComment)
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isAddingComment = true;
                                });
                              },
                              child: const Text('Add a comment'),
                            ),
                          ),
                      ],
                    );
                  }
                } else if (state is CommentError) {
                  return Center(child: Text(state.message));
                } else {
                  return const Center(child: Text('No comments found'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<ImageInfo> _getImageInfo(Image image) async {
  final completer = Completer<ImageInfo>();
  image.image.resolve(const ImageConfiguration()).addListener(
    ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    }),
  );
  return completer.future;
}

class AddCommentForm extends StatefulWidget {
  final int userId;
  final int cafeId;
  final VoidCallback onSubmitSuccess;
  final VoidCallback onCancel;

  const AddCommentForm({
    super.key,
    required this.userId,
    required this.cafeId,
    required this.onSubmitSuccess,
    required this.onCancel,
  });

  @override
  _AddCommentFormState createState() => _AddCommentFormState();
}

class _AddCommentFormState extends State<AddCommentForm> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _commentController,
          decoration: const InputDecoration(
            labelText: 'Add a comment',
            border: OutlineInputBorder(),
          ),
          maxLines: null,
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: widget.onCancel,
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                final commentText = _commentController.text;
                if (commentText.isNotEmpty) {
                  BlocProvider.of<CommentBloc>(context).add(
                    AddComment(widget.cafeId, commentText),
                  );
                  _commentController.clear();
                  widget.onSubmitSuccess();
                }
              },
              child: const Text('Submit'),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }
}
