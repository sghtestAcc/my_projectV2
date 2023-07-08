import 'package:flutter/material.dart';

void addQuestionsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    // Handle the close button action here
                    //   Navigator.push(context, MaterialPageRoute(builder: (context)=>
                    // NavigatorBar()));
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Text(
              'Add Questions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200], // Background color
                borderRadius: BorderRadius.circular(10.0), // Rounded border
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              child: TextFormField(
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Enter your question here...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(10.0),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {},
                child: const Text(
                  'Add',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {},
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
          ],
        ),
      );
    },
  );
}
