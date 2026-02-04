import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/collection_icons.dart';
import '../../../core/constants/strings.dart';
import '../../../core/services/localization_service.dart';
import '../../../data/models/collection.dart';
import '../../../data/models/pdf_document.dart';
import '../../collections/controllers/collections_controller.dart';
import '../controllers/library_controller.dart';
import '../widgets/document_card.dart';
import '../widgets/document_grid_card.dart';
import '../widgets/empty_state.dart';

class LibraryView extends GetView<LibraryController> {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = Get.find<LocalizationService>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 30,
        title: Obx(() => Text(l10n.tr('appName'))),
        actions: [
          // View mode toggle button
          Obx(
            () => IconButton(
              icon: Icon(_getViewModeIcon(controller.viewMode.value)),
              onPressed: controller.cycleViewMode,
              tooltip: _getViewModeTooltip(controller.viewMode.value, l10n),
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.bookmark),
            onPressed: () => Get.toNamed('/highlights'),
            tooltip: l10n.tr('highlights'),
          ),
          IconButton(
            icon: const Icon(Iconsax.setting_2),
            onPressed: () => Get.toNamed('/settings'),
            tooltip: l10n.tr('settings'),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(l10n, theme),
          Expanded(child: Obx(() => _buildContent(l10n, context))),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.pickAndAddPdf,
        icon: const Icon(Iconsax.add),
        label: Obx(() => Text(l10n.tr('openPdf'))),
      ),
    );
  }

  IconData _getViewModeIcon(LibraryViewMode mode) {
    switch (mode) {
      case LibraryViewMode.list:
        return Iconsax.menu;
      case LibraryViewMode.grid:
        return Iconsax.grid_2;
      case LibraryViewMode.staggered:
        return Iconsax.element_3;
    }
  }

  String _getViewModeTooltip(LibraryViewMode mode, LocalizationService l10n) {
    switch (mode) {
      case LibraryViewMode.list:
        return l10n.tr('viewList');
      case LibraryViewMode.grid:
        return l10n.tr('viewGrid');
      case LibraryViewMode.staggered:
        return l10n.tr('viewStaggered');
    }
  }

  Widget _buildTabBar(LocalizationService l10n, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(
        () => Row(
          children: [
            _buildTab(l10n.tr('recent'), 0, theme, Iconsax.clock),
            _buildTab(l10n.tr('favorites'), 1, theme, Iconsax.heart),
            _buildTab(l10n.tr('collections'), 2, theme, Iconsax.folder_2),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index, ThemeData theme, IconData icon) {
    final isSelected = controller.selectedTabIndex.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setTabIndex(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(LocalizationService l10n, BuildContext context) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    // Collections tab
    if (controller.selectedTabIndex.value == 2) {
      return _buildCollectionsContent(l10n, context);
    }

    final documents = controller.selectedTabIndex.value == 0
        ? controller.recentDocuments
        : controller.favoriteDocuments;

    if (documents.isEmpty) {
      return EmptyState(
        icon: controller.selectedTabIndex.value == 0
            ? Iconsax.book
            : Iconsax.heart,
        title: controller.selectedTabIndex.value == 0
            ? l10n.tr('noDocuments')
            : l10n.tr('noFavorites'),
        description: controller.selectedTabIndex.value == 0
            ? l10n.tr('noDocumentsDescription')
            : l10n.tr('noFavoritesDescription'),
      );
    }

    // Build different layouts based on view mode
    switch (controller.viewMode.value) {
      case LibraryViewMode.list:
        return _buildListView(documents, l10n, context);
      case LibraryViewMode.grid:
        return _buildGridView(documents, l10n, context);
      case LibraryViewMode.staggered:
        return _buildStaggeredView(documents, l10n, context);
    }
  }

  Widget _buildCollectionsContent(
    LocalizationService l10n,
    BuildContext context,
  ) {
    final collectionsController = Get.find<CollectionsController>();
    final theme = Theme.of(context);

    // No need for Obx here - parent widget already has Obx wrapping _buildContent
    if (collectionsController.collections.isEmpty) {
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
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Get.toNamed('/collections'),
                icon: const Icon(Iconsax.add),
                label: Text(l10n.tr('createCollection')),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick access to full collections page
        ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Iconsax.setting_4, color: theme.colorScheme.primary),
          ),
          title: Text(l10n.tr('collections')),
          subtitle: Text(
            '${collectionsController.collections.length} ${l10n.tr('collections').toLowerCase()}',
          ),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () => Get.toNamed('/collections'),
        ),
        const Divider(height: 32),
        // Collection grid
        ...collectionsController.collections.map((collection) {
          return _buildCollectionTile(
            collection,
            collectionsController,
            l10n,
            theme,
          );
        }),
      ],
    );
  }

  Widget _buildCollectionTile(
    Collection collection,
    CollectionsController collectionsController,
    LocalizationService l10n,
    ThemeData theme,
  ) {
    final collectionColor = Color(collection.colorValue);
    final documentCount = collectionsController
        .getDocumentsInCollection(collection)
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: collectionColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            CollectionIcons.getIcon(collection.iconName),
            color: collectionColor,
          ),
        ),
        title: Text(
          collection.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text('$documentCount ${l10n.tr('documents')}'),
        trailing: const Icon(Iconsax.arrow_right_3),
        onTap: () =>
            Get.toNamed('/collection/${collection.id}', arguments: collection),
      ),
    );
  }

  /// Get collection name for a document
  String? _getCollectionName(PdfDocument doc) {
    if (doc.collectionId == null) return null;
    final collectionsController = Get.find<CollectionsController>();
    final collection = collectionsController.collections.firstWhereOrNull(
      (c) => c.id == doc.collectionId,
    );
    return collection?.name;
  }

  Widget _buildListView(
    List<PdfDocument> documents,
    LocalizationService l10n,
    BuildContext context,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        return DocumentCard(
          document: doc,
          onTap: () => controller.openDocument(doc),
          onFavorite: () => controller.toggleFavorite(doc),
          onDelete: () => _showDeleteDialog(context, doc, l10n),
          onMoveToCollection: () => _showMoveToCollectionDialog(context, doc),
          collectionName: _getCollectionName(doc),
        );
      },
    );
  }

  Widget _buildGridView(
    List<PdfDocument> documents,
    LocalizationService l10n,
    BuildContext context,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        return DocumentGridCard(
          document: doc,
          onTap: () => controller.openDocument(doc),
          onFavorite: () => controller.toggleFavorite(doc),
          onDelete: () => _showDeleteDialog(context, doc, l10n),
          onLongPress: () => _showMoveToCollectionDialog(context, doc),
          collectionName: _getCollectionName(doc),
          isStaggered: false,
        );
      },
    );
  }

  Widget _buildStaggeredView(
    List<PdfDocument> documents,
    LocalizationService l10n,
    BuildContext context,
  ) {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        return DocumentGridCard(
          document: doc,
          onTap: () => controller.openDocument(doc),
          onFavorite: () => controller.toggleFavorite(doc),
          onDelete: () => _showDeleteDialog(context, doc, l10n),
          onLongPress: () => _showMoveToCollectionDialog(context, doc),
          collectionName: _getCollectionName(doc),
          isStaggered: true,
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    PdfDocument doc,
    LocalizationService l10n,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tr('removeFromLibrary')),
        content: Text('${doc.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              controller.deleteDocument(doc);
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

  void _showMoveToCollectionDialog(
    BuildContext context,
    PdfDocument doc,
  ) async {
    final collectionsController = Get.find<CollectionsController>();
    final l10n = Get.find<LocalizationService>();
    final previousCollectionId = doc.collectionId;

    final collection = await collectionsController.showCollectionPicker(
      context,
    );

    // Check if context is still mounted
    if (!context.mounted) return;

    if (collection != null) {
      await collectionsController.moveDocumentToCollection(doc, collection);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.tr('addToCollection')}: ${collection.name}'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else if (previousCollectionId != null) {
      // Only show removal message if document was actually in a collection
      await collectionsController.removeDocumentFromCollection(doc);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.tr('removeFromCollection')),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
    controller.loadDocuments();
  }
}
