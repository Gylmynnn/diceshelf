import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/localization_service.dart';
import '../controllers/pdf_viewer_controller.dart';

class PdfSearchBar extends StatefulWidget {
  final PdfViewerController controller;

  const PdfSearchBar({super.key, required this.controller});

  @override
  State<PdfSearchBar> createState() => _PdfSearchBarState();
}

class _PdfSearchBarState extends State<PdfSearchBar> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Get.find<LocalizationService>();
    final theme = Theme.of(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: theme.colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () {
                      widget.controller.clearSearch();
                      widget.controller.isSearching.value = false;
                    },
                    color: theme.colorScheme.onSurface,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: l10n.tr('searchInDocument'),
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1,
                          ),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  widget.controller.clearSearch();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        widget.controller.search(value);
                        setState(() {});
                      },
                      onSubmitted: (value) {
                        widget.controller.search(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              // Search results info and navigation
              Obx(() {
                final resultCount = widget.controller.searchResultCount.value;
                final currentIndex = widget.controller.currentSearchIndex.value;
                final isInProgress = widget.controller.isSearchInProgress.value;

                if (_searchController.text.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8, left: 48, right: 8),
                  child: Row(
                    children: [
                      if (isInProgress)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      else if (resultCount > 0)
                        Text(
                          '$currentIndex / $resultCount',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: 14,
                          ),
                        )
                      else
                        Text(
                          l10n.tr('noResultsFound'),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                            fontSize: 14,
                          ),
                        ),
                      const Spacer(),
                      if (resultCount > 0) ...[
                        IconButton(
                          icon: Icon(
                            Icons.keyboard_arrow_up_rounded,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          onPressed: widget.controller.goToPreviousSearchResult,
                          iconSize: 24,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          onPressed: widget.controller.goToNextSearchResult,
                          iconSize: 24,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
