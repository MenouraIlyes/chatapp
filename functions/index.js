const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { error } = require('firebase-functions/logger');
admin.initializeApp();

exports.sendNotificationOnMessage = functions.firestore.document('chat_rooms/{chatRoomID}/messages/{messageID}').onCreate(async (snapshot, context) => {
    // get the message
    const messsage = snapshot.data();

    try{
        // get receiverid
        const receiverDoc = await admin.firestore().collection('Users').doc(messsage.receiverID).get();

        if(!receiverDoc.exists){
            console.log('No such receiver');
            return null;
        }

        // get receiver data
        const receiverData = receiverDoc.data();
        const token = receiverData.fcmToken;

        if(!token){
            console.log('No token for user, cannot send notification');
            return null;
        }

        // updated message payload for 'send' method
        const messagePayload = {
            token : token,
            notification : {
                title : 'New Message',
                body : '${message.senderEmail} says : ${message.message}',
            },
            android: {
                notification: {
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                }
            },
            apns: {
                payload: {
                    aps: {
                        category: 'FLUTTER_NOTIFICATION_CLICK'
                    }
                }
            }
        };

        // send the notification
        const response = await admin.messaging().send(messagePayload);
        console.log('Notification sent successfully', response);
        return response;
    } catch(e){
        console.error('Detailed error:', error);
        if(e.code && e.messsage){
            console.error('Error code:', e.code);
            console.error('Error message:', e.messsage);
        }

        throw new Error('Failed to send notification');
    }
})