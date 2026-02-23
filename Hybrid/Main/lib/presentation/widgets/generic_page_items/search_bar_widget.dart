import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final String hintText;
  final Function(String) onChanged;
  final TextEditingController? controller;
  final EdgeInsetsGeometry? padding;

  const SearchBarWidget({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.controller,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  bool _isControllerInternal = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _isControllerInternal = true;
    }
    
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (_isControllerInternal) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding!,
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear',
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}