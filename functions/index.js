/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
const functions = require("firebase-functions");
require("dotenv").config();
const moment = require("moment-timezone");

console.log("🔧 Environment check:");
console.log("📧 GMAIL_EMAIL:", process.env.GMAIL_EMAIL ? "SET" : "MISSING");
console.log("🔐 GMAIL_PASSWORD:", process.env.GMAIL_PASSWORD ? "SET" : "MISSING");

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onRequest} = require("firebase-functions/v2/https");
const {onCall} = require("firebase-functions/v2/https");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {setGlobalOptions} = require("firebase-functions/v2");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

// Initialize admin
if (admin.apps.length === 0) {
  admin.initializeApp();
}

// Direct firestore reference
const firestore = admin.firestore();
const messaging = admin.messaging();

// Configure email transporter with better error handling
let transporter = null;

try {
  if (!process.env.GMAIL_EMAIL || !process.env.GMAIL_PASSWORD) {
    console.error("Missing Gmail credentials in environment variables");
  } else {
    transporter = nodemailer.createTransport({
      service: "gmail",
      host: "smtp.gmail.com",
      port: 587,
      secure: false,
      auth: {
        user: process.env.GMAIL_EMAIL,
        pass: process.env.GMAIL_PASSWORD
      },
      tls: {
        rejectUnauthorized: false
      }
    });

    // Test the connection
    transporter.verify((error) => {
      if (error) {
        console.log("SMTP Error:", error);
      } else {
        console.log("SMTP Server is ready to take our messages");
      }
    });
  }
} catch (error) {
  console.error("Error creating email transporter:", error);
}

