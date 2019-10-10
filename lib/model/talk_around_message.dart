class TalkAroundMessage {
  final String origin;
  final String id;
  final String channel;
  final String message;
  final DateTime timestamp;
  final String author;
  final String authorId;
  final String reportedByPhone;
  final double latitude;
  final double longitude;

  TalkAroundMessage(this.origin, this.id, this.channel, this.message, this.timestamp, this.author, this.authorId, this.reportedByPhone, this.latitude, this.longitude);
}