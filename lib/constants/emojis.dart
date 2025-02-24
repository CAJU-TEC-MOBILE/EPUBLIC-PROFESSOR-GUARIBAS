import 'package:flutter_emoji/flutter_emoji.dart';

class Emojis {
  static final EmojiParser emojiParser = EmojiParser();
  static final String happyEmoji = emojiParser.get('smile').code;
  static final String sadEmoji = emojiParser.get('disappointed').code;
  static final String loveEmoji = emojiParser.get('heart_eyes').code;
  static final String laughEmoji = emojiParser.get('joy').code;
  static final String noEntrySign = emojiParser.get('no_entry_sign').code;
}