setGlobalOptions({ 
  maxInstances: 10,
  region: "asia-southeast1"
});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// 1. Send verification email when request is created
exports.sendVerificationEmail = onDocumentCreated(
  "verification_requests/{requestId}",
  async (event) => {
    const data = event.data && event.data.data();
    const requestId = event.params.requestId;
    
    if (!data) {
      console.log("No data found");
      return;
    }
    
    console.log("Sending verification email for request:", requestId);
    
    // Create action links using your actual project info
    const acceptLink = "https://asia-southeast1-sgh-project-e1afb.cloudfunctions.net/processVerification" +
      `?requestId=${requestId}&action=accept`;
    const rejectLink = "https://asia-southeast1-sgh-project-e1afb.cloudfunctions.net/processVerification" +
      `?requestId=${requestId}&action=reject`;
    
    const mailOptions = {
      from: process.env.GMAIL_EMAIL,
      to: data.patientEmail,
      subject: "Caregiver Verification Request - Grace App",
      html: createEmailHTML({
        patientName: data.patientName,
        caregiverName: data.caregiverName,
        caregiverEmail: data.caregiverEmail,
        acceptLink: acceptLink,
        rejectLink: rejectLink
      })
    };

    try {
      if (!transporter) {
        throw new Error("Email transporter not initialized");
      }
      
      await transporter.sendMail(mailOptions);
      console.log("Verification email sent to:", data.patientEmail);
      
      await event.data.ref.update({
        emailSent: true,
        emailSentAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
    } catch (error) {
      console.error("Error sending email:", error);
      await event.data.ref.update({
        emailSent: false,
        emailError: error.message
      });
    }
  }
);

// 2. Process verification (accept/reject) via direct link
exports.processVerification = onRequest(async (req, res) => {
  const {requestId, action} = req.query;

  // Set CORS headers
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "GET, POST");
  res.set("Access-Control-Allow-Headers", "Content-Type");
  
  if (!requestId || !action) {
    return res.status(400).send(createErrorHTML("Missing required parameters."));
  }

  try {
    // Get the verification request
    const requestDoc = await firestore
      .collection("verification_requests")
      .doc(requestId)
      .get();

    if (!requestDoc.exists) {
      return res.status(404).send(createErrorHTML("Verification request not found."));
    }

    const data = requestDoc.data();

    // Check if request has expired
    const now = admin.firestore.Timestamp.now();
    if (data.expiresAt && data.expiresAt < now) {
      return res.status(410).send(createErrorHTML("This verification request has expired."));
    }

    // Check if already processed
    if (data.status !== "pending") {
      return res.status(409).send(createInfoHTML(
        "Already Processed",
        `This request has already been ${data.status}.`
      ));
    }

    if (action === "accept") {
      // Add patient to caregiver's patient list
      await firestore
        .collection("users")
        .doc(data.caregiverUid)
        .collection("patients")
        .add({
          id: data.patientUid,
          name: data.patientName,
          email: data.patientEmail,
          addedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      // Update request status
      await requestDoc.ref.update({
        status: "accepted",
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Verification accepted: Patient ${data.patientName} added to caregiver ${data.caregiverName}`);

      return res.send(createSuccessHTML(
        "Verification Successful!",
        "You have been successfully added as a patient under " + 
        `<strong>${data.caregiverName}</strong>'s care.<br><br>` +
        "Your caregiver can now help manage your medications through the Grace App.<br><br>" +
        "You can now close this window and use the Grace App together."
      ));

    } else if (action === "reject") {
      // Update request status
      await requestDoc.ref.update({
        status: "rejected",
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Verification rejected: ${data.patientName} declined caregiver ${data.caregiverName}`);

      return res.send(createInfoHTML(
        "Request Declined",
        "You have declined the caregiver request from " +
        `<strong>${data.caregiverName}</strong>.<br><br>` +
        "No changes have been made to your account. You can safely close this window."
      ));

    } else {
      return res.status(400).send(createErrorHTML("Invalid action specified."));
    }

  } catch (error) {
    console.error("Error processing verification:", error);
    return res.status(500).send(createErrorHTML(
      "An error occurred while processing your request. Please try again."
    ));
  }
});

// 3. Schedule medication notifications
exports.scheduleMedicationNotification = onCall(async (request) => {
  // Verify the user is authenticated
  if (!request.auth) {
    throw new Error("User must be authenticated");
  }

  const {patientId, patientName, notificationTime, caregiverUid} = request.data;

  try {
    // Verify caregiver has access to this patient
    const patientDoc = await admin.firestore()
      .collection("users")
      .doc(caregiverUid)
      .collection("patients")
      .where("id", "==", patientId)
      .get();

    if (patientDoc.empty) {
      throw new Error("Access denied to this patient");
    }

    // Create notification document
    const notificationId = admin.firestore().collection("notifications").doc().id;
    
    await admin.firestore().collection("scheduled_patient_notifications").doc(notificationId).set({
      id: notificationId,
      type: "medication_reminder",
      caregiverUid: caregiverUid,
      patientId: patientId,
      patientName: patientName,
      scheduledTime: notificationTime,
      title: `Medication Reminder for ${patientName}`,
      body: `Time to remind ${patientName} to take their medication!`,
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      nextNotification: calculateNextNotification(notificationTime)
    });

    // Immediately log the scheduling event
    await firestore.collection("notification_logs").add({
      notificationId: notificationId,
      type: "medication_reminder",
      caregiverUid: caregiverUid,
      patientId: patientId,
      patientName: patientName,
      title: `Medication Reminder for ${patientName}`,
      message: `Time to remind ${patientName} to take their medication!`,
      scheduledTime: notificationTime,
      status: "scheduled",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAtISO: new Date().toISOString()
    });

    console.log(`Medication reminder scheduled for ${patientName} at ${notificationTime}`);

    return { 
      success: true, 
      notificationId: notificationId,
      message: `Daily medication reminder set for ${patientName}` 
    };

  } catch (error) {
    console.error("❌ Error scheduling notification:", error);
    throw new Error("Failed to schedule notification");
  }
});



// 5. Clean up expired verification requests (runs daily)
exports.cleanupExpiredRequests = onSchedule("every 24 hours", async () => {
  const now = admin.firestore.Timestamp.now();
  
  try {
    const expiredRequests = await admin.firestore()
      .collection("verification_requests")
      .where("expiresAt", "<=", now)
      .where("status", "==", "pending")
      .get();

    const batch = admin.firestore().batch();
    
    expiredRequests.forEach(doc => {
      batch.update(doc.ref, { 
        status: "expired",
        expiredAt: admin.firestore.FieldValue.serverTimestamp()
      });
    });

    await batch.commit();
    console.log(`🧹 Cleaned up ${expiredRequests.size} expired verification requests`);

  } catch (error) {
    console.error("❌ Error cleaning up expired requests:", error);
  }
});

//Send push notification to patient
exports.sendMedicationReminderToPatient = onCall(async (request) => {
  if (!request.auth) {
    throw new Error("User must be authenticated");
  }

  const {patientId, patientName, medicationName, message} = request.data;

  try {
    // Get patient's FCM token
    const patientDoc = await admin.firestore()
      .collection("users")
      .doc(patientId)
      .get();

    if (!patientDoc.exists) {
      throw new Error("Patient not found");
    }

    const patientData = patientDoc.data();
    const fcmToken = patientData.fcmToken;

    if (!fcmToken) {
      throw new Error("Patient does not have notification token");
    }

    // Send push notification
    const notificationPayload = {
      token: fcmToken,
      notification: {
        title: "Medication Reminder",
        body: message || `Time to take your ${medicationName}!`,
      },
      data: {
        type: "medication_reminder",
        patientId: patientId,
        medicationName: medicationName || "medication",
        timestamp: new Date().toISOString(),
      },
      android: {
        notification: {
          icon: "ic_notification",
          color: "#0CE25C",
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    };

    const response = await messaging.send(notificationPayload);
    console.log("Push notification sent to patient:", response);

    return {
      success: true,
      messageId: response,
      message: `Notification sent to ${patientName}`,
    };

  } catch (error) {
    console.error("Error sending push notification:", error);
    throw new Error(`Failed to send notification: ${error.message}`);
  }
});

// Update your Firebase Function for testing
exports.schedulePatientNotification = onCall(async (request) => {
  // Require authentication
  if (!request.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
  }

  const caregiverUid = request.auth.uid;

  const { 
    patientId, 
    patientName, 
    medicationName, 
    scheduledTime, 
    frequency, 
    dayOfWeek,
    title,
    message,
    timezone = "Asia/Singapore" // Default to Singapore timezone
  } = request.data;

  try {
    console.log(`Scheduling ${frequency} notification for patient: ${patientName}`);
    console.log(`Scheduled time: ${scheduledTime} in timezone: ${timezone}`);
    console.log(`Current UTC time: ${new Date().toISOString()}`);

    // Use moment-timezone for proper timezone handling
    const now = moment.utc();
    const nextExecution = calculateNextExecutionWithTimezone(scheduledTime, frequency, dayOfWeek, timezone);
    
    console.log(`Next execution calculated: ${nextExecution.toISOString()}`);
    console.log(`Time difference: ${(nextExecution.valueOf() - now.valueOf()) / (1000 * 60)} minutes`);

    console.log("Creating notification document in collection: scheduled_patient_notifications");
    
    // Create notification document
    const notificationDoc = await firestore.collection("scheduled_patient_notifications").add({
      caregiverUid: caregiverUid,
      patientId: patientId,
      patientName: patientName,
      medicationName: medicationName || "Medication",
      title: title || `Medication Reminder for ${patientName}`,
      message: message || `Time to take your ${medicationName || "medication"}!`,
      scheduledTime: scheduledTime, // Keep original time string
      timezone: timezone, // Store the timezone
      nextExecution: admin.firestore.Timestamp.fromDate(nextExecution.toDate()), // Use calculated UTC time
      frequency: frequency,
      dayOfWeek: dayOfWeek || null,
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      // Add debugging fields
      createdAtISO: now.toISOString(),
      nextExecutionISO: nextExecution.toISOString(),
      timezoneInfo: timezone
    });

    // Immediately log the scheduling event
    await firestore.collection("notification_logs").add({
      notificationId: notificationDoc.id,
      type: "medication_reminder",
      caregiverUid: caregiverUid,
      patientId: patientId,
      patientName: patientName,
      title: title || `Medication Reminder for ${patientName}`,
      message: message || `Time to take your ${medicationName || "medication"}!`,
      scheduledTime: scheduledTime,
      timezone: timezone,
      frequency: frequency,
      dayOfWeek: dayOfWeek || null,
      status: "scheduled",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAtISO: now.toISOString(),
      nextExecution: admin.firestore.Timestamp.fromDate(nextExecution.toDate()),
      nextExecutionISO: nextExecution.toISOString()
    });

    console.log(`Notification scheduled successfully with ID: ${notificationDoc.id}`);
    console.log(`   Next execution: ${nextExecution.toISOString()}`);
    console.log(`   Timezone: ${timezone}`);
    console.log("Document created in Firestore collection: scheduled_patient_notifications");

    return {
      success: true,
      notificationId: notificationDoc.id,
      nextExecution: nextExecution.toISOString(),
      message: `${frequency} notification scheduled for ${patientName}`,
      scheduledFor: nextExecution.toISOString(),
      currentTime: now.toISOString(),
      timezone: timezone
    };

  } catch (error) {
    console.error("Error scheduling patient notification:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

// calculateNextExecution with proper timezone handling
function calculateNextExecutionWithTimezone(timeString, frequency, dayOfWeek, timezone) {
  try {
    const now = moment.utc(); // Current UTC time
    console.log(`Calculating next execution from current UTC time: ${now.toISOString()}`);
    console.log(`Target timezone: ${timezone}`);
    
    // Parse time (assuming format "HH:MM")
    const [hours, minutes] = timeString.split(":").map(num => parseInt(num, 10));
    
    if (frequency === "daily") {
      // Create a moment object in the target timezone for today
      let nextExecution = moment.tz(timezone).set({hour: hours, minute: minutes, second: 0, millisecond: 0});
      
      // Convert to UTC for storage
      let nextExecutionUTC = nextExecution.utc();
      
      // If the time has passed today in the target timezone, schedule for tomorrow
      if (nextExecutionUTC.isSameOrBefore(now)) {
        nextExecution = moment.tz(timezone).add(1, "day").set({hour: hours, minute: minutes, second: 0, millisecond: 0});
        nextExecutionUTC = nextExecution.utc();
      }
      
      console.log("Daily notification calculated:");
      console.log(`   Local time (${timezone}): ${nextExecution.format("YYYY-MM-DD HH:mm:ss")}`);
      console.log(`   UTC time: ${nextExecutionUTC.toISOString()}`);
      return nextExecutionUTC;
      
    } else if (frequency === "weekly") {
      // Create a moment object in the target timezone for today
      let nextExecution = moment.tz(timezone).set({hour: hours, minute: minutes, second: 0, millisecond: 0});
      
      // Calculate days until target day (1=Monday, 7=Sunday)
      const currentDay = nextExecution.day() || 7; // Convert 0 (Sunday) to 7
      const targetDay = dayOfWeek;
      
      let daysUntilTarget = (targetDay - currentDay + 7) % 7;
      
      // If it's the same day but time has passed, schedule for next week
      if (daysUntilTarget === 0 && nextExecution.utc().isSameOrBefore(now)) {
        daysUntilTarget = 7;
      }
      
      nextExecution = moment.tz(timezone).add(daysUntilTarget, "days").set({hour: hours, minute: minutes, second: 0, millisecond: 0});
      const nextExecutionUTC = nextExecution.utc();
      
      console.log("Weekly notification calculated:");
      console.log(`   Local time (${timezone}): ${nextExecution.format("YYYY-MM-DD HH:mm:ss")}`);
      console.log(`   UTC time: ${nextExecutionUTC.toISOString()}`);
      return nextExecutionUTC;
    }
    
    throw new Error(`Unsupported frequency: ${frequency}`);
  } catch (error) {
    console.error("Error calculating next execution:", error);
    // Fallback: schedule for 1 hour from now
    const fallback = moment.utc().add(1, "hour");
    return fallback;
  }
}

// Missing processScheduledNotifications function
exports.processScheduledNotifications = onSchedule("every 1 minutes", async () => {
  const now = new Date();
  const currentTimestamp = admin.firestore.Timestamp.fromDate(now);
  
  console.log(`Processing scheduled notifications at: ${now.toISOString()}`);
  console.log(`Current timestamp seconds: ${currentTimestamp.seconds}`);

  try {
    // Get all active notifications that are due
    console.log("Querying for notifications...");
    console.log(`   Current time: ${now.toISOString()}`);
    console.log(`   Current timestamp: ${currentTimestamp.seconds}`);
    
    // First, let's see all active notifications
    const allActiveSnapshot = await firestore
      .collection("scheduled_patient_notifications")
      .where("isActive", "==", true)
      .get();
    
    console.log(`Found ${allActiveSnapshot.docs.length} total active notifications`);
    
    // Log each notification's details
    allActiveSnapshot.docs.forEach(doc => {
      const data = doc.data();
      const nextExecMs = data.nextExecution ? data.nextExecution.toDate().getTime() : null;
      console.log(`Notification: ${data.patientName}`);
      console.log(`ID: ${doc.id}`);
      console.log(`Next execution: ${data.nextExecution ? data.nextExecution.toDate().toISOString() : "NULL"}`);
      console.log(`Next execution ms: ${nextExecMs ?? "NULL"}`);
      console.log(`Is due: ${nextExecMs !== null ? (nextExecMs <= now.getTime()) : "NO TIMESTAMP"}`);
    });
    
    // Get all active notifications that are due
    // Note: This query requires a composite index on (isActive, nextExecution)
    // For now, we'll get all active notifications and filter in code
    const snapshot = await firestore
      .collection("scheduled_patient_notifications")
      .where("isActive", "==", true)
      .get();

    // Filter notifications that are due
    const dueNotifications = snapshot.docs.filter(doc => {
      const data = doc.data();
      if (!data.nextExecution) return false;
      const execMs = data.nextExecution.toDate().getTime();
      return execMs <= now.getTime();
    });

    console.log(`Found ${dueNotifications.length} notifications ready to send out of ${snapshot.docs.length} total active`);

    for (const doc of dueNotifications) {
      const data = doc.data();
      const nextExecutionDate = data.nextExecution.toDate();
      
      console.log(`Processing notification for ${data.patientName}:`);
      console.log(`Scheduled: ${nextExecutionDate.toISOString()}`);
      console.log(`Current:   ${now.toISOString()}`);
      console.log(`Difference: ${(now.getTime() - nextExecutionDate.getTime()) / (1000 * 60)} minutes`);

      try {
        // Send the notification
        const result = await sendNotificationToPatient(data, doc.id);
        
        if (result.success) {
          // Calculate next execution time using timezone-aware function
          const nextExecution = calculateNextExecutionWithTimezone(
            data.scheduledTime,
            data.frequency,
            data.dayOfWeek,
            data.timezone || "Asia/Singapore" // Default fallback
          );
          
          // Create notification log entry
          await firestore.collection("notification_logs").add({
            notificationId: doc.id,
            type: "medication_reminder",
            caregiverUid: data.caregiverUid,
            patientId: data.patientId,
            patientName: data.patientName,
            title: data.title,
            message: data.message,
            scheduledTime: data.scheduledTime,
            timezone: data.timezone,
            frequency: data.frequency,
            dayOfWeek: data.dayOfWeek,
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            sentAtISO: now.toISOString(),
            nextExecution: admin.firestore.Timestamp.fromDate(nextExecution.toDate()),
            nextExecutionISO: nextExecution.toISOString(),
            status: "sent"
          });

          // Caregiver push disabled: ensure only the patient receives the medication reminder
          
          // Update for next occurrence
          await doc.ref.update({
            nextExecution: admin.firestore.Timestamp.fromDate(nextExecution.toDate()),
            lastSent: admin.firestore.FieldValue.serverTimestamp(),
            lastSentISO: now.toISOString(),
            nextExecutionISO: nextExecution.toISOString(),
            sentCount: (data.sentCount || 0) + 1
          });

          console.log(`Notification sent and rescheduled for: ${nextExecution.toISOString()}`);
          console.log("Notification log created in notification_logs collection");
        } else {
          console.log(`Notification failed: ${result.error}`);
          
          // Log failed notification
          await firestore.collection("notification_logs").add({
            notificationId: doc.id,
            type: "medication_reminder",
            caregiverUid: data.caregiverUid,
            patientId: data.patientId,
            patientName: data.patientName,
            title: data.title,
            message: data.message,
            scheduledTime: data.scheduledTime,
            timezone: data.timezone,
            frequency: data.frequency,
            dayOfWeek: data.dayOfWeek,
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            sentAtISO: now.toISOString(),
            status: "failed",
            error: result.error
          });
        }

      } catch (error) {
        console.error(`Error sending notification for ${data.patientName}:`, error);
        
        // Log error notification
        await firestore.collection("notification_logs").add({
          notificationId: doc.id,
          type: "medication_reminder",
          caregiverUid: data.caregiverUid,
          patientId: data.patientId,
          patientName: data.patientName,
          title: data.title,
          message: data.message,
          scheduledTime: data.scheduledTime,
          timezone: data.timezone,
          frequency: data.frequency,
          dayOfWeek: data.dayOfWeek,
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
          sentAtISO: now.toISOString(),
          status: "error",
          error: error.message
        });
        
        // Mark error but don't deactivate - will retry next time
        await doc.ref.update({
          lastError: error.message,
          errorCount: (data.errorCount || 0) + 1,
          lastErrorAt: admin.firestore.FieldValue.serverTimestamp()
        });
      }
    }

  } catch (error) {
    console.error("Error processing scheduled notifications:", error);
  }
});

// Helper function to send notification to patient
async function sendNotificationToPatient(notificationData, notificationId) {
  try {
    // Get patient's FCM token
    const patientDoc = await firestore.collection("users").doc(notificationData.patientId).get();
    const patientData = patientDoc.data();
    
    if (!patientData) {
      throw new Error(`Patient not found: ${notificationData.patientId}`);
    }
    
    if (!patientData.fcmToken) {
      console.log(`No FCM token found for patient: ${notificationData.patientId}`);
      return {success: false, error: "No FCM token"};
    }

    const message = {
      token: patientData.fcmToken,
      notification: {
        title: notificationData.title || "Medication Reminder",
        body: notificationData.message || `Time to take your ${notificationData.medicationName || "medication"}!`
      },
      data: {
        type: "medication_reminder",
        medicationName: notificationData.medicationName || "medication",
        patientId: notificationData.patientId,
        caregiverUid: notificationData.caregiverUid,
        notificationId: notificationId,
        timestamp: new Date().toISOString()
      },
      android: {
        priority: "high",
        notification: {
          channelId: "medication_channel",
          priority: "high",
          defaultSound: true,
          defaultVibrateTimings: true
        }
      }
    };

    const response = await messaging.send(message);
    console.log(`Push notification sent to patient: ${response}`);

    return {success: true, messageId: response};

  } catch (error) {
    console.error("Error sending push notification to patient:", error);
    return {success: false, error: error.message};
  }
}

// Caregiver notification intentionally removed







// Missing HTML template functions
function createEmailHTML({patientName, caregiverName, caregiverEmail, acceptLink, rejectLink}) {
  return `
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>Caregiver Verification Request</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 20px; }
            .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
            .header { background-color: #0CE25C; color: black; padding: 30px; text-align: center; }
            .content { padding: 30px; }
            .button { 
                display: inline-block; 
                padding: 15px 30px; 
                text-decoration: none; 
                border-radius: 8px; 
                font-weight: bold; 
                margin: 10px 5px; 
                text-align: center;
                font-size: 16px;
            }
            .accept-button { background-color: #0CE25C; color: black; }
            .reject-button { background-color: #ff4757; color: white; }
            .button-container { text-align: center; margin: 30px 0; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Grace App</h1>
                <h2>Caregiver Verification Request</h2>
            </div>
            <div class="content">
                <h2>Hello ${patientName},</h2>
                <p>You have received a caregiver verification request from <strong>${caregiverName}</strong> (${caregiverEmail}).</p>
                <p>If you trust this person to help manage your medications, please click "Accept Caregiver" below. If you do not know this person or do not want them to access your medication information, please click "Reject Request".</p>
                <div class="button-container">
                    <a href="${acceptLink}" class="button accept-button">Accept Caregiver</a>
                    <a href="${rejectLink}" class="button reject-button">Reject Request</a>
                </div>
                <p><strong>Important:</strong> Only accept caregivers you trust with your medical information.</p>
                <p>Best regards,<br><strong>Grace App Team</strong></p>
            </div>
        </div>
    </body>
    </html>
  `;
}

function createSuccessHTML(title, message) {
  return `
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${title}</title>
        <style>
            body { 
                font-family: Arial, sans-serif; 
                background: linear-gradient(135deg, #0CE25C 0%, #9EE8BF 100%); 
                margin: 0; padding: 50px; min-height: 100vh; 
                display: flex; align-items: center; justify-content: center; 
            }
            .container { 
                background: white; padding: 40px; border-radius: 20px; 
                box-shadow: 0 10px 30px rgba(0,0,0,0.2); text-align: center; 
                max-width: 500px; 
            }
            .success-icon { 
                font-size: 80px; 
                color: #0CE25C; 
                margin-bottom: 20px; 
                font-weight: bold;
            }
            h1 { color: #333; margin-bottom: 20px; }
            p { color: #666; font-size: 16px; line-height: 1.6; }
            .grace-logo { 
                width: 80px; height: 80px; margin: 20px auto; 
                background-color: #0CE25C; border-radius: 50%; 
                display: flex; align-items: center; justify-content: center; 
                font-weight: bold; font-size: 24px; color: black; 
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="success-icon">SUCCESS</div>
            <div class="grace-logo">G</div>
            <h1>${title}</h1>
            <p>${message}</p>
        </div>
    </body>
    </html>
  `;
}

function createErrorHTML(message) {
  return `
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Error - Grace App</title>
        <style>
            body { 
                font-family: Arial, sans-serif; 
                background: linear-gradient(135deg, #ff6b6b 0%, #ff8e8e 100%); 
                margin: 0; padding: 50px; min-height: 100vh; 
                display: flex; align-items: center; justify-content: center; 
            }
            .container { 
                background: white; padding: 40px; border-radius: 20px; 
                box-shadow: 0 10px 30px rgba(0,0,0,0.2); text-align: center; 
                max-width: 500px; 
            }
            .error-icon { 
                font-size: 80px; 
                color: #ff4757; 
                margin-bottom: 20px; 
                font-weight: bold;
            }
            h1 { color: #333; margin-bottom: 20px; }
            p { color: #666; font-size: 16px; line-height: 1.6; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="error-icon">ERROR</div>
            <h1>Error</h1>
            <p>${message}</p>
        </div>
    </body>
    </html>
  `;
}

function createInfoHTML(title, message) {
  return `
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${title}</title>
        <style>
            body { 
                font-family: Arial, sans-serif; 
                background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%); 
                margin: 0; padding: 50px; min-height: 100vh; 
                display: flex; align-items: center; justify-content: center; 
            }
            .container { 
                background: white; padding: 40px; border-radius: 20px; 
                box-shadow: 0 10px 30px rgba(0,0,0,0.2); text-align: center; 
                max-width: 500px; 
            }
            .info-icon { 
                font-size: 80px; 
                color: #74b9ff; 
                margin-bottom: 20px; 
                font-weight: bold;
            }
            h1 { color: #333; margin-bottom: 20px; }
            p { color: #666; font-size: 16px; line-height: 1.6; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="info-icon">INFO</div>
            <h1>${title}</h1>
            <p>${message}</p>
        </div>
    </body>
    </html>
  `;
}

// Missing notification helper functions
function calculateNextNotification(notificationTime, timezone = "Asia/Singapore") {
  try {
    const now = moment.utc();
    const [hours, minutes] = notificationTime.split(":").map(num => parseInt(num, 10));
    
    // Create a moment object in the target timezone for today
    let nextNotification = moment.tz(timezone).set({hour: hours, minute: minutes, second: 0, millisecond: 0});
    
    // Convert to UTC for storage
    let nextNotificationUTC = nextNotification.utc();
    
    // If the time has passed today in the target timezone, schedule for tomorrow
    if (nextNotificationUTC.isSameOrBefore(now)) {
      nextNotification = moment.tz(timezone).add(1, "day").set({hour: hours, minute: minutes, second: 0, millisecond: 0});
      nextNotificationUTC = nextNotification.utc();
    }
    
    return admin.firestore.Timestamp.fromDate(nextNotificationUTC.toDate());
  } catch (error) {
    console.error("Error calculating next notification:", error);
    // Fallback: schedule for 1 hour from now
    const fallback = moment.utc().add(1, "hour");
    return admin.firestore.Timestamp.fromDate(fallback.toDate());
  }
}

// Log on schedule creation as a safety net
exports.logScheduleCreation = onDocumentCreated(
  "scheduled_patient_notifications/{notificationId}",
  async (event) => {
    try {
      const notificationId = event.params.notificationId;
      const data = event.data && event.data.data();
      if (!data) return;

      // Avoid duplicate logs
      const existing = await firestore
        .collection("notification_logs")
        .where("notificationId", "==", notificationId)
        .limit(1)
        .get();
      if (!existing.empty) return;

      await firestore.collection("notification_logs").add({
        notificationId: notificationId,
        type: "medication_reminder",
        caregiverUid: data.caregiverUid,
        patientId: data.patientId,
        patientName: data.patientName,
        title: data.title,
        message: data.message,
        scheduledTime: data.scheduledTime,
        timezone: data.timezone,
        frequency: data.frequency,
        dayOfWeek: data.dayOfWeek || null,
        status: "scheduled",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdAtISO: new Date().toISOString(),
        nextExecution: data.nextExecution || null,
        nextExecutionISO: data.nextExecutionISO || null
      });
    } catch (e) {
      console.error("Error logging schedule creation:", e);
    }
  }
);



