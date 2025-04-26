import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../exporter.dart';

class SelectedDateNotifier extends ValueNotifier<DateTime> {
  SelectedDateNotifier(super.value);
}

final dateNotifier = SelectedDateNotifier(DateTime.now());

class CurrentDate extends StatefulWidget {
  const CurrentDate({super.key, required this.onDateChanged, this.initialDate});
  final Function(DateTime) onDateChanged;
  final DateTime? initialDate;
  @override
  State<CurrentDate> createState() => _CurrentDateState();
}

class _CurrentDateState extends State<CurrentDate> {
  DateTime today = DateTime.now();

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      animateToCurrentDate();
    });
  }

  late DateTime selectedDate;

  int itemsCount = SizeUtils.deviceType == DeviceType.mobile ? 7 : 9;
  int get dateCount {
    int result = today.day + (itemsCount / 2).toInt() + 1;
    if (result < itemsCount) {
      result = itemsCount;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final itemWidth = context.width / itemsCount;

    return SizedBox(
      height: itemWidth,
      child: AnimatedBuilder(
        animation: dateNotifier,
        builder: (context, child) {
          final totalDates = selectedDate.month == today.month ? dateCount : 33;
          return ListView.builder(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: totalDates,
            itemBuilder: (context, index) {
              // put date picker on first
              if (index == 0) {
                return Container(
                  width: itemWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(padding),
                    border: Border.all(color: const Color(0xffefefef)),
                  ),
                  child: InkWell(
                    onTap: showCustomDate,
                    child: Icon(Icons.date_range),
                  ),
                );
              }
              // put date picker on last
              if (index == totalDates - 1) {
                return Container(
                  width: context.width / itemsCount,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(padding),
                    border: Border.all(color: const Color(0xffefefef)),
                  ),
                  child: InkWell(
                    onTap: showCustomDate,
                    child: Icon(Icons.date_range),
                  ),
                );
              }
              DateTime date = DateTime(
                selectedDate.year,
                selectedDate.month,
                index,
              );
              String dayOfWeek = DateFormat.E().format(date).toUpperCase();
              String dayOfMonth = DateFormat.d().format(date);

              bool isPastDate = date.isBefore(today);
              bool isFutureDate = date.isAfter(today);
              return GestureDetector(
                onTap: isFutureDate ? null : () => changeDate(date),
                child: Container(
                  width: context.width / itemsCount,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(padding),
                    gradient: date.isSameDay(selectedDate)
                        ? LinearGradient(
                            colors: [Color(0xffD52358), Color(0xffEC7130)],
                          )
                        : LinearGradient(
                            colors: [Color(0xffFFFFFF), Color(0xffFFFFFF)],
                          ),
                    border: Border.all(
                      width: 0.5,
                      color: date.isSameDay(selectedDate)
                          ? Colors.transparent
                          : const Color(0xffefefef),
                    ),
                    color: date.isSameDay(selectedDate)
                        ? const Color(0xffFFD7D4)
                        : const Color(0xffffffff),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayOfWeek,
                        style: context.bodySmall.copyWith(
                          color: date.isSameDay(selectedDate)
                              ? Colors.white
                              : isPastDate
                                  ? Colors.black
                                  : const Color(0xff999999),
                        ),
                      ),
                      Text(
                        dayOfMonth,
                        style: context.bodySmall.copyWith(
                          color: date.isSameDay(selectedDate)
                              ? Colors.white
                              : isPastDate
                                  ? Colors.black
                                  : const Color(0xff999999),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void animateToCurrentDate() {
    final itemWidth = context.width / itemsCount;

    double offset = (selectedDate.day - (itemsCount / 2).toInt()) * (itemWidth);
    scrollController.animateTo(
      offset,
      duration: animationDuration,
      curve: Curves.fastOutSlowIn,
    );
  }

  void changeDate(DateTime date) {
    if (selectedDate.isSameDay(date)) return;
    selectedDate = date;
    setState(() {});
    animateToCurrentDate();
    widget.onDateChanged(date);
  }

  void showCustomDate() async {
    final pickedDate = await showDatePicker(
      keyboardType: TextInputType.name,
      context: context,
      firstDate: DateTime(2024),
      lastDate: today,
    );
    if (pickedDate == null) return;
    changeDate(pickedDate);
  }
}
