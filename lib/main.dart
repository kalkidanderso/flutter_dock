import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dock Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

/// HomePage widget that contains the [Dock].
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dock Demo')),
      body: Center(
        child: Dock<IconData>(
          items: const [
            Icons.person,
            Icons.message,
            Icons.call,
            Icons.camera,
            Icons.photo,
          ],
          builder: (IconData icon, bool isDragging) {
            return DockItem(
              icon: icon,
              isDragging: isDragging,
            );
          },
        ),
      ),
    );
  }
}

/// A single item in the [Dock].
class DockItem extends StatelessWidget {
  final IconData icon;
  final bool isDragging;

  const DockItem({
    super.key,
    required this.icon,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      height: 48,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Center(child: Icon(icon, color: Colors.white)),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  /// Constructor for the Dock widget.
  const Dock({
    super.key,
    required this.items,
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder function for creating widgets from [T] items.
  final Widget Function(T, bool) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> with TickerProviderStateMixin {
  /// [T] items being manipulated.
  late List<T> _items;

  /// Controller for the reordering animation.
  late final AnimationController _reorderAnimationController;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _reorderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _reorderAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return Draggable<int>(
            key: ValueKey(_items[index]),
            data: index,
            feedback: widget.builder(_items[index], true),
            childWhenDragging: Opacity(
              opacity: 0.5,
              child: widget.builder(_items[index], false),
            ),
            child: DragTarget<int>(
              builder: (context, candidateData, rejectedData) {
                return widget.builder(_items[index], false);
              },
              onAccept: (int oldIndex) => _onReorder(oldIndex, index),
            ),
          );
        },
        onReorder: _onReorder,
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              final double animValue =
                  Curves.easeInOut.transform(animation.value);
              final double elevation = lerpDouble(0, 6, animValue)!;
              return Material(
                elevation: elevation,
                color: Colors.transparent,
                child: child,
              );
            },
            child: child,
          );
        },
      ),
    );
  }

  /// Handles the reordering of items in the dock.
  ///
  /// [oldIndex] is the original position of the item.
  /// [newIndex] is the new position where the item should be placed.
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final T item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });

    _reorderAnimationController.forward(from: 0);
  }
}
