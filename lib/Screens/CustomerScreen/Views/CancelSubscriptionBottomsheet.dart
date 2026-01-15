import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CancelSubscriptionBottomSheet extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String customerProfileId;

  const CancelSubscriptionBottomSheet({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.customerProfileId,
  });

  @override
  State<CancelSubscriptionBottomSheet> createState() =>
      _CancelSubscriptionBottomSheetState();
}

class _CancelSubscriptionBottomSheetState
    extends State<CancelSubscriptionBottomSheet>
    with SingleTickerProviderStateMixin {
  final DateFormat formatter = DateFormat('dd MMM yyyy');
  DateTime? rangeStart;
  DateTime? rangeEnd;
  late DateTime focusedDay;

  String cancelType = "RANGE"; 

  @override
  void initState() {
    super.initState();
    focusedDay = widget.startDate;
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.startDate;
    final end = widget.endDate;

    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxHeight: cancelType == "ALL"
              ? MediaQuery.of(context).size.height * 0.4
              : MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          physics: cancelType == "ALL"
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const Center(
                child: Text(
                  "Cancel Subscription",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0474B9),
                    fontFamily: "Inter",
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),

              const Text(
                "Choose cancellation type",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Inter",
                ),
              ),
              const SizedBox(height: 10),

  
              RadioListTile<String>(
                title: const Text("Cancel for a specific range"),
                value: "RANGE",
                groupValue: cancelType,
                activeColor: const Color(0xFF0474B9),
                onChanged: (v) => setState(() => cancelType = v!),
              ),
              RadioListTile<String>(
                title: const Text("Cancel entire subscription"),
                value: "ALL",
                groupValue: cancelType,
                activeColor: const Color(0xFF0474B9),
                onChanged: (v) => setState(() => cancelType = v!),
              ),

         
              if (cancelType == "RANGE") ...[
                const SizedBox(height: 10),
                const Text(
                  "Select cancel range between:",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Inter",
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${formatter.format(start)} – ${formatter.format(end)}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TableCalendar(
                    firstDay: start,
                    lastDay: end,
                    focusedDay: focusedDay.isAfter(end)
                        ? end
                        : focusedDay.isBefore(start)
                            ? start
                            : focusedDay,
                    rangeStartDay: rangeStart,
                    rangeEndDay: rangeEnd,
                    rangeSelectionMode: RangeSelectionMode.toggledOn,
                    onRangeSelected: (startDay, endDay, fd) {
                      setState(() {
                        rangeStart = startDay;
                        rangeEnd = endDay;
                        focusedDay = fd;
                      });
                    },
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                    ),
                    calendarStyle: CalendarStyle(
                      rangeHighlightColor: const Color(0x330474B9),
                      rangeStartDecoration: const BoxDecoration(
                        color: Color(0xFF0474B9),
                        shape: BoxShape.circle,
                      ),
                      rangeEndDecoration: const BoxDecoration(
                        color: Color(0xFF0474B9),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Selected Cancel Range:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Inter",
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.grey.shade50,
                  ),
                  child: Center(
                    child: Text(
                      rangeStart != null && rangeEnd != null
                          ? "${formatter.format(rangeStart!)} → ${formatter.format(rangeEnd!)}"
                          : "No range selected",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0474B9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Close"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (cancelType == "RANGE") {
                        if (rangeStart != null && rangeEnd != null) {
                          Navigator.pop(context, {
                            "type": "RANGE",
                            "start": rangeStart,
                            "end": rangeEnd,
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a valid cancel range'),
                            ),
                          );
                        }
                      } else {
                        Navigator.pop(context, {"type": "ALL"});
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0474B9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Confirm Cancel"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
