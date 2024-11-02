import admin from 'firebase-admin';
import functions from 'firebase-functions';
import { DateTime } from 'luxon';
import nodemailer from 'nodemailer';

//import { firestore } from 'firebase-admin';



admin.initializeApp();
const firestore = admin.firestore();
const messaging = admin.messaging();

// Fonction pour notifier les nouveaux messages
/*export const notifyNewMessage = functions.firestore
  .document('messages/{groupId1}/{groupId2}/{message}')
  .onCreate(async (snapshot) => {
    const message = snapshot.data();
    console.log('notifyNewMessage déclenché', { message });

    try {
      const receiver = await firestore.collection('users').doc(message.idTo).get();
      const sender = await firestore.collection('users').doc(message.idFrom).get();
      if (!receiver.exists) {
        console.log(`Utilisateur avec l'ID ${message.idTo} introuvable.`);
        return null;
      }

      const token = receiver.data().token;
      const senderName = sender.data().firstName +' '+ sender.data().lastName;
      console.log('Token de l\'utilisateur récupéré:', token);
      let rN = 'G4 Academie';
      
      if(senderName.trim() != 'admin admin'){
        rN = senderName;
        console.log('Sender name:', rN);

      }

      const payload = {
        token: token,
        notification: {
          title: 'Nouveau message de '+ rN,
          body: message.content,
        },
      };

      await messaging.send(payload);
      console.log('Notification envoyée avec succès.');
    } catch (error) {
      console.error('Erreur lors de l\'envoi de la notification de message:', error);
    }
    return null;
  });*/

  export const notifyNewMessage = functions.firestore
  .document('messages/{groupId1}/{groupId2}/{message}')
  .onCreate(async (snapshot) => {
    const message = snapshot.data();
    console.log('notifyNewMessage déclenché', { message });

    try {
      const receiver = await firestore.collection('users').doc(message.idTo).get();
      const sender = await firestore.collection('users').doc(message.idFrom).get();

      if (!receiver.exists) {
        console.log(`Utilisateur avec l'ID ${message.idTo} introuvable.`);
        return null;
      }

      const token = receiver.data().token;
      const senderName = sender.data().firstName + ' ' + sender.data().lastName;
      console.log('Token de l\'utilisateur récupéré:', token);
      let rN = 'G4 Academie';

      if (senderName.trim() !== 'admin admin') {
        rN = senderName;
        console.log('Sender name:', rN);
      }

      const payload = {
        token: token, 
        notification: { 
          title: 'Nouveau message de ' + rN,
          body: message.content,
        },
      };

      await messaging.send(payload);
      console.log('Notification envoyée avec succès.');
 
      // Mise à jour des timestamps des messages pour les utilisateurs
      await updateLastMessageTimestamp(message.idTo, message.idFrom,  DateTime.now().toISO()); 
    } catch (error) {
      console.error('Erreur lors de l\'envoi de la notification de message:', error);
    }
    return null; 
  });

// Fonction pour mettre à jour le dernier timestamp du message
async function updateLastMessageTimestamp(idTo, idFrom, timestamp) {
  const updates = {
    lastMessageTimestamp: timestamp, // Ajoutez le champ lastMessageTimestamp
  };

  // Mise à jour du document de l'utilisateur destinataire
  await firestore.collection('users').doc(idTo).update(updates);
  console.log(`Document de l'utilisateur ${idTo} mis à jour avec lastMessageTimestamp.`);

  // Mise à jour du document de l'utilisateur expéditeur
  await firestore.collection('users').doc(idFrom).update(updates);
  console.log(`Document de l'utilisateur ${idFrom} mis à jour avec lastMessageTimestamp.`);
}

