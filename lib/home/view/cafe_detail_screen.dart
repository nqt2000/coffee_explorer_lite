// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'dart:io';
// import '../bloc/home_bloc.dart';
// import '../bloc/home_event.dart';
// import '../bloc/home_state.dart';
//
// class CafeDetailScreen extends StatelessWidget {
//   final int cafeId;
//
//   CafeDetailScreen({required this.cafeId});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => HomeBloc()..add(FetchCafeDetail(cafeId)),
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Cafe Details'),
//         ),
//         body: BlocBuilder<HomeBloc, HomeState>(
//           builder: (context, state) {
//             if (state is CafeDetailLoading) {
//               return Center(child: CircularProgressIndicator());
//             } else if (state is CafeDetailLoaded) {
//               final cafe = state.cafe;
//               return SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         cafe['name'],
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                       cafe['imagePath'] != null && cafe['imagePath'].isNotEmpty
//                           ? Image.file(
//                         File(cafe['imagePath']),
//                         fit: BoxFit.cover,
//                         height: 200,
//                         width: double.infinity,
//                       )
//                           : Container(
//                         height: 200,
//                         width: double.infinity,
//                         color: Colors.grey,
//                         child: Icon(Icons.image, size: 100),
//                       ),
//                       SizedBox(height: 16),
//                       Text(
//                         'Address: ${cafe['address']}',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                       SizedBox(height: 16),
//                       Text(
//                         'Description: ${cafe['description']}',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             } else if (state is CafeDetailError) {
//               return Center(child: Text(state.message));
//             } else {
//               return Center(child: Text("Something went wrong!"));
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';

import 'package:flutter/material.dart';

class CafeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> cafe;

  CafeDetailScreen({required this.cafe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cafe['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (cafe['imagePath'] != null && cafe['imagePath'].isNotEmpty)
              Image.file(File(cafe['imagePath'])),
            SizedBox(height: 16),
            Text('Address: ${cafe['address']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Description: ${cafe['description']}', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
