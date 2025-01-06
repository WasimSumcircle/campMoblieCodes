import 'dart:math';

import 'package:campapplication/constants.dart';
import 'package:campapplication/screens/home/components/about_us_page.dart';
import 'package:campapplication/screens/home/components/schedule_page.dart';
import 'package:campapplication/screens/home/components/search_patient.dart';
import 'package:campapplication/screens/home/components/setting_page.dart';
import 'package:campapplication/screens/home/home_screen.dart';
import 'package:campapplication/utils/rive_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../model/menu.dart';
import 'components/btm_nav_item.dart';
import 'components/menu_btn.dart';
import 'components/side_bar.dart';

class EntryPoint extends StatefulWidget {
  final Map<String, dynamic> data;

  const EntryPoint({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint>
    with SingleTickerProviderStateMixin {
  bool isSideBarOpen = false;
  int _selectedIndex = 0;
  Menu selectedBottonNav = bottomNavItems.first;
  Menu selectedSideMenu = sidebarMenus.first;
  late SMIBool isMenuOpenInput;

  late AnimationController _animationController;
  late Animation<double> scaleAnimation;
  late Animation<double> animation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {});
      });

    scaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(Menu menu, int index) {
    setState(() {
      _isLoading = true;
      selectedBottonNav = menu;
      selectedSideMenu = menu;
      _selectedIndex = index;
    });
    _loadData();
  }

  void _onItemSideBarTapped(Menu menu, int index) {
    setState(() {
      _isLoading = true;
      selectedBottonNav = menu;
      selectedSideMenu = menu;
      _selectedIndex = index;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor2,
      body: Stack(
        children: [
          AnimatedPositioned(
            width: 288,
            height: MediaQuery.of(context).size.height,
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            left: isSideBarOpen ? 0 : -288,
            top: 0,
            child: SideBar(
              onMenuSelected: (menu) {
                int index = sidebarMenus.indexOf(menu);
                _onItemSideBarTapped(menu, index);
              },
              data: widget.data,
            ),
          ),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(1 * animation.value - 30 * animation.value * pi / 180),
            child: Transform.translate(
              offset: Offset(animation.value * 265, 0),
              child: Transform.scale(
                scale: scaleAnimation.value,
                child: Stack(
                  children: [
                    IndexedStack(
                      index: _selectedIndex,
                      children: [
                        HomePage(data: widget.data),
                        SchedulePage(data: widget.data),
                        SearchPatientPage(data: widget.data),
                        SettingPage(data: widget.data),
                        AboutUsPage(data: widget.data),
                      ],
                    ),
                    if (_isLoading)
                      Center(
                        child: LoadingAnimationWidget.fourRotatingDots(
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            left: isSideBarOpen ? 220 : 0,
            top: 1,
            child: MenuBtn(
              press: () {
                isMenuOpenInput.value = !isMenuOpenInput.value;

                if (_animationController.value == 0) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }

                setState(() {
                  isSideBarOpen = !isSideBarOpen;
                });
              },
              riveOnInit: (artboard) {
                final controller = StateMachineController.fromArtboard(
                  artboard,
                  "State Machine",
                );

                artboard.addController(controller!);

                isMenuOpenInput =
                    controller.findInput<bool>("isOpen") as SMIBool;
                isMenuOpenInput.value = true;
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Transform.translate(
        offset: Offset(0, 100 * animation.value),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 3, 34, 38).withOpacity(0.8),
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor1.withOpacity(0.3),
                  offset: const Offset(0, 20),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...List.generate(
                  bottomNavItems.length,
                  (index) {
                    Menu navBar = bottomNavItems[index];
                    return BtmNavItem(
                      navBar: navBar,
                      press: () {
                        _onItemTapped(navBar, index);
                        RiveUtils.chnageSMIBoolState(navBar.rive.status!);
                      },
                      riveOnInit: (artboard) {
                        navBar.rive.status = RiveUtils.getRiveInput(
                          artboard,
                          stateMachineName: navBar.rive.stateMachineName,
                        );
                      },
                      selectedNav: selectedBottonNav,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
