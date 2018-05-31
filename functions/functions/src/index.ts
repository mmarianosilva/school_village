'use strict';

import * as functions from 'firebase-functions'
const admin = require('firebase-admin');
const firebase = require('firebase');
admin.initializeApp();


const config = {
  apiKey: "AIzaSyAbuIElF_ufTQ_NRdSz3z-0Wm21H6GQDQI",
  authDomain: "schoolvillage-1.firebaseapp.com",
  databaseURL: "https://schoolvillage-1.firebaseio.com",
  projectId: "schoolvillage-1",
  storageBucket: "schoolvillage-1.appspot.com",
  messagingSenderId: "801521806783"
};
firebase.initializeApp(config);

const firestore = admin.firestore();
const auth = admin.auth();

exports.schoolNotificationWrite = functions.firestore
    .document('schools/{schoolId}/notifications/{notificationId}')
           .onWrite((change, context) => {
             // If we set `/users/marie/incoming_messages/134` to {body: "Hello"} then
             // context.params.userId == "marie";
             // context.params.messageCollectionId == "incoming_messages";
             // context.params.messageId == "134";
             // ... and ...
             // change.after.data() == {body: "Hello"}

             const schoolId = context.params.schoolId;
             const notificationId = context.params.notificationId;
             const body = change.after.data();
             console.log(body);

             const payload = {
              notification: {
                title: body['title'],
                body: body['body'],
                clickAction: 'FLUTTER_NOTIFICATION_CLICK'
              },
              data: {
                body : body['body'],
                title: body['title']
              }
             };
             const topic = schoolId+"-"+body["type"];
             return admin.messaging().sendToTopic(topic, payload);
           });


exports.onUserCreate = functions.auth.user().onCreate((user) => {
            console.log(user);

            const userRef = firestore.doc(`users/${user.uid}`);
            let name = user.displayName;
            if (name === null ) {
              name = "";
            }
            
            return userRef.set({
              email: user.email,
              displayName: name
            }).then(() => {
              return firebase.auth().sendPasswordResetEmail(user.email)
            });

          });