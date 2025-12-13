import 'package:flutter/material.dart';
import 'package:icare/screens/chat.dart';
import 'package:icare/screens/filters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_text_input.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class ChatlistScreen extends StatelessWidget {
  const ChatlistScreen({super.key});

  // Sample chat data
  final List<Map<String, String>> chats = const [
    {
      'name': 'Josiah Zayner',
      'time': '9:56 AM',
      'title': 'Hi there!',
      'message': 'How are you today?',
      'avatar': 'https://i.pravatar.cc/150?img=1',
    },
    {
      'name': 'Jillian Jacob',
      'time': 'yesterday',
      'title': "It's been a while",
      'message': 'How are you?',
      'avatar': 'https://i.pravatar.cc/150?img=2',
    },
    {
      'name': 'Victoria Hanson',
      'time': '5 Mar',
      'title': 'Photos from holiday',
      'message': 'Hi, I put together some photos from...',
      'avatar': 'https://i.pravatar.cc/150?img=3',
    },
    {
      'name': 'Victoria Hanson',
      'time': '4 Mar',
      'title': 'Lates order delivery',
      'message': 'Good morning! Hope you are good..',
      'avatar': 'https://i.pravatar.cc/150?img=4',
    },
    {
      'name': 'Peter Landt',
      'time': '4 Mar',
      'title': 'Service confirmation',
      'message': 'Respected Sir, I Peter, your computer...',
      'avatar': 'https://i.pravatar.cc/150?img=5',
    },
    {
      'name': 'Janice Nelson',
      'time': '3 Mar',
      'title': 'Re: Blog for beta relea...',
      'message': 'Hi, Please take a look at the beta...',
      'avatar': 'https://i.pravatar.cc/150?img=6',
    },
    {
      'name': 'James Norris',
      'time': '3 Mar',
      'title': 'Fwd: Event Updated',
      'message': 'samuel@goodman@zara.com Invite...',
      'avatar': 'https://i.pravatar.cc/150?img=7',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF5F5F5),
      // appBar: AppBar(
      //   title: const Text("Chats"),
      //   backgroundColor: Colors.teal.shade600,
      // ),
      body: Column(
        children: [
          
           CustomInputField(
            width: Utils.windowWidth(context) * 0.9,
            
           hintText: "Search", 
           trailingIcon: SvgWrapper(assetPath: ImagePaths.filters,onPress: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> FiltersScreen()));
           },),
           leadingIcon: SvgWrapper(assetPath: ImagePaths.search),
           ),
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder:(ctx) => ChatScreen()));
                  },
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 1),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(ImagePaths.user1),
                          radius: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    chat['name']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    chat['time']!,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                chat['title']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                chat['message']!,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}