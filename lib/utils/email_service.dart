import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  static const String _emailjsUrl = 'https://api.emailjs.com/api/v1.0/email/send';

  /// Send verification email to patient
  static Future<bool> sendPatientVerificationEmail({
    required String patientEmail,
    required String patientName,
    required String caregiverName,
    required String caregiverEmail,
    required String verificationRequestId,
  }) async {
    try {
      final serviceId = dotenv.env['EMAILJS_SERVICE_ID'];
      final templateId = dotenv.env['EMAILJS_TEMPLATE_ID'];
      final userId = dotenv.env['EMAILJS_USER_ID'];

      if (serviceId == null || templateId == null || userId == null) {
        print('❌ EmailJS configuration missing');
        return false;
      }

      // Create verification link (you can customize this)
      final verificationLink = 'https://your-app.com/verify?requestId=$verificationRequestId';

      final response = await http.post(
        Uri.parse(_emailjsUrl),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost', // Required by EmailJS
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'to_email': patientEmail,
            'to_name': patientName,
            'caregiver_name': caregiverName,
            'caregiver_email': caregiverEmail,
            'verification_link': verificationLink,
            'app_name': 'Grace App',
            'subject': 'Caregiver Verification Request - Grace App',
            'message': createEmailMessage(
              patientName: patientName,
              caregiverName: caregiverName,
              caregiverEmail: caregiverEmail,
              verificationLink: verificationLink,
            ),
          },
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Verification email sent to $patientEmail');
        return true;
      } else {
        print('❌ Failed to send email: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending email: $e');
      return false;
    }
  }

  /// Alternative: Send email using simple backend service
  static Future<bool> sendEmailViaBackend({
    required String patientEmail,
    required String patientName,
    required String caregiverName,
    required String caregiverEmail,
    required String verificationRequestId,
  }) async {
    try {
      final emailServiceUrl = dotenv.env['EMAIL_SERVICE_URL'];
      
      if (emailServiceUrl == null) {
        print('❌ Email service URL not configured');
        return false;
      }

      final response = await http.post(
        Uri.parse(emailServiceUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': patientEmail,
          'to_name': patientName,
          'subject': 'Caregiver Verification Request - Grace App',
          'html': createEmailHTML(
            patientName: patientName,
            caregiverName: caregiverName,
            caregiverEmail: caregiverEmail,
            verificationRequestId: verificationRequestId,
          ),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error sending email via backend: $e');
      return false;
    }
  }

  /// Create email message content
  static String createEmailMessage({
    required String patientName,
    required String caregiverName,
    required String caregiverEmail,
    required String verificationLink,
  }) {
    return '''
Hello $patientName,

You have received a caregiver verification request for the Grace Medication Tracker App.

Caregiver Details:
- Name: $caregiverName
- Email: $caregiverEmail

$caregiverName wants to add you as their patient to help manage your medications. This will allow them to:
- View your medication information
- Set medication reminders for you
- Help manage your medication schedule

To accept this request, please click the link below:
$verificationLink

If you trust this caregiver and want to allow them to help manage your medications, click the verification link.

IMPORTANT SECURITY NOTICE:
- Only accept this request if you know and trust $caregiverName
- You can remove caregivers at any time from within the app
- If you don't recognize this request, please ignore this email

This verification link will expire in 24 hours for security reasons.

Best regards,
Grace App Team
Singapore General Hospital

This email was sent because someone requested to add you as a patient in the Grace Medication Tracker App.
If you didn't expect this email, you can safely ignore it.
    ''';
  }

  /// Create HTML email template
  static String createEmailHTML({
    required String patientName,
    required String caregiverName,
    required String caregiverEmail,
    required String verificationRequestId,
  }) {
    // Create action links that will directly process the verification
    final acceptLink = 'https://your-app.com/verify-action?requestId=$verificationRequestId&action=accept';
    final rejectLink = 'https://your-app.com/verify-action?requestId=$verificationRequestId&action=reject';
    
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>Caregiver Verification Request</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #0CE25C; color: black; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
            .content { background-color: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
            .button { 
                display: inline-block; 
                padding: 15px 30px; 
                text-decoration: none; 
                border-radius: 6px; 
                font-weight: bold; 
                margin: 10px 5px; 
                text-align: center;
                font-size: 16px;
            }
            .accept-button { 
                background-color: #0CE25C; 
                color: black; 
            }
            .reject-button { 
                background-color: #ff4757; 
                color: white; 
            }
            .button-container { 
                text-align: center; 
                margin: 30px 0; 
            }
            .warning { background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 4px; margin: 20px 0; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🏥 Grace App - Caregiver Request</h1>
            </div>
            <div class="content">
                <h2>Hello $patientName,</h2>
                
                <p>You have received a caregiver verification request for the <strong>Grace Medication Tracker App</strong>.</p>
                
                <div style="background-color: white; padding: 20px; border-radius: 6px; margin: 20px 0; border-left: 4px solid #0CE25C;">
                    <h3>📋 Request Details:</h3>
                    <p><strong>Caregiver Name:</strong> $caregiverName</p>
                    <p><strong>Caregiver Email:</strong> $caregiverEmail</p>
                    <p><strong>Request Type:</strong> Add you as a patient under their care</p>
                </div>
                
                <p>Click one of the buttons below to respond to this request:</p>
                
                <div class="button-container">
                    <a href="$acceptLink" class="button accept-button">✅ Accept Caregiver</a>
                    <a href="$rejectLink" class="button reject-button">❌ Reject Request</a>
                </div>
                
                <div class="warning">
                    <h4>⚠️ Important Security Notice:</h4>
                    <ul>
                        <li>Only accept this request if you know and trust $caregiverName</li>
                        <li>This will allow them to view your medication information</li>
                        <li>You can remove caregivers at any time from within the app</li>
                        <li>If you don't recognize this request, please click "Reject"</li>
                    </ul>
                </div>
                
                <p><small>This verification link will expire in 24 hours for security reasons.</small></p>
                
                <p>Best regards,<br>
                <strong>Grace App Team</strong><br>
                Singapore General Hospital</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }
}