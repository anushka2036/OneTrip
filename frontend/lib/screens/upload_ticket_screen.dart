// lib/screens/upload_ticket_screen.dart

import 'package:flutter/material.dart';

class UploadTicketScreen extends StatefulWidget {
  const UploadTicketScreen({super.key});

  @override
  State<UploadTicketScreen> createState() => _UploadTicketScreenState();
}

class _UploadTicketScreenState extends State<UploadTicketScreen> {
  bool _isProcessing = false;
  bool _ticketProcessed = false;

  String _ticketType = 'Train';

  final Map<String, String> _extractedDetails = {
    'Passenger Name': 'Not extracted yet',
    'PNR': 'Not extracted yet',
    'Train / Flight No.': 'Not extracted yet',
    'Seat No.': 'Not extracted yet',
    'From': 'Not extracted yet',
    'To': 'Not extracted yet',
    'Travel Date': 'Not extracted yet',
    'Departure Time': 'Not extracted yet',
  };

  Future<void> _uploadTicket() async {
    setState(() {
      _isProcessing = true;
      _ticketProcessed = false;
    });

    // Backend / AI ticket extraction will be connected here later.
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
      _ticketProcessed = true;

      // Demo extracted data.
      _extractedDetails['Passenger Name'] = 'Demo Passenger';
      _extractedDetails['PNR'] = 'A1B2C3';
      _extractedDetails['Train / Flight No.'] =
          _ticketType == 'Train' ? '12345' : 'AI-204';
      _extractedDetails['Seat No.'] = 'S4 / 32';
      _extractedDetails['From'] = 'Mumbai';
      _extractedDetails['To'] = 'Manali';
      _extractedDetails['Travel Date'] = '12 October 2026';
      _extractedDetails['Departure Time'] = '08:30 AM';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Upload Ticket'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ticket Processing',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload your train or flight ticket. AI will extract important travel details automatically.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Ticket Type',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _ticketTypeButton(
                    title: 'Train',
                    icon: Icons.train_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ticketTypeButton(
                    title: 'Flight',
                    icon: Icons.flight_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            InkWell(
              onTap: _isProcessing ? null : _uploadTicket,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 42,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _isProcessing
                          ? Icons.hourglass_top_rounded
                          : Icons.cloud_upload_outlined,
                      size: 58,
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isProcessing
                          ? 'Processing ticket...'
                          : 'Upload Ticket',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isProcessing
                          ? 'AI is extracting ticket details'
                          : 'Tap to select a ticket image or PDF',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_isProcessing)
              const LinearProgressIndicator(),

            if (_ticketProcessed) ...[
              const SizedBox(height: 24),
              const Text(
                'Extracted Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: _extractedDetails.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: Text(
                              entry.value,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 24),

            const Text(
              'AI Extraction',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The uploaded ticket will later be sent to the OneTrip backend, where OCR and AI processing can extract PNR, seat number, transport number, passenger details, dates and locations.',
              style: TextStyle(
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ticketTypeButton({
    required String title,
    required IconData icon,
  }) {
    final selected = _ticketType == title;

    return InkWell(
      onTap: () {
        setState(() {
          _ticketType = title;
          _ticketProcessed = false;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.black : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}