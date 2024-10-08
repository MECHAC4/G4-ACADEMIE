import admin from 'firebase-admin';
import functions from 'firebase-functions';
import { DateTime } from 'luxon';
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

        // Mettre à jour le champ lastMessageTimestamp dans le document utilisateur
        return admin.firestore().collection('users').doc(userId).update({
            lastMessageTimestamp: currentTimestamp
        }).then(() => {
            console.log(`Document mis à jour avec lastMessageTimestamp pour l'utilisateur ${userId}`);
        }).catch((error) => {
            console.error("Erreur lors de la mise à jour du document :", error);
        });
    });


  /*export const updateAllUsersLastMessageTimestampScheduled = functions.pubsub.schedule('every 2 minutes').onRun(async (context) => {
    console.log('Mise à jour de lastMessageTimestamp pour tous les utilisateurs');
  
    try {
      const usersSnapshot = await firestore.collection('users').get();
      const batch = firestore.batch();
  
      // Parcourez chaque document d'utilisateur
      usersSnapshot.forEach((doc) => {
        const userId = doc.id;
        const userData = doc.data();
  
        // Ici, nous mettons simplement à jour avec un timestamp fictif (par exemple, la date actuelle)
        const lastMessageTimestamp = new Date().toISOString(); // Remplacez ceci par votre logique de récupération
  
        batch.update(doc.ref, { lastMessageTimestamp });
        console.log(`Document de l'utilisateur ${userId} mis à jour avec lastMessageTimestamp : ${lastMessageTimestamp}`);
      });
  
      await batch.commit();
      console.log('Mise à jour réussie pour tous les utilisateurs.');
    } catch (error) {
      console.error('Erreur lors de la mise à jour des utilisateurs :', error);
    }
  });*/

