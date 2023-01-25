part of 'setup_properties_cubit.dart';

abstract class SetupPropertiesState extends Equatable {
  const SetupPropertiesState();

  @override
  List<Object> get props => [];
}

class SetupPropertiesInitial extends SetupPropertiesState {}

class SetupPropertiesBlockScreen extends SetupPropertiesState {}

class SetupPropertiesAppReady extends SetupPropertiesState {}

class SetupPropertiesIsOnPreferences extends SetupPropertiesState {}
