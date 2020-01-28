/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import 'fbx_parser.dart';
import 'fbx_element.dart';
import 'input_buffer.dart';

/// Decodes an ASCII FBX file.
class FbxAsciiParser extends FbxParser {
  static const FILE_HEADER = '; FBX';

  InputBuffer _input;

  static bool isValidFile(InputBuffer input) {
    final fp = input.offset;
    final header = input.readString(FILE_HEADER.length);
    input.offset = fp;

    if (header != FILE_HEADER) {
      return false;
    }

    return true;
  }

  FbxAsciiParser(InputBuffer input) {
    final fp = input.offset;
    final header = input.readString(FILE_HEADER.length);
    input.offset = fp;

    if (header != FILE_HEADER) {
      return;
    }

    _input = input;
  }

  @override
  FbxElement nextElement() {
    if (_input == null) {
      return null;
    }

    var tk = _nextToken(_input);
    if (tk == '}') {
      return null;
    }

    if (_nextToken(_input) != ':') {
      return null;
    }

    final elem = FbxElement(tk);

    final sp = _input.offset;
    tk = _nextToken(_input);

    // If the next token is a node definition (nodeType:*), then back up
    // and save it for the next node.
    final tk2 = _nextToken(_input, peek: true);
    if (tk2 == ':') {
      _input.offset = sp;
      return elem;
    }

    if (tk != '{') {
      while (!_input.isEOS) {
        elem.properties.add(tk);
        tk = _nextToken(_input, peek: true);
        if (tk == ',' || tk == '{') {
          _nextToken(_input); // consume the ,{ token
          if (tk == '{') {
            break;
          }
          tk = _nextToken(_input);
        } else {
          break;
        }
      }
    }

    if (tk == '{') {
      var n = nextElement();
      while (n != null) {
        elem.children.add(n);
        n = nextElement();
      }
    }

    return elem;
  }

  @override
  String sceneName() => 'Model::Scene';

  @override
  String getName(String rawName) => rawName.split('::').last;

  String _nextToken(InputBuffer input, {bool peek = false}) {
    _skipWhitespace(input);

    if (input.isEOS) {
      return null;
    }

    final sp = input.offset;
    var c = input.readByte();

    if (c == TK_QUOTE) {
      final s = _readString(input);
      if (peek) {
        input.offset = sp;
      }
      return s;
    }

    if (c == TK_COMMA || c == TK_LBRACE || c == TK_RBRACE || c == TK_COLON) {
      final s = String.fromCharCode(c);
      if (peek) {
        input.offset = sp;
      }
      return s;
    }

    while (!input.isEOS) {
      c = input.peekBytes(1)[0];
      if (!_isAlphaNumeric(c)) {
        break;
      }
      input.skip(1);
    }

    final ep = input.offset;
    input.offset = sp;

    final token = input.readString(ep - sp);
    if (peek) {
      input.offset = sp;
    }

    //if (token.length > 5 && token.toLowerCase().startsWith("c")) logger("------ token: " + token);

    return token;
  }

  String _readString(InputBuffer input) {
    final sp = input.offset;
    while (!input.isEOS) {
      final c = input.readByte();
      if (c == TK_QUOTE) {
        break;
      }
    }
    final ep = input.offset;
    input.offset = sp;
    final string = input.readString(ep - sp - 1); // don't include ending "
    input.skip(1); // skip ending "
    return string;
  }

  bool _isAlphaNumeric(int c) {
    return (c >= TK_a && c <= TK_z) ||
        (c >= TK_A && c <= TK_Z) ||
        (c >= TK_0 && c <= TK_9) ||
        (c == TK_DOT) ||
        (c == TK_PLUS) ||
        (c == TK_MINUS) ||
        (c == TK_ASTERISK) ||
        (c == TK_BAR) ||
        (c == TK_UNDERSCORE);
  }

  void _skipWhitespace(InputBuffer input) {
    while (!input.isEOS) {
      final c = input.peekBytes(1)[0];

      if (c == TK_SPACE || c == TK_TAB || c == TK_RL || c == TK_NL) {
        input.skip(1);
        continue;
      }

      // skip comments
      if (c == TK_SEMICOLON) {
        while (!input.isEOS) {
          final c2 = input.readByte();
          if (c2 == TK_NL) {
            break;
          }
        }
        continue;
      }

      break;
    }
  }

  final int TK_LBRACE = '{'.codeUnits[0];
  final int TK_RBRACE = '}'.codeUnits[0];
  final int TK_SEMICOLON = ';'.codeUnits[0];
  final int TK_COLON = ':'.codeUnits[0];
  final int TK_RL = '\r'.codeUnits[0];
  final int TK_NL = '\n'.codeUnits[0];
  final int TK_QUOTE = '"'.codeUnits[0];
  final int TK_SPACE = ' '.codeUnits[0];
  final int TK_TAB = '\t'.codeUnits[0];
  final int TK_COMMA = ','.codeUnits[0];
  final int TK_DOT = '.'.codeUnits[0];
  final int TK_ASTERISK = '*'.codeUnits[0];
  final int TK_MINUS = '-'.codeUnits[0];
  final int TK_PLUS = '+'.codeUnits[0];
  final int TK_BAR = '|'.codeUnits[0];
  final int TK_UNDERSCORE = '_'.codeUnits[0];
  final int TK_a = 'a'.codeUnits[0];
  final int TK_e = 'e'.codeUnits[0];
  final int TK_z = 'z'.codeUnits[0];
  final int TK_A = 'A'.codeUnits[0];
  final int TK_E = 'E'.codeUnits[0];
  final int TK_Z = 'Z'.codeUnits[0];
  final int TK_0 = '0'.codeUnits[0];
  final int TK_9 = '9'.codeUnits[0];
}
