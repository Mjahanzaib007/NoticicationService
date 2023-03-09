import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:foodle/app/routes/app_pages.dart';
import 'package:foodle/data/models/foodle_video.dart';
import 'package:foodle/data/repositories/search_repository.dart';
import 'package:foodle/presentation/profile/views/foreign_profile_view.dart';
import 'package:get/get.dart';

class DynamicLinkService {
  bool isOpenWithLink = false;
  Future handleDynamicLinks() async {
    // 1. Get the initial dynamic link if the app is opened with a dynamic link
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    Get.log('${DateTime.now()} [DynamicLinkService.handleDynamicLinks] called');

    if (data != null) {
      isOpenWithLink = true;
    }

    // 2. handle link that has been retrieved
    _handleDeepLink(data);

    // 3. Register a link callback to fire if the app is opened up from the background
    // using a dynamic link.
    // FirebaseDynamicLinks.instance.onLink(
    //     onSuccess: (PendingDynamicLinkData? dynamicLink) async {
    //       // 3a. handle link that has been retrieved
    //       isOpenWithLink=true;
    //       _handleDeepLink(dynamicLink);
    //     }, onError: (OnLinkErrorException e) async {
    //   print('Link Failed: ${e.message}');
    // }
    // );
    FirebaseDynamicLinks.instance.onLink.listen((event) {
      Get.log('[DynamicLinkService.handleDynamicLinks] called ');
      isOpenWithLink = true;
      _handleDeepLink(event);
    }, onError: (e) {
      print(
          '[DynamicLinkService.handleDynamicLinks] called error: ${e.message}');
    });
  }

  _handleDeepLink(PendingDynamicLinkData? data) async {
    Get.log('[DynamicLinkService._handleDeepLink] called ');
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      var isProfile = deepLink.toString().contains(Routes.PROFILE);
      var isCollection = deepLink.toString().contains(Routes.COLLECTIONS);
      var isHomePage = deepLink.toString().contains(Routes.HOME);
      var isRestaurant =
          deepLink.toString().contains(Routes.RESTAURANT_PROFILE);
      var isPlaylist = deepLink.toString().contains(Routes.PLAYLIST);
      Get.log('[DynamicLinkService._handleDeepLink] called1 $isProfile');
      if (isProfile) {
        var id = deepLink.queryParameters['userId'];
        Get.log('[DynamicLinkService._handleDeepLink] called2 $id');
        if (id != null) {
          Get.to(() => ForeignProfilePageView(), arguments: id)
              ?.then((value) => null);
          // Get.offAndToNamed(Routes.PRODUCT_DESCRIPTION,parameters: {"id":id.toString(),"order":"false"});
        }
      } else if (isHomePage) {
        var id = deepLink.queryParameters['videoId'];
        Get.log('[DynamicLinkService._handleDeepLink] called2 $id');

        if (id != null) {
          await getVideo(id).then((value) {
            if (value != null) {
              Get.toNamed(Routes.PROFILE_VIDEO_PLAYER, arguments: [
                0,
                [value]
              ]);
            }
          });

          // Get.offAndToNamed(Routes.PRODUCT_DESCRIPTION,parameters: {"id":id.toString(),"order":"false"});
        }
      } else if (isRestaurant) {
        var id = deepLink.queryParameters['restaurantId'];
        Get.log('[DynamicLinkService._handleDeepLink] called2 $id');
        if (id != null) {
          Get.toNamed(Routes.RESTAURANT_PROFILE, arguments: id);
          // Get.offAndToNamed(Routes.PRODUCT_DESCRIPTION,parameters: {"id":id.toString(),"order":"false"});
        }
      } else if (isPlaylist) {
        var id = deepLink.queryParameters['playlistId'];
        Get.log('[DynamicLinkService._handleDeepLink] called2 $id');
        if (id != null) {
          Get.toNamed(Routes.PROFILE_VIDEO_PLAYER, arguments: [0, []]);
          // Get.offAndToNamed(Routes.PRODUCT_DESCRIPTION,parameters: {"id":id.toString(),"order":"false"});
        }
      }

      print('_handleDeepLink | deeplink: ${deepLink.toString()}');
      print(deepLink.queryParameters.runtimeType);
    }
  }

  Future<FoodleVideo?> getVideo(id) async {
    Map<String, dynamic>? resp =
        await SearchRepository().getAllVideos("", 1, 1, id: id);
    if (resp != null && resp['payload'] != null && resp['payload'].isNotEmpty) {
      return FoodleVideo.fromJson(resp['payload'][0]);
    }
    return null;
  }
}
