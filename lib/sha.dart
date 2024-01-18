
import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/core/common/chat_shimmer.dart';
import 'package:customer/core/constants/constants.dart';
import 'package:customer/core/constants/firebase_constants.dart';
import 'package:customer/core/globals/globals.dart';
import 'package:customer/features/home/controller/product_controller.dart';
import 'package:customer/features/home/screens/product_List.dart';
import 'package:customer/features/home/screens/product_single_page.dart';
import 'package:customer/features/home/screens/products_page.dart';
import 'package:customer/features/home/screens/search_page.dart';
import 'package:customer/features/home/screens/she_chef.dart';
import 'package:customer/features/home/screens/video_player.dart';
import 'package:customer/features/profile/screens/my_orders_page.dart';
import 'package:customer/theme/palette.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g_map;
import 'package:google_maps_place_picker/google_maps_place_picker.dart'
as g_map_place_picker;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/common/local_delicacies_widget.dart';
import '../../../core/common/shimmer/home/homeShimmer.dart';
import '../../../core/globals/local_variables.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../models/OrderModel.dart';
import '../../auth/screens/splash_screen/splash.dart';
import '../../profile/screens/my_orders_single_page.dart';
import 'banner_view_page.dart';
import 'insta_kitchen_view_page.dart';
import 'localdelicacies.dart';
import 'mbu_list_page.dart';
import 'mbu_profile_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late YoutubePlayerController _controller;

  TextEditingController reasonController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isBottomSheetVisible = false;
  bool isExpanded = false;
  String videoLink = '';
  String? initialVideoId;

  Future<bool> getVideoLink() async {
    var data = await ref
        .read(firestoreProvider)
        .collection(FirebaseConstants.settingsCollection)
        .doc(FirebaseConstants.settingsCollection)
        .get();
    videoLink = data.get("youTubeLink");
    initialVideoId = YoutubePlayer.convertUrlToId(data.get("youTubeLink"));
    if (initialVideoId == null) {
      return false;
    } else {
      _controller = YoutubePlayerController(
          initialVideoId: YoutubePlayer.convertUrlToId(videoLink)!,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            forceHD: true,
            mute: false,
          ));
      return true;
    }
  }

  void toggleBottomSheet() {
    setState(() {
      isBottomSheetVisible = !isBottomSheetVisible;
    });
  }

  int currentIndexPage = 0;
  final shimmerBaseColor = Colors.grey[300];
  final shimmerHighlightColor = Colors.grey[100];

  counter() async {
    for (int i = count; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      var status = await Permission.location.status;

      if (status.isDenied) {
        var a = await Permission.location.request();
      }
    }

    // if (mounted) {
    //   print("counter rebuild");
    //   setState(() {});
    // }
    counter();
  }
  // updateLatLng() async {
  //   CollectionReference vendorsRef =
  //       FirebaseFirestore.instance.collection("vendors");
  //
  //   QuerySnapshot<Map<String, dynamic>> snapshot =
  //       await vendorsRef.get() as QuerySnapshot<Map<String, dynamic>>;
  //
  //   List<Future<void>> updateTasks = [];
  //
  //   snapshot.docs.forEach((doc) {
  //     Map<String, dynamic> data = doc.data();
  //     data['lat'] = 10.9864395; // Replace with your desired latitude value
  //     data['long'] = 76.2234067; // Replace with your desired longitude value
  //
  //     updateTasks.add(vendorsRef.doc(doc.id).update(data));
  //   });
  //
  //   await Future.wait(updateTasks);
  //
  //   print("Latitude and longitude updated successfully!");
  // }

  // List banner = [
  //   Constants.cakes,
  //   Constants.offer50,
  //   Constants.offer35,
  //   Constants.gusty,
  // ];

  // getBaner(){
  //   FirebaseFirestore.instance.
  // }
  Position? currentLoc;
  getLoc() async {
    currentLoc = await Geolocator.getCurrentPosition();
    lat = currentLoc!.latitude;
    long = currentLoc!.longitude;
    List<Placemark> placemarks = await placemarkFromCoordinates(
        currentLoc!.latitude, currentLoc!.longitude);
    Placemark place = placemarks[0];
    currenPlace = place.locality!;
  }

  ScrollController scrollController = ScrollController();
  bool showbtn = false;
  // bool order = ;
  bool review = true;
  bool onGoing = false;
  List<OrderModel>? orderData = [];
  // Duration? remainingTime;
  // DateTime? targetTime;

  // List rejectReasons = [];
  // String? reasons;
  // List<String> rejectReasonsA = [];
  // getCancelReasons() async {
  //   var data = await FirebaseFirestore.instance
  //       .collection('settings')
  //       .doc('settings')
  //       .get();
  //   rejectReasons = data.get('customerCancelReason');
  //   rejectReasonsA = ['other'];
  //   rejectReasonsA
  //       .addAll(rejectReasons.map((element) => element.toString()).toList());
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  // getCancelTime({required DateTime placedDate}) async {
  //   var settings = await ref.read(getSettingsProvider.future);
  //   var cancellationTime = settings.cancellationTime;
  //   targetTime = placedDate.add(Duration(minutes: cancellationTime!));
  //   remainingTime = targetTime?.difference(DateTime.now());
  //   Timer.periodic(const Duration(seconds: 1), (timer) {
  //     if (mounted) {
  //       setState(() {});
  //     }
  //   });
  // }

  StreamSubscription? getOrderStream;

  getOrder() async {
    if (userId != null) {
      getOrderStream = FirebaseFirestore.instance
          .collection('orders')
          .where('customerId', isEqualTo: userId)
          .where("orderStatus", whereIn: [0, 1, 4, 5])
          .orderBy('placedDate', descending: true)
          .snapshots()
          .listen(
            (data) {
          print("order rebuild");
          if (data.docs.isNotEmpty) {
            orderData = [];
            for (var order in data.docs) {
              //  var order = data.docs.first;
              if (order.get('orderStatus') == 3 ||
                  order.get('orderStatus') == 2 ||
                  order.get('orderStatus') == 7) {
                onGoing = false;

                // getCancelTime(placedDate: orderData!.placedDate!);
              } else {
                onGoing = true;
                orderData!.add(OrderModel.fromJson(order.data()));
              }
            }
          } else {
            onGoing = false;
            orderData = [];

            return;
          }
          if (mounted) {
            setState(() {});
          }
        },
      );
    }
  }

  @override
  void initState() {
    // getLoc();
    // getCancelReasons();
    getOrder();
    counter();
    getVideoLink();
    // updateLatLng();
    if (kDebugMode) {
      print(userDataBox?.get("Uid"));
      print(userId);
    }

    super.initState();
    // update();
  }

  // update() {
  //   FirebaseFirestore.instance
  //       .collection(FirebaseConstants.userCollection)
  //       .get()
  //       .then((event) {
  //     for (var doc in event.docs) {
  //       doc.reference.update({'serviceMode': ''});
  //     }
  //   });
  // }

  getservicemode() {
    Future.delayed(const Duration(microseconds: 1), () {
      if (!ordermod && userId != null) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return SizedBox(
              height: h * 0.3,
              child: AlertDialog(
                // shape:RoundedRectangleBorder(borderRadius: BorderRadiusGeometry()),
                title: Text(
                  "Select Your Service Mode ?",
                  style: GoogleFonts.montserrat(
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                content: SizedBox(
                  height: h * 0.2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          // serviceMode = 'Dine in';
                          ref
                              .watch(serviceModeProvider.notifier)
                              .update((state) => 'Dine in');

                          ordermod = true;
                          Navigator.pop(context);
                          await FirebaseFirestore.instance
                              .collection(FirebaseConstants.userCollection)
                              .doc(userId)
                              .update({
                            'serviceMode': ref.read(serviceModeProvider)
                          });
                          // setState(() {});
                        },
                        child: SizedBox(
                          child: Text(
                            "Dine in",
                            style: GoogleFonts.montserrat(
                              fontSize: w * 0.045,
                              color: Palette.primaryColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: h * 0.015,
                      ),
                      GestureDetector(
                        onTap: () async {
                          // serviceMode = 'Delivery';
                          ref
                              .watch(serviceModeProvider.notifier)
                              .update((state) => 'Delivery');
                          ordermod = true;
                          Navigator.pop(context);
                          await FirebaseFirestore.instance
                              .collection(FirebaseConstants.userCollection)
                              .doc(userId)
                              .update({
                            'serviceMode': ref.read(serviceModeProvider)
                          });
                          // setState(() {});
                        },
                        child: SizedBox(
                          child: Text(
                            "Delivery",
                            style: GoogleFonts.montserrat(
                              fontSize: w * 0.045,
                              color: Palette.primaryColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: h * 0.015,
                      ),
                      GestureDetector(
                        onTap: () async {
                          ordermod = true;
                          ref
                              .watch(serviceModeProvider.notifier)
                              .update((state) => 'Take Away');
                          // serviceMode = 'Take Away';
                          Navigator.pop(context);
                          await FirebaseFirestore.instance
                              .collection(FirebaseConstants.userCollection)
                              .doc(userId)
                              .update({
                            'serviceMode': ref.read(serviceModeProvider)
                          });
                          // setState(() {});
                        },
                        child: Text(
                          "Take Away",
                          style: GoogleFonts.montserrat(
                            fontSize: w * 0.045,
                            color: Palette.primaryColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    if (ref.watch(serviceModeProvider) == '' && !homeService) {
      service = false;
      ordermod = false;
      homeService = true;
    }
    super.didChangeDependencies();

    // getservicemode();
  }

  @override
  void dispose() {
    super.dispose();
    getOrderStream?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    print("rebuild");
    // String formattedTime =
    //     '${remainingTime?.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
    //     '${remainingTime?.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton:
      //  showbtn
      AnimatedOpacity(
        duration: const Duration(milliseconds: 100), //show/hide animation
        opacity: showbtn ? 1.0 : 0.0, //set obacity to 1 on visible, or hide
        child: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(w * 0.45),
          ),
          foregroundColor: Palette.primaryColor,
          onPressed: () {
            scrollController.animateTo(
              //go to top of scroll
                0, //scroll offset to go
                duration:
                const Duration(milliseconds: 100), //duration of scroll
                curve: Curves.fastOutSlowIn //scroll type
            );
          },
          child: const Icon(Icons.arrow_upward),
          backgroundColor: Colors.white,
        ),
      ),
      // : StreamBuilder(
      //     stream: FirebaseFirestore.instance
      //         .collection(FirebaseConstants.ordersCollection)
      //         .where('customerId', isEqualTo: userId)
      //         .orderBy('orderDate', descending: true)
      //         .limit(1)
      //         .snapshots(),
      //     builder: (context, snapshot) {
      //       return Container(
      //         width: w * 0.9,
      //         height: h * 0.07,
      //         decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(10),
      //             color: Palette.whiteColor,
      //             boxShadow: [
      //               BoxShadow(
      //                   color: Palette.black.withOpacity(0.16),
      //                   offset: const Offset(3, 3),
      //                   blurRadius: 3),
      //             ]),
      //         child: const Row(children: [
      //           Text("Your Order "),
      //           Text("Your Order "),
      //         ]),
      //       );
      //     },
      //   ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: h * 0.04,
              ),
              const CustomAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // SizedBox(
                      //   height: h * 0.02,
                      // ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => const SearchPage()));
                        },
                        child: Container(
                          width: w * 0.95,
                          height: h * 0.055,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(w * 0.025),
                              color: const Color(0xffF4F4F4)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: w * 0.2,
                                child: Center(
                                  child: Text("Search...",
                                      style: GoogleFonts.montserrat(
                                          fontSize: w * 0.03,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xff777777))),
                                ),
                              ),
                              SizedBox(
                                width: w * 0.13,
                                child: Center(
                                  child: Icon(
                                    Icons.search_outlined,
                                    color: Palette.primaryColor,
                                    size: w * 0.07,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: h * 0.02,
                      ),
                      Container(
                        height: h * 0.23,
                        color: Colors.transparent,
                        child: Consumer(builder: (context, ref, child) {
                          var data = ref.watch(getBannersProvider);
                          // int selactIndex = 0;
                          return data.when(
                            data: (homeBanner) {
                              if (homeBanner.isNotEmpty) {
                                return Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    // SizedBox(
                                    //   height: h * 0.15,
                                    //   child: ListView.builder(
                                    //     itemCount: bannerData.homeBanner!.length,
                                    //     shrinkWrap: true,
                                    //     physics: const BouncingScrollPhysics(),
                                    //     scrollDirection: Axis.horizontal,
                                    //     itemBuilder: (context, index) {
                                    //       var banner =
                                    //           bannerData.homeBanner![index];
                                    //       selactIndex = index;
                                    //       return Padding(
                                    //         padding: EdgeInsets.only(
                                    //             left: w * 0.012, right: w * 0.012),
                                    //         child: GestureDetector(
                                    //           onTap: () {
                                    //             Navigator.push(
                                    //                 context,
                                    //                 MaterialPageRoute(
                                    //                     builder: (context) =>
                                    //                         BannerViewPage(
                                    //                             vendors: banner
                                    //                                 .vendors!)));
                                    //           },
                                    //           child: Container(
                                    //             // height: 150,
                                    //             width: w * 0.64,
                                    //             decoration: BoxDecoration(
                                    //                 borderRadius:
                                    //                     BorderRadius.circular(10),
                                    //                 image: DecorationImage(
                                    //                     image:
                                    //                         CachedNetworkImageProvider(
                                    //                             banner.url!),
                                    //                     fit: BoxFit.fill)),
                                    //           ),
                                    //         ),
                                    //       );
                                    //     },
                                    //   ),
                                    // ),
                                    // Row(
                                    //     mainAxisAlignment: MainAxisAlignment.center,
                                    //     children: List.generate(
                                    //         bannerData.homeBanner!.length, (index) {
                                    //       return Padding(
                                    //         padding: const EdgeInsets.only(
                                    //             left: 5, right: 5),
                                    //         child: SvgPicture.asset(
                                    //           Constants.dot,
                                    //           height: w * 0.02,
                                    //           width: w * 0.02,
                                    //           color: selactIndex == index
                                    //               ? Palette.primaryColor
                                    //               : const Color(0xffADADAD),
                                    //         ),
                                    //       );
                                    //     }))

                                    CarouselSlider(
                                        items: List.generate(
                                            homeBanner.length,
                                                (index) => Padding(
                                              padding:
                                              const EdgeInsets.all(8.0),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  if (homeBanner[index]
                                                      .orderType ==
                                                      "She Chef") {
                                                    if(userId==null){
                                                      showSnackBar(context,
                                                          "Please login to register she chef!");
                                                    } else{
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                  SheChef(
                                                                    id: userId,
                                                                  )));
                                                    }

                                                  } else {
                                                    if (homeBanner[index]
                                                        .link ==
                                                        "") {
                                                      if (homeBanner[index]
                                                          .orderType !=
                                                          "") {
                                                        if (homeBanner[
                                                        index]
                                                            .orderType ==
                                                            "Insta Kitchen") {
                                                          Navigator.push(
                                                            context,
                                                            CupertinoPageRoute(
                                                              builder: (context) =>
                                                              // SheChef()
                                                              const InstaKitchenPage(),
                                                            ),
                                                          );
                                                        } else if (homeBanner[
                                                        index]
                                                            .orderType ==
                                                            "Local Delicacies") {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                              const LocalDelicaciesSinglePage(),
                                                            ),
                                                          );
                                                        } else if (homeBanner[
                                                        index]
                                                            .orderType ==
                                                            "Home Chef") {
                                                          var radius =
                                                          ref.watch(
                                                              radiusProvider);
                                                          var data =
                                                          await ref.watch(
                                                              getVendorsProvider(
                                                                jsonEncode(
                                                                  {
                                                                    'radius':
                                                                    radius,
                                                                    "lat": lat,
                                                                    "long":
                                                                    long,
                                                                  },
                                                                ),
                                                              ).future);
                                                          Navigator.push(
                                                              context,
                                                              CupertinoPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                    MbuList(
                                                                      mbuData:
                                                                      data,
                                                                    ),
                                                              ));
                                                        } else {
                                                          Navigator.push(
                                                            context,
                                                            CupertinoPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                  ProductList(
                                                                    home: true,
                                                                    orderType: homeBanner[
                                                                    index]
                                                                        .orderType!,
                                                                  ),
                                                            ),
                                                          );
                                                        }
                                                      } else {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    BannerViewPage(
                                                                        vendors:
                                                                        homeBanner[index].vendors!)));
                                                      }
                                                    } else {
                                                      Uri? uri = Uri.tryParse(
                                                          homeBanner[index]
                                                              .link ??
                                                              "");
                                                      if (homeBanner[index]
                                                          .openInApp ==
                                                          true) {
                                                        launchUrl(uri!,
                                                            mode: LaunchMode
                                                                .inAppWebView);
                                                      } else {
                                                        launchUrl(uri!);
                                                      }
                                                    }
                                                  }
                                                },
                                                child: Container(
                                                  height: h * 0.22,
                                                  width: w * 0.9,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          w * 0.03),
                                                      image: DecorationImage(
                                                          image: CachedNetworkImageProvider(
                                                              homeBanner[index]
                                                                  .url ??
                                                                  ''),
                                                          fit: BoxFit
                                                              .cover)),
                                                ),
                                              ),
                                            )),
                                        options: CarouselOptions(
                                          height: h * 0.19,
                                          aspectRatio: 16 / 9,
                                          viewportFraction: 0.8,
                                          initialPage: 0,
                                          disableCenter: false,
                                          padEnds: true,
                                          enableInfiniteScroll: true,
                                          reverse: false,
                                          autoPlay: true,
                                          autoPlayInterval:
                                          const Duration(seconds: 3),
                                          autoPlayAnimationDuration:
                                          const Duration(milliseconds: 800),
                                          autoPlayCurve: Curves.fastOutSlowIn,
                                          enlargeCenterPage: true,
                                          enlargeFactor: 0.0,
                                          onPageChanged: (index, val) {
                                            currentIndexPage = index;
                                            setState(() {});
                                          },
                                          scrollDirection: Axis.horizontal,
                                        )),

                                    DotsIndicator(
                                      dotsCount: homeBanner.length,
                                      position:
                                      homeBanner.length < currentIndexPage
                                          ? 0
                                          : currentIndexPage,
                                      decorator: const DotsDecorator(
                                        color:
                                        Palette.lightgrey, // Inactive color
                                        activeColor: Palette.primaryColor,
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return const SizedBox();
                              }
                            },
                            error: (error, stackTrace) => const Text(""),
                            loading: () => const ShimmerOrderCard(),
                          );
                        }),
                      ),

                      SizedBox(
                        height: h * 0.02,
                      ),
                      // Row(
                      //   children: [
                      //     Padding(
                      //       padding: const EdgeInsets.only(left: 19),
                      //       child: GestureDetector(
                      //         onTap: () {
                      //           Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) =>
                      //                       InstaKitchenVendorPage()));
                      //         },
                      //         child: Container(
                      //           height: w * 0.08,
                      //           width: w * 0.37,
                      //           decoration: BoxDecoration(
                      //             borderRadius: BorderRadius.circular(14),
                      //             border: Border.all(
                      //                 color: Colors.black, width: w * 0.0005),
                      //           ),
                      //           child: Center(
                      //             child: Padding(
                      //               padding: EdgeInsets.only(
                      //                   left: w * 0.015, right: w * 0.015),
                      //               child: Text("Insta Kitchen",
                      //                   style: GoogleFonts.poppins(
                      //                     fontSize: w * 0.04,
                      //                     fontWeight: FontWeight.w400,
                      //                   )),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     Consumer(
                      //       builder: (context, ref, child) {
                      //         var data = ref.watch(getSettingsProvider);
                      //         return data.when(
                      //           data: (data) {
                      //             return SizedBox(
                      //               height: w * 0.08,
                      //               width: w,
                      //               child: ListView.builder(
                      //                 itemCount: data.ordersType?.length,
                      //                 shrinkWrap: true,
                      //                 scrollDirection: Axis.horizontal,
                      //                 itemBuilder:
                      //                     (BuildContext context, int index) {
                      //                   var tab = data.ordersType![index];
                      //                   return Padding(
                      //                     padding:
                      //                         EdgeInsets.only(left: w * 0.03),
                      //                     child: GestureDetector(
                      //                       onTap: () {
                      //                         Navigator.push(
                      //                             context,
                      //                             MaterialPageRoute(
                      //                                 builder: (context) =>
                      //                                     ProductList(
                      //                                       orderType: tab,
                      //                                     )));
                      //                       },
                      //                       child: Container(
                      //                         height: w * 0.05,
                      //                         decoration: BoxDecoration(
                      //                           borderRadius:
                      //                               BorderRadius.circular(14),
                      //                           border: Border.all(
                      //                               color: Colors.black,
                      //                               width: w * 0.0005),
                      //                         ),
                      //                         child: Center(
                      //                           child: Padding(
                      //                             padding: EdgeInsets.only(
                      //                                 left: w * 0.015,
                      //                                 right: w * 0.015),
                      //                             child: Text(tab,
                      //                                 style: GoogleFonts.poppins(
                      //                                   fontSize: w * 0.04,
                      //                                   fontWeight:
                      //                                       FontWeight.w400,
                      //                                 )),
                      //                           ),
                      //                         ),
                      //                       ),
                      //                     ),
                      //                   );
                      //                 },
                      //               ),
                      //             );
                      //           },
                      //           error: (error, stackTrace) {
                      //             print(error);
                      //             return Text("");
                      //           },
                      //           loading: () => CircularProgressIndicator(),
                      //         );
                      //       },
                      //     ),
                      //   ],
                      // ),
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          height: h * 0.044,
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: w * 0.03, right: w * 0.015),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) =>
                                        const InstaKitchenPage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    // height: w * 0.08,
                                    // width: w * 0.37,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(w * 0.04),
                                      border: Border.all(
                                        color: Palette.primaryColor,
                                        width: w * 0.0028,
                                      ),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                          w * 0.015,
                                          // right: w * 0.015,
                                        ),
                                        child: Text(
                                          "Insta Kitchen",
                                          style: GoogleFonts.montserrat(
                                            fontSize: w * 0.035,
                                            color: Palette.primaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Padding(
                              //     padding: const EdgeInsets.only(left: 19),
                              //     child: shimmerPage(
                              //       h: h * 0.035,
                              //       w: w * 0.37,
                              //     )
                              //     //  Shimmer.fromColors(
                              //     //   baseColor: shimmerBaseColor!,
                              //     //   highlightColor: shimmerHighlightColor!,
                              //     //   child: Card(
                              //     //     elevation: 2.0,
                              //     //     margin: const EdgeInsets.symmetric(
                              //     //         horizontal: 10.0, vertical: 6.0),
                              //     //     child: Container(
                              //     //       height: h * 0.035,
                              //     //        width: w * 0.37,
                              //     //       decoration: BoxDecoration(
                              //     //         borderRadius: BorderRadius.circular(8.0),
                              //     //         gradient: LinearGradient(
                              //     //           colors: [
                              //     //             shimmerBaseColor!,
                              //     //             shimmerHighlightColor!,
                              //     //             shimmerBaseColor!,
                              //     //           ],
                              //     //           begin: const Alignment(-1.0, -0.5),
                              //     //           end: const Alignment(1.0, 0.5),
                              //     //           stops: const [0.4, 0.5, 0.6],
                              //     //         ),
                              //     //       ),
                              //     //     ),
                              //     //   ),
                              //     // ),

                              //     ),
                              Consumer(
                                builder: (context, ref, child) {
                                  var data = ref.watch(getSettingsProvider);
                                  return data.when(
                                    data: (data) {
                                      return SizedBox(
                                        height: h * 0.044,
                                        // width: w * 0.8,
                                        child: ListView.builder(
                                          itemCount: data.ordersType?.length,
                                          shrinkWrap: true,
                                          physics:
                                          const NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            var tab = data.ordersType![index];
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                  left: w * 0.015,
                                                  right: w * 0.015),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                      builder: (context) =>
                                                          ProductList(
                                                            home: true,
                                                            orderType: tab,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  // height: w * 0.05,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        w * 0.04),
                                                    border: Border.all(
                                                      color:
                                                      Palette.primaryColor,
                                                      width: w * 0.0028,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                        w * 0.015,
                                                        // right: w * 0.015,
                                                      ),
                                                      child: Text(
                                                        tab,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          fontSize: w * 0.035,
                                                          color: Palette
                                                              .primaryColor,
                                                          fontWeight:
                                                          FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    error: (error, stackTrace) {
                                      if (kDebugMode) {
                                        print(error);
                                      }
                                      return const Text("");
                                    },
                                    loading: () => SizedBox(
                                      height: h * 0.048,
                                      width: w * 0.8,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                        const NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: 2,
                                        itemBuilder: (context, index) {
                                          return ShimmerPage(
                                            h: h * 0.048,
                                            w: w * 0.37,
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        height: w * 0.05,
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   children: [
                      //     SizedBox(width: w * 0.03),
                      //     Text(
                      //       "InstaKitchen",
                      //       style: GoogleFonts.poppins(
                      //           fontWeight: FontWeight.w600, fontSize: w * 0.05),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(
                      //   height: w * 0.03,
                      // ),
                      // Consumer(builder: (context, ref, child) {
                      //   var lat = ref.watch(latProvider) ?? 0;
                      //   var long = ref.watch(longProvider) ?? 0;
                      //   Map dataMap = {"lat": lat, "long": long};
                      //
                      //   var data = ref.watch(
                      //       getInstaKitchenVendorsProvider(jsonEncode(dataMap)));
                      //   return data.when(
                      //     data: (data) {
                      //       return data.isEmpty
                      //           ? Column(
                      //               children: [
                      //                 SizedBox(
                      //                   height: 56,
                      //                 ),
                      //                 Center(
                      //                   child: Text("No Products Found"),
                      //                 ),
                      //                 SizedBox(
                      //                   height: 56,
                      //                 ),
                      //               ],
                      //             )
                      //           : SizedBox(
                      //               height: h * 0.25,
                      //               width: w,
                      //               child: GridView.builder(
                      //                 shrinkWrap: true,
                      //                 physics:
                      //                     const NeverScrollableScrollPhysics(),
                      //                 itemCount:
                      //                     data.length >= 4 ? 4 : data.length,
                      //                 gridDelegate:
                      //                     const SliverGridDelegateWithFixedCrossAxisCount(
                      //                         crossAxisCount: 2,
                      //                         childAspectRatio: 2),
                      //                 itemBuilder: (context, index) {
                      //                   return GestureDetector(
                      //                     onTap: () {
                      //                       // Navigator.push(context, MaterialPageRoute(builder: (context)=>InstaKitchenProductsPage(vendorId: data[index].,)));
                      //                       // showModalBottomSheet(
                      //                       //   shape: RoundedRectangleBorder(
                      //                       //       borderRadius:
                      //                       //           BorderRadius.circular(0)),
                      //                       //   context: context,
                      //                       //   builder: (context) {
                      //                       //     return productViewBottomSheet(
                      //                       //       image: data[index]
                      //                       //           .imageUrls!
                      //                       //           .first
                      //                       //           .toString(),
                      //                       //       name:
                      //                       //           data[index].name.toString(),
                      //                       //       desc: data[index]
                      //                       //           .shortDescription
                      //                       //           .toString(),
                      //                       //       price: data[index].price ?? 0,
                      //                       //       id: data[index].productId ??
                      //                       //           'a',
                      //                       //       mbuId:
                      //                       //           data[index].vendorId ?? 'b',
                      //                       //       mbuName:
                      //                       //           data[index].vendorName ??
                      //                       //               "c",
                      //                       //       leadingTime:
                      //                       //           data[index].leadingTime ??
                      //                       //               1,
                      //                       //       maxOrder:
                      //                       //           data[index].maxOrder ?? 3,
                      //                       //       minOrder:
                      //                       //           data[index].minOrder ?? 4,
                      //                       //     );
                      //                       //   },
                      //                       // );
                      //                     },
                      //                     child: LocalDelicaciesWidget(
                      //                       image: data[index].image.toString(),
                      //                       name: data[index].shopName ?? "",
                      //                       time: '',
                      //                     ),
                      //                   );
                      //                 },
                      //               ),
                      //             );
                      //     },
                      //     error: (error, stackTrace) {
                      //       print(error);
                      //       return Text('error${error}${stackTrace}');
                      //     },
                      //     loading: () => CircularProgressIndicator(),
                      //   );
                      // }),
                      FutureBuilder<bool>(
                        future: getVideoLink(),
                        builder: (context, snapshot) {
                          print("future rebuild");
                          if (!snapshot.hasData || snapshot.data == false) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: EdgeInsets.only(
                                left: w * 0.03, right: w * 0.03),
                            child: ClipRRect(
                              // Use ClipRRect to clip the edges
                              borderRadius: BorderRadius.circular(
                                  20.0), // Adjust the radius as needed
                              child: SizedBox(
                                height: h * 0.2,
                                child: YoutubePlayer(
                                  controller: _controller,
                                  showVideoProgressIndicator: true,
                                  progressIndicatorColor: Colors.red,
                                  bottomActions: [
                                    CurrentPosition(),
                                    ProgressBar(
                                      isExpanded: true,
                                      colors: const ProgressBarColors(
                                        playedColor: Palette.primaryColor,
                                        handleColor: Colors.green,
                                      ),
                                    ),
                                    const PlaybackSpeedButton(),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _controller.pause();
                                        });
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VideoScreen(
                                              link: videoLink,
                                            ),
                                          ),
                                        );
                                      },
                                      child: SizedBox(
                                        height: h * 0.045,
                                        width: w * 0.1,
                                        child: const Center(
                                          child: Icon(
                                            Icons.zoom_out_map,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(
                        height: h * 0.02,
                      ),

                      Consumer(builder: (context, ref, child) {
                        // var lat = ref.watch(latProvider);
                        // var long = ref.watch(longProvider);
                        var radius = ref.watch(radiusProvider);
                        Map dataMap = {
                          "lat": lat,
                          "long": long,
                          'radius': radius,
                        };

                        var data = ref.watch(
                            getLocalDelicaciesProvider(jsonEncode(dataMap)));
                        return data.when(
                          data: (data) {
                            return data.isEmpty
                                ? const Column(
                              children: [
                                SizedBox(),
                              ],
                            )
                                : SizedBox(
                              height: h * 0.28,
                              width: w,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        bottom: h * 0.005),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                            const LocalDelicaciesSinglePage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: w,
                                        decoration: const BoxDecoration(),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: w * 0.035),
                                              child: Text(
                                                "Local Delicacies",
                                                style: GoogleFonts
                                                    .montserrat(
                                                    fontWeight:
                                                    FontWeight
                                                        .w600,
                                                    fontSize:
                                                    w * 0.048),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: w * 0.03),
                                              child: Text(
                                                'View All',
                                                style: GoogleFonts
                                                    .montserrat(
                                                  fontWeight:
                                                  FontWeight.w500,
                                                  color: Palette
                                                      .primaryColor,
                                                  fontSize: w * 0.03,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  data.length == 1
                                      ? Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              // showModalBottomSheet(
                                              //   shape: RoundedRectangleBorder(
                                              //       borderRadius:
                                              //           BorderRadius.circular(0)),
                                              //   context: context,
                                              //   builder: (context) {
                                              //     return productViewBottomSheet(
                                              //       product: data[index],
                                              //     );
                                              //   },
                                              // );
                                              // showModalBottomSheet<void>(
                                              //   context: context,
                                              //   shape: RoundedRectangleBorder(
                                              //       borderRadius:
                                              //           BorderRadius.circular(0)),
                                              //   builder: (BuildContext context) {
                                              //     return productViewBottomSheet(
                                              //       product: data[index],
                                              //     );
                                              //   },
                                              // );
                                              // showModalBottomSheet<void>(
                                              //   context: context,
                                              //   builder: (BuildContext context) {
                                              //     return productViewBottomSheet(
                                              //       product: data[index],
                                              //     );
                                              //   },
                                              // );
                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (context) =>
                                                      ProductSinglePage(
                                                        product:
                                                        data.first,
                                                      ),
                                                ),
                                              );
                                            },
                                            child:
                                            LocalDelicaciesWidget(
                                              data: data.first,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                      : Expanded(
                                    flex: 1,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection:
                                      Axis.horizontal,
                                      physics:
                                      const BouncingScrollPhysics(),
                                      itemCount: data.length >= 4
                                          ? 4
                                          : data.length,
                                      // gridDelegate:
                                      //     const SliverGridDelegateWithFixedCrossAxisCount(
                                      //         crossAxisCount: 2,
                                      //         childAspectRatio: 2),
                                      itemBuilder:
                                          (context, index) {
                                        return Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                // showModalBottomSheet(
                                                //   shape: RoundedRectangleBorder(
                                                //       borderRadius:
                                                //           BorderRadius.circular(0)),
                                                //   context: context,
                                                //   builder: (context) {
                                                //     return productViewBottomSheet(
                                                //       product: data[index],
                                                //     );
                                                //   },
                                                // );
                                                // showModalBottomSheet<void>(
                                                //   context: context,
                                                //   shape: RoundedRectangleBorder(
                                                //       borderRadius:
                                                //           BorderRadius.circular(0)),
                                                //   builder: (BuildContext context) {
                                                //     return productViewBottomSheet(
                                                //       product: data[index],
                                                //     );
                                                //   },
                                                // );
                                                // showModalBottomSheet<void>(
                                                //   context: context,
                                                //   builder: (BuildContext context) {
                                                //     return productViewBottomSheet(
                                                //       product: data[index],
                                                //     );
                                                //   },
                                                // );
                                                Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                        builder: (context) =>
                                                            ProductSinglePage(
                                                                product:
                                                                data[index])));
                                              },
                                              child:
                                              LocalDelicaciesWidget(
                                                data: data[index],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          error: (error, stackTrace) {
                            if (kDebugMode) {
                              print(error);
                            }
                            return const Text('');
                          },
                          loading: () => SizedBox(
                            height: h * 0.225,
                            width: w,
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 2,
                                itemBuilder: (context, index) {
                                  return ShimmerPage(
                                    w: w * 0.48,
                                    h: h * 0.01,
                                  );
                                }),
                          ),
                        );
                      }),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: w * 0.03),
                          Text(
                            "Make your wish",
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                fontSize: w * 0.049),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: h * 0.02),
                        child: Consumer(
                          builder: (context, ref, child) {
                            // var lat = ref.watch(latProvider);
                            // var long = ref.watch(longProvider);
                            var data = ref.watch(getProductCategory);
                            return data.when(
                              data: (data) {
                                if (data.isNotEmpty) {
                                  return SizedBox(
                                    // color: Palette.primaryColor,
                                    height: h * 0.33,
                                    child: GridView.builder(
                                      // shrinkWrap: true,
                                      itemCount: data.length,
                                      scrollDirection: Axis.horizontal,
                                      gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,

                                        // maxCrossAxisExtent: h * 0.125,
                                        childAspectRatio: 1.2,
                                        // crossAxisSpacing: 10,
                                        // mainAxisSpacing: 10
                                      ),
                                      physics: const BouncingScrollPhysics(),
                                      // gridDelegate:
                                      //     const SliverGridDelegateWithFixedCrossAxisCount(
                                      //   childAspectRatio: 1 / 1.2,
                                      //   crossAxisCount: 4,
                                      // ),
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (context) =>
                                                    ProductsPage(
                                                      categoryName:
                                                      data[index].name!,
                                                      categoryId: data[index].id!,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: w * 0.015,
                                                right: w * 0.015),
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              children: [
                                                //     Container(
                                                //   decoration: BoxDecoration(
                                                //     shape: BoxShape.circle,
                                                //     image: DecorationImage(
                                                //         image:
                                                //             CachedNetworkImageProvider(
                                                //                 data[index].image!),
                                                //         fit: BoxFit.fill),
                                                //   ),
                                                //   height: h * 0.1,
                                                //   width: w * 0.2,
                                                // ),
                                                CircleAvatar(
                                                  radius: w * 0.1,
                                                  backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      data[index].image!),
                                                ),
                                                SizedBox(
                                                  width: w * 0.2,
                                                  // height: h * 0.02,
                                                  child: Center(
                                                    child: Text(
                                                        data[index].name!,
                                                        textAlign:
                                                        TextAlign.center,
                                                        // overflow:
                                                        //     TextOverflow.ellipsis,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          fontSize: 10,
                                                          fontWeight:
                                                          FontWeight.w500,
                                                        )),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              },
                              error: (error, stackTrace) {
                                if (kDebugMode) {
                                  print('error$error$stackTrace');
                                }
                                return const Text('');
                              },
                              loading: () => SizedBox(
                                  height: h * 0.1,
                                  width: w,
                                  child: ListView.builder(
                                      itemCount: 4,
                                      shrinkWrap: true,
                                      physics:
                                      const NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ShimmerPage(
                                          h: h * 0.1,
                                          w: w * 0.2,
                                        );
                                      })),
                            );
                          },
                        ),
                      ),

                      // Padding(
                      //   padding: EdgeInsets.only(top: h * 0.005),
                      //   child: Consumer(
                      //     builder: (context, ref, child) {
                      //       // var lat = ref.watch(latProvider);
                      //       // var long = ref.watch(longProvider);
                      //       var data = ref.watch(getProductCategory);
                      //       return data.when(
                      //         data: (data) {
                      //           if (data.isNotEmpty) {
                      //             return SizedBox(
                      //               // color: Palette.primaryColor,
                      //               height: h * 0.12,
                      //               child: ListView.builder(
                      //                 shrinkWrap: true,
                      //                 itemCount: data.length,

                      //                 scrollDirection: Axis.horizontal,
                      //                 physics: const BouncingScrollPhysics(),
                      //                 // gridDelegate:
                      //                 //     const SliverGridDelegateWithFixedCrossAxisCount(
                      //                 //   childAspectRatio: 1 / 1.2,
                      //                 //   crossAxisCount: 4,
                      //                 // ),
                      //                 itemBuilder: (context, index) {
                      //                   return GestureDetector(
                      //                     onTap: () {
                      //                       Navigator.push(
                      //                         context,
                      //                         MaterialPageRoute(
                      //                           builder: (context) => ProductsPage(
                      //                             categoryName: data[index].name!,
                      //                             categoryId: data[index].id!,
                      //                           ),
                      //                         ),
                      //                       );
                      //                     },
                      //                     child: Padding(
                      //                       padding: EdgeInsets.only(
                      //                           left: w * 0.015, right: w * 0.015),
                      //                       child: Column(
                      //                         mainAxisAlignment:
                      //                             MainAxisAlignment.start,
                      //                         children: [
                      //                           //     Container(
                      //                           //   decoration: BoxDecoration(
                      //                           //     shape: BoxShape.circle,
                      //                           //     image: DecorationImage(
                      //                           //         image:
                      //                           //             CachedNetworkImageProvider(
                      //                           //                 data[index].image!),
                      //                           //         fit: BoxFit.fill),
                      //                           //   ),
                      //                           //   height: h * 0.1,
                      //                           //   width: w * 0.2,
                      //                           // ),
                      //                           CircleAvatar(
                      //                             radius: w * 0.1,
                      //                             backgroundImage:
                      //                                 CachedNetworkImageProvider(
                      //                                     data[index].image!),
                      //                           ),
                      //                           SizedBox(
                      //                             width: w * 0.2,
                      //                             height: h * 0.02,
                      //                             child: Center(
                      //                               child: Text(data[index].name!,
                      //                                   overflow:
                      //                                       TextOverflow.ellipsis,
                      //                                   style:
                      //                                       GoogleFonts.montserrat(
                      //                                     fontSize: 10,
                      //                                     fontWeight:
                      //                                         FontWeight.w500,
                      //                                   )),
                      //                             ),
                      //                           ),
                      //                         ],
                      //                       ),
                      //                     ),
                      //                   );
                      //                 },
                      //               ),
                      //             );
                      //           } else {
                      //             return const SizedBox();
                      //           }
                      //         },
                      //         error: (error, stackTrace) {
                      //           print('error$error$stackTrace');
                      //           return const Text('');
                      //         },
                      //         loading: () => SizedBox(
                      //             height: h * 0.1,
                      //             width: w,
                      //             child: ListView.builder(
                      //                 itemCount: 4,
                      //                 shrinkWrap: true,
                      //                 physics: const NeverScrollableScrollPhysics(),
                      //                 scrollDirection: Axis.horizontal,
                      //                 itemBuilder:
                      //                     (BuildContext context, int index) {
                      //                   return shimmerPage(
                      //                     h: h * 0.1,
                      //                     w: w * 0.2,
                      //                   );
                      //                 })),
                      //       );
                      //     },
                      //   ),
                      // ),
                      // // Container(
                      //   width: w * 0.9,
                      //   height: h * 0.03,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(5),
                      //     border: Border.all(color: Color(0xff707070)),
                      //   ),
                      //   child: Center(
                      //     child: Text(
                      //       "See more",
                      //       style: TextStyle(
                      //           fontWeight: FontWeight.w400,
                      //           fontSize: 9,
                      //           color: Color.fromRGBO(0, 0, 0, 1)),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: h * 0.03),
                      Consumer(
                        builder: (context, ref, child) {
                          var radius = ref.watch(radiusProvider);
                          var lat = ref.watch(latProvider);
                          var long = ref.watch(longProvider);

                          var data = ref.watch(
                            getVendorsProvider(
                              jsonEncode(
                                {
                                  'radius': radius,
                                  "lat": lat,
                                  "long": long,
                                },
                              ),
                            ),
                          );
                          return data.when(
                            data: (data) {
                              if (data.isEmpty) {
                                return Column(
                                  children: [
                                    // GestureDetector(
                                    //   child: Row(
                                    //     mainAxisAlignment:
                                    //         MainAxisAlignment.spaceBetween,
                                    //     children: [
                                    //       Padding(
                                    //         padding:
                                    //             const EdgeInsets.only(left: 15),
                                    //         child: Text(
                                    //           "Home Chef around you",
                                    //           style: GoogleFonts.montserrat(
                                    //             fontWeight: FontWeight.w600,
                                    //             fontSize: w * 0.045,
                                    //           ),
                                    //         ),
                                    //       ),
                                    //       Padding(
                                    //         padding: EdgeInsets.only(
                                    //             right: w * 0.03),
                                    //         child: Text(
                                    //           'View All',
                                    //           style: GoogleFonts.montserrat(
                                    //             fontWeight: FontWeight.w500,
                                    //             color: Palette.primaryColor,
                                    //             fontSize: w * 0.03,
                                    //           ),
                                    //         ),
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),
                                    SizedBox(
                                      height: w * 0.03,
                                    ),
                                    SizedBox(
                                      height: h * 0.050,
                                    ),
                                    Text(
                                      '''OOPS!
No Home Chefs are available
In this Area
Currently Serving In Idukki & Wayanad Area
''',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      height: h * 0.050,
                                    ),
                                  ],
                                );
                              } else {
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        data.length > 5
                                            ? Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) => MbuList(
                                                mbuData: data,
                                              ),
                                            ))
                                            : null;
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: w * 0.045),
                                            child: Text(
                                              "Home Chefs around you",
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w600,
                                                fontSize: w * 0.045,
                                              ),
                                            ),
                                          ),
                                          data.length > 5
                                              ? Padding(
                                            padding: EdgeInsets.only(
                                                right: w * 0.03),
                                            child: Text(
                                              'View All',
                                              style:
                                              GoogleFonts.montserrat(
                                                fontWeight:
                                                FontWeight.w500,
                                                color:
                                                Palette.primaryColor,
                                                fontSize: w * 0.03,
                                              ),
                                            ),
                                          )
                                              : const SizedBox()
                                        ],
                                      ),
                                    ),
                                    // SizedBox(
                                    //   height: h * 0.01,
                                    // ),
                                    ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount:
                                      data.length > 5 ? 5 : data.length,
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder: (context, ind) {
                                        /* data.sort((a, b) {
                                          if (a.available == b.available) {
                                            return 0; // No change in order if both have the same availability.
                                          } else if (a.available!) {
                                            return -1; // 'a' goes before 'b' if 'a' is available and 'b' is not.
                                          } else {
                                            return 1; // 'b' goes before 'a' if 'b' is available and 'a' is not.
                                          }
                                        });*/
                                        // double distanceInMeters =
                                        //     Geolocator.distanceBetween(
                                        //   lat ?? 0,
                                        //   long ?? 0,
                                        //   data[ind].lat ?? 0,
                                        //   data[ind].long ?? 0,
                                        // );
                                        //
                                        // double distanceInkm =
                                        //     (distanceInMeters / 1000);
                                        double distanceInMeters =
                                        Geolocator.distanceBetween(
                                          lat,
                                          long,
                                          data[ind].lat ?? 0,
                                          data[ind].long ?? 0,
                                        );

                                        String distanceText;
                                        if (distanceInMeters < 1000) {
                                          distanceText =
                                          '${distanceInMeters.toStringAsFixed(2)} m';
                                        } else {
                                          double distanceInKilometers =
                                              distanceInMeters / 1000;
                                          distanceText =
                                          '${distanceInKilometers.toStringAsFixed(2)} km';
                                        }
                                        // print('data');
                                        // print(data[0].toJson());
                                        // print('data');

                                        // print('lat,long');
                                        // print('$lat,$long');
                                        // print('lat,long');
                                        return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  CupertinoPageRoute(
                                                    builder: (context) =>
                                                        MbuProfile(
                                                          mbuModel: data[ind],
                                                        ),
                                                  ));
                                            },
                                            child: Padding(
                                                padding: EdgeInsets.only(
                                                    top: w * 0.03, bottom: 8),
                                                child: data[ind].available!
                                                    ? Container(
                                                    margin: EdgeInsets.only(
                                                        left: w * 0.05,
                                                        right: w * 0.05),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(w *
                                                            0.03),
                                                        color: Palette
                                                            .whiteColor,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: Palette
                                                                  .black
                                                                  .withOpacity(
                                                                  0.16),
                                                              offset:
                                                              const Offset(
                                                                  0, 3),
                                                              blurRadius:
                                                              3),
                                                        ]),
                                                    // elevation: 0.7,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        (data[ind].image ==
                                                            null ||
                                                            data[ind]
                                                                .image ==
                                                                '')
                                                            ? Container(
                                                          width:
                                                          w * 0.9,
                                                          height: h *
                                                              0.25,
                                                          decoration:
                                                          BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                                topRight: Radius.circular(w *
                                                                    0.04),
                                                                topLeft:
                                                                Radius.circular(w * 0.04)),
                                                            image: const DecorationImage(
                                                                image: AssetImage(
                                                                    "assets/images/gbannercopy.png"),
                                                                fit: BoxFit
                                                                    .cover),
                                                          ),
                                                        )
                                                            : Container(
                                                          width:
                                                          w * 0.9,
                                                          height: h *
                                                              0.25,
                                                          decoration:
                                                          BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                                topRight: Radius.circular(w *
                                                                    0.04),
                                                                topLeft:
                                                                Radius.circular(w * 0.04)),
                                                            image: DecorationImage(
                                                                image: CachedNetworkImageProvider(data[ind]
                                                                    .image
                                                                    .toString()),
                                                                fit: BoxFit
                                                                    .cover),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: h * 0.01,
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .only(
                                                              left: w *
                                                                  0.025,
                                                              right: w *
                                                                  0.02),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                            children: [
                                                              SizedBox(
                                                                width:
                                                                w * 0.7,
                                                                child: Text(
                                                                    data[ind]
                                                                        .shopName
                                                                        .toString(),
                                                                    overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                    style: GoogleFonts
                                                                        .montserrat(
                                                                      fontSize:
                                                                      w * 0.04,
                                                                      fontWeight:
                                                                      FontWeight.w600,
                                                                    )),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  SvgPicture
                                                                      .asset(
                                                                    Constants
                                                                        .ratingStar,
                                                                    height: h *
                                                                        0.015,
                                                                    width: w *
                                                                        0.02,
                                                                    fit: BoxFit
                                                                        .contain,
                                                                  ),
                                                                  SizedBox(
                                                                    width: w *
                                                                        0.010,
                                                                  ),
                                                                  Text(
                                                                    calculateRating(
                                                                      oneRating:
                                                                      data[ind].oneRating ?? 0,
                                                                      twoRating:
                                                                      data[ind].twoRating ?? 0,
                                                                      threeRating:
                                                                      data[ind].threeRating ?? 0,
                                                                      fourRating:
                                                                      data[ind].fourRating ?? 0,
                                                                      fiveRating:
                                                                      data[ind].fiveRating ?? 0,
                                                                    ).toStringAsFixed(
                                                                        1),
                                                                    style: GoogleFonts.montserrat(
                                                                        fontSize: w *
                                                                            0.035,
                                                                        color:
                                                                        Palette.primaryColor),
                                                                  )
                                                                ],
                                                              ),

                                                              // RatingBar.builder(
                                                              //   itemSize:
                                                              //       w * 0.03,
                                                              //   initialRating:
                                                              //       4.5,
                                                              //   minRating: 1,
                                                              //   direction: Axis
                                                              //       .horizontal,
                                                              //   allowHalfRating:
                                                              //       true,
                                                              //   itemCount: 5,
                                                              //   itemPadding: EdgeInsets
                                                              //       .symmetric(
                                                              //           horizontal:
                                                              //               4.0),
                                                              //   itemBuilder: (context,
                                                              //           _) =>
                                                              //       Icon(
                                                              //           Icons
                                                              //               .star,
                                                              //           color: Color(
                                                              //               0xffFFC400)),
                                                              //   onRatingUpdate:
                                                              //       (rating) {
                                                              //     print(rating);
                                                              //   },
                                                              // )
                                                            ],
                                                          ),
                                                        ),
                                                        data[ind].description ==
                                                            '' ||
                                                            data[ind]
                                                                .description ==
                                                                null
                                                            ? const SizedBox()
                                                            : Padding(
                                                          padding: EdgeInsets.only(
                                                              left: w *
                                                                  0.02,
                                                              bottom: h *
                                                                  0.01,
                                                              right: w *
                                                                  0.02),
                                                          child: Text(
                                                              data[ind].description ??
                                                                  "",
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                fontSize:
                                                                10,
                                                                color: const Color.fromRGBO(
                                                                    0,
                                                                    0,
                                                                    0,
                                                                    0.4),
                                                                fontWeight:
                                                                FontWeight.w400,
                                                              )),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .only(
                                                              left: w *
                                                                  0.02,
                                                              bottom: h *
                                                                  0.01,
                                                              right: w *
                                                                  0.02),
                                                          child: Row(
                                                            children: [
                                                              SvgPicture
                                                                  .asset(
                                                                "assets/images/distance.svg",
                                                                color: Palette
                                                                    .primaryColor,
                                                              ),
                                                              const SizedBox(
                                                                width: 6,
                                                              ),
                                                              Text(
                                                                // distanceInkm
                                                                //         .toStringAsFixed(
                                                                //             2) +
                                                                //     '  km',
                                                                distanceText
                                                                    .toString(),
                                                                textAlign:
                                                                TextAlign
                                                                    .center,
                                                                style: GoogleFonts.montserrat(
                                                                    fontSize:
                                                                    12,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                    color: Palette
                                                                        .primaryColor),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ))
                                                    : ColorFiltered(
                                                  colorFilter:
                                                  const ColorFilter
                                                      .mode(
                                                      Colors.white,
                                                      BlendMode
                                                          .color),
                                                  child: Container(
                                                      margin:
                                                      EdgeInsets.only(
                                                          left: w *
                                                              0.05,
                                                          right: w *
                                                              0.05),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(w *
                                                              0.03),
                                                          color: Palette
                                                              .whiteColor,
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Palette
                                                                    .black
                                                                    .withOpacity(
                                                                    0.16),
                                                                offset:
                                                                const Offset(
                                                                    0,
                                                                    3),
                                                                blurRadius:
                                                                3),
                                                          ]),
                                                      // elevation: 0.7,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          (data[ind].image ==
                                                              null ||
                                                              data[ind].image ==
                                                                  '')
                                                              ? Container(
                                                            width: w *
                                                                0.9,
                                                            height: h *
                                                                0.25,
                                                            decoration:
                                                            BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                  topRight: Radius.circular(w * 0.04),
                                                                  topLeft: Radius.circular(w * 0.04)),
                                                              image: const DecorationImage(
                                                                  image: AssetImage("assets/images/gbannercopy.png"),
                                                                  fit: BoxFit.cover),
                                                            ),
                                                          )
                                                              : Container(
                                                            width: w *
                                                                0.9,
                                                            height: h *
                                                                0.25,
                                                            decoration:
                                                            BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                  topRight: Radius.circular(w * 0.04),
                                                                  topLeft: Radius.circular(w * 0.04)),
                                                              image: DecorationImage(
                                                                  image: CachedNetworkImageProvider(data[ind].image.toString()),
                                                                  fit: BoxFit.cover),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                            h * 0.01,
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.only(
                                                                left: w *
                                                                    0.025,
                                                                right: w *
                                                                    0.02),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                              children: [
                                                                SizedBox(
                                                                  width: w *
                                                                      0.7,
                                                                  child: Text(
                                                                      data[ind]
                                                                          .shopName
                                                                          .toString(),
                                                                      overflow:
                                                                      TextOverflow.ellipsis,
                                                                      style: GoogleFonts.montserrat(
                                                                        fontSize: w * 0.04,
                                                                        fontWeight: FontWeight.w600,
                                                                      )),
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    SvgPicture
                                                                        .asset(
                                                                      Constants.ratingStar,
                                                                      height:
                                                                      h * 0.015,
                                                                      width:
                                                                      w * 0.02,
                                                                      fit:
                                                                      BoxFit.contain,
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                      w * 0.010,
                                                                    ),
                                                                    Text(
                                                                      calculateRating(oneRating: data[ind].oneRating ?? 0, twoRating: data[ind].twoRating ?? 0, threeRating: data[ind].threeRating ?? 0, fourRating: data[ind].fourRating ?? 0, fiveRating: data[ind].fiveRating ?? 0).toStringAsFixed(1),
                                                                      style:
                                                                      GoogleFonts.montserrat(fontSize: w * 0.035, color: Palette.primaryColor),
                                                                    )
                                                                  ],
                                                                ),

                                                                // RatingBar.builder(
                                                                //   itemSize:
                                                                //       w * 0.03,
                                                                //   initialRating:
                                                                //       4.5,
                                                                //   minRating: 1,
                                                                //   direction: Axis
                                                                //       .horizontal,
                                                                //   allowHalfRating:
                                                                //       true,
                                                                //   itemCount: 5,
                                                                //   itemPadding: EdgeInsets
                                                                //       .symmetric(
                                                                //           horizontal:
                                                                //               4.0),
                                                                //   itemBuilder: (context,
                                                                //           _) =>
                                                                //       Icon(
                                                                //           Icons
                                                                //               .star,
                                                                //           color: Color(
                                                                //               0xffFFC400)),
                                                                //   onRatingUpdate:
                                                                //       (rating) {
                                                                //     print(rating);
                                                                //   },
                                                                // )
                                                              ],
                                                            ),
                                                          ),
                                                          data[ind].description ==
                                                              '' ||
                                                              data[ind].description ==
                                                                  null
                                                              ? const SizedBox()
                                                              : Padding(
                                                            padding: EdgeInsets.only(
                                                                left: w *
                                                                    0.02,
                                                                bottom: h *
                                                                    0.01,
                                                                right:
                                                                w * 0.02),
                                                            child: Text(
                                                                data[ind].description ??
                                                                    "",
                                                                style:
                                                                GoogleFonts.montserrat(
                                                                  fontSize: 10,
                                                                  color: const Color.fromRGBO(0, 0, 0, 0.4),
                                                                  fontWeight: FontWeight.w400,
                                                                )),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.only(
                                                                left: w *
                                                                    0.02,
                                                                bottom: h *
                                                                    0.01,
                                                                right: w *
                                                                    0.02),
                                                            child: Row(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  "assets/images/distance.svg",
                                                                ),
                                                                const SizedBox(
                                                                  width:
                                                                  6,
                                                                ),
                                                                Text(
                                                                  // distanceInkm
                                                                  //         .toStringAsFixed(
                                                                  //             2) +
                                                                  //     '  km',
                                                                  distanceText
                                                                      .toString(),
                                                                  textAlign:
                                                                  TextAlign.center,
                                                                  style: GoogleFonts.montserrat(
                                                                      fontSize:
                                                                      12,
                                                                      fontWeight:
                                                                      FontWeight.w600,
                                                                      color: Palette.primaryColor),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                ))

                                          //   // Stack(children: [
                                          //   //   Center(
                                          //   //     child: Padding(
                                          //   //       padding: EdgeInsets.only(
                                          //   //           bottom: h * 0.03),
                                          //   //       child: Card(
                                          //   //         shape: RoundedRectangleBorder(
                                          //   //           borderRadius:
                                          //   //               BorderRadius.circular(
                                          //   //                   w * 0.04),
                                          //   //         ),
                                          //   //         elevation: 10,
                                          //   //         child: (data[ind].image ==
                                          //   //                     null ||
                                          //   //                 data[ind].image == '')
                                          //   //             ? Container(
                                          //   //                 width: w * 0.9,
                                          //   //                 height: h * 0.27,
                                          //   //                 decoration:
                                          //   //                     BoxDecoration(
                                          //   //                   borderRadius:
                                          //   //                       BorderRadius
                                          //   //                           .circular(
                                          //   //                               w * 0.04),
                                          //   //                   image: DecorationImage(
                                          //   //                       image: AssetImage(
                                          //   //                           "assets/images/gbanner.png"),
                                          //   //                       fit: BoxFit.fill),
                                          //   //                 ),
                                          //   //               )
                                          //   //             : Container(
                                          //   //                 width: w * 0.9,
                                          //   //                 height: h * 0.27,
                                          //   //                 decoration:
                                          //   //                     BoxDecoration(
                                          //   //                   borderRadius:
                                          //   //                       BorderRadius
                                          //   //                           .circular(
                                          //   //                               w * 0.04),
                                          //   //                   image: DecorationImage(
                                          //   //                       image: CachedNetworkImageProvider(
                                          //   //                           data[ind]
                                          //   //                               .image
                                          //   //                               .toString()),
                                          //   //                       fit: BoxFit.fill),
                                          //   //                 ),
                                          //   //               ),
                                          //   //       ),
                                          //   //     ),
                                          //   //   ),
                                          //   //   Positioned(
                                          //   //     left: w * 0.05,
                                          //   //     top: h * 0.18,
                                          //   //     child: Container(
                                          //   //       width: w * 0.9,
                                          //   //       height: h * 0.1,
                                          //   //       decoration: BoxDecoration(
                                          //   //           borderRadius:
                                          //   //               BorderRadius.only(
                                          //   //                   bottomLeft:
                                          //   //                       Radius.circular(
                                          //   //                           w * 0.04),
                                          //   //                   bottomRight:
                                          //   //                       Radius.circular(
                                          //   //                           w * 0.04)),
                                          //   //           color: Colors.white),
                                          //   //       child: Row(
                                          //   //         children: [
                                          //   //           SizedBox(
                                          //   //             width: w * 0.045,
                                          //   //           ),
                                          //   //           Column(
                                          //   //             crossAxisAlignment:
                                          //   //                 CrossAxisAlignment
                                          //   //                     .start,
                                          //   //             mainAxisAlignment:
                                          //   //                 MainAxisAlignment
                                          //   //                     .center,
                                          //   //             children: [
                                          //   //               SizedBox(
                                          //   //                 width: w * 0.8,
                                          //   //                 child: Row(
                                          //   //                   mainAxisAlignment:
                                          //   //                       MainAxisAlignment
                                          //   //                           .spaceBetween,
                                          //   //                   children: [
                                          //   //                     Text(
                                          //   //                         "${data[ind].shopName.toString()}",
                                          //   //                         style:
                                          //   //                             TextStyle(
                                          //   //                           fontSize:
                                          //   //                               w * 0.04,
                                          //   //                           fontWeight:
                                          //   //                               FontWeight
                                          //   //                                   .w600,
                                          //   //                         )),
                                          //   //                     // RatingBar.builder(
                                          //   //                     //   itemSize:
                                          //   //                     //       w * 0.03,
                                          //   //                     //   initialRating:
                                          //   //                     //       4.5,
                                          //   //                     //   minRating: 1,
                                          //   //                     //   direction: Axis
                                          //   //                     //       .horizontal,
                                          //   //                     //   allowHalfRating:
                                          //   //                     //       true,
                                          //   //                     //   itemCount: 5,
                                          //   //                     //   itemPadding: EdgeInsets
                                          //   //                     //       .symmetric(
                                          //   //                     //           horizontal:
                                          //   //                     //               4.0),
                                          //   //                     //   itemBuilder: (context,
                                          //   //                     //           _) =>
                                          //   //                     //       Icon(
                                          //   //                     //           Icons
                                          //   //                     //               .star,
                                          //   //                     //           color: Color(
                                          //   //                     //               0xffFFC400)),
                                          //   //                     //   onRatingUpdate:
                                          //   //                     //       (rating) {
                                          //   //                     //     print(rating);
                                          //   //                     //   },
                                          //   //                     // )
                                          //   //                   ],
                                          //   //                 ),
                                          //   //               ),
                                          //   //               Text(
                                          //   //                   data[ind]
                                          //   //                           .description ??
                                          //   //                       "",
                                          //   //                   style: TextStyle(
                                          //   //                     fontSize: 10,
                                          //   //                     color:
                                          //   //                         Color.fromRGBO(
                                          //   //                             0,
                                          //   //                             0,
                                          //   //                             0,
                                          //   //                             0.4),
                                          //   //                     fontWeight:
                                          //   //                         FontWeight.w400,
                                          //   //                   )),
                                          //   //             ],
                                          //   //           ),
                                          //   //         ],
                                          //   //       ),
                                          //   //     ),
                                          //   //   ),
                                          //   //   // Positioned(
                                          //   //   //   child: SvgPicture.asset(Constants.backarrow),
                                          //   //   //   top: h * 0.13,
                                          //   //   //   left: w * 0.13,
                                          //   //   // ),
                                          //   //   // Positioned(
                                          //   //   //   child: SvgPicture.asset(Constants.forwardarrow),
                                          //   //   //   top: h * 0.085,
                                          //   //   //   left: w * 0.76,
                                          //   //   // ),
                                          //   // ]),
                                          //   // ),
                                          // );
                                        );
                                      },
                                    ),
                                  ],
                                );
                              }
                            },
                            error: (error, stackTrace) {
                              if (kDebugMode) {
                                print('error$error$stackTrace');
                              }
                              return const Text("");
                            },
                            loading: () => ListView.builder(
                                shrinkWrap: true,
                                itemCount: 2,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, ind) {
                                  return ShimmerPage(
                                    w: w * 0.9,
                                    h: h * 0.25,
                                  );
                                }),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // bottomNavigationBar: Padding(
          //   padding:
          //       EdgeInsets.only(left: w * 0.03, right: w * 0.03, bottom: h * 0.005),
          //   child: Container(
          //     width: w * 0.9,
          //     height: h * 0.06,
          //     decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(10),
          //         color: Palette.whiteColor,
          //         boxShadow: [
          //           BoxShadow(
          //               color: Palette.black.withOpacity(0.16),
          //               offset: const Offset(3, 3),
          //               blurRadius: 3),
          //         ]),
          //   ),
          // ),
          onGoing
              ? StatefulBuilder(
            builder: (context, setState) {
              // getCancelTime(placedDate: orderData!.placedDate!);
              return Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width * 0.04),
                  child: ExpandableCardContainer(
                    expandedChild: InkWell(
                        onTap: () {
                          orderData!.length == 1
                              ? setState(() {
                            isExpanded = false;
                            showbtn = true;
                          })
                              : null;
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.width * 0.6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(w * 0.06),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade500,
                                offset: const Offset(
                                  0.0,
                                  0.0,
                                ),
                                blurRadius: w * 0.04,
                                spreadRadius: w * 0.004,
                              ), //BoxShadow
                              //BoxShadow
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.05),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                              children: [
                                orderData?.length != 1
                                    ? Text(orderData!.length.toString())
                                    : Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Text(
                                      orderData![0].orderStatus == 0
                                          ? "Pending..."
                                          : orderData![0]
                                          .orderStatus ==
                                          1
                                          ? "Accepted"
                                          : orderData![0]
                                          .orderStatus ==
                                          4
                                          ? 'Ready for Pickup'
                                          : orderData![0]
                                          .orderStatus ==
                                          5
                                          ? 'Picked'
                                          : orderData![0]
                                          .orderStatus ==
                                          6
                                          ? 'Not Delivered'
                                          : orderData![0].orderStatus ==
                                          7
                                          ? 'Delivered'
                                          : '',
                                      style: GoogleFonts.montserrat(
                                          fontWeight:
                                          FontWeight.w600,
                                          fontSize: w * 0.03,
                                          color:
                                          Palette.primaryColor),
                                    ),
                                    Container(
                                        decoration:
                                        const BoxDecoration(
                                            shape:
                                            BoxShape.circle,
                                            color: Palette
                                                .primaryColor),
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              MediaQuery.of(context)
                                                  .size
                                                  .width *
                                                  0.01),
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: w * 0.045,
                                          ),
                                        ))
                                  ],
                                ),
                                SizedBox(
                                  height:
                                  MediaQuery.of(context).size.width *
                                      0.015,
                                ),
                                Text(
                                  orderData![0].mbuName!,
                                  style: GoogleFonts.montserrat(
                                      fontSize: w * 0.045,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  height:
                                  MediaQuery.of(context).size.width *
                                      0.005,
                                ),
                                Text(
                                  DateFormat("dd MMMM yyyy, hh:mm aa")
                                      .format(orderData![0].placedDate!),
                                  style: GoogleFonts.montserrat(
                                      fontSize: w * 0.032,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade500),
                                ),
                                SizedBox(
                                  height:
                                  MediaQuery.of(context).size.width *
                                      0.005,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Order ID',
                                        style: GoogleFonts.montserrat(
                                            fontSize: w * 0.032,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade500),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.025),
                                      child: Text(
                                        ':',
                                        style: GoogleFonts.montserrat(
                                            fontSize: w * 0.032,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade500),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        orderData![0].orderId!,
                                        style: GoogleFonts.montserrat(
                                            fontSize: w * 0.032,
                                            fontWeight: FontWeight.w500,
                                            color: Palette.primaryColor),
                                      ),
                                    ),
                                    const Expanded(child: SizedBox())
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Delivery Type',
                                        style: GoogleFonts.montserrat(
                                            fontSize: w * 0.032,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade500),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.025),
                                      child: Text(
                                        ':',
                                        style: GoogleFonts.montserrat(
                                            fontSize: w * 0.032,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade500),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        orderData![0].orderType!,
                                        style: GoogleFonts.montserrat(
                                            fontSize: w * 0.032,
                                            fontWeight: FontWeight.w500,
                                            color: Palette.primaryColor),
                                      ),
                                    ),
                                    const Expanded(child: SizedBox())
                                  ],
                                ),
                                orderData![0].orderType == 'Delivery'
                                    ? Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Delivery Pin',
                                        style:
                                        GoogleFonts.montserrat(
                                            fontSize: w * 0.032,
                                            fontWeight:
                                            FontWeight.w500,
                                            color: Colors
                                                .grey.shade500),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right:
                                          MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.025),
                                      child: Text(
                                        ':',
                                        style:
                                        GoogleFonts.montserrat(
                                            fontSize: w * 0.032,
                                            fontWeight:
                                            FontWeight.w500,
                                            color: Colors
                                                .grey.shade500),
                                      ),
                                    ),
                                    Expanded(
                                        child: Text(
                                          orderData![0].deliveryPin!,
                                          style: GoogleFonts.montserrat(
                                              fontSize: w * 0.032,
                                              fontWeight:
                                              FontWeight.w500,
                                              color:
                                              Palette.primaryColor),
                                        )),
                                    const Expanded(
                                        child: SizedBox())
                                  ],
                                )
                                    : const SizedBox(),
                                // Row(
                                //   children: [
                                //     Expanded(
                                //       child: Column(
                                //         crossAxisAlignment:
                                //             CrossAxisAlignment.start,
                                //         children: [
                                //           Text(
                                //             'Order ID',
                                //             style: GoogleFonts.montserrat(
                                //                 fontSize: w * 0.032,
                                //                 fontWeight:
                                //                     FontWeight.w500,
                                //                 color:
                                //                     Colors.grey.shade500),
                                //           ),
                                //           Text(
                                //             'Delivery Type',
                                //             style: GoogleFonts.montserrat(
                                //                 fontSize: w * 0.031,
                                //                 fontWeight:
                                //                     FontWeight.w500,
                                //                 color:
                                //                     Colors.grey.shade500),
                                //           ),
                                //           orderData![0].orderType ==
                                //                   'Delivery'
                                //               ? Text(
                                //                   'Delivery Pin',
                                //                   style: TextStyle(
                                //                       fontSize: w * 0.032,
                                //                       fontWeight:
                                //                           FontWeight.w500,
                                //                       color: Colors
                                //                           .grey.shade500),
                                //                 )
                                //               // : orderData![0].orderType ==
                                //               //         'Take Away'
                                //               //     ? Text(
                                //               //         'Take Away Pin',
                                //               //         style: TextStyle(
                                //               //             fontSize:
                                //               //                 w * 0.032,
                                //               //             fontWeight:
                                //               //                 FontWeight
                                //               //                     .w500,
                                //               //             color: Colors
                                //               //                 .grey
                                //               //                 .shade500),
                                //               //       )
                                //                   : const SizedBox()
                                //         ],
                                //       ),
                                //     ),
                                //     Padding(
                                //       padding: EdgeInsets.only(
                                //           right: MediaQuery.of(context)
                                //                   .size
                                //                   .width *
                                //               0.025),
                                //       child: Column(
                                //         crossAxisAlignment:
                                //             CrossAxisAlignment.start,
                                //         children: [
                                //           Text(
                                //             ':',
                                //             style: GoogleFonts.montserrat(
                                //                 fontSize: w * 0.032,
                                //                 fontWeight:
                                //                     FontWeight.w500,
                                //                 color:
                                //                     Colors.grey.shade500),
                                //           ),
                                //           Text(
                                //             ':',
                                //             style: GoogleFonts.montserrat(
                                //                 fontSize: w * 0.032,
                                //                 fontWeight:
                                //                     FontWeight.w500,
                                //                 color:
                                //                     Colors.grey.shade500),
                                //           ),
                                //           orderData![0].orderType ==
                                //                       'Delivery'
                                //               // ||
                                //               //     orderData![0]
                                //               //             .orderType ==
                                //               //         'Take Away'
                                //               ? Text(
                                //                   ':',
                                //                   style: GoogleFonts
                                //                       .montserrat(
                                //                           fontSize:
                                //                               w * 0.032,
                                //                           fontWeight:
                                //                               FontWeight
                                //                                   .w500,
                                //                           color: Colors
                                //                               .grey
                                //                               .shade500),
                                //                 )
                                //               : const SizedBox(),
                                //         ],
                                //       ),
                                //     ),
                                //     Expanded(
                                //       child: Column(
                                //         crossAxisAlignment:
                                //             CrossAxisAlignment.start,
                                //         children: [
                                //           Text(
                                //             orderData![0].orderId!,
                                //             style: GoogleFonts.montserrat(
                                //                 fontSize: w * 0.032,
                                //                 fontWeight:
                                //                     FontWeight.w500,
                                //                 color:
                                //                     Palette.primaryColor),
                                //           ),
                                //           Text(
                                //             orderData![0].orderType!,
                                //             style: GoogleFonts.montserrat(
                                //                 fontSize: w * 0.032,
                                //                 fontWeight:
                                //                     FontWeight.w500,
                                //                 color:
                                //                     Palette.primaryColor),
                                //           ),
                                //           orderData![0].orderType ==
                                //                       'Delivery'
                                //               // ||
                                //               //     orderData![0]
                                //               //             .orderType ==
                                //               //         'Take Away'
                                //               ? Text(
                                //                   orderData![0]
                                //                       .deliveryPin!,
                                //                   style: GoogleFonts
                                //                       .montserrat(
                                //                           fontSize:
                                //                               w * 0.032,
                                //                           fontWeight:
                                //                               FontWeight
                                //                                   .w500,
                                //                           color: Palette
                                //                               .primaryColor),
                                //                 )
                                //               : const SizedBox()
                                //         ],
                                //       ),
                                //     ),
                                //     const Expanded(child: SizedBox())
                                //   ],
                                // ),
                                Expanded(
                                    child: SizedBox(
                                      height:
                                      MediaQuery.of(context).size.width *
                                          0.005,
                                    )),
                                IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (context) =>
                                                      MyOrdersSinglePage(
                                                          data:
                                                          orderData![
                                                          0],
                                                          splash: false),
                                                ));
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Palette.primaryColor,
                                              borderRadius:
                                              BorderRadius.circular(
                                                  w * 0.06),
                                            ),
                                            child: Center(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    top: w * 0.03,
                                                    bottom: w * 0.03),
                                                child: const Text(
                                                  "View Orders",
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      color:
                                                      Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // SizedBox(
                                      //   width: MediaQuery.of(context)
                                      //           .size
                                      //           .width *
                                      //       0.05,
                                      // ),
                                      // Expanded(
                                      //   child: remainingTime == null ||
                                      //           remainingTime!.isNegative
                                      //       ? const SizedBox()
                                      //       : SizedBox(
                                      //           width: w * 0.9,
                                      //           child: Row(
                                      //               mainAxisAlignment:
                                      //                   MainAxisAlignment
                                      //                       .end,
                                      //               children: [
                                      //                 InkWell(
                                      //                   onTap: () {
                                      //                     showDialog(
                                      //                       context:
                                      //                           context,
                                      //                       builder:
                                      //                           (BuildContext
                                      //                               context) {
                                      //                         return StatefulBuilder(
                                      //                           builder:
                                      //                               (context,
                                      //                                   setState) {
                                      //                             return AlertDialog(
                                      //                               // shape:RoundedRectangleBorder(borderRadius: BorderRadiusGeometry()),
                                      //                               title:
                                      //                                   const Row(
                                      //                                 mainAxisAlignment:
                                      //                                     MainAxisAlignment.center,
                                      //                                 children: [
                                      //                                   Text(
                                      //                                     "cancel Reason?",
                                      //                                     style: TextStyle(
                                      //                                       fontSize: 16,
                                      //                                       fontWeight: FontWeight.w500,
                                      //                                     ),
                                      //                                   ),
                                      //                                 ],
                                      //                               ),
                                      //                               actions: [
                                      //                                 Row(
                                      //                                   mainAxisAlignment: MainAxisAlignment.end,
                                      //                                   children: [
                                      //                                     GestureDetector(
                                      //                                       onTap: () async {
                                      //                                         Navigator.pop(context);
                                      //                                       },
                                      //                                       child: SizedBox(
                                      //                                         child: Text(
                                      //                                           "No",
                                      //                                           style: TextStyle(
                                      //                                             fontSize: w * 0.05,
                                      //                                             color: Palette.primaryColor,
                                      //                                             fontWeight: FontWeight.w400,
                                      //                                           ),
                                      //                                         ),
                                      //                                       ),
                                      //                                     ),
                                      //                                     SizedBox(
                                      //                                       width: w * 0.03,
                                      //                                     ),
                                      //                                     GestureDetector(
                                      //                                       onTap: () {
                                      //                                         if (reasons != null) {
                                      //                                           if (reasons == 'other' && reasonController.text.isNotEmpty) {
                                      //                                             print('0000000');
                                      //                                             OrderModel updateData = OrderModel(orderStatus: 3, cancelledBy: 'By Customer', cancelledDate: DateTime.now(), cancellReason: reasons != 'other' ? reasons : reasonController.text);
                                      //                                             FirebaseFirestore.instance.collection('orders').doc(orderData!.orderId).update(updateData.updateJson());
                                      //                                             onGoing = false;
                                      //                                             setState(() {});
                                      //                                             Navigator.pop(context);
                                      //                                           } else if (reasons != 'other') {
                                      //                                             print('11111111111');
                                      //                                             OrderModel updateData = OrderModel(
                                      //                                               orderStatus: 3,
                                      //                                               cancelledBy: 'By Customer',
                                      //                                               cancelledDate: DateTime.now(),
                                      //                                               cancellReason: reasons != 'other' ? reasons : reasonController.text,
                                      //                                             );
                                      //                                             FirebaseFirestore.instance.collection('orders').doc(orderData!.orderId).update(updateData.updateJson());
                                      //                                             onGoing = false;
                                      //                                             setState(() {});
                                      //                                             Navigator.pop(context);
                                      //                                           } else {
                                      //                                             showSnackBar(context, "Please enter Reason");
                                      //                                           }
                                      //                                         } else {
                                      //                                           showSnackBar(context, "Please select Reason");
                                      //                                         }
                                      //                                       },
                                      //                                       child: Text(
                                      //                                         "Yes",
                                      //                                         style: TextStyle(
                                      //                                           fontSize: w * 0.05,
                                      //                                           color: Palette.primaryColor,
                                      //                                           fontWeight: FontWeight.w400,
                                      //                                         ),
                                      //                                       ),
                                      //                                     ),
                                      //                                   ],
                                      //                                 ),
                                      //                               ],
                                      //                               content: Container(
                                      //                                   height: reasons != "other" ? h * 0.065 : h * 0.17,
                                      //                                   // width: w * 0.01,
                                      //                                   decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                      //                                   child: Column(
                                      //                                     children: [
                                      //                                       Center(
                                      //                                         child: DropdownButtonHideUnderline(
                                      //                                           child: DropdownButton2(
                                      //                                             hint: Text('Reason', style: GoogleFonts.montserrat(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500)),
                                      //                                             items: rejectReasonsA
                                      //                                                 .map((item) => DropdownMenuItem<String>(
                                      //                                                     value: item,
                                      //                                                     child: Text(
                                      //                                                       item,
                                      //                                                       style: const TextStyle(overflow: TextOverflow.ellipsis, color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500),
                                      //                                                     )))
                                      //                                                 .toList(),
                                      //                                             value: reasons,
                                      //                                             onChanged: (value) {
                                      //                                               print('Selected value: $value');
                                      //                                               setState(() {
                                      //                                                 reasons = value as String;
                                      //                                                 // value ==
                                      //                                                 //         'other'
                                      //                                                 //     ? other =
                                      //                                                 //         true
                                      //                                                 //     : other =
                                      //                                                 //         false;
                                      //                                               });
                                      //                                             },
                                      //                                           ),
                                      //                                         ),
                                      //                                       ),
                                      //                                       reasons == "other"
                                      //                                           ? Form(
                                      //                                               key: formKey,
                                      //                                               child: TextFormField(
                                      //                                                 controller: reasonController,
                                      //                                                 decoration: const InputDecoration(
                                      //                                                   hintText: "Enter Reason",
                                      //                                                 ),
                                      //                                                 validator: (value) {
                                      //                                                   if (value!.isEmpty) {
                                      //                                                     return 'Please enter Reason';
                                      //                                                   } else {
                                      //                                                     return null;
                                      //                                                   }
                                      //                                                 },
                                      //                                               ),
                                      //                                             )
                                      //                                           : const SizedBox()
                                      //                                     ],
                                      //                                   )),
                                      //                             );
                                      //                           },
                                      //                         );
                                      //                       },
                                      //                     );
                                      //                   },
                                      //                   child: Container(
                                      //                     width: w * 0.32,
                                      //                     height:
                                      //                         h * 0.048,
                                      //                     decoration: BoxDecoration(
                                      //                         borderRadius:
                                      //                             BorderRadius.circular(
                                      //                                 15),
                                      //                         color: Palette
                                      //                             .primaryColor),
                                      //                     child: Column(
                                      //                         mainAxisAlignment:
                                      //                             MainAxisAlignment
                                      //                                 .center,
                                      //                         children: [
                                      //                           Text(
                                      //                             formattedTime,
                                      //                             style: GoogleFonts.montserrat(
                                      //                                 color:
                                      //                                     Palette.whiteColor,
                                      //                                 fontWeight: FontWeight.w600,
                                      //                                 fontSize: w * 0.03),
                                      //                           ),
                                      //                           Text(
                                      //                             "Cancel Order",
                                      //                             style: GoogleFonts.montserrat(
                                      //                                 color:
                                      //                                     Palette.whiteColor,
                                      //                                 fontWeight: FontWeight.w600,
                                      //                                 fontSize: w * 0.03),
                                      //                           ),
                                      //                         ]),
                                      //                   ),
                                      //                 )
                                      //               ])),
                                      // )
                                    ],
                                  ),
                                ),
                                Expanded(
                                    child: SizedBox(
                                      height:
                                      MediaQuery.of(context).size.width *
                                          0.005,
                                    )),
                              ],
                            ),
                          ),
                        )),
                    collapsedChild: InkWell(
                        onTap: () {
                          orderData!.length == 1
                              ? setState(() {
                            isExpanded = true;

                            showbtn = false;
                          })
                              : null;
                        },
                        child: Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width * 0.7,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade500,
                                offset: const Offset(
                                  0.0,
                                  0.0,
                                ),
                                blurRadius: 15.0,
                                spreadRadius: 2.0,
                              ), //BoxShadow
                              //BoxShadow
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width *
                                    0.025),
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                  EdgeInsets.only(right: w * 0.02),
                                  // child: Image.asset(
                                  //   Constants.appIconPng,
                                  //   width: w * 0.09,
                                  //   height: w * 0.09,
                                  //   fit: BoxFit.cover,
                                  // ),
                                  child: SvgPicture.asset(
                                    Constants.green3DLogo,
                                    width: w * 0.09,
                                    height: w * 0.09,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // Image.asset('assets/order.gif',height: 100,fit: BoxFit.cover,)

                                orderData!.length == 1
                                    ? Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        'Status : ',
                                        style:
                                        GoogleFonts.montserrat(
                                          fontSize: w * 0.04,
                                          fontWeight:
                                          FontWeight.w500,
                                          color: Palette.textColor,
                                        ),
                                      ),
                                      Text(
                                        orderData![0].orderStatus ==
                                            0
                                            ? "Pending..."
                                            : orderData![0]
                                            .orderStatus ==
                                            1
                                            ? "Accepted"
                                            : orderData![0]
                                            .orderStatus ==
                                            4
                                            ? 'Ready for Pickup'
                                            : orderData![0]
                                            .orderStatus ==
                                            5
                                            ? 'Picked'
                                            : orderData![0].orderStatus ==
                                            6
                                            ? 'Not Delivered'
                                            : orderData![0].orderStatus ==
                                            7
                                            ? 'Delivered'
                                            : ''.toUpperCase(),
                                        style:
                                        GoogleFonts.montserrat(
                                            fontWeight:
                                            FontWeight.bold,
                                            color: Palette
                                                .primaryColor),
                                      ),
                                    ],
                                  ),
                                )
                                    : Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (context) =>
                                                  const MyOrdersPage(),
                                                ));
                                          },
                                          child: Container(
                                            decoration:
                                            BoxDecoration(
                                              color: Palette
                                                  .primaryColor,
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  w * 0.06),
                                            ),
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                EdgeInsets.only(
                                                    top: w *
                                                        0.03,
                                                    bottom: w *
                                                        0.03),
                                                child: const Text(
                                                  "View Orders",
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w600,
                                                      color: Colors
                                                          .white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // const CircleAvatar(
                                //   backgroundColor: Color(0xffFF007F),
                                //   radius: 15,
                                //   child: Center(
                                //     child: Text(
                                //       '1',
                                //       style: TextStyle(
                                //           fontWeight: FontWeight.bold,
                                //           color: Colors.white),
                                //     ),
                                //   ),
                                // )
                              ],
                            ),
                          ),
                        )),
                    isExpanded: isExpanded,
                  ),
                ),
              );
            },
          )
              : const SizedBox(),
        ],
      ),
    );
  }
}

