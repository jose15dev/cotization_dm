import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@Injectable()
class CacheService {
  final SharedPreferences prefs;

  CacheService(this.prefs);
  Future<void> resetDatabase() async {
    await prefs.clear();
  }
}