// Fonction pour envoyer une notification push
export const sendPushNotification = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snapshot) => {
    const notificationData = snapshot.data();
    console.log('sendPushNotification déclenché', { notificationData });

    const userId = notificationData.idTo;
    const notificationType = notificationData.type;
    

    try {
      const userDoc = await firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        console.log('Utilisateur avec l\'ID ' + userId + ' introuvable.');
        return null;
      }

      const userData = userDoc.data();
      const userToken = userData.token;
      console.log('Token de l\'utilisateur récupéré:', userToken);

      const notificationTitle = 'Notification de G4 ACADEMIE';
      let notificationBody = 'Vous avez une nouvelle notification.';

      switch (notificationType) {
        case 0:
          notificationBody = 'Nouvelle demande de cours.';
          break;
        case 11:
          notificationBody = 'Votre demande de cours a été rejetée.';
          break;
        case 1:
          notificationBody = 'Vous avez une nouvelle offre d\'emploi de cours de maison.';
          break;
        case 2:
          notificationBody = 'Un enseignant a postulé pour une offre.';
          break;
        case 3:
          notificationBody = 'Votre candidature a été approuvée.';
          break;
        case 33:
          notificationBody = 'Votre candidature a été rejetée.';
          break;
        case 4:
          notificationBody = 'Retour de l\'admin sur votre demande de cours.';
          break;
        case 7:
          notificationBody = 'Votre profil est en cours de vérification.';
          break;
        case 8:
          notificationBody = ' ';
          break;
        default:
          console.log('Type de notification inconnu : ' + notificationType);
          return null;
      }

      const payload = {
        token: userToken,
        notification: {
          title: notificationTitle,
          body: notificationBody,
        },
      };

      await messaging.send(payload);
      console.log('Notification envoyée avec succès.');
    } catch (error) {
      console.error('Erreur lors de l\'envoi de la notification push:', error);
    }
    return null;
  });

// Fonction pour gérer les changements de statut des cours
export const handleCourseStatusChange = functions.firestore
  .document('users/{userId}/profil/{profilId}/courses/{courseId}')
  .onUpdate(async (change, context) => {
    const beforeStatus = change.before.data().state;
    const afterStatus = change.after.data().state;
    console.log('handleCourseStatusChange déclenché', { beforeStatus, afterStatus });

    if (
      beforeStatus !== 'Actif' &&
      beforeStatus !== 'Traité' &&
      (afterStatus === 'Actif' || afterStatus === 'Traité')
    ) {
      const courseData = change.after.data();
      const userId = context.params.userId;
      const profilId = context.params.profilId;
      const courseId = context.params.courseId;

      console.log('Changement de statut détecté pour le cours', { userId, profilId, courseId });

      // Construire le chemin complet de l'utilisateur
      const coursePath = `${userId}/${profilId}/${courseId}`;
      console.log('Chemin complet du cours:', coursePath);
      const userDoc = await firestore.collection('users').doc(userId).get();
      const userData = userDoc.data();
      const userType = userData.userType;

      // Récupérer le mois actuel en français
      const currentMonth = DateTime.now().setLocale('fr').toFormat('MMMM');
      console.log('Mois actuel:', currentMonth);

      // Préparer les données du nouveau document de paiement
      const requestPaymentData = {
        course: courseData.subject,
        amount: courseData.price,
        fullName: courseData.studentFullName,
        monthOfTransaction: currentMonth,
        coursePath: coursePath,
        transactionDateTime: admin.firestore.FieldValue.serverTimestamp(),
        state: 'Unpaid',
      };

      // Référence de la sous-collection request_payment
      const requestPaymentRef = change.after.ref.collection('request_payment');
      console.log('Ajout des données de paiement:', requestPaymentData);
      if(userType !== 'Enseignant'){
        try {
          await requestPaymentRef.add(requestPaymentData);
          console.log('Document de paiement ajouté avec succès.');
        } catch (error) {
          console.error('Erreur lors de l\'ajout du document de paiement:', error);
        }
      }
    }
  });



  export const notifyNewReport = functions.firestore
  .document('rapports/{groupId1}/{groupId2}/{rapport}')
  .onCreate(async (snapshot) => {
    const rapport = snapshot.data();
    console.log('notifyNewRapporte déclenché', { rapport });

    try {
      const receiver = await firestore.collection('users').doc(rapport.idTo).get();
      const sender = await firestore.collection('users').doc(rapport.idFrom).get();
      if (!receiver.exists) {
        console.log(`Utilisateur avec l'ID ${message.idTo} introuvable.`);
        return null;
      }

      const token = receiver.data().token;
      const senderName = sender.data().firstName +' '+ sender.data().lastName;
      console.log('Token de l\'utilisateur récupéré:', token);
      let rN = 'G4 Academie';
      
      if(senderName.trim() != 'admin admin'){
        rN = senderName;
        console.log('Sender name:', rN);

      }

      const payload = {
        token: token,
        notification: { 
          title: 'Rapport disponible ',
          body: 'Le rapport du cours de '+ rapport.content.subject+' du '+rapport.content.date +' est disponible',
        },
      };

      await messaging.send(payload);
      console.log('Notification envoyée avec succès.');
    } catch (error) {
      console.error('Erreur lors de l\'envoi de la notification de message:', error);
    }
    return null;
  });



  export const handleReportStateChange = functions.firestore
  .document('rapports/{groupId1}/{groupId2}/{rapport}')
  .onUpdate(async (change, context) => {
    const rapport = change.after;
    console.log('handleReportStateChange déclenché', { rapport });

    try {
      const sender = await firestore.collection('users').doc(rapport.idTo).get();
      const  receiver = await firestore.collection('users').doc(rapport.idFrom).get();
      if (!receiver.exists) {
        console.log(`Utilisateur avec l'ID ${message.idTo} introuvable.`);
        return null;
      }

      const token = receiver.data().token;
      const senderName = sender.data().firstName +' '+ sender.data().lastName;
      console.log('Token de l\'utilisateur récupéré:', token);
      let rN = 'G4 Academie';
      
      if(senderName.trim() != 'admin admin'){
        rN = senderName;
        console.log('Sender name:', rN);

      }

      const payload = {
        token: token,
        notification: { 
          title: 'Statut de rapport',
          body: 'Votre rapport du cours de '+ rapport.content.subject+' du '+rapport.content.date +' est validé',
        },
      };

      if(rapport.content.type === 1){
        await messaging.send(payload);
        console.log('Notification envoyée avec succès.');
      }
    } catch (error) {
      console.error('Erreur lors de l\'envoi de la notification de message:', error);
    }
    return null;
  });






// Fonction pour le paiement programmé tous les 30 jours
export const scheduledPayment = functions.pubsub
  .schedule('every 43200 minutes') // Utilisez '0 0 1 * *' pour le déclenchement mensuel
  .timeZone('Africa/Lagos')
  .onRun(async () => {
    console.log('scheduledPayment déclenché.');

    try {
      const usersSnapshot = await firestore.collection('users').get();
      console.log('Nombre d\'utilisateurs trouvés:', usersSnapshot.size);

      // Parcourir tous les utilisateurs
      for (const userDoc of usersSnapshot.docs) {
        const userId = userDoc.id;
        const userData = userDoc.data();
        if(userData.userType !== 'Enseignant'){
          console.log('Traitement des profils pour l\'utilisateur:', userId);

        const profilsSnapshot = await userDoc.ref.collection('profil').get();
        console.log('Nombre de profils trouvés:', profilsSnapshot.size);

        // Parcourir tous les profils de chaque utilisateur
        for (const profilDoc of profilsSnapshot.docs) {
          const profilId = profilDoc.id;
          console.log('Traitement des cours pour le profil:', profilId);

          const coursesSnapshot = await profilDoc.ref.collection('courses').get();
          console.log('Nombre de cours trouvés:', coursesSnapshot.size);

          // Parcourir tous les cours de chaque profil
          for (const courseDoc of coursesSnapshot.docs) {
            const courseData = courseDoc.data();
            const courseId = courseDoc.id;
            console.log('Traitement du cours:', { courseId, status: courseData.state });

            // Vérifier si le cours est "Actif" ou "Traité"
            if (courseData.state === 'Actif' || courseData.state === 'Traité') {
              const coursePath = `${userId}/${profilId}/${courseId}`;
              const currentMonth = DateTime.now().setLocale('fr').toFormat('MMMM');
              console.log('Préparation des données de paiement pour le cours:', coursePath);

              const requestPaymentData = {
                course: courseData.subject,
                amount: courseData.price,
                fullName: courseData.studentFullName,
                monthOfTransaction: currentMonth,
                coursePath: coursePath,
                transactionDateTime: admin.firestore.FieldValue.serverTimestamp(),
                state: 'Unpaid',
              };

              const requestPaymentRef = courseDoc.ref.collection('request_payment');
              console.log('Ajout des données de paiement:', requestPaymentData);

              try {
                await requestPaymentRef.add(requestPaymentData);
                console.log('Document de paiement ajouté pour le cours:', coursePath);
              } catch (error) {
                console.error('Erreur lors de l\'ajout du document de paiement pour le cours:', error);
              }
            }
          }
        }
        }
      }
    } catch (error) {
      console.error('Erreur lors du paiement programmé:', error);
    }
  });


  export const sendPaymentNotification = functions.firestore
  .document('users/{userId}/profil/{profilId}/courses/{courseId}/request_payment/{paymentId}')
  .onCreate(async (snap, context) => {
    const paymentData = snap.data();
    const { userId } = context.params;

    console.log('Nouveau document request_payment détecté:', paymentData);

    try {
      // Récupérer le document utilisateur
      const userDoc = await admin.firestore().collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        console.log('Utilisateur non trouvé:', userId);
        return;
      }

      const userData = userDoc.data();
      const userToken = userData.token; // Assurez-vous que le token de notification est stocké dans le champ 'token'
      const userType = userData.userType; // Récupérer le type d'utilisateur

      if (!userToken) {
        console.log('Aucun token de notification trouvé pour l\'utilisateur:', userId);
        return;
      }

      // Vérifier le type d'utilisateur et adapter le message
      let message;

      if (userType === 'Enseignant') {
        // Notification spécifique pour les enseignants
        message = {
          token: userToken,
          notification: {
            title: 'Versement reçu',
            body: `Vous avez reçu un versement de ${paymentData.amount}FCFA pour le cours: ${paymentData.course}`,
          },
          data: {
            coursePath: paymentData.coursePath,
            amount: paymentData.amount.toString(),
            monthOfTransaction: paymentData.monthOfTransaction,
          },
        };
      } else {
        // Notification pour les autres utilisateurs
        message = {
          token: userToken,
          notification: { 
            title: 'Nouvelle demande de paiement',
            body: `Un nouveau paiement est requis pour le cours: ${paymentData.course}`,
          },
          data: {
            coursePath: paymentData.coursePath,
            amount: paymentData.amount.toString(),
            monthOfTransaction: paymentData.monthOfTransaction,
          },
        };
      }

      // Envoyer la notification via Firebase Cloud Messaging (FCM)
      await admin.messaging().send(message);
      console.log('Notification envoyée avec succès à l\'utilisateur:', userId);

    } catch (error) {
      console.error('Erreur lors de l\'envoi de la notification:', error);
    }
  });





  export const updateLastMessageTimestampOnUserCreate = functions.firestore
    .document('users/{userId}')
    .onCreate((snap, context) => {
        // Récupérer l'ID du document (utilisateur)
        const userId = context.params.userId;

        // Créer l'objet DateTime actuel
        const currentTimestamp = DateTime.now().toISO();
        const epo = (Date.now()+3600*1000).toString();//DateTime.now().toString();
        const adminId = 'rY33iKsQgGew8akQ4ILyULwrYSt2';
        const groupChatId1 = 'rY33iKsQgGew8akQ4ILyULwrYSt2'+'-'+userId;
        const groupChatId2 = userId+'-'+'rY33iKsQgGew8akQ4ILyULwrYSt2';

        admin.firestore().collection('messages').doc(groupChatId1).collection(groupChatId1).doc(epo).set(
          {
            content:'Bienvenu sur G4 ACADEMIE!\nPosez nous toutes vos préocupations ici.',
            idFrom: adminId,
            idTo: userId,
            timestamp: epo,
            type: 0
          }
        ).then(() => {
          console.log(`Document mis à jour avec lastMessageTimestamp pour l'utilisateur ${userId}`);
      }).catch((error) => {
          console.error("Erreur lors de la mise à jour du document :", error);
      });

        admin.firestore().collection('messages').doc(groupChatId2).collection(groupChatId2).doc(epo).set(
          {
            content:'Bienvenu sur G4 ACADEMIE!\nPosez nous toutes vos préocupations ici.',
            idFrom: adminId,
            idTo: userId,
            timestamp: epo,
            type: 0
          }
        ).then(() => {
          console.log(`Document mis à jour avec lastMessageTimestamp pour l'utilisateur ${userId}`);
      }).catch((error) => {
          console.error("Erreur lors de la mise à jour du document :", error);
      });
      return null;

        // Mettre à jour le champ lastMessageTimestamp dans le document utilisateur
        /*return admin.firestore().collection('users').doc(userId).update({
            lastMessageTimestamp: currentTimestamp
        }).then(() => {
            console.log(`Document mis à jour avec lastMessageTimestamp pour l'utilisateur ${userId}`);
        }).catch((error) => {
            console.error("Erreur lors de la mise à jour du document :", error);
        });*/
    });


    export const updateUserBalance = functions.firestore
    .document('users/{userId}/profiles/{profileId}/courses/{courseId}/request_payment/{paymentId}')
    .onWrite(async (change, context) => {
        const paymentData = change.after.exists ? change.after.data() : null;
        const previousPaymentData = change.before.exists ? change.before.data() : null;

        // Ignore the change if it doesn't modify the 'state' or it's deleted
        if (!paymentData || (previousPaymentData && paymentData.state === previousPaymentData.state)) {
            return null;
        }

        // Only process if the payment's state is 'Unpaid'
        const userId = context.params.userId;  // Extract userId from the document path

        // Reference to all courses under the user's profiles
        const profilesRef = admin.firestore().collection(`users/${userId}/profiles`);

        let totalAmountDue = 0;

        try {
            // Fetch all profiles for the user
            const profilesSnapshot = await profilesRef.get();

            for (const profileDoc of profilesSnapshot.docs) {
                const profileId = profileDoc.id;
                
                // Reference to all courses under each profile
                const coursesRef = admin.firestore().collection(`users/${userId}/profiles/${profileId}/courses`);
                const coursesSnapshot = await coursesRef.get();

                for (const courseDoc of coursesSnapshot.docs) {
                    const courseId = courseDoc.id;

                    // Reference to request_payment subcollection for each course
                    const paymentsRef = admin.firestore().collection(`users/${userId}/profiles/${profileId}/courses/${courseId}/request_payment`);

                    // Fetch all unpaid payments
                    const unpaidPaymentsSnapshot = await paymentsRef.where('state', '==', 'Unpaid').get();

                    unpaidPaymentsSnapshot.forEach(paymentDoc => {
                        const paymentData = paymentDoc.data();
                        totalAmountDue += paymentData.amount;
                    });
                }
            }

            // Reference to the 'price' collection for storing the user's total balance
            const priceRef = admin.firestore().collection('price').doc(userId);

            // Create or update the document with the total balance
            await priceRef.set({
                solde: totalAmountDue
            }, { merge: true }); // Merge in case the document exists

            console.log(`Updated balance for user ${userId}: ${totalAmountDue}`);

        } catch (error) {
            console.error("Error updating user balance:", error);
        }

        return null;
    });


    const OTP_EXPIRATION_TIME = 300; // en secondes, ici 5 minutes

