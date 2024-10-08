class RapportParams{
   String userCourseUid;
   String peerCourseUid;

  RapportParams(this.userCourseUid, this.peerCourseUid);

  String getChatGroupId() {
    userCourseUid = userCourseUid.replaceAll('/', '-');
    peerCourseUid = peerCourseUid.replaceAll('/', '-');
    peerCourseUid = peerCourseUid.split('/').join('-');
    userCourseUid = userCourseUid.split('/').join('-');
    if (userCourseUid.hashCode <= peerCourseUid.hashCode) {
      return '$userCourseUid||$peerCourseUid';
    } else {
      return '$peerCourseUid||$userCourseUid';
    }
  }
}