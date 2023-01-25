import 'package:cotizacion_dm/ui/bloc/bloc.dart';
import 'package:cotizacion_dm/ui/components/profile_image_picker/cubit/profile_image_picker_cubit.dart';
import 'package:cotizacion_dm/ui/styled/styled.dart';
import 'package:cotizacion_dm/ui/utilities/theme_utility.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileImagePicker extends StatefulWidget {
  final void Function(Uint8List) onChange;
  final Function(ProfileImagePickerCubit)? controller;
  const ProfileImagePicker({
    Key? key,
    this.controller,
    required this.onChange,
  }) : super(key: key);

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  ProfileImagePickerCubit imageBloc = ProfileImagePickerCubit();

  SnackbarBloc get snackbarBloc => BlocProvider.of(context);

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    imageBloc.close();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.controller is Function) {
      widget.controller!(imageBloc);
    }
  }

  @override
  Widget build(BuildContext context) {
    var borderRadius = BorderRadius.circular(20.0);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: imageBloc.pickAnImage,
        child: ClipRRect(
          child: Ink(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: ColorPalete.primary.withOpacity(0.2),
            ),
            child:
                BlocConsumer<ProfileImagePickerCubit, ProfileImagePickerState>(
              bloc: imageBloc,
              listener: (context, state) {
                if (state is OnPickingImageFailed) {
                  snackbarBloc.add(ErrorSnackbarEvent(state.message));
                }
                if (state is OnPickingImageNoLoaded) {
                  snackbarBloc.add(ErrorSnackbarEvent(state.message));
                }
                if (state is OnPickingImageSuccess) {
                  widget.onChange(state.image);
                }
              },
              builder: (context, state) {
                if (state is OnPickingImageLoading) {
                  return Stack(
                    children: [
                      Align(
                        alignment: FractionalOffset.center,
                        child: Icon(
                          Icons.image,
                          size: 100,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Align(
                        alignment: FractionalOffset.center,
                        child: LoadingIndicator(
                          size: 60,
                        ),
                      ),
                    ],
                  );
                }
                if (state is OnPickingImageSuccess) {
                  return Image.memory(
                    state.image,
                    fit: BoxFit.cover,
                  );
                }
                return Icon(
                  Icons.image,
                  size: 100,
                  color: ColorPalete.primary,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
