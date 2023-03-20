import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jiffy/jiffy.dart';

typedef DS = DocumentSnapshot<Map<String, dynamic>>;
typedef QS = QuerySnapshot<Map<String, dynamic>>;
typedef DR = DocumentReference<Map<String, dynamic>>;
typedef CR = CollectionReference<Map<String, dynamic>>;

final kDB = FirebaseFirestore.instance;
final kUSR = FirebaseAuth.instance.currentUser;

String formatFirestoreDoc(DS doc) {
  String jsonString = json.encode(doc.data(), toEncodable: (o) {
    if (o is Timestamp) {
      return Jiffy(o.toDate()).format('yyyy-MM-dd HH:mm:ss');
    }
    return o;
  });
  return JsonEncoder.withIndent('  ').convert(jsonDecode(jsonString));
}

String getFirstCharactersOfString(String str, int length) {
  if (str.length > length) {
    return str.substring(0, length);
  } else {
    return str;
  }
}

const dateFormat = 'yyyy-MM-dd';
const dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

String formatDate(Timestamp dateTime) {
  return Jiffy(dateTime.toDate()).format(dateFormat);
}

String formatDateTime(Timestamp dateTime) {
  return Jiffy(dateTime.toDate()).format(dateTimeFormat);
}
