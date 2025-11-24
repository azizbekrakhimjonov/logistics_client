import 'package:get_it/get_it.dart';
import '../repositories/auth_repositories.dart';
import '../repositories/services_repository.dart';

GetIt di = GetIt.instance;

Future<void> locatorSetUp() async {
 di.registerSingleton(AuthRepository());
 di.registerSingleton(ServicesRepository());

}