import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class PauseOrderBottomSheet extends StatefulWidget {
  final DateTime orderStart;
  final DateTime orderEnd;
  final String customerProfileId; // for controller call

  const PauseOrderBottomSheet({
    super.key,
    required this.orderStart,
    required this.orderEnd,
    required this.customerProfileId,
  });

  @override
  State<PauseOrderBottomSheet> createState() => _PauseOrderBottomSheetState();
}

class _PauseOrderBottomSheetState extends State<PauseOrderBottomSheet> {
  final DateFormat formatter = DateFormat('dd MMM yyyy');

  DateTime? rangeStart;
  DateTime? rangeEnd;
  late DateTime focusedDay;

  @override
  void initState() {
    super.initState();
    focusedDay = widget.orderStart;
  }

  @override
  Widget build(BuildContext context) {
    final orderStart = widget.orderStart;
    final orderEnd = widget.orderEnd;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Text(
                "Pause Order",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0474B9),
                ),
              ),
              const Divider(thickness: 1),
              const SizedBox(height: 8),

              Text(
                "Select pause range between:",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                "${formatter.format(orderStart)} – ${formatter.format(orderEnd)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 20),

              // Calendar
           Center( child: 
           Container(
             width: MediaQuery.of(context).size.width * 0.85, 
             decoration: BoxDecoration( 
              border: Border.all(
                color: Colors.grey.shade300),
                 borderRadius: 
                 BorderRadius.circular(12), ),
                  padding: const EdgeInsets.all(8), 
                  child: TableCalendar(
                     firstDay: orderStart, 
                     lastDay: orderEnd,
                      focusedDay: focusedDay.isAfter(orderEnd) ? orderEnd : focusedDay.isBefore(orderStart) ? orderStart : focusedDay,
                       rangeStartDay: rangeStart,
                        rangeEndDay: rangeEnd, 
                        rangeSelectionMode: RangeSelectionMode.toggledOn, 
                        onRangeSelected: (start, end, fd) { setState(() { rangeStart = start; rangeEnd = end; focusedDay = fd; }); }, 
                        headerStyle: const HeaderStyle( titleCentered: true, formatButtonVisible: false, ), 
                        calendarStyle: CalendarStyle( rangeHighlightColor: const Color(0x330474B9),
                         rangeStartDecoration: const BoxDecoration( color: Color(0xFF0474B9), shape: BoxShape.circle, ), 
                         rangeEndDecoration: const BoxDecoration( color: Color(0xFF0474B9), shape: BoxShape.circle, ), 
                         todayDecoration: BoxDecoration( color: Colors.red.shade100, shape: BoxShape.circle, ), ), ), ), ),


              const SizedBox(height: 20),
              const Text(
                "Selected Pause Range:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),

              if (rangeStart == null || rangeEnd == null)
                const Text("No range selected", style: TextStyle(color: Colors.grey))
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0474B9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF0474B9)),
                  ),
                  child: Center(
                    child: Text(
                      "${formatter.format(rangeStart!)} → ${formatter.format(rangeEnd!)}",
                      style: const TextStyle(
                        color: Color(0xFF0474B9),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

             const SizedBox(height: 20), const Divider(thickness: 1), const SizedBox(height: 10),
            Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween, 
               children: [
                 ElevatedButton( onPressed: () => Navigator.pop(context), 
                 style: ElevatedButton.styleFrom(
                   backgroundColor: const Color(0xFF0474B9), 
                   foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric( horizontal: 24, vertical: 12, ),
                     shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(8),
                      ), ), child: const Text("Cancel"), 
                      ),
                       ElevatedButton( onPressed: () { 
                        // Handle pause order with rangeStart & rangeEnd 
                        if (rangeStart != null && rangeEnd != null) { Navigator.pop(context, 
                        { 'start': rangeStart, 'end': rangeEnd, }); } 
                        else { ScaffoldMessenger.of(context).showSnackBar( 
                          const SnackBar( content: Text('Please select a valid pause date range'),
                           ), ); } },
                            style: ElevatedButton.styleFrom( 
                              backgroundColor: const Color(0xFF0474B9),
                               foregroundColor: Colors.white, 
                               padding: const EdgeInsets.symmetric( horizontal: 24, vertical: 12, ), 
                               shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(8), ), ),
                                child: const Text("Pause Order"), ), ], ), ], ),
           
          
        ),
      ),
    );
  }
}
