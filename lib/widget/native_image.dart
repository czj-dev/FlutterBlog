import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef ClickListener = void Function();

class NativeImage extends StatelessWidget {
  final String imageName;
  final double width;
  final double height;
  final BoxFit fit;
  final String postfix;
  final ClickListener? onPressed;

  const NativeImage(this.imageName,
      {Key? key,
      this.width = 0.0,
      this.height = 0.0,
      this.fit = BoxFit.fill,
      this.postfix = 'png',
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Image image;
    if (width != 0 && height != 0) {
      image = Image(
        image: AssetImage(imagePath(imageName: imageName, postfix: postfix)),
        fit: fit,
        width: this.width,
        height: this.height,
      );
    } else
      image = Image(
        image: AssetImage(imagePath(imageName: imageName, postfix: postfix)),
        fit: fit,
      );
    return decorateImage(image);
  }

  static String imagePath({required String imageName, String postfix = 'png'}) {
    return 'static/images/$imageName.$postfix';
  }

  Widget decorateImage(Image image) {
    if (onPressed == null) {
      return image;
    }
    return Material(
        // clear background
        color: Color(0x00000000),
        child: InkWell(
          onTap: onPressed,
          child: image,
        ));
  }
}
