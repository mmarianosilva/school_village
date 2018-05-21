'use strict';

import * as functions from 'firebase-functions'
const admin = require('firebase-admin');
admin.initializeApp();

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