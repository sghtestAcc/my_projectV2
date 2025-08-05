/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
require("dotenv").config();

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

// ✅ Initialize admin
if (admin.apps.length === 0) {
  admin.initializeApp();
}

// ✅ Direct firestore reference
const firestore = admin.firestore();
const messaging = admin.messaging();

// ✅ FIXED: Configure email transporter with better error handling
let transporter = null;

try {
  if (!process.env.GMAIL_EMAIL || !process.env.GMAIL_PASSWORD) {
    console.error("❌ Missing Gmail credentials in environment variables");
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
    
    console.log("📩 Sending verification email for request:", requestId);
    
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
      console.log("✅ Verification email sent to:", data.patientEmail);
      
      await event.data.ref.update({
        emailSent: true,
        emailSentAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
    } catch (error) {
      console.error("❌ Error sending email:", error);
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
    return res.status(400).send(createErrorHTML("Invalid request parameters"));
  }

  try {
    const db = admin.firestore();
    const doc = await db.collection("verification_requests").doc(requestId).get();

    if (!doc.exists) {
      return res.send(createErrorHTML("Verification request not found or has expired."));
    }

    const data = doc.data();

    if (data.status !== "pending") {
      return res.send(createInfoHTML(`Request already ${data.status}`, 
        `This verification request has already been ${data.status}.`));
    }

    // Check if request has expired
    const now = new Date();
    const expiresAt = data.expiresAt?.toDate();
    if (expiresAt && now > expiresAt) {
      return res.send(createErrorHTML("This verification link has expired."));
    }

    if (action === "accept") {
      // ✅ Accept: Add patient to caregiver's list
      await db.collection("users").doc(data.caregiverUid).collection("patients").add({
        id: data.patientUid,
        email: data.patientEmail,
        name: data.patientName,
        addedAt: admin.firestore.FieldValue.serverTimestamp(),
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        verifiedViaEmail: true,
      });

      // Update verification request status
      await doc.ref.update({
        status: "accepted",
        acceptedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 🔔 Create notification for caregiver
      await createCaregiverNotification(data.caregiverUid, {
        title: "✅ Patient Added Successfully",
        body: `${data.patientName} has accepted your caregiver request and has been added to your patient list.`,
        type: "patient_accepted",
        patientId: data.patientUid,
        patientName: data.patientName,
        timestamp: admin.firestore.FieldValue.serverTimestamp()
      });

      console.log(`✅ Patient ${data.patientName} accepted caregiver ${data.caregiverName}`);

      return res.send(createSuccessHTML(
        "✅ Verification Successful!",
        `You have been successfully added as a patient under <strong>${data.caregiverName}</strong>'s care.<br><br>
        Your caregiver can now help manage your medications through the Grace App.<br><br>
        You can now close this window and use the Grace App together.`
      ));

    } else if (action === "reject") {
      // ❌ Reject: Update status only
      await doc.ref.update({
        status: "rejected",
        rejectedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 🔔 Create notification for caregiver
      await createCaregiverNotification(data.caregiverUid, {
        title: "❌ Patient Request Declined",
        body: `${data.patientName} has declined your caregiver request.`,
        type: "patient_rejected",
        patientId: data.patientUid,
        patientName: data.patientName,
        timestamp: admin.firestore.FieldValue.serverTimestamp()
      });

      console.log(`❌ Patient ${data.patientName} rejected caregiver ${data.caregiverName}`);

      return res.send(createInfoHTML(
        "❌ Request Declined",
        `You have declined the caregiver request from <strong>${data.caregiverName}</strong>.<br><br>
        No changes have been made to your account. You can safely close this window.`
      ));

    } else {
      return res.status(400).send(createErrorHTML("Invalid action specified."));
    }

  } catch (error) {
    console.error("❌ Error processing verification:", error);
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
    
    await admin.firestore().collection("scheduled_notifications").doc(notificationId).set({
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

    console.log(`🔔 Medication reminder scheduled for ${patientName} at ${notificationTime}`);

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

// 4. Trigger scheduled notifications (runs every minute)
exports.triggerScheduledNotifications = onSchedule("every 1 minutes", async () => {
  const now = new Date();
  const currentTime = `${now.getHours().toString().padStart(2, "0")}:${now.getMinutes().toString().padStart(2, "0")}`;
  
  console.log(`🕐 Checking for notifications at ${currentTime}`);

  try {
    // Find notifications that should be triggered
    const snapshot = await admin.firestore()
      .collection("scheduled_notifications")
      .where("isActive", "==", true)
      .where("scheduledTime", "==", currentTime)
      .get();

    const promises = [];

    snapshot.forEach(doc => {
      const data = doc.data();
      
      // Create notification for caregiver
      promises.push(
        createCaregiverNotification(data.caregiverUid, {
          title: data.title,
          body: data.body,
          type: "medication_reminder",
          patientId: data.patientId,
          patientName: data.patientName,
          timestamp: admin.firestore.FieldValue.serverTimestamp()
        })
      );

      console.log(`🔔 Triggered notification for ${data.patientName} to caregiver ${data.caregiverUid}`);
    });

    await Promise.all(promises);
    console.log(`✅ Processed ${promises.length} notifications`);

  } catch (error) {
    console.error("❌ Error triggering notifications:", error);
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

// ✅ NEW: Send push notification to patient
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
        title: "💊 Medication Reminder",
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
    console.log("✅ Push notification sent to patient:", response);

    return {
      success: true,
      messageId: response,
      message: `Notification sent to ${patientName}`,
    };

  } catch (error) {
    console.error("❌ Error sending push notification:", error);
    throw new Error(`Failed to send notification: ${error.message}`);
  }
});

// ✅ TEMPORARY: Update your Firebase Function for testing
exports.schedulePatientNotification = onCall(async (request) => {
  // ✅ RESTORED: Require authentication
  if (!request.auth) {
    throw new Error("User must be authenticated");
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
    message 
  } = request.data;

  try {
    console.log(`🔔 Creating scheduled notification for patient: ${patientName}`);
    
    // ✅ RESTORED: Verify caregiver has access to this patient
    const patientDoc = await firestore
      .collection("users")
      .doc(caregiverUid)
      .collection("patients")
      .where("id", "==", patientId)
      .get();

    if (patientDoc.empty) {
      throw new Error("Patient not found or access denied");
    }

    // Create scheduled notification document
    const notificationData = {
      caregiverUid: caregiverUid,
      patientId: patientId,
      patientName: patientName,
      medicationName: medicationName || "medication",
      scheduledTime: scheduledTime,
      frequency: frequency,
      dayOfWeek: dayOfWeek,
      title: title || "💊 Medication Reminder",
      message: message || `Time to take your ${medicationName || "medication"}!`,
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      nextExecution: calculateNextExecution(scheduledTime, frequency, dayOfWeek)
    };

    console.log("📝 Notification data prepared:", JSON.stringify(notificationData, null, 2));

    const docRef = await firestore
      .collection("scheduled_patient_notifications")
      .add(notificationData);

    console.log(`🔔 Scheduled notification created: ${docRef.id}`);

    return {
      success: true,
      notificationId: docRef.id,
      message: `${frequency} reminder scheduled for ${patientName} at ${scheduledTime}`,
      nextExecution: notificationData.nextExecution
    };

  } catch (error) {
    console.error("❌ Error scheduling patient notification:", error);
    throw new Error(`Failed to schedule notification: ${error.message}`);
  }
});

// calculateNextExecution function
function calculateNextExecution(timeString, frequency, dayOfWeek) {
  try {
    const [hours, minutes] = timeString.split(":").map(Number);
    const now = new Date();
    const nextRun = new Date();
    
    nextRun.setHours(hours, minutes, 0, 0);
    
    if (frequency === "daily") {
      if (nextRun <= now) {
        nextRun.setDate(nextRun.getDate() + 1);
      }
    } else if (frequency === "weekly" && dayOfWeek) {
      const currentDay = now.getDay() || 7;
      let daysUntilTarget = (dayOfWeek - currentDay) % 7;
      
      if (daysUntilTarget === 0 && nextRun <= now) {
        daysUntilTarget = 7;
      }
      
      nextRun.setDate(nextRun.getDate() + daysUntilTarget);
    }
    
    return admin.firestore.Timestamp.fromDate(nextRun);
  } catch (error) {
    console.error("❌ Error calculating next execution:", error);
    return admin.firestore.Timestamp.fromDate(new Date(Date.now() + 24 * 60 * 60 * 1000));
  }
}

// processScheduledNotifications function
exports.processScheduledNotifications = onSchedule("every 1 minutes", async () => {
  const now = new Date();
  const currentTime = `${now.getHours().toString().padStart(2, "0")}:${now.getMinutes().toString().padStart(2, "0")}`;
  const currentDay = now.getDay() || 7;
  
  console.log(`🕐 Checking scheduled notifications at ${currentTime}, day: ${currentDay}`);

  try {
    const snapshot = await firestore
      .collection("scheduled_patient_notifications")
      .where("isActive", "==", true)
      .where("scheduledTime", "==", currentTime)
      .get();

    const promises = [];

    snapshot.docs.forEach(doc => {
      const data = doc.data();
      
      let shouldRun = false;
      
      if (data.frequency === "daily") {
        shouldRun = true;
      } else if (data.frequency === "weekly" && data.dayOfWeek === currentDay) {
        shouldRun = true;
      }

      if (shouldRun) {
        console.log(`📱 Triggering notification for patient: ${data.patientName}`);
        promises.push(sendNotificationToPatient(data, doc.id));
      }
    });

    await Promise.all(promises);
    console.log(`✅ Processed ${promises.length} notifications`);

  } catch (error) {
    console.error("❌ Error processing scheduled notifications:", error);
  }
});

// sendNotificationToPatient function
async function sendNotificationToPatient(notificationData, notificationId) {
  try {
    const patientDoc = await firestore
      .collection("users")
      .doc(notificationData.patientId)
      .get();

    if (!patientDoc.exists) {
      console.error(`Patient ${notificationData.patientId} not found`);
      return;
    }

    const patientData = patientDoc.data();
    const fcmToken = patientData.fcmToken;

    if (!fcmToken) {
      console.log(`No FCM token for patient ${notificationData.patientName}`);
      return;
    }

    const payload = {
      token: fcmToken,
      notification: {
        title: notificationData.title,
        body: notificationData.message,
      },
      data: {
        type: "scheduled_medication_reminder",
        patientId: notificationData.patientId,
        medicationName: notificationData.medicationName,
        notificationId: notificationId,
        timestamp: new Date().toISOString(),
      },
      android: {
        notification: {
          icon: "ic_notification",
          color: "#0CE25C",
          sound: "default",
          priority: "high",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    const response = await messaging.send(payload);
    console.log(`✅ Push notification sent to ${notificationData.patientName}:`, response);

    await firestore
      .collection("notification_logs")
      .add({
        notificationId: notificationId,
        patientId: notificationData.patientId,
        patientName: notificationData.patientName,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        messageId: response,
        status: "sent"
      });

  } catch (error) {
    console.error(`❌ Error sending notification to ${notificationData.patientName}:`, error);
    
    await firestore
      .collection("notification_logs")
      .add({
        notificationId: notificationId,
        patientId: notificationData.patientId,
        patientName: notificationData.patientName,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        error: error.message,
        status: "failed"
      });
  }
}

// cancelPatientNotification function
exports.cancelPatientNotification = onCall(async (request) => {
  if (!request.auth) {
    throw new Error("User must be authenticated");
  }

  const {notificationId} = request.data;

  try {
    await firestore
      .collection("scheduled_patient_notifications")
      .doc(notificationId)
      .update({
        isActive: false,
        cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
        cancelledBy: request.auth.uid
      });

    return {success: true, message: "Notification cancelled successfully"};

  } catch (error) {
    console.error("❌ Error cancelling notification:", error);
    throw new Error(`Failed to cancel notification: ${error.message}`);
  }
});

// ✅ RESTORED: sendMedicationReminderToPatient with proper authentication
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
        title: "💊 Medication Reminder",
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
    console.log("✅ Push notification sent to patient:", response);

    return {
      success: true,
      messageId: response,
      message: `Notification sent to ${patientName}`,
    };

  } catch (error) {
    console.error("❌ Error sending push notification:", error);
    throw new Error(`Failed to send notification: ${error.message}`);
  }
});

// Keep all your existing functions (email verification, etc.)
exports.sendVerificationEmail = onDocumentCreated(
  "verification_requests/{requestId}",
  async (event) => {
    const data = event.data && event.data.data();
    const requestId = event.params.requestId;
    
    if (!data) {
      console.log("No data found");
      return;
    }
    
    console.log("📩 Sending verification email for request:", requestId);
    
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
      console.log("✅ Verification email sent to:", data.patientEmail);
      
      await event.data.ref.update({
        emailSent: true,
        emailSentAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
    } catch (error) {
      console.error("❌ Error sending email:", error);
      await event.data.ref.update({
        emailSent: false,
        emailError: error.message
      });
    }
  }
);

exports.processVerification = onRequest(async (req, res) => {
  const {requestId, action} = req.query;

  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "GET, POST");
  res.set("Access-Control-Allow-Headers", "Content-Type");
  
  if (!requestId || !action) {
    return res.status(400).send(createErrorHTML("Invalid request parameters"));
  }

  try {
    const doc = await firestore.collection("verification_requests").doc(requestId).get();

    if (!doc.exists) {
      return res.send(createErrorHTML("Verification request not found or has expired."));
    }

    const data = doc.data();

    if (data.status !== "pending") {
      return res.send(createInfoHTML(`Request already ${data.status}`, 
        `This verification request has already been ${data.status}.`));
    }

    const now = new Date();
    const expiresAt = data.expiresAt?.toDate();
    if (expiresAt && now > expiresAt) {
      return res.send(createErrorHTML("This verification link has expired."));
    }

    if (action === "accept") {
      await firestore.collection("users").doc(data.caregiverUid).collection("patients").add({
        id: data.patientUid,
        email: data.patientEmail,
        name: data.patientName,
        addedAt: admin.firestore.FieldValue.serverTimestamp(),
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        verifiedViaEmail: true,
      });

      await doc.ref.update({
        status: "accepted",
        acceptedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`✅ Patient ${data.patientName} accepted caregiver ${data.caregiverName}`);

      return res.send(createSuccessHTML(
        "✅ Verification Successful!",
        "You have been successfully added as a patient under " + 
              `<strong>${data.caregiverName}</strong>'s care.<br><br>
        Your caregiver can now help manage your medications through the Grace App.<br><br>
        You can now close this window and use the Grace App together.`
      ));

    } else if (action === "reject") {
      await doc.ref.update({
        status: "rejected",
        rejectedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`❌ Patient ${data.patientName} rejected caregiver ${data.caregiverName}`);

      return res.send(createInfoHTML(
        "❌ Request Declined",
        "You have declined the caregiver request from" +
              `<strong>${data.caregiverName}</strong>.<br><br>
        No changes have been made to your account. You can safely close this window.`
      ));

    } else {
      return res.status(400).send(createErrorHTML("Invalid action specified."));
    }

  } catch (error) {
    console.error("❌ Error processing verification:", error);
    return res.status(500).send(createErrorHTML(
      "An error occurred while processing your request. Please try again."
    ));
  }
});

// Helper functions for HTML responses
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
                <h1>🏥 Grace App</h1>
                <h2>Caregiver Verification Request</h2>
            </div>
            <div class="content">
                <h2>Hello ${patientName},</h2>
                <p>You have received a caregiver verification request from <strong>${caregiverName}</strong> (${caregiverEmail}).</p>
                <div class="button-container">
                    <a href="${acceptLink}" class="button accept-button">✅ Accept Caregiver</a>
                    <a href="${rejectLink}" class="button reject-button">❌ Reject Request</a>
                </div>
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
            body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #0CE25C 0%, #9EE8BF 100%); margin: 0; padding: 50px; min-height: 100vh; display: flex; align-items: center; justify-content: center; }
            .container { background: white; padding: 40px; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); text-align: center; max-width: 500px; }
            .success-icon { font-size: 80px; color: #0CE25C; margin-bottom: 20px; }
            h1 { color: #333; margin-bottom: 20px; }
            p { color: #666; font-size: 16px; line-height: 1.6; }
            .grace-logo { width: 80px; height: 80px; margin: 20px auto; background-color: #0CE25C; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 24px; color: black; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="success-icon">✅</div>
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
            body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #ff6b6b 0%, #ff8e8e 100%); margin: 0; padding: 50px; min-height: 100vh; display: flex; align-items: center; justify-content: center; }
            .container { background: white; padding: 40px; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); text-align: center; max-width: 500px; }
            .error-icon { font-size: 80px; color: #ff4757; margin-bottom: 20px; }
            h1 { color: #333; margin-bottom: 20px; }
            p { color: #666; font-size: 16px; line-height: 1.6; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="error-icon">❌</div>
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
            body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%); margin: 0; padding: 50px; min-height: 100vh; display: flex; align-items: center; justify-content: center; }
            .container { background: white; padding: 40px; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); text-align: center; max-width: 500px; }
            .info-icon { font-size: 80px; color: #74b9ff; margin-bottom: 20px; }
            h1 { color: #333; margin-bottom: 20px; }
            p { color: #666; font-size: 16px; line-height: 1.6; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="info-icon">ℹ️</div>
            <h1>${title}</h1>
            <p>${message}</p>
        </div>
    </body>
    </html>
  `;
}

// Add your other existing functions here (scheduleMedicationNotification, triggerScheduledNotifications, cleanupExpiredRequests, etc.)

// ✅ NEW: Test function to send push notification directly to patient
exports.testPatientNotification = onCall(async (request) => {
  if (!request.auth) {
    throw new Error("User must be authenticated");
  }

  const {patientId, title, message} = request.data;

  try {
    // Get patient's FCM token
    const patientDoc = await firestore
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

    // Send push notification directly
    const payload = {
      token: fcmToken,
      notification: {
        title: title || "💊 Test Medication Reminder",
        body: message || "Time to take your medication!",
      },
      data: {
        type: "test_medication_reminder",
        patientId: patientId,
        timestamp: new Date().toISOString(),
      },
      android: {
        notification: {
          icon: "ic_notification",
          color: "#0CE25C",
          sound: "default",
          priority: "high",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    const response = await messaging.send(payload);
    console.log("✅ Test push notification sent:", response);

    return {
      success: true,
      messageId: response,
      message: "Test notification sent successfully",
    };

  } catch (error) {
    console.error("❌ Error sending test notification:", error);
    throw new Error(`Failed to send test notification: ${error.message}`);
  }
});

// ✅ Add these helper functions at the end of your index.js file

// Helper function to create caregiver notifications
async function createCaregiverNotification(caregiverUid, notificationData) {
  try {
    await firestore.collection("users").doc(caregiverUid).collection("notifications").add({
      ...notificationData,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      read: false,
    });
    console.log("✅ Caregiver notification created");
  } catch (error) {
    console.error("❌ Error creating caregiver notification:", error);
  }
}

// Helper function to calculate next notification time
function calculateNextNotification(timeString) {
  const now = new Date();
  const [hours, minutes] = timeString.split(":").map(Number);
  
  const nextNotification = new Date();
  nextNotification.setHours(hours, minutes, 0, 0);
  
  // If time has passed today, schedule for tomorrow
  if (nextNotification <= now) {
    nextNotification.setDate(nextNotification.getDate() + 1);
  }
  
  return nextNotification.toISOString();
}
