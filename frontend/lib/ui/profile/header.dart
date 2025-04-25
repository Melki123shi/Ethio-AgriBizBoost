import 'package:app/ui/profile/profile_screen.dart';
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
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                ),
                child: image != null
                    ? CircleAvatar(
                        radius: 15,
                        backgroundImage: AssetImage(image!),
                      )
                    : Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFB0FF72), Color(0xFF7EFFA1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.person,
                          size: 18,
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications),
                color: Theme.of(context).focusColor,
                splashRadius: 20,
                onPressed: () {},
              ),
            ],
          )
        ],
      ),
    );
  }
}
