'use strict';

import * as functions from 'firebase-functions'
const admin = require('firebase-admin');
const firebase = require('firebase');
admin.initializeApp();

const express = require('express');
const cors = require('cors')({origin: true});

const app = express();


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

const api_key = '861655fab39100239813b724618e190d-b892f62e-f2a64b99';
const domain = 'schoolvillage.org';
const mailgun = require('mailgun-js')({apiKey: api_key, domain: domain});
const bodyParser = require('body-parser')

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
                title: body['title'],
                notificationId: notificationId,
                schoolId: schoolId
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

app.use(cors);

app.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  next();
});


app.use( bodyParser.json() );       // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
  extended: true
})); 

app.post('/contact', (req, res) => {

  console.log("Adding new contact entry")

  const body = {
      firstName : req.body.firstName ? req.body.firstName : "",
      lastName : req.body.lastName ? req.body.lastName : "",
      email : req.body.email ? req.body.email : "",
      phone : req.body.phone ? req.body.phone : "",
      schoolDistrict : req.body.schoolDistrict ? req.body.schoolDistrict : "",
      comments : req.body.comments ? req.body.comments : ""
  };
  console.log(body);

  const collectionRef = firestore.collection("requests");
  
  collectionRef.add(body).then(documentReference => {
    const mail = {
      from: 'schoolvillageowner@gmail.com',
      to: 'mwiggins@schoolvillage.org',
      subject: 'New Contact Submission',
      html: 
      `
      First Name: ${body.firstName} <br>
      Last Name:  ${body.lastName} <br>
      Email:  ${body.email} <br>
      Phone:  ${body.phone} <br>
      School District:  ${body.schoolDistrict} <br>
      Comments:  ${body.comments} <br>
      `
    };
     
    mailgun.messages().send(mail, function (error, mailResp) {
      console.log(mailResp);
      if(!error) {
        res.send("Success");
      } else {
        console.error(error);
        res.status(500).send('Server Error');
      }
    });
  }).catch(error => {
    console.error(error);
    res.status(500).send('Server Error');
  });
  
});          

exports.api = functions.https.onRequest(app);