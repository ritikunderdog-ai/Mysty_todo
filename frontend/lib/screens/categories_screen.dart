import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mysty/theme/cyberpunk_theme.dart';
import 'package:mysty/providers/category_provider.dart';

/// Categories management screen.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'LABELS',
                  style: TextStyle(
                    color: CyberpunkColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                ),
                IconButton(
                  onPressed: () => _showAddCategoryDialog(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CyberpunkColors.primary.withValues(alpha: 0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CyberpunkColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: CyberpunkColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category list
            Expanded(
              child: Consumer<CategoryProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: CyberpunkColors.primary,
                      ),
                    );
                  }

                  if (provider.categories.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.label_off_outlined,
                            color: CyberpunkColors.textSecondary.withValues(alpha: 0.3),
                            size: 64,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'NO LABELS',
                            style: TextStyle(
                              color: CyberpunkColors.textSecondary,
                              fontSize: 14,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Create labels to organize your tasks',
                            style: TextStyle(
                              color: CyberpunkColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: provider.categories.length,
                    itemBuilder: (context, index) {
                      final category = provider.categories[index];
                      final color = _parseColor(category.color);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: neonGlowDecoration(
                          glowColor: color,
                          blurRadius: 6,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: const TextStyle(
                                      color: CyberpunkColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${category.taskCount} tasks',
                                    style: const TextStyle(
                                      color: CyberpunkColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _deleteCategory(
                                context,
                                category.id,
                                category.name,
                              ),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: CyberpunkColors.textSecondary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    String selectedColor = '#00fff5';

    final colors = [
      '#00fff5', '#ff00ff', '#f5ff00', '#ff3131',
      '#00ff88', '#ff6b35', '#8b5cf6', '#3b82f6',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: CyberpunkColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: CyberpunkColors.primary,
              width: 1,
            ),
          ),
          title: const Text(
            'NEW LABEL',
            style: TextStyle(
              color: CyberpunkColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(
                  color: CyberpunkColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  hintText: 'Label name',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'COLOR',
                style: TextStyle(
                  color: CyberpunkColors.textSecondary,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colors.map((hex) {
                  final isSelected = selectedColor == hex;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = hex),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _parseColor(hex),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _parseColor(hex).withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: CyberpunkColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  context.read<CategoryProvider>().createCategory(
                        name: nameController.text.trim(),
                        color: selectedColor,
                      );
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'CREATE',
                style: TextStyle(color: CyberpunkColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCategory(
    BuildContext context,
    int categoryId,
    String name,
  ) async {
    final provider = context.read<CategoryProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CyberpunkColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CyberpunkColors.error, width: 1),
        ),
        title: const Text(
          'DELETE LABEL?',
          style: TextStyle(
            color: CyberpunkColors.error,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        content: Text(
          'Delete "$name"? Tasks in this label will become uncategorized.',
          style: const TextStyle(
            color: CyberpunkColors.textSecondary,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: CyberpunkColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'DELETE',
              style: TextStyle(color: CyberpunkColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      provider.deleteCategory(categoryId);
    }
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return CyberpunkColors.primary;
    }
  }
}
