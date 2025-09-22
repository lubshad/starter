import 'package:flutter/material.dart';
import 'package:starter/models/name_id.dart';
import '../../core/app_route.dart';
import '../../exporter.dart';
import '../../mixins/event_listener.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/network_resource.dart';
import '../../widgets/shimwrapper.dart';
import 'service_controller.dart';
import 'widgets/service_card.dart';

class ServiceListingSectionV2 extends StatefulWidget {
  const ServiceListingSectionV2({super.key, this.axis = Axis.vertical});

  final Axis axis;

  @override
  State<ServiceListingSectionV2> createState() => _OfferListingSectionState();
}

class _OfferListingSectionState extends State<ServiceListingSectionV2>
    with EventListenerMixin {
  @override
  void initState() {
    getData();
    allowedEvents = [EventType.locationUpdate, EventType.resumed];
    listenForEvents((event) {
      getData();
    });
    super.initState();
  }

  @override
  void dispose() {
    disposeEventListener();
    super.dispose();
  }

  Future<List<NameId>>? future;

  Future<void> getData() async {
    if (ServiceController.i.services.isNotEmpty) {
      future = Future.value(ServiceController.i.services);
      return;
    }

    // future = DataRepository.i
    //     .fetchBusinessServices(pageSize: 100, page: 1)
    //     .then((value) => value.results);
  }

  @override
  Widget build(BuildContext context) {
    final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: widget.axis == Axis.horizontal ? 1 : 3,
      mainAxisSpacing: padding,
    );
    final gridPadding = EdgeInsets.symmetric(
      horizontal: paddingLarge,
      vertical: middlePadding,
    );
    return NetworkResource(
      future,
      loading: Builder(
        builder: (context) {
          if (widget.axis == Axis.horizontal) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: middlePadding - padding,
              ),
              scrollDirection: widget.axis,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  5,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: paddingSmall),
                    width: 120.w,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Shimwrapper(child: Container()),
                    ),
                  ),
                ),
              ),
            );
          }
          return GridView(
            shrinkWrap: true,
            padding: gridPadding,
            gridDelegate: gridDelegate,
            children: List.generate(
              6,
              (index) => Shimwrapper(child: Container()),
            ),
          );
        },
      ),
      error: (error) => ErrorWidgetWithRetry(exception: error, retry: getData),
      success: (services) {
        if (widget.axis == Axis.vertical) {
          return GridView(
            padding: gridPadding,
            gridDelegate: gridDelegate,
            children: services
                .map(
                  (e) => ServiceCard(
                    text: e.name,
                    image: e.secondary,
                    grid: true,
                    onTap: () => navigate(
                      context,
                      ServiceListingScreen.path,
                      arguments: e.id,
                    ),
                  ),
                )
                .toList(),
          );
        }
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: middlePadding - padding),
          scrollDirection: widget.axis,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: services
                .map(
                  (e) => ServiceCard(
                    text: e.name,
                    image: e.secondary,
                    onTap: () => navigate(
                      context,
                      ServiceListingScreen.path,
                      arguments: e.id,
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class ServiceListingScreen extends StatelessWidget {
  static const String path = "/service-listing-screen";

  const ServiceListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Services".tr),
      body: ServiceListingSectionV2(),
    );
  }
}
