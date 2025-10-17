import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:darbk/screens/appointmentDetails.dart';
import '../models/physiotherapist.dart';

class BookingScreen extends StatefulWidget {
  final int nextSession;
  final PhysiotherapistCardModel physiotherapistCardModel;
  const BookingScreen({
    super.key,
    required this.physiotherapistCardModel,
    required this.nextSession,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;
  String? _selectedTime;

  List<int> availableDays = [];
  List<Map<String, dynamic>> availableTimes = [];

  Future<void> fetchAvailableDays() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('physiotherapists')
            .doc(widget.physiotherapistCardModel.uid)
            .collection('availableSlots')
            .get();

    final days =
        snapshot.docs
            .where((doc) {
              final docDate = DateTime.parse(doc.id);
              return docDate.year == _focusedMonth.year &&
                  docDate.month == _focusedMonth.month;
            })
            .map((doc) => DateTime.parse(doc.id).day)
            .toList();

    setState(() {
      availableDays = days;
    });
  }

  // Fetch available time slots for a selected day
  Future<void> fetchAvailableSlotsForDay(DateTime selectedDate) async {
    final docId = DateFormat('yyyy-MM-dd').format(selectedDate);
    final docRef = FirebaseFirestore.instance
        .collection('physiotherapists')
        .doc(widget.physiotherapistCardModel.uid)
        .collection('availableSlots')
        .doc(docId);

    final snapshot = await docRef.get();

    List<Map<String, dynamic>> fetchedSlots = [];
    if (snapshot.exists) {
      final data = snapshot.data()!;
      if (data.containsKey('slots')) {
        final slots = List<Map<String, dynamic>>.from(data['slots']);
        fetchedSlots =
            slots.map((slot) {
              return {
                'time': slot['time'],
                'isBooked': slot['isBooked'] ?? false, // Ensure isBooked exists
              };
            }).toList();
      }
    }

    setState(() {
      _selectedDate = selectedDate;
      availableTimes = fetchedSlots;
    });
  }

  @override
  void initState() {
    fetchAvailableDays();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startingWeekday = firstDay.weekday;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text(
          'Booking',
          style: TextStyle(
            color: Color(0xFF14abc2),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left, size: 30),
                  onPressed: () {
                    setState(() {
                      _focusedMonth = DateTime(
                        _focusedMonth.year,
                        _focusedMonth.month - 1,
                      );
                    });
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedMonth),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right, size: 30),
                  onPressed: () {
                    setState(() {
                      _focusedMonth = DateTime(
                        _focusedMonth.year,
                        _focusedMonth.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Weekday labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                      .map(
                        (e) => Expanded(
                          child: Center(
                            child: Text(
                              e,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),

            const SizedBox(height: 8),

            // Days grid
            GridView.builder(
              itemCount: daysInMonth + startingWeekday - 1,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                if (index < startingWeekday - 1) {
                  return const SizedBox();
                }

                final day = index - startingWeekday + 2;
                final isAvailable = availableDays.contains(day);
                final isSelected =
                    _selectedDate?.day == day &&
                    _selectedDate?.month == _focusedMonth.month &&
                    _selectedDate?.year == _focusedMonth.year;

                return GestureDetector(
                  onTap:
                      isAvailable
                          ? () async {
                            final selected = DateTime(
                              _focusedMonth.year,
                              _focusedMonth.month,
                              day,
                            );
                            await fetchAvailableSlotsForDay(
                              selected,
                            ); // Fetch slots for the selected day
                          }
                          : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF14abc2)
                              : isAvailable
                              ? Colors.grey[200]
                              : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color:
                            isSelected
                                ? Colors.white
                                : isAvailable
                                ? Colors.black
                                : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            if (_selectedDate != null) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Time:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    availableTimes.map((timeSlot) {
                      final time = timeSlot['time'];
                      final isBooked = timeSlot['isBooked'];
                      final isSelected = _selectedTime == time;

                      return ChoiceChip(
                        label: Text(time),
                        selected: isSelected,
                        selectedColor: Color(0xFF14abc2),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected:
                            isBooked
                                ? null // Disable if time is booked
                                : (_) {
                                  setState(() {
                                    _selectedTime = time;
                                  });
                                },
                      );
                    }).toList(),
              ),
            ],

            const Spacer(),

            // Booking Button
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed:
                    (_selectedDate != null && _selectedTime != null)
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AppointmentDetailsScreen(
                                    selectedDate: _selectedDate!,
                                    selectedTime: _selectedTime!,
                                    therapist: widget.physiotherapistCardModel,
                                    nextSession: widget.nextSession,
                                  ),
                            ),
                          );
                        }
                        : null,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14abc2),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Booking',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
