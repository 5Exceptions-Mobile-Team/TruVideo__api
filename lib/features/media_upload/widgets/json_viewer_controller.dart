import 'package:get/get.dart';

class JsonViewerController extends GetxController {
  // Map to track expanded state of JSON items by their unique keys
  final RxMap<String, bool> expandedItems = <String, bool>{}.obs;

  // Check if an item is expanded
  bool isExpanded(String key) {
    return expandedItems[key] ?? false;
  }

  // Toggle expanded state
  void toggleExpanded(String key) {
    expandedItems[key] = !isExpanded(key);
  }

  // Set initial expanded state
  void setExpanded(String key, bool value) {
    expandedItems[key] = value;
  }

  // Clear all expanded states (useful when data changes)
  void clearExpandedStates() {
    expandedItems.clear();
  }
}
