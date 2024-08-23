const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotificationOnFirestoreChange = functions.firestore
    .document("users/{userId}/courses/{courseId}")
    .onCreate((snap, context) => {
      const newValue = snap.data();
      const payload = {
        notification: {
          title: "Nouveau cours ajouté",
          body: `Un nouveau cours a été ajouté par ${newValue.author}`,
        },
      };
      return admin.messaging().sendToTopic("notifications", payload);
    });
