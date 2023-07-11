import 'package:flutter/material.dart';


class patientcard extends StatefulWidget {
  int index;
  patientcard(this.index,{super.key});

  @override
  State<patientcard> createState() => _patientcardState();
}

class _patientcardState extends State<patientcard> {
      bool isDropdownOpen = false;
  @override
  Widget build(BuildContext context) {
   List<int> values = [
      2,
      4,
      6,
      8,
      10
    ]; // Replace with your actual list of values
    List<bool> isItemExpanded = List.filled(values.length, false);
    return Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(22)),
            color: Color(0xDDF6F6F6),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.5),
                offset: Offset(0, 1),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patient ${widget.index}',
                style: const TextStyle(fontSize: 15),
              ),
              Text('phoneNumber ${widget.index}', style: const TextStyle(fontSize: 12)),
              Row(
                children: [
                  const Text(
                    'View more for medication info',
                    style: TextStyle(fontSize: 10),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isDropdownOpen = !isDropdownOpen;
                      });
                    },
                    icon: Icon(
                        isDropdownOpen ? Icons.expand_less : Icons.expand_more),
                  ),
                ],
              ),
              if (isDropdownOpen)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < values.length; i++)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isItemExpanded[i] = !isItemExpanded[i];
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('1 $i',
                                    style: const TextStyle(fontSize: 12)),
                                Text('1 $i',
                                    style: const TextStyle(fontSize: 12)),
                                const Text('Morning',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                          if (isItemExpanded[i])
                            Padding(
                              padding: const EdgeInsets.only(
                                  left:
                                      20.0), // Adjust the indentation as needed
                              child: Text(
                                'Additional medication info for item $i',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
            ],
          ),
        );
  }
}