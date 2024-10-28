import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../bloc/comment_bloc.dart';
import '../bloc/comment_event.dart';
import '../bloc/comment_state.dart';
import 'full_size_image_screen.dart';
import '../../utils/database_helper.dart';
import '../../utils/session_manager.dart';

class CafeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> cafe;

  const CafeDetailScreen({Key? key, required this.cafe}) : super(key: key);

  @override
  _CafeDetailScreenState createState() => _CafeDetailScreenState();
}

class _CafeDetailScreenState extends State<CafeDetailScreen> {
  bool isAdmin = false;

  late Map<String, dynamic> cafe;

  @override
  void initState() {
    super.initState();
    cafe = Map<String, dynamic>.from(widget.cafe);
  }

  Future<void> _pickImage(BuildContext context) async {
    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You do not have permission to change the image.')),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        await DatabaseHelper.instance
            .updateCafeImage(widget.cafe['id'], image.path);

        setState(() {
          widget.cafe['imagePath'] = image.path;
        });

        Navigator.pop(context, widget.cafe['imagePath']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () => _pickImage(context),
              child: cafe['imagePath'] != null &&
                      cafe['imagePath'].isNotEmpty &&
                      File(cafe['imagePath']).existsSync()
                  ? Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white,
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
                                  final aspectRatio = imageInfo.image.width /
                                      imageInfo.image.height;
                                  final fit = aspectRatio > 1
                                      ? BoxFit.fitWidth
                                      : BoxFit.fitHeight;

                                  return Image.file(
                                    File(cafe['imagePath']),
                                    fit: fit,
                                  );
                                } else if (snapshot.hasError ||
                                    !snapshot.hasData) {
                                  return Icon(Icons.error,
                                      color: Colors.white, size: 30);
                                } else {
                                  return Icon(Icons.image,
                                      color: Colors.white, size: 30);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 40,
                    ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditCafeDialog(context);
            },
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => CommentBloc(DatabaseHelper.instance)
          ..add(FetchComments(cafe['id'])),
        child: CafeDetailBody(
          cafe: cafe,
          onAdminStatusChanged: (isAdminStatus) {
            setState(() {
              isAdmin = isAdminStatus;
            });
          },
        ),
      ),
    );
  }

  Future<void> _updateCafeDetails(
      String newName, String newAddress, String newDescription) async {
    if (newName.isNotEmpty && newAddress.isNotEmpty) {
      await DatabaseHelper.instance.updateCafeDetails(
        cafe['id'],
        newName,
        newAddress,
        newDescription,
      );

      final updatedCafe =
          await DatabaseHelper.instance.queryCafeById(cafe['id']);

      if (updatedCafe != null) {
        setState(() {
          cafe = Map<String, dynamic>.from(updatedCafe);
          print("Updated cafe: $cafe");
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Address cannot be empty')),
      );
    }
  }

  void _showEditCafeDialog(BuildContext context) {
    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You do not have permission to make this change.')),
      );
      return;
    }
    final TextEditingController nameController =
        TextEditingController(text: cafe['name']);
    final TextEditingController addressController =
        TextEditingController(text: cafe['address']);
    final TextEditingController descriptionController =
        TextEditingController(text: cafe['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Cafe Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Cafe Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _updateCafeDetails(
                  nameController.text,
                  addressController.text,
                  descriptionController.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class CafeDetailBody extends StatefulWidget {
  final Map<String, dynamic> cafe;
  final ValueChanged<bool> onAdminStatusChanged;

  const CafeDetailBody(
      {super.key, required this.cafe, required this.onAdminStatusChanged});

  @override
  _CafeDetailBodyState createState() => _CafeDetailBodyState();
}

class _CafeDetailBodyState extends State<CafeDetailBody> {
  bool _isAddingComment = false;
  late int userId;
  String userFullName = 'User';
  bool isAdmin = false;
  int _currentIndex = 0;
  PageController? _pageController;
  List<String> imagePaths = [];

  @override
  void initState() {
    super.initState();
    _loadUserSession();
    _loadImagePaths();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _loadImagePaths() async {
    final images =
        await DatabaseHelper.instance.getCafeImages(widget.cafe['id']);
    setState(() {
      imagePaths = images;
      _pageController = PageController(initialPage: _currentIndex);
    });
  }

  Future<void> _loadUserSession() async {
    final sessionManager = SessionManager();
    final userInfo = await sessionManager.getUserInfo();

    setState(() {
      userId = userInfo?['id'] ?? 0;
      userFullName = userInfo?['name'] ?? 'User';
      isAdmin = (userInfo?['isAdmin'] ?? 0) == 1;

      widget.onAdminStatusChanged(isAdmin);
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
            Center(
              child: SizedBox(
                height: 350,
                width: 350,
                child: imagePaths.isEmpty
                    ? Center(
                        child: Icon(Icons.image, size: 100, color: Colors.grey),
                      )
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: imagePaths.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final imagePath = imagePaths[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullSizeImageScreen(
                                    imageUrl: imagePath,
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
                                  filterQuality: FilterQuality.high,
                                  color: Colors.black.withOpacity(0.1),
                                  colorBlendMode: BlendMode.lighten,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imagePaths.length, (index) {
                return GestureDetector(
                  onTap: () {
                    _pageController?.jumpToPage(index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: index == _currentIndex ? 12.0 : 8.0,
                    height: index == _currentIndex ? 12.0 : 8.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentIndex ? Colors.blue : Colors.grey,
                      boxShadow: index == _currentIndex
                          ? [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.6),
                                spreadRadius: 2,
                                blurRadius: 4,
                              ),
                            ]
                          : [],
                    ),
                  ),
                );
              }),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.cafe['address']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.cafe['description'] != null &&
                    widget.cafe['description'] != '')
                  const Icon(Icons.description, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.cafe['description']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
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
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: state.comments.length,
                          itemBuilder: (context, index) {
                            final comment = state.comments[index];
                            final userName = comment['userName'] ?? 'Anonymous';
                            final timestamp = comment['timestamp'];
                            final idUser = comment['userId'];
                            final isCommentHidden = comment['isHidden'] == 1;
                            final idComment = comment['commentId'];
                            final textComment = comment['commentText'];

                            final formattedTime = timestamp != null
                                ? DateFormat('dd/MM/yyyy')
                                    .format(DateTime.parse(timestamp))
                                : '';

                            return Visibility(
                              visible: !isCommentHidden ||
                                  isAdmin ||
                                  idUser == userId,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isAdmin || !isCommentHidden)
                                      Text(
                                        '$userName - $formattedTime',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (isCommentHidden)
                                          if (isAdmin)
                                            Opacity(
                                              opacity: 0.5,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  color: Colors.grey[200],
                                                ),
                                                child: Text(textComment),
                                              ),
                                            )
                                          else
                                            Opacity(
                                              opacity: 0.5,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  color: Colors.grey[200],
                                                ),
                                                child: Text(
                                                    'Comment has been removed'),
                                              ),
                                            )
                                        else if (!isCommentHidden)
                                          Container(
                                            padding: const EdgeInsets.all(12.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              color: Colors.grey[200],
                                            ),
                                            child: Text(textComment),
                                          ),
                                        if ((idUser == userId || isAdmin) &&
                                            !isCommentHidden)
                                          Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                  IconButton(
                                                    icon: Icon(Icons.edit),
                                                    onPressed: () {
                                                      showEditCommentDialog(context, idComment, textComment, widget.cafe['id']);
                                                    },
                                                  ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.red),
                                                  onPressed: () {
                                                    if (idComment != null) {
                                                      BlocProvider.of<
                                                                  CommentBloc>(
                                                              context)
                                                          .add(
                                                        HideComment(idComment),
                                                      );
                                                    } else {
                                                      print(
                                                          'Comment ID is null');
                                                    }
                                                  },
                                                ),
                                              ])
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        const Text('No comments yet'),
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

  void showEditCommentDialog(BuildContext context, int commentId, String initialContent, int cafeId) {
    final TextEditingController controller = TextEditingController(text: initialContent);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit comment'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Nội dung mới'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final updatedContent = controller.text;
              BlocProvider.of<CommentBloc>(context).add(
                UpdateComment(
                  commentId,
                  updatedContent,
                  cafeId,
                ),
              );
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
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
