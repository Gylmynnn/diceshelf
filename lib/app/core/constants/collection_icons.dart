import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Centralized icon mapping for collections to avoid code duplication.
/// Used by: CollectionsController, CollectionCard, CollectionFormDialog, LibraryView
class CollectionIcons {
  CollectionIcons._();

  /// Static const map for O(1) icon lookup
  static const Map<String, IconData> iconMap = {
    'folder': Iconsax.folder_2,
    'book': Iconsax.book,
    'document': Iconsax.document,
    'archive': Iconsax.archive,
    'briefcase': Iconsax.briefcase,
    'category': Iconsax.category,
    'clipboard': Iconsax.clipboard,
    'note': Iconsax.note,
    'bookmark': Iconsax.bookmark,
    'star': Iconsax.star,
    'heart': Iconsax.heart,
    'flag': Iconsax.flag,
    'tag': Iconsax.tag,
    'layer': Iconsax.layer,
    'box': Iconsax.box,
  };

  /// Default icon when icon name is not found
  static const IconData defaultIcon = Iconsax.folder_2;

  /// Get IconData from icon name string with O(1) lookup
  static IconData getIcon(String iconName) {
    return iconMap[iconName] ?? defaultIcon;
  }
}
