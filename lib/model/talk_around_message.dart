class TalkAroundMessage {
  final String origin;
  final String id;
  final String channel;
  final String message;
  final DateTime timestamp;
  final String author;
  final String authorId;
  final double latitude;
  final double longitude;

  TalkAroundMessage(this.origin, this.id, this.channel, this.message, this.timestamp, this.author, this.authorId, this.latitude, this.longitude);
}