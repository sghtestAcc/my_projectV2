
class PatientModel {
  final String? id;
  final String? Email;
  final String? Name;
  final String? Password;
  
  const PatientModel({
    this.id,
    required this.Email,
    required this.Name,
    required this.Password,

  });

  toJson() {
    return {
      'Name' : Name,
      'Email' : Email,
      'Password' : Password,
    };
  }
}