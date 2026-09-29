import 'package:flutter/material.dart';

class UploadTicketScreen extends StatefulWidget {
  const UploadTicketScreen({super.key});

  @override
  State<UploadTicketScreen> createState() => _UploadTicketScreenState();
}

class _UploadTicketScreenState extends State<UploadTicketScreen> {
  String selectedTicketType = 'Flight';
  bool ticketUploaded = false;
  bool detailsExtracted = false;
  bool reminderEnabled = false;

  void uploadTicket() {
    setState(() {
      ticketUploaded = true;
    });
  }

  void extractDetails() {
    setState(() {
      detailsExtracted = true;
    });
  }

  void setReminder() {
    setState(() {
      reminderEnabled = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminder set successfully!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 35,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE1E1E1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Upload Ticket',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 15, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =========================================
            // TICKET TYPE
            // =========================================

            const Text(
              'Ticket Type',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _ticketTypeButton(
                    title: 'Flight',
                    icon: Icons.flight_outlined,
                    selected: selectedTicketType == 'Flight',
                    onTap: () {
                      setState(() {
                        selectedTicketType = 'Flight';
                      });
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _ticketTypeButton(
                    title: 'Train',
                    icon: Icons.train_outlined,
                    selected: selectedTicketType == 'Train',
                    onTap: () {
                      setState(() {
                        selectedTicketType = 'Train';
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // =========================================
            // UPLOAD AREA
            // =========================================

            const Text(
              'Upload your ticket',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            InkWell(
              onTap: uploadTicket,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1E1E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade400,
                  ),
                ),
                child: Column(
                  children: [

                    Icon(
                      ticketUploaded
                          ? Icons.check_circle_outline
                          : Icons.cloud_upload_outlined,
                      size: 48,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      ticketUploaded
                          ? 'Ticket uploaded'
                          : 'Tap to upload ticket',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      ticketUploaded
                          ? 'Ready for AI extraction'
                          : 'Upload JPG, PNG or PDF',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // =========================================
            // AI EXTRACTION
            // =========================================

            if (ticketUploaded && !detailsExtracted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: extractDetails,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text(
                    'Extract Ticket Details with AI',
                  ),
                ),
              ),

            // =========================================
            // EXTRACTED DETAILS
            // =========================================

            if (detailsExtracted) ...[
              const SizedBox(height: 5),

              Row(
                children: const [
                  Icon(
                    Icons.auto_awesome,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Extracted Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1E1E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [

                    _detailRow(
                      'Passenger',
                      'Aryan Antad',
                    ),

                    _detailRow(
                      selectedTicketType == 'Flight'
                          ? 'Flight Number'
                          : 'Train Number',
                      selectedTicketType == 'Flight'
                          ? 'AI 202'
                          : '12951',
                    ),

                    _detailRow(
                      'From',
                      'Pune',
                    ),

                    _detailRow(
                      'To',
                      'Delhi',
                    ),

                    _detailRow(
                      'Date',
                      '12 October 2026',
                    ),

                    _detailRow(
                      'Departure',
                      '08:30 AM',
                    ),

                    _detailRow(
                      'Booking ID',
                      'ONETRIP12345',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // =========================================
              // REMINDER
              // =========================================

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1E1E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.notifications_none,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Travel Reminder',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Remind me before departure',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Switch(
                      value: reminderEnabled,
                      onChanged: (value) {
                        setState(() {
                          reminderEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // =========================================
              // SAVE BUTTON
              // =========================================

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: reminderEnabled
                      ? setReminder
                      : null,
                  child: const Text(
                    'Save Ticket & Reminder',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================================
  // TICKET TYPE BUTTON
  // =========================================

  Widget _ticketTypeButton({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFD5D5D5)
              : const Color(0xFFE1E1E1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? Colors.black
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================
  // DETAIL ROW
  // =========================================

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}