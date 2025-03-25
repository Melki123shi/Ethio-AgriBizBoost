import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String? image;
  const Header({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 16, left: 16, top: 30, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/plant.jpeg'),
          ),
          Row(
            children: [
              image != null ? CircleAvatar(radius: 15, backgroundImage: AssetImage('$image')) :
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB0FF72), Color(0xFF7EFFA1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).dividerColor,
                  size: 20,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications),
                color: Theme.of(context).focusColor,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
