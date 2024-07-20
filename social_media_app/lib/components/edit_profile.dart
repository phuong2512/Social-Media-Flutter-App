import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfile extends StatefulWidget {
  final String currentUsername;
  final String? currentAvatarUrl;
  final Function(String, XFile?) onSave;

  const EditProfile({
    required this.currentUsername,
    required this.currentAvatarUrl,
    required this.onSave,
    super.key,
  });

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _usernameController = TextEditingController();
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.currentUsername;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _pickedImage = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.currentAvatarUrl != null && widget.currentAvatarUrl!.isNotEmpty)
            CircleAvatar(
              radius: 50,
              backgroundImage: _pickedImage != null
                  ? FileImage(File(_pickedImage!.path))
                  : NetworkImage(widget.currentAvatarUrl!) as ImageProvider,
            )
          else
            CircleAvatar(
              radius: 50,
              child: _pickedImage != null
                  ? ClipOval(child: Image.file(File(_pickedImage!.path), fit: BoxFit.cover, width: 100, height: 100,))
                  : const Icon(Icons.person, size: 50),
            ),
          TextButton(
            onPressed: _pickImage,
            child: const Text("Change Avatar"),
          ),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onSave(_usernameController.text, _pickedImage);
              Navigator.of(context).pop();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
