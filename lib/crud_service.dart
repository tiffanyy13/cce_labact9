import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cce_task9/cloudinary_config.dart';
import 'package:image_picker/image_picker.dart';

class PickedImage {
  final Uint8List bytes;
  final String url;
  PickedImage({required this.bytes, required this.url});
}

class CrudService {
  final CollectionReference items =
      FirebaseFirestore.instance.collection('items');

  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    CloudinaryConfig.cloudName,
    CloudinaryConfig.uploadPreset,
    cache: false,
  );

  final ImagePicker _picker = ImagePicker();

  Future<PickedImage?> pickImageForAddItem() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // compress a bit before uploading
    );
    if (picked == null) return null;

    final bytes = await picked.readAsBytes();

    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromBytesData(
        bytes,
        identifier: picked.name,
        resourceType: CloudinaryResourceType.Image,
      ),
    );

    return PickedImage(bytes: bytes, url: response.secureUrl);
  }

  Future<void> addItem(String name, int quantity, {String? imageUrl}) {
    return items.add({
      'name': name,
      'quantity': quantity,
      'image_url': imageUrl ?? '',
      'isFavorite': false,
      'createdAt': Timestamp.now(),
    });
  }

  //read
  Stream<QuerySnapshot> getItems() {
    return items.orderBy('createdAt', descending: true).snapshots();
  }

  //update 
  Future<void> updateItem(String id, String name, int quantity) {
    return items.doc(id).update({
      'name': name,
      'quantity': quantity,
    });
  }

  //favorite
  Future<void> toggleFavorite(String id, bool isFavorite) {
    return items.doc(id).update({'isFavorite': isFavorite});
  }

  //delete
  Future<void> deleteItem(String id) {
    return items.doc(id).delete();
  }
}
