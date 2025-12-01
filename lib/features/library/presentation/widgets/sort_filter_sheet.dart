import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../app/theme.dart';

/// Sort options for library
enum SortOption {
  name,
  date,
  size,
  rating,
  viewCount,
}

/// Filter options for library
enum FilterOption {
  unviewed,
  bookmarked,
}

/// Bottom sheet for sort and filter options
class SortFilterSheet extends StatelessWidget {
  final SortOption currentSort;
  final bool sortAscending;
  final FilterOption? currentFilter;
  final void Function(SortOption option, bool ascending) onSortChanged;
  final void Function(FilterOption? option) onFilterChanged;

  const SortFilterSheet({
    super.key,
    required this.currentSort,
    required this.sortAscending,
    this.currentFilter,
    required this.onSortChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SelonaColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sort section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.sortBy,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 8),

          _SortOptionTile(
            title: l10n.sortByName,
            icon: Icons.sort_by_alpha,
            isSelected: currentSort == SortOption.name,
            ascending: sortAscending,
            onTap: () => onSortChanged(
              SortOption.name,
              currentSort == SortOption.name ? !sortAscending : true,
            ),
          ),
          _SortOptionTile(
            title: l10n.sortByDate,
            icon: Icons.calendar_today,
            isSelected: currentSort == SortOption.date,
            ascending: sortAscending,
            onTap: () => onSortChanged(
              SortOption.date,
              currentSort == SortOption.date ? !sortAscending : false,
            ),
          ),
          _SortOptionTile(
            title: l10n.sortBySize,
            icon: Icons.storage,
            isSelected: currentSort == SortOption.size,
            ascending: sortAscending,
            onTap: () => onSortChanged(
              SortOption.size,
              currentSort == SortOption.size ? !sortAscending : false,
            ),
          ),
          _SortOptionTile(
            title: l10n.sortByRating,
            icon: Icons.star_outline,
            isSelected: currentSort == SortOption.rating,
            ascending: sortAscending,
            onTap: () => onSortChanged(
              SortOption.rating,
              currentSort == SortOption.rating ? !sortAscending : false,
            ),
          ),
          _SortOptionTile(
            title: l10n.sortByViewCount,
            icon: Icons.visibility_outlined,
            isSelected: currentSort == SortOption.viewCount,
            ascending: sortAscending,
            onTap: () => onSortChanged(
              SortOption.viewCount,
              currentSort == SortOption.viewCount ? !sortAscending : false,
            ),
          ),

          const Divider(height: 32),

          // Filter section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.filterBy,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 8),

          _FilterOptionTile(
            title: l10n.filterUnviewed,
            icon: Icons.fiber_new,
            isSelected: currentFilter == FilterOption.unviewed,
            onTap: () => onFilterChanged(
              currentFilter == FilterOption.unviewed
                  ? null
                  : FilterOption.unviewed,
            ),
          ),
          _FilterOptionTile(
            title: l10n.filterBookmarked,
            icon: Icons.bookmark_outline,
            isSelected: currentFilter == FilterOption.bookmarked,
            onTap: () => onFilterChanged(
              currentFilter == FilterOption.bookmarked
                  ? null
                  : FilterOption.bookmarked,
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final bool ascending;
  final VoidCallback onTap;

  const _SortOptionTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.ascending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? SelonaColors.primaryAccent
            : SelonaColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? SelonaColors.primaryAccent
              : SelonaColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(
              ascending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 20,
              color: SelonaColors.primaryAccent,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _FilterOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOptionTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? SelonaColors.primaryAccent
            : SelonaColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? SelonaColors.primaryAccent
              : SelonaColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check,
              size: 20,
              color: SelonaColors.primaryAccent,
            )
          : null,
      onTap: onTap,
    );
  }
}
