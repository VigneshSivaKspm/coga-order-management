import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Widget for filtering and searching orders
class OrderFilters extends StatefulWidget {
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onStatusChanged;
  final String initialSearchQuery;
  final String initialStatusFilter;

  const OrderFilters({
    super.key,
    this.onSearchChanged,
    this.onStatusChanged,
    this.initialSearchQuery = '',
    this.initialStatusFilter = 'All',
  });

  @override
  State<OrderFilters> createState() => _OrderFiltersState();
}

class _OrderFiltersState extends State<OrderFilters> {
  late TextEditingController _searchController;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearchQuery);
    _selectedStatus = widget.initialStatusFilter;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: kBorderColor)),
      ),
      child: Row(
        children: [
          // Search Field
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              onChanged: widget.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or order ID...',
                hintStyle: const TextStyle(color: kTextTertiary, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search,
                  color: kTextTertiary,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: kTextTertiary,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearchChanged?.call('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: kSurfaceColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kDefaultRadius),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kDefaultRadius),
                  borderSide: const BorderSide(color: kBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kDefaultRadius),
                  borderSide: const BorderSide(
                    color: kPrimaryColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Status Filter Dropdown
          Container(
            decoration: BoxDecoration(
              color: kSurfaceColor,
              borderRadius: BorderRadius.circular(kDefaultRadius),
              border: Border.all(color: kBorderColor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatus,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: kTextSecondary,
                ),
                style: const TextStyle(fontSize: 14, color: kTextPrimary),
                items: kOrderStatusFilters.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Row(
                      children: [
                        if (status != 'All') ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getStatusColor(status),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(status),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                    widget.onStatusChanged?.call(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFF92400E);
      case 'processing':
        return const Color(0xFF1E40AF);
      case 'shipped':
        return const Color(0xFF6B21A8);
      case 'delivered':
        return const Color(0xFF065F46);
      case 'cancelled':
        return const Color(0xFF991B1B);
      default:
        return kTextSecondary;
    }
  }
}

/// Compact filter bar for mobile
class CompactOrderFilters extends StatelessWidget {
  final String searchQuery;
  final String statusFilter;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;

  const CompactOrderFilters({
    super.key,
    required this.searchQuery,
    required this.statusFilter,
    this.onSearchTap,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: kBorderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onSearchTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: kSurfaceColor,
                  borderRadius: BorderRadius.circular(kDefaultRadius),
                  border: Border.all(color: kBorderColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: kTextTertiary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        searchQuery.isNotEmpty
                            ? searchQuery
                            : 'Search orders...',
                        style: TextStyle(
                          fontSize: 14,
                          color: searchQuery.isNotEmpty
                              ? kTextPrimary
                              : kTextTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: statusFilter != 'All' ? kPrimaryColor : kSurfaceColor,
                borderRadius: BorderRadius.circular(kDefaultRadius),
                border: Border.all(
                  color: statusFilter != 'All' ? kPrimaryColor : kBorderColor,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: statusFilter != 'All'
                        ? Colors.white
                        : kTextSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    statusFilter,
                    style: TextStyle(
                      fontSize: 14,
                      color: statusFilter != 'All'
                          ? Colors.white
                          : kTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Status filter chips
class StatusFilterChips extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String>? onStatusChanged;

  const StatusFilterChips({
    super.key,
    required this.selectedStatus,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      child: Row(
        children: kOrderStatusFilters.map((status) {
          final isSelected = selectedStatus == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onStatusChanged?.call(status);
                }
              },
              backgroundColor: kSurfaceColor,
              selectedColor: kPrimaryColor.withOpacity(0.1),
              checkmarkColor: kPrimaryColor,
              labelStyle: TextStyle(
                fontSize: 13,
                color: isSelected ? kPrimaryColor : kTextSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected ? kPrimaryColor : kBorderColor,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          );
        }).toList(),
      ),
    );
  }
}
