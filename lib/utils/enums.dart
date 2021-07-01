import 'package:hive/hive.dart';
part 'enums.g.dart';

enum MobileVerificationState {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE,
}
@HiveType(typeId: 2)
enum MessageStatus {
  @HiveField(0)
  SENT,
  @HiveField(1)
  FAILED,
  @HiveField(2)
  RECIEVED,
  @HiveField(3)
  RECIEVED_READED,
  @HiveField(4)
  DELETED,
}
