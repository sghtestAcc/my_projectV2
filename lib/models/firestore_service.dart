


class FirestoreService {
}

// class FirestoreService {
//   //access the authService
//   AuthService authService = AuthService();

// //firestorm Service method add bookings
//   addBooking(booking_description, booking_rate, date) {
//     return FirebaseFirestore.instance
//         .collection('bookings')
//         .add({'email': authService.getCurrentUser()!.email,'booking_description': booking_description, 'booking_rate': booking_rate, 'date': date});
//   }

// //Firestore Service add Account
//   addAccount(firstname, email, phone) {
//     return FirebaseFirestore.instance
//         .collection('profile')
//         .add({'firstname': firstname,'email': email, 'phone': phone, 'profileImage': 'https://i.postimg.cc/KctzHMqS/user.png'});
//   }


// //Firestore Service edit profile
//   editProfile(uid, firstname, phone,profileImage) async {
//     return await FirebaseFirestore.instance
//         .collection('profile')
//         .doc(uid)
//         .set({'firstname': firstname, 'email': authService.getCurrentUser()!.email, 'phone': phone, 'profileImage' : profileImage
//     });
//   }

//   //Firestore Service display profile information
//   Stream<List<user>> getProfile() {
//     return FirebaseFirestore.instance
//         .collection('profile')
//         .where('email', isEqualTo: authService.getCurrentUser()!.email)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//         .map<user>((doc) => user.fromMap(doc.data(), doc.id))
//         .toList());
//   }

//   //Firestore Service remove booking from id
//   removeBooking(id) {
//     return FirebaseFirestore.instance
//         .collection('bookings')
//         .doc(id)
//         .delete();
//   }
//   //Firestore Service display bookings
//   Stream<List<Booking>> getBookings() {
//     return FirebaseFirestore.instance
//         .collection('bookings')
//         .where('email', isEqualTo: authService.getCurrentUser()!.email)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//         .map<Booking>((doc) => Booking.fromMap(doc.data(), doc.id))
//         .toList());
//   }
//   //Firestore Service get currentUser
//   Stream<User?> getAuthUser() {
//     return FirebaseAuth.instance.authStateChanges();
//   }

//   //Firestore Service edit bookings
//     editBooking(id, booking_description, booking_rate, date) {
//       return FirebaseFirestore.instance
//           .collection('bookings')
//           .doc(id)
//           .set({
//         'booking_description': booking_description,
//         'booking_rate': booking_rate, 'date': date, 'email': authService.getCurrentUser()!.email
//       });
//     }
// }