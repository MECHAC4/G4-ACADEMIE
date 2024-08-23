
import '../../users.dart';

class ChatParams{
  final String userUid;
  final AppUser peer;

  ChatParams(this.userUid, this.peer);

  String getChatGroupId() {
    if (userUid.hashCode <= peer.id.hashCode) {
      return '$userUid-${peer.id}';
    } else {
      return '${peer.id}-$userUid';
    }
  }
}



