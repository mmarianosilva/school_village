'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
const functions = require("firebase-functions");
exports.useMultipleWildcards = functions.firestore
    .document('schools/{schoolId}/notifications/{notificationId}')
    .onWrite((change, context) => {
    // If we set `/users/marie/incoming_messages/134` to {body: "Hello"} then
    // context.params.userId == "marie";
    // context.params.messageCollectionId == "incoming_messages";
    // context.params.messageId == "134";
    // ... and ...
    // change.after.data() == {body: "Hello"}
});
//# sourceMappingURL=notifications-write.js.map