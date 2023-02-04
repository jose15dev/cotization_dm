import 'package:bloc/bloc.dart';
import 'package:cotizacion_dm/ui/utilities/delay.utility.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

part 'profile_image_picker_state.dart';

class ProfileImagePickerCubit extends Cubit<ProfileImagePickerState> {
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
      var image = await PickImageUtility.pickImage();
      emit(OnPickingImageLoading());
      await DelayUtility.delay();
      if (image != null) {
        emit(OnPickingImageSuccess(image));
      } else {
        emit(OnPickingImageNoLoaded());
      }
    } catch (e) {
      emit(OnPickingImageFailed(e.toString()));
    }
  }
}
