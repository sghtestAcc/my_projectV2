
class PatientModel {
  final String?  id;
  final String PhoneNo;
  final String Name;
  final String Password;
  
  

  const PatientModel({
    this.id,
    required this.PhoneNo,
    required this.Name,
    required this.Password,

  });

  toJson() {
    return {
      'Name' : Name,
      'PhoneNo' : PhoneNo,
      'Password' : Password,
    };
  }
  
}