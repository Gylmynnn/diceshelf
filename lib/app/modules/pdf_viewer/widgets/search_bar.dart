import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/colors.dart';
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

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: EverblushColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  widget.controller.clearSearch();
                  widget.controller.isSearching.value = false;
                },
                color: EverblushColors.textPrimary,
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  style: const TextStyle(color: EverblushColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: l10n.tr('searchInDocument'),
                    hintStyle: const TextStyle(
                      color: EverblushColors.textMuted,
                    ),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: EverblushColors.backgroundLight,
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
                      borderSide: const BorderSide(
                        color: EverblushColors.primary,
                        width: 1,
                      ),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: EverblushColors.textSecondary,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              widget.controller.clearSearch();
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
        ),
      ),
    );
  }
}
