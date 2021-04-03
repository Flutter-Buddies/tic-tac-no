import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_no/common/widgets/animate_icons.dart';
import 'package:tic_tac_no/common/consts/keys.dart';
import 'package:tic_tac_no/menu/menu_enums.dart';
import 'package:tic_tac_no/menu/ui/game_start_bottom_sheet.dart';
import 'package:tic_tac_no/menu/ui/language_bottom_sheet.dart';
import 'package:tic_tac_no/menu/ui/primary_button.dart';
import 'package:tic_tac_no/menu/ui/title.dart';
import 'package:tic_tac_no/translations/locale_keys.g.dart';
import 'package:tic_tac_no/utils/audio.dart';
import 'package:tic_tac_no/utils/utils.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  AnimateIconController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimateIconController();
  }

  @override
  Widget build(BuildContext context) {
    void primaryButtonPress(GameType gameType) {
      context.read<UIAudio>().playSound(UISounds.ButtonClick);
      showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return GameStartModal(
            key: const Key(Keys.gameSetupModalSheet),
            gameType: gameType,
          );
        },
      );
    }

    void languageButtonPress(BuildContext context) {
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return LanguageBottomSheet();
        },
      );
    }

    return Theme(
      data: ThemeData(
        textTheme: const TextTheme(
          headline1: TextStyle(
            fontSize: 100,
            color: Colors.white,
            letterSpacing: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xff1E3C72), Color(0xff2A5298)],
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App Title
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: TitleWidget(),
                          ),
                        ),
                        // List of buttons
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: PrimaryButton(
                                key: const Key(Keys.menuGameSpBtn),
                                buttonText: LocaleKeys.menu_single_player.tr(),
                                buttonIcon: Icons.person,
                                buttonPress: () =>
                                    primaryButtonPress(GameType.SinglePlayer),
                                buttonGradient: const LinearGradient(
                                  colors: [
                                    Color(0xffFF5F6D),
                                    Color(0xffFFC371)
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: PrimaryButton(
                                key: const Key(Keys.menuGameLocalMpBtn),
                                buttonText:
                                    LocaleKeys.menu_local_multiplayer.tr(),
                                buttonIcon: Icons.phone_android_outlined,
                                buttonPress: () => primaryButtonPress(
                                    GameType.LocalMultiplayer),
                                buttonGradient: const LinearGradient(
                                  colors: [
                                    Color(0xffE33E49),
                                    Color(0xff9B00B5)
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  PrimaryButton(
                                    key: const Key(Keys.menuGameOnlineMpBtn),
                                    buttonText:
                                        LocaleKeys.menu_online_multiplayer.tr(),
                                    buttonIcon: Icons.people,
                                    buttonPress: () {
                                      // Do nothing
                                    },
                                    buttonGradient: const LinearGradient(
                                      colors: [
                                        Color(0xff9534E1),
                                        Color(0xff009E95)
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: -7,
                                    left: -2,
                                    child: Transform.rotate(
                                      angle: -0.2,
                                      child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white,
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.grey,
                                                blurRadius: 3.0,
                                                spreadRadius: 2.0,
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12.0),
                                            child: Text(
                                              LocaleKeys.menu_coming_soon.tr(),
                                              style: GoogleFonts.cairo(),
                                            ),
                                          )),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 55,
                right: Utils.isCurrentLocaleRTL(context) ? null : 32,
                left: Utils.isCurrentLocaleRTL(context) ? 32 : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      key: const Key(Keys.menuSoundBtn),
                      child: AnimateIcons(
                        startIcon: Icons.volume_up,
                        endIcon: Icons.volume_off,
                        controller: controller,
                        onStartIconPress: () {
                          setState(() {
                            context.read<UIAudio>().switchMute();
                          });
                          return true;
                        },
                        onEndIconPress: () {
                          setState(() {
                            context.read<UIAudio>().switchMute();
                          });
                          return true;
                        },
                        duration: const Duration(milliseconds: 500),
                        startIconColor: Colors.white,
                        endIconColor: Colors.redAccent,
                        clockwise: false,
                      ),
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      key: const Key(Keys.menuRulesBtn),
                      onTap: () => Navigator.of(context).pushNamed('/rules'),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            LocaleKeys.menu_how_to_play.tr(),
                            key: const Key(Keys.menuHowToPlayText),
                            style: GoogleFonts.cairo(
                              textStyle: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                // decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      key: const Key(Keys.menuLanguageBtn),
                      onTap: () => languageButtonPress(context),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.language,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            LocaleKeys.menu_change_language.tr(),
                            style: GoogleFonts.cairo(
                              textStyle: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                // decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pushNamed('/contributors'),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.code,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            LocaleKeys.contributors_contributors.tr(),
                            style: GoogleFonts.cairo(
                              textStyle: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
