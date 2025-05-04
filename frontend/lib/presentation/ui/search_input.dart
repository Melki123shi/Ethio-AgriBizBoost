import 'package:app/presentation/utils/localization_extension.dart';
import 'package:flutter/material.dart';

class SearchInputField extends StatelessWidget {
  const SearchInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 45,
      child: TextField(
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          labelText: '${context.commonLocals.search}...', 
          labelStyle: const TextStyle(color: Colors.grey), 
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor, 
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30), 
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            color:Colors.grey, 
            onPressed: () {
            },
          ),
        ),
      ),
    );
  }
}
