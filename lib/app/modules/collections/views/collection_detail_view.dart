import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/strings.dart';
import '../../../core/services/localization_service.dart';
import '../../../data/models/collection.dart';
import '../../../data/models/pdf_document.dart';
import '../../library/controllers/library_controller.dart';
import '../../library/widgets/document_card.dart';
import '../../library/widgets/document_grid_card.dart';
import '../controllers/collections_controller.dart';

class CollectionDetailView extends StatelessWidget {
  const CollectionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final collection = Get.arguments as Collection;
    final collectionsController = Get.find<CollectionsController>();
    final libraryController = Get.find<LibraryController>();
    final l10n = Get.find<LocalizationService>();
    final theme = Theme.of(context);
    final collectionColor = Color(collection.colorValue);

    return Scaffold(
      appBar: AppBar(
        title: Text(collection.name),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(_getViewModeIcon(libraryController.viewMode.value)),
              onPressed: libraryController.cycleViewMode,
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Obx(() {
        final documents = collectionsController.getDocumentsInCollection(
          collection,
        );

        if (documents.isEmpty) {
          return _buildEmptyState(context, l10n, theme, collectionColor);
        }

        switch (libraryController.viewMode.value) {
          case LibraryViewMode.list:
            return _buildListView(
              documents,
              libraryController,
              collectionsController,
              l10n,
              context,
            );
          case LibraryViewMode.grid:
            return _buildGridView(
              documents,
              libraryController,
              collectionsController,
              l10n,
              context,
            );
          case LibraryViewMode.staggered:
            return _buildStaggeredView(
              documents,
              libraryController,
              collectionsController,
              l10n,
              context,
            );
        }
      }),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    LocalizationService l10n,
    ThemeData theme,
    Color collectionColor,
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
                color: collectionColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Iconsax.document, size: 40, color: collectionColor),
            ),
            const SizedBox(height: 24),
            Text(l10n.tr('emptyCollection'), style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              l10n.tr('emptyCollectionDescription'),
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

  Widget _buildListView(
    List<PdfDocument> documents,
    LibraryController libraryController,
    CollectionsController collectionsController,
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
          onTap: () => libraryController.openDocument(doc),
          onFavorite: () => libraryController.toggleFavorite(doc),
          onDelete: () => _showRemoveFromCollectionDialog(
            context,
            doc,
            collectionsController,
            l10n,
          ),
        );
      },
    );
  }

  Widget _buildGridView(
    List<PdfDocument> documents,
    LibraryController libraryController,
    CollectionsController collectionsController,
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
          onTap: () => libraryController.openDocument(doc),
          onFavorite: () => libraryController.toggleFavorite(doc),
          onDelete: () => _showRemoveFromCollectionDialog(
            context,
            doc,
            collectionsController,
            l10n,
          ),
          isStaggered: false,
        );
      },
    );
  }

  Widget _buildStaggeredView(
    List<PdfDocument> documents,
    LibraryController libraryController,
    CollectionsController collectionsController,
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
          onTap: () => libraryController.openDocument(doc),
          onFavorite: () => libraryController.toggleFavorite(doc),
          onDelete: () => _showRemoveFromCollectionDialog(
            context,
            doc,
            collectionsController,
            l10n,
          ),
          isStaggered: true,
        );
      },
    );
  }

  void _showRemoveFromCollectionDialog(
    BuildContext context,
    PdfDocument doc,
    CollectionsController controller,
    LocalizationService l10n,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.tr('removeFromCollection')),
        content: Text('${doc.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.tr('cancel')),
          ),
          TextButton(
            onPressed: () async {
              await controller.removeDocumentFromCollection(doc);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.tr('removeFromCollection')),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
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
}
