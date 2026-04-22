import 'package:flutter/material.dart';

typedef CellTap = void Function(int index);

class SudokuGrid extends StatelessWidget {
  final List<int> values;
  final List<bool> fixed;
  final int? selectedIndex;
  final bool Function(int index)? isCorrectAt;
  final CellTap? onTap;
  final bool readOnly;

  const SudokuGrid({
    super.key,
    required this.values,
    required this.fixed,
    required this.selectedIndex,
    this.isCorrectAt,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
        ),
        itemCount: 81,
        itemBuilder: (context, index) {
          final v = values[index];
          final isFixed = fixed[index];
          final isSelected = selectedIndex == index;
          final correct = isCorrectAt?.call(index) ?? true;

          final r = index ~/ 9;
          final c = index % 9;
          final thickTop = r % 3 == 0;
          final thickLeft = c % 3 == 0;

          return InkWell(
            onTap: readOnly ? null : () => onTap?.call(index),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: thickTop ? 2 : 0.5,
                  ),
                  left: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: thickLeft ? 2 : 0.5,
                  ),
                  right: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: c == 8 ? 2 : 0.5,
                  ),
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: r == 8 ? 2 : 0.5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  v == 0 ? '' : '$v',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isFixed ? FontWeight.bold : FontWeight.w500,
                    color: isFixed
                        ? Theme.of(context).colorScheme.onSurface
                        : (readOnly
                            ? Theme.of(context).colorScheme.primary
                            : (correct
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.error)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

