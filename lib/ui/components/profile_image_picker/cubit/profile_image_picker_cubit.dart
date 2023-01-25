import 'package:bloc/bloc.dart';
import 'package:cotizacion_dm/ui/utilities/delay.utility.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

part 'profile_image_picker_state.dart';

class ProfileImagePickerCubit extends Cubit<ProfileImagePickerState> {
  final ImagePicker _picker = ImagePicker();

  ProfileImagePickerCubit() : super(ProfileImagePickerInitial());

  void loadImage(Uint8List value) async {
    emit(OnPickingImageLoading());
    await DelayUtility.delay();
    emit(OnPickingImageSuccess(value));
  }

  void resetImage() {
    emit(ProfileImagePickerInitial());
  }

  void pickAnImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      emit(OnPickingImageLoading());
      await DelayUtility.delay();
      if (image != null) {
        var base64 = await image.readAsBytes();
        emit(OnPickingImageSuccess(base64));
      } else {
        emit(OnPickingImageNoLoaded());
      }
    } catch (e) {
      emit(OnPickingImageFailed(e.toString()));
    }
  }
}
