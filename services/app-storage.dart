
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';


class AppStorage extends GetxService {

  static const key = 'customCacheKey';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 30,
      // fileSystem:,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

 static Future<FileInfo?> checkCache(String url)async{
    final FileInfo? value = await AppStorage.instance.getFileFromCache(url);
    return value;
  }
}
