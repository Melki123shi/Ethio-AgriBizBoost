import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
              IconButton(
                  icon: const Icon(Icons.chat_rounded),
                  iconSize: 30,
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    context.push('/chatbot');
                  }),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  context.push('/profile');
                },
                child: image != null
                    ? CircleAvatar(
                        radius: 15,
                        backgroundImage: AssetImage(image!),
                      )
                    : Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.person,
                          size: 18,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
              )
            ],
          )
        ],
      ),
    );
  }
}
