import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
                  width: Utils.windowWidth(context) * 0.75,
                  margin: EdgeInsets.only(
                    top: ScallingConfig.verticalScale(12),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: ScallingConfig.verticalScale(12),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.veryLightGrey.withOpacity(
                          0.5,
                        ),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "Dec 05, 2023 - 10:00 AM",
                        color: AppColors.primary500,
                        fontSize: 12,
                        fontFamily: "Gilroy-SemiBold",
                      ),
                      SizedBox(height: ScallingConfig.scale(10)),
                      Row(
                        children: [
                          Container(
                            width: Utils.windowWidth(context) * 0.22,
                            height: Utils.windowWidth(context) * 0.22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              ImagePaths.user1,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: ScallingConfig.scale(12)),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CustomText(
                                  width: double.infinity,
                                  text: "Emily Jordan",
                                  isSemiBold: true,
                                  textAlign: TextAlign.start,
                                ),
                                SizedBox(height: ScallingConfig.scale(5)),
                                Row(
                                  children: [
                                    SvgWrapper(assetPath: ImagePaths.location),
                                    SizedBox(
                                      width: Utils.windowWidth(context) * 0.025,
                                    ),
                                    CustomText(
                                      text: "20 Cooper Square, USA",
                                      fontSize: 12,
                                      color: AppColors.darkGreyColor,
                                    ),
                                  ],
                                ),
                                SizedBox(height: ScallingConfig.scale(6),),
                                Row(
                                  children: [
                                    SvgWrapper(assetPath: ImagePaths.scan),
                                    SizedBox(
                                      width: Utils.windowWidth(context) * 0.025,
                                    ),
                                    CustomText(
                                      text: "Booking ID: #DR452SA54",
                                      fontSize: 12,
                                      color: AppColors.darkGreyColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
  }
}