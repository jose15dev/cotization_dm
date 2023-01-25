part of 'profile_image_picker_cubit.dart';

abstract class ProfileImagePickerState extends Equatable {
  const ProfileImagePickerState();

  @override
  List<Object> get props => [];
}

class ProfileImagePickerInitial extends ProfileImagePickerState {}

class OnPickingImageLoading extends ProfileImagePickerState {}

class OnPickingImageNoLoaded extends ProfileImagePickerState {
  final String message = "No hay imagen seleccionada";
}

class OnPickingImageSuccess extends ProfileImagePickerState {
  final Uint8List image;

  const OnPickingImageSuccess(this.image);
}

class OnPickingImageFailed extends ProfileImagePickerState {
  final String message;

  const OnPickingImageFailed(this.message);
}
