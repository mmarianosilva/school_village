import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onTextInput;
  final VoidCallback onTap;

  const SearchBar({Key key, this.controller, this.onTextInput, this.onTap}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState(this.controller, this.onTextInput);
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
        color: Color.fromARGB(205, 0, 88, 110)
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.search, color: Colors.white),
          Expanded(
            child: TextField(
              controller: this._controller,
              onChanged: onTextInput,
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.white)
              ),
              onTap: widget != null ? widget.onTap : null,
            ),
          ),
          Icon(Icons.mic, color: Colors.white)
        ],
      ),
    );
  }
}