// var currenPlace='';
// String? admistrativeArea='';
// double? lat;
// double? long;
class CustomAppBar extends ConsumerStatefulWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends ConsumerState<CustomAppBar> {
  g_map_place_picker.PickResult? result;
  bool selectLocation = false;

  set() {
    setState(() {});
  }

  Future<String?> getBuildingName(placeId, String apiKey) async {
    String url = 'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId&fields=address_component&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'OK') {
        List<dynamic> addressComponents = data['result']['address_components'];

        for (var component in addressComponents) {
          if (kDebugMode) {
            print(component);
          }
          List<dynamic> types = component['types'];
          if (types.contains('premise')) {
            if (kDebugMode) {
              print("hereeeeeeeeeeeeeeeeeeeeeeeeeeee");
            }
            return component['long_name'];
          }
        }

        return null; // Building name not found in address components
      } else {
        return 'Error: ${data['status']}';
      }
    } else {
      return 'Error: Unable to connect to the API';
    }
  }

  getLocationDetails(double lat, double long) async {
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=AIzaSyDc5GsjLIukF_OMKTbFqkUPmWFrI7cxTAQ";
    final response = await http.get(Uri.parse(url));

    Map<String, dynamic> data = json.decode(response.body);

    if (data['status'] == 'OK') {
      for (var a in data['results']) {
        if (kDebugMode) {
          print(a['formatted_address']);
          print(a['types']);
        }
      }

      // List pcs = data['results'][0]['formatted_address'].split(",");
      // print(pcs[pcs.length - 6]);

      // print(data['results'][0]['types']);
    } else {
      if (kDebugMode) {
        print("Error: ${data['status']}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: w * 0.15,
      color: Palette.whiteColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () async {
              debugPrint('onTap');
              try {
                debugPrint('try');

                if (!selectLocation) {
                  debugPrint('selectLocation');

                  selectLocation = true;
                  location = location ??
                      await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.bestForNavigation);
                  // Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      // const getMapRoute()),
                      g_map_place_picker.PlacePicker(
                        apiKey: "AIzaSyDc5GsjLIukF_OMKTbFqkUPmWFrI7cxTAQ",
                        // apiKey: "AIzaSyCUZFUZ1yMpkzh6QUnKj54Q2N4L2iT4tBY",
                        initialPosition: g_map.LatLng(
                            location!.latitude, location!.longitude),
                        hintText: 'Search Location',
                        usePlaceDetailSearch: true,
                        enableMapTypeButton: true,
                        // Put YOUR OWN KEY here.
                        searchForInitialValue: true,
                        selectInitialPosition: true,

                        // initialPosition: LatLng(currentLoc==null?0:currentLoc!.latitude,currentLoc==null?0:currentLoc!.longitude),
                        onPlacePicked: (res) async {
                          // picked = res;
                          if (kDebugMode) {
                            print(res.formattedAddress);
                          }

                          Navigator.of(context).pop();
                          // Navigator.of(context).pop();
                          // GeoCode geoCode = GeoCode();
                          // Address address=await geoCode.reverseGeocoding(latitude: res.geometry!.location.lat,longitude: res.geometry!.location.lng);
                          result = res;
                          // latitude!.text=res.geometry!.location.lat.toString();
                          // longitude!.text=res.geometry!.location.lng.toString();
                          lat = res.geometry!.location.lat;
                          long = res.geometry!.location.lng;
                          ref
                              .read(latProvider.notifier)
                              .update((state) => res.geometry!.location.lat);
                          ref
                              .read(longProvider.notifier)
                              .update((state) => res.geometry!.location.lng);

                          currenPlace = res.name;
                          // admistrativeArea = (res.formattedAddress?.split(',').sublist(1)??res.vicinity).toString().replaceAll("[", "").replaceAll("]", "");
                          List addList = res.formattedAddress?.split(",") ?? [];
                          // addList.removeAt(0);
                          admistrativeArea = "";
                          for (String a in addList) {
                            if (!a.contains("+") &&
                                !a.contains(" Kerala ") &&
                                !a.contains(" India")) {
                              admistrativeArea = '$admistrativeArea$a,';
                            }
                          }

                          set();
                          // getNearestShop();
                        },
                        useCurrentLocation: true,
                      ),
                    ),
                  );
                  set();
                  selectLocation = false;
                }
              } catch (e) {
                debugPrint('e');
                debugPrint('$e');
                debugPrint('e');
              }
            },
            child: SizedBox(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: w * 0.04,
                  ),
                  // Image.asset(
                  //   Constants.appIconPng,
                  //   width: w * 0.09,
                  //   height: w * 0.09,
                  //   fit: BoxFit.cover,
                  // ),
                  SvgPicture.asset(
                    Constants.green3DLogo,
                    width: w * 0.09,
                    height: w * 0.09,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    width: w * 0.02,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          // InkWell(
                          //   onTap: ()  async {
                          //     Position location = await Geolocator.getCurrentPosition(
                          //         desiredAccuracy: LocationAccuracy.high
                          //     );
                          //
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) =>
                          //             gMapPlacePicker.PlacePicker(
                          //               apiKey: "AIzaSyDc5GsjLIukF_OMKTbFqkUPmWFrI7cxTAQ",
                          //               initialPosition: gMap.LatLng(
                          //                   location.latitude,location.longitude
                          //               ),
                          //               // Put YOUR OWN KEY here.
                          //               searchForInitialValue: false,
                          //               selectInitialPosition: true,
                          //               // initialPosition: LatLng(currentLoc==null?0:currentLoc!.latitude,currentLoc==null?0:currentLoc!.longitude),
                          //               onPlacePicked: (res) async {
                          //                 Navigator.of(context).pop();
                          //                 // GeoCode geoCode = GeoCode();
                          //                 // Address address=await geoCode.reverseGeocoding(latitude: res.geometry!.location.lat,longitude: res.geometry!.location.lng);
                          //                 result=res;
                          //                 // latitude!.text=res.geometry!.location.lat.toString();
                          //                 // longitude!.text=res.geometry!.location.lng.toString();
                          //                 lat=res.geometry!.location.lat;
                          //                 long=res.geometry!.location.lng;
                          //                 List<Placemark> placemarks = await placemarkFromCoordinates(
                          //                     res.geometry!.location.lat, res.geometry!.location.lng);
                          //                 Placemark place = placemarks[0];
                          //                 currenPlace = place.locality!;
                          //                 admistrativeArea= place.administrativeArea;
                          //
                          //                 set();
                          //                 // getNearestShop();
                          //               },
                          //               useCurrentLocation: true,
                          //             ),
                          //       ),
                          //     );
                          //
                          //   },
                          //
                          //   child: Container(
                          //     child: SvgPicture.asset(
                          //       "assets/images/location_Icon.svg",
                          //       height: 24.33,
                          //       width: 19,
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          // ),
                          Text(
                            currenPlace ?? 'Location',
                            textAlign: TextAlign.left,
                            style: GoogleFonts.montserrat(
                              fontSize: w * 0.044,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            width: w * 0.02,
                          ),
                          SvgPicture.asset(
                            Constants.arrowDown,
                            color: const Color(0xff777777),
                            width: w * 0.03,
                            height: h * 0.012,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                      SizedBox(
                        width: w * 0.8,
                        child: Text(
                          admistrativeArea ?? 'Location',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w400,
                            fontSize: w * 0.028,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: h * 0.008,
                      )
                    ],
                  ),
                  SizedBox(
                    height: w * 0.015,
                  ),
                ],
              ),
            ),
          ),
          const Row(
            children: [
              // SvgPicture.asset(
              //   Constants.notification,
              //   color: Palette.primaryColor,
              //   width: w * 0.04,
              //   height: h * 0.025,
              // ),
              // SizedBox(
              //   width: w * 0.03,
              // )
            ],
          )
        ],
      ),
    );
  }

// void _showLocationBottomSheet(Position location) {
//   showModalBottomSheet(
//     context: context,
//     builder: (context) {
//       return Container(
//         // Customize the bottom sheet layout and content here
//         child: Column(
//           children: [
//             Text(
//               'Current Location:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text('Latitude: ${location.latitude}'),
//             Text('Longitude: ${location.longitude}'),
//           ],
//         ),
//       );
//     },
//   );
// }
}

class ExpandableCardContainer extends StatefulWidget {
  final bool isExpanded;
  final Widget collapsedChild;
  final Widget expandedChild;

  const ExpandableCardContainer(
      {Key? key,
        required this.isExpanded,
        required this.collapsedChild,
        required this.expandedChild})
      : super(key: key);

  @override
  _ExpandableCardContainerState createState() =>
      _ExpandableCardContainerState();
}

class _ExpandableCardContainerState extends State<ExpandableCardContainer> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: widget.isExpanded ? widget.expandedChild : widget.collapsedChild,
    );
  }
}
