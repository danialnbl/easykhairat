import 'package:get/get.dart';
import 'package:easykhairat/models/userModel.dart';

class NavigationController extends GetxController {
  var selectedIndex = 0.obs;
  var user = Rxn<User>();

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  // Method to set user
  void setUser(User newUser) {
    user.value = newUser;
  }

  // Method to get user
  User? getUser() {
    return user.value;
  }
}
