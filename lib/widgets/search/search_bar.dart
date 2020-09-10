import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({
    Key key,
    this.controller,
    this.displayIcon = true,
    this.focusNode,
    this.hint,
    this.onTextInput,
    this.onTap,
  }) : super(key: key);

  final TextEditingController controller;
  final bool displayIcon;
  final FocusNode focusNode;
  final String hint;
  final Function(String) onTextInput;
  final VoidCallback onTap;

  @override
  _SearchBarState createState() =>
      _SearchBarState(this.controller, this.onTextInput);
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller;
  final Function(String) onTextInput;

  _SearchBarState(this._controller, this.onTextInput);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: Color.fromARGB(205, 0, 88, 110)),
      child: Row(
        children: <Widget>[
          widget.displayIcon ?
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
            )
          :
            const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              controller: this._controller,
              onChanged: onTextInput,
              decoration: InputDecoration(
                  hintText: widget.hint ?? "Search",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: InputBorder.none),
              style: TextStyle(color: Colors.white),
              onTap: widget != null ? widget.onTap : null,
              focusNode: widget.focusNode,
            ),
          ),
//          Icon(Icons.mic, color: Colors.white)
        ],
      ),
    );
  }
}
