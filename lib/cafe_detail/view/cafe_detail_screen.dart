import 'dart:async';
import 'dart:io';
import 'package:coffee_explorer_lite/common/primary_button.dart';
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
  Map<String, dynamic> cafe;

  CafeDetailScreen({super.key, required this.cafe});

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
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('You do not have permission to change the image.'),
      //   ),
      // );
      return;
    }

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        await DatabaseHelper.instance.updateCafeImage(cafe['id'], image.path);

        final updatedCafe = Map<String, dynamic>.from(cafe);
        updatedCafe['imagePath'] = image.path;

        setState(() {
          cafe = updatedCafe;
        });

        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Image updated successfully')),
        // );
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('No image selected')),
        // );
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error selecting image: $e')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: BlocProvider(
          create: (context) => CommentBloc(DatabaseHelper.instance),
          child: MaterialApp(
            theme: ThemeData(
                primarySwatch: Colors.blue,
                inputDecorationTheme: InputDecorationTheme(
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.black)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ))),
            home: Scaffold(
              appBar: AppBar(
                leading: BackButton(
                  onPressed: () {
                    Navigator.pop(context, "refresh");
                  },
                ),
                title: Row(
                  children: [
                    GestureDetector(
                      onTap: () async => _pickImage(context),
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
                                    final image =
                                        Image.file(File(cafe['imagePath']));

                                    return FutureBuilder<ImageInfo>(
                                      future: _getImageInfo(image),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.hasData) {
                                          final imageInfo = snapshot.data!;
                                          final aspectRatio =
                                              imageInfo.image.width /
                                                  imageInfo.image.height;
                                          final fit = aspectRatio > 1
                                              ? BoxFit.fitWidth
                                              : BoxFit.fitHeight;
                                          return Image.file(
                                            File(cafe['imagePath']),
                                            key: ValueKey(cafe['imagePath']),
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
                  if (isAdmin)
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
            ),
          )),
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
          // print("Updated cafe: $cafe");
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
          content: Text('You do not have permission to make this change.'),
        ),
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
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Coffee Shop Details'),
          content: SingleChildScrollView(
            // Wrap content in SingleChildScrollView to handle overflows
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.02),
                    child: const Text('Coffee Shop Name'),
                  ),
                ),
                TextField(
                  controller: nameController,
                  maxLength: 25,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.02),
                    child: const Text('Address'),
                  ),
                ),
                TextField(
                  controller: addressController,
                  maxLength: 150,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.02),
                    child: const Text('Description'),
                  ),
                ),
                TextField(
                  controller: descriptionController,
                  minLines: 1,
                  maxLines: 3,
                  maxLength: 300,
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    title: Text(
                      'Cancel',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: PrimaryButton(
                    onPressed: () async {
                      await _updateCafeDetails(
                        nameController.text,
                        addressController.text,
                        descriptionController.text,
                      );
                      Navigator.pop(dialogContext);
                    },
                    title: Text(
                      'Save',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}

class CafeDetailBody extends StatefulWidget {
  Map<String, dynamic> cafe;
  ValueChanged<bool> onAdminStatusChanged;

  CafeDetailBody(
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

  late int cafeId;

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
    var images = await DatabaseHelper.instance.getCafeImages(widget.cafe['id']);
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
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
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
                      color: index == _currentIndex ? Colors.green : Colors.grey,
                      boxShadow: index == _currentIndex
                          ? [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.6),
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
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
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
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
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
                            child: PrimaryButton(
                              onPressed: () {
                                setState(() {
                                  _isAddingComment = true;
                                });
                              },
                              title: Text(
                                'Add a comment',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
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
                            // print(comment);

                            return Visibility(
                              visible: !isCommentHidden ||
                                  isAdmin ||
                                  idUser == userId,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(
                                      color: Colors.black12,
                                      height: 20,
                                    ),
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
                                                constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.8,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                ),
                                                child: Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.8,
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                  ),
                                                  child: Text(
                                                    textComment,
                                                    softWrap: true,
                                                  ),
                                                ),
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
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7,
                                                // maxWidth: 240,
                                              ),
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                              ),
                                              child: Text(
                                                textComment,
                                                softWrap: true,
                                              ),
                                            ),
                                          ),
                                        if ((idUser == userId || isAdmin) &&
                                            !isCommentHidden)
                                          BlocProvider(
                                            create: (context) => CommentBloc(
                                                DatabaseHelper.instance),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                PopupMenuButton<int>(
                                                  icon: Icon(Icons.more_vert),
                                                  onSelected: (value) {
                                                    switch (value) {
                                                      case 1: // Edit option
                                                        _showEditCommentDialog(
                                                          context,
                                                          idComment,
                                                          textComment,
                                                          widget.cafe['id'],
                                                        );
                                                        break;
                                                      case 2: // Delete option
                                                        if (idComment != null) {
                                                          BlocProvider.of<
                                                                      CommentBloc>(
                                                                  context)
                                                              .add(
                                                            HideComment(
                                                                idComment,
                                                                widget.cafe[
                                                                    'id']),
                                                          );
                                                        } else {
                                                          print(
                                                              'Comment ID is null');
                                                        }
                                                        break;
                                                    }
                                                  },
                                                  itemBuilder: (context) => [
                                                    PopupMenuItem(
                                                      value: 1,
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.edit,
                                                              size: 20),
                                                          SizedBox(width: 8),
                                                          Text('Edit'),
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 2,
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.delete,
                                                              size: 20,
                                                              color:
                                                                  Colors.red),
                                                          SizedBox(width: 8),
                                                          Text('Delete'),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
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
                            child: PrimaryButton(
                                onPressed: () {
                                  setState(() {
                                    _isAddingComment = true;
                                  });
                                },
                                title: Text(
                                  'Add a comment',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )),
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

  void _showEditCommentDialog(
      BuildContext context, int commentId, String initialContent, int cafeId) {
    final TextEditingController controller =
        TextEditingController(text: initialContent);

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: BlocProvider.of<CommentBloc>(context),
        child: AlertDialog(
          title: Text('Edit comment'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(labelText: 'Comment'),
              minLines: 1,
              maxLines: 5,
              maxLength: 150,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                final updatedContent = controller.text;

                BlocProvider.of<CommentBloc>(context).add(
                  EditComment(
                    commentId,
                    updatedContent,
                    cafeId,
                  ),
                );

                Navigator.pop(dialogContext);
              },
              child: Text('Save'),
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
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding:
                EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
            child: Text('Add a comment'),
          ),
        ),
        TextField(
          controller: _commentController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          minLines: 1,
          maxLines: 5,
          maxLength: 150,
          keyboardType: TextInputType.multiline,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: PrimaryButton(
                onPressed: widget.onCancel,
                title: const Text(
                  'Cancel',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
            Expanded(
              child: PrimaryButton(
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
                title: Text(
                  'Submit',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