// Configurez votre service d'envoi d'email, ici avec nodemailer
const transporter = nodemailer.createTransport({
  service: 'gmail',
   host: 'smtp.gmail.com',
   port: 465,
   secure: true,
   auth: {
    user: 'g4academie@gmail.com',
    pass: 'ewgg bfkz mjrt sfal',
   },
});

// Fonction pour générer un OTP aléatoire
function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Cloud Function pour envoyer un OTP
export const sendOtp = functions.https.onCall(async (data, context) => {
  console.log("sendOtp - Données reçues:", data);
  
  const { email, phoneNumber } = data;
  
  const otp = generateOtp();
  console.log("sendOtp - OTP généré:", otp);

  // Sauvegarde OTP dans Firestore avec une expiration
  const otpRef = admin.firestore().collection("otps").doc(email || phoneNumber);
  try {
    await otpRef.set({
      otp: otp,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log("sendOtp - OTP sauvegardé dans Firestore pour:", email || phoneNumber);

    if (email) {
      // Envoie OTP par email
      await transporter.sendMail({
        from: "g4academie@gmail.com",
        to: email,
        subject: "Votre code OTP",
        text: `Votre code OTP est ${otp}`,
      });
      console.log("sendOtp - OTP envoyé par email à:", email);
      return { status: "otp_sent_email" };
    } else if (phoneNumber) {
      // Envoie OTP par SMS via Firebase Auth
      let userRecord;

      // Essayer de récupérer l'utilisateur par numéro de téléphone
      try {
        userRecord = await admin.auth().getUserByPhoneNumber(phoneNumber);
        console.log("sendOtp - Utilisateur trouvé:", userRecord.uid);
      } catch (error) {
        if (error.code === 'auth/user-not-found') {
          // Si l'utilisateur n'existe pas, créer un nouvel utilisateur
          userRecord = await admin.auth().createUser({
            phoneNumber: `+${phoneNumber}`,
            // Ajoutez d'autres champs nécessaires si nécessaire, comme `email`, `displayName`, etc.
          });
          console.log("sendOtp - Nouvel utilisateur créé:", userRecord.uid);
        } else {
          throw error; // Relancer les autres erreurs
        }
      }

      // Mettez à jour le numéro de téléphone de l'utilisateur si nécessaire
      await admin.auth().updateUser(userRecord.uid, {
        phoneNumber: `+${phoneNumber}`
      });

      // Envoyez l'OTP (implémentez votre service SMS ici)
      console.log("sendOtp - OTP envoyé par SMS à:", phoneNumber);
      return { status: "otp_sent_sms" };

    }
  } catch (error) {
    console.error("sendOtp - Erreur lors de l'envoi de l'OTP:", error);
    throw new functions.https.HttpsError("internal", "Erreur lors de l'envoi de l'OTP.");
  }
});

// Cloud Function pour vérifier OTP
export const verifyOtp = functions.https.onCall(async (data, context) => {
  console.log("verifyOtp - Données reçues:", data);
  
  const { email, phoneNumber, otp } = data;
  let haveAccount = false;
  
  const otpRef = admin.firestore().collection("otps").doc(email || phoneNumber);
  try {
    const otpDoc = await otpRef.get();
    if (!otpDoc.exists) {
      console.warn("verifyOtp - OTP non trouvé pour:", email || phoneNumber);
      throw new functions.https.HttpsError("not-found", "OTP non trouvé.");
    }

    const { otp: storedOtp, createdAt } = otpDoc.data();
    console.log("verifyOtp - OTP stocké trouvé:", storedOtp);

    // Vérifiez si OTP a expiré
    const now = admin.firestore.Timestamp.now();
    if (now.seconds - createdAt.seconds > OTP_EXPIRATION_TIME) {
      console.warn("verifyOtp - OTP expiré pour:", email || phoneNumber);
      throw new functions.https.HttpsError("deadline-exceeded", "OTP expiré.");
    }

    if (storedOtp !== otp) {
      console.warn("verifyOtp - OTP invalide pour:", email || phoneNumber);
      throw new functions.https.HttpsError("invalid-argument", "OTP invalide.");
    }

    // Supprimez OTP après vérification réussie
    await otpRef.delete();
    console.log("verifyOtp - OTP supprimé après vérification réussie pour:", email || phoneNumber);

    // Enregistrement de l'utilisateur ou connexion
    let user;
    if (email) {
      try {
        // Essayer de récupérer l'utilisateur par email
        user = await admin.auth().getUserByEmail(email);
        haveAccount = true;
        console.log("verifyOtp - Utilisateur trouvé par email:", user.uid);
        //return { status: "user_verified", userId: user.uid };
      } catch (error) {
        if (error.code === 'auth/user-not-found') {
          // Si l'utilisateur n'existe pas, créez un nouvel utilisateur avec un mot de passe par défaut
          const defaultPassword = email + 'g4academieDefaultPassword';
          user = await admin.auth().createUser({
            email: email,
            password: defaultPassword,
          });
          console.log("verifyOtp - Nouvel utilisateur créé:", user.uid);
        } else {
          // Relancer les autres erreurs
          throw error;
        }
      }
    } else if (phoneNumber) {
      user = await admin.auth().getUserByPhoneNumber(`+${phoneNumber}`);
      console.log("verifyOtp - Utilisateur trouvé par numéro de téléphone:", user.uid);
    }

    // Génération du token pour connecter l'utilisateur
    const customToken = await admin.auth().createCustomToken(user.uid);
    console.log("verifyOtp - Token personnalisé généré pour:", user.uid);
     console.log("verifyotp - UserToken: ******************************: ", customToken);
    return {token: customToken , userExist: haveAccount};
  } catch (error) {
    console.error("verifyOtp - Erreur lors de la vérification de l'OTP:", error);
    throw new functions.https.HttpsError("internal", "Erreur lors de la vérification de l'OTP.");
  }
});




    