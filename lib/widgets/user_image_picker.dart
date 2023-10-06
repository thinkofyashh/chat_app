import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({Key? key,required this.onPickimage}) : super(key: key);

  final void Function(File pickedimage) onPickimage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? pickedimagefile;
  void pickimage()async{
   final pickedimage=await ImagePicker().pickImage(source:ImageSource.camera,imageQuality: 50,maxWidth: 150);

   if(pickedimage==null){
     return ;
   }
   setState(() {
     pickedimagefile=File(pickedimage.path);
   });
   widget.onPickimage(pickedimagefile!);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:pickedimagefile!=null ? FileImage(pickedimagefile!):null,
        ),
        TextButton.icon(
            onPressed: pickimage,
            icon:const  Icon(Icons.image),
            label: Text(
              "Add Image",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ))
      ],
    );
  }
}
