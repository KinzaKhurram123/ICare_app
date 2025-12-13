import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/models/chat.dart';
import 'package:icare/screens/video_call.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  BasicState createState() => BasicState();
}

class BasicState extends State<ChatScreen> {
  var textMessage = '';

  List<Chat> messages = [
     Chat(
      isMe: false,
      text: "Lorem ipsum dolor sit amet consectetur adipiscing elit maecenas porta fermentum, ",
      photo: ImagePaths.user1,

      ),  
     Chat(
      isMe: false,
      text: "Lorem ipsum dolor sit amet consectetur adipiscing elit maecenas porta fermentum, ",
      photo: ImagePaths.user1,

      ),  
     Chat(
      isMe: false,
      text: "Lorem ipsum dolor sit amet consectetur adipiscing elit maecenas porta fermentum, ",
      photo: ImagePaths.user1,

      ),  
     Chat(
      isMe: true,
      text: "Lorem ipsum dolor sit amet consectetur adipiscing elit maecenas porta fermentum, ",
      photo: ImagePaths.user5,

      ),  
     Chat(
      isMe: true,
      text: "Lorem ipsum dolor sit amet consectetur adipiscing elit maecenas porta fermentum, ",
      photo: ImagePaths.user5,

      ),  
     Chat(
      isMe: true,
      text: "Lorem ipsum dolor sit amet consectetur adipiscing elit maecenas porta fermentum, ",
      photo: ImagePaths.user5,

      ),  
     Chat(
      isMe: true,
      text: "Lorem ipsum dolor sit amet consectetur adipiscing elit maecenas porta fermentum, ",
      photo: ImagePaths.user5,
      ),  
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(text:"Chat"),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => VideoCall()));
            },
            child: SvgWrapper(assetPath: ImagePaths.video
          ),
          ),
          SizedBox(width: ScallingConfig.scale(10),),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => VideoCall()));
            },
            child: SvgWrapper(assetPath: ImagePaths.audio
          ),
          ),
          SizedBox(width: ScallingConfig.scale(10),)
        ],
      ),
      body: Column(
        children: [
          Expanded(child: ListView.builder(
            itemCount: messages.length,
            padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(4)),
            itemBuilder: (ctx,i) {
            return (

              MessageBubble(isMe: messages[i].isMe, text: messages[i].text, photo: messages[i].photo!,)
            );
          })),
          // SizedBox(height: 50,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: CustomInputField(
                  borderColor: AppColors.darkGreyColor.withAlpha(40),
                  borderWidth: 1,
                  
                  onChanged: (value) {
                    setState(() {
                      textMessage = value;
                    });
                  } ,
                  hintText: "Write A Messafe")),
                SizedBox(width: ScallingConfig.scale(20),),
                InkWell(
                  onTap: () {
                    setState(() {
                      messages.add( 
                      Chat(text: textMessage,
                      isMe: true, 
                      photo: ImagePaths.user5));
                    });

                    textMessage= '';
                  },
                  child: CircleAvatar(
                    
                    radius: 25,
                    backgroundColor: AppColors.primaryColor,
                    child: SvgWrapper(assetPath: ImagePaths.send) ,
                  ),
                )
              ],
            ),
          )
        ],
      )
    );
  }
}




class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, 
 required this.photo,
 required this.text,
  this.isMe = false});
  final bool isMe;
  final String text;
  final String photo;

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: ScallingConfig.verticalScale(5)),
      child: Stack(
        children: [
          Positioned(
            top: ScallingConfig.scale(0),
            right: isMe ? ScallingConfig.scale(0) : null,
            child:
          CircleAvatar(
                    maxRadius: 35,
                    backgroundImage: AssetImage(photo),
                  ),
           ),
          Row(
                mainAxisAlignment: isMe ?  MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  
                  SizedBox(width: ScallingConfig.scale( isMe ?  0 : 70),),
                  Container(
                    // margin: EdgeInsets.only(left: isMe  ? 0 : ScallingConfig.scale()),
                    width: Utils.windowWidth(context) * 0.65,
                    height: Utils.windowHeight(context) * 0.1,
                    padding: EdgeInsets.only(left: 6, top: 12, bottom: 12),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.secondaryColor : AppColors.veryLightGrey,
                      borderRadius: isMe ?  BorderRadius.only(topLeft: Radius.circular(12), bottomRight: Radius.circular(12) ) : BorderRadius.circular(20),
               
                    ),
                    child: CustomText(text: text,
                    width:Utils.windowWidth(context) * 0.5,
                    padding: EdgeInsets.symmetric(horizontal:8),
                    fontSize: 14,
                    maxLines: 5, 
              color: AppColors.primary500,),
                  ),
                  // if(isMe) 
                       SizedBox(width: ScallingConfig.scale(isMe ? 70 : 0),)
              
                ],
           )
         
        ],
      ),
    );
  }
}