import 'package:flutter/material.dart';
import 'package:school_village/model/searchable.dart';
import 'package:school_village/widgets/search/search_bar.dart';

const Duration _waitingDuration = Duration(milliseconds: 200);

class SearchDropdownField<T extends Searchable> extends StatefulWidget {
  const SearchDropdownField({
    Key key,
    this.closeOnTap = true,
    this.contentHeight = 256.0,
    this.contentPercentWidth,
    this.controller,
    this.data,
    this.focusNode,
    this.hint,
    this.itemBuilder,
    this.onItemTap,
  }) : super(key: key);

  final bool closeOnTap;
  final double contentHeight;
  final double contentPercentWidth;
  final TextEditingController controller;
  final List<T> data;
  final FocusNode focusNode;
  final String hint;
  final Widget Function(BuildContext, T) itemBuilder;
  final Function(T) onItemTap;

  @override
  _SearchDropdownFieldState<T> createState() => _SearchDropdownFieldState();
}

class _SearchDropdownFieldState<T extends Searchable>
    extends State<SearchDropdownField> {
  final List<T> _filteredData = List<T>();
  TextEditingController _textEditingController;
  OverlayEntry entry;
  double contentHeight = 0.0;

  @override
  void initState() {
    _textEditingController = widget.controller ?? TextEditingController();
    super.initState();
  }

  void _filterResults(String text) {
    _filteredData.clear();
    if (text.isEmpty) {
      _onClosed();
      return;
    }
    final Iterable<T> matching = widget.data
        .where((Searchable item) => item.filter(text));
    if (matching.isEmpty) {
      _onClosed();
    } else {
      _displayItemsIfNotVisible();
      setState(() {
        _filteredData.addAll(matching);
        entry?.markNeedsBuild();
      });
    }
  }

  Future<void> _onClosed() async {
    contentHeight = 0.0;
    entry?.markNeedsBuild();
    await Future<void>.delayed(Duration(
        milliseconds: (_waitingDuration.inMilliseconds * 1.3).toInt()));
    entry?.remove();
    entry = null;
  }

  void _displayItemsIfNotVisible() {
    if (entry == null || contentHeight < widget.contentHeight) {
      _displayItems();
    }
  }

  Future<void> _displayItems() async {
    entry?.remove();

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final mediaQuerySize = MediaQuery.of(context).size;
    final topPosition = offset.dy + size.height;

    final contentWidth = widget.contentPercentWidth != null
        ? mediaQuerySize.width * widget.contentPercentWidth
        : size.width;

    entry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _onClosed(),
                  child: Container(
                    color: Colors.black12,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration:
                    Duration(milliseconds: _waitingDuration.inMilliseconds * 2),
                left: offset.dx,
                top: topPosition,
                height: contentHeight,
                width: contentWidth,
                child: Material(
                  elevation: 10,
                  color: Color.fromARGB(205, 0, 88, 110),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _filteredData.length,
                    itemBuilder: (_, index) {
                      final item = _filteredData[index];
                      if (widget.itemBuilder != null) {
                        return GestureDetector(
                          onTap: () {
                            _textEditingController.clear();
                            widget.onItemTap(
                              item,
                            );
                            _onClosed();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: widget.itemBuilder(
                              context,
                              item,
                            ),
                          ),
                        );
                      }
                      return ListTile(
                        onTap: () {
                          _textEditingController.clear();
                          widget.onItemTap(item);
                          _onClosed();
                        },
                        title: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Text(
                            item.toString(),
                            maxLines: 1,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(entry);
    Future.delayed(_waitingDuration, () {
      if (widget.contentHeight + topPosition > mediaQuerySize.height) {
        contentHeight =
            mediaQuerySize.height - topPosition - kMaterialListPadding.vertical;
      } else {
        contentHeight = widget.contentHeight;
      }

      entry?.markNeedsBuild();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SearchBar(
          controller: _textEditingController,
          focusNode: widget.focusNode,
          hint: widget.hint,
          onTextInput: _filterResults,
        ),
        const SizedBox(height: 0.0),
      ],
    );
  }
}
