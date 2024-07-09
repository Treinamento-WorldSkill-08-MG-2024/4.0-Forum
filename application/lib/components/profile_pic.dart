import 'package:application/modules/storage_module.dart';
import 'package:flutter/material.dart';

class ProfilePic extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;

  final _defaultProfilePic =
      'https://images.unsplash.com/photo-1712847333364-296afd7ba69a?crop=entropy&cs=srgb&fm=jpg&ixid=M3w0Mzc0NDd8MXwxfGFsbHwxfHx8fHx8Mnx8MTcxODcxMjI1OHw&ixlib=rb-4.0.3&q=85&q=85&fmt=jpg&crop=entropy&cs=tinysrgb&w=450';

  const ProfilePic(
    this.imageUrl, {
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final profilePic =
        imageUrl != null ? StorageHandler.fmtImageUrl(imageUrl!) : null;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.fill,
          image: NetworkImage(profilePic ?? _defaultProfilePic),
        ),
      ),
    );
  }
}
