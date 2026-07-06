const { setGlobalOptions } = require("firebase-functions");
const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

// For cost control — caps concurrent container instances per function.
setGlobalOptions({ maxInstances: 10 });

// ── New direct message ──────────────────────────────────────────────────
exports.onNewMessage = onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (event) => {
    const message = event.data.data();
    const chatId = event.params.chatId;

    // DM chat IDs are "uid1_uid2" — recipient is whichever uid isn't the sender.
    const [uid1, uid2] = chatId.split("_");
    const recipientId = message.senderId === uid1 ? uid2 : uid1;

    const recipientDoc = await admin
      .firestore()
      .collection("users")
      .doc(recipientId)
      .get();

    const tokens = recipientDoc.data()?.fcmTokens;
    if (!tokens || tokens.length === 0) return;

    const senderDoc = await admin
      .firestore()
      .collection("users")
      .doc(message.senderId)
      .get();
    const senderName = senderDoc.data()?.name ?? "Someone";

    const payload = {
      notification: {
        title: senderName,
        body: message.text ?? "Sent you a message",
      },
      data: { chatId, type: "message" },
      tokens,
    };

    const response = await admin.messaging().sendEachForMulticast(payload);
    await cleanupInvalidTokens(recipientId, tokens, response);
  }
);

// ── Added to a team ──────────────────────────────────────────────────────
exports.onMemberAdded = onDocumentUpdated(
  "teams/{teamId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    const beforeIds = before.memberIds || [];
    const afterIds = after.memberIds || [];
    const newMemberIds = afterIds.filter((id) => !beforeIds.includes(id));
    if (newMemberIds.length === 0) return; // no new members, e.g. just a name/bio edit

    for (const memberId of newMemberIds) {
      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(memberId)
        .get();

      const tokens = userDoc.data()?.fcmTokens;
      if (!tokens || tokens.length === 0) continue;

      const payload = {
        notification: {
          title: "Added to a team",
          body: `You've been added to "${after.name}"`,
        },
        data: { teamId: event.params.teamId, type: "team_added" },
        tokens,
      };

      const response = await admin.messaging().sendEachForMulticast(payload);
      await cleanupInvalidTokens(memberId, tokens, response);
    }
  }
);

// ── Shared helper: remove tokens that failed (uninstalled app, etc.) ──────
async function cleanupInvalidTokens(userId, tokens, response) {
  const invalidTokens = [];
  response.responses.forEach((res, idx) => {
    if (!res.success) invalidTokens.push(tokens[idx]);
  });
  if (invalidTokens.length > 0) {
    await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .update({
        fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
      });
  }
}