import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/services/localization_service.dart';
import '../../../data/models/collection.dart';
import '../controllers/collections_controller.dart';
import '../widgets/collection_card.dart';
import '../widgets/collection_form_dialog.dart';

class CollectionsView extends GetView<CollectionsController> {
  const CollectionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = Get.find<LocalizationService>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(l10n.tr('collections'))),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.collections.isEmpty) {
          return _buildEmptyState(context, l10n, theme);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.collections.length,
          itemBuilder: (context, index) {
            final collection = controller.collections[index];
            return CollectionCard(
              collection: collection,
              documentCount: controller
                  .getDocumentsInCollection(collection)
                  .length,
              onTap: () => _openCollection(context, collection),
              onEdit: () => _showEditDialog(context, collection, l10n),
              onDelete: () => _showDeleteDialog(context, collection, l10n),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, l10n),
        icon: const Icon(Iconsax.add),
        label: Obx(() => Text(l10n.tr('createCollection'))),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    LocalizationService l10n,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Iconsax.folder_2,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.tr('noCollections'), style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              l10n.tr('noCollectionsDescription'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openCollection(BuildContext context, Collection collection) {
    Get.toNamed('/collection/${collection.id}', arguments: collection);
  }

  void _showCreateDialog(BuildContext context, LocalizationService l10n) {
    controller.prepareForCreate();
    showDialog(
      context: context,
      builder: (dialogContext) => CollectionFormDialog(
        title: l10n.tr('createCollection'),
        onSave: () async {
          final result = await controller.createCollection();
          if (result != null && dialogContext.mounted) {
            Navigator.pop(dialogContext);
          }
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    Collection collection,
    LocalizationService l10n,
  ) {
    controller.prepareForEdit(collection);
    showDialog(
      context: context,
      builder: (dialogContext) => CollectionFormDialog(
        title: l10n.tr('editCollection'),
        onSave: () async {
          await controller.updateCollection(collection);
          if (dialogContext.mounted) {
            Navigator.pop(dialogContext);
          }
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Collection collection,
    LocalizationService l10n,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tr('deleteCollection')),
        content: Text('${collection.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              controller.deleteCollection(collection);
              Navigator.pop(context);
            },
            child: Text(
              l10n.tr('delete'),
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
