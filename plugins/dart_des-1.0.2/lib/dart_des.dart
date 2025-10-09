
import 'dart:typed_data';
import 'package:dart_des/des_padding.dart';

// Modes of crypting / cyphering
enum DESMode { ECB, CBC }

// Types for pad / unpad data
enum DESPaddingType { None, OneAndZeroes, PKCS7, PKCS5 }

// The base class shared by des and triple des.
class _BaseDES {
  final List<int> key;
  final DESMode mode;
  List<int> iv;

  _BaseDES(this.key, this.mode, this.iv) {
    if (iv.length != 8) {
      throw Exception(
          'Invalid Initial Value (iv), must be exactly ${DES.BLOCK_SIZE} bytes');
    }
  }
}

class DES {
  static const BLOCK_SIZE = 8;
  static const IV_ZEROS = [0, 0, 0, 0, 0, 0, 0, 0];

  // Type of crypting being done
  static const _ENCRYPT = 0x00;
  static const _DECRYPT = 0x01;

  // Tables  --------------------------
  static const List<int> _pc1 = [
    56, 48, 40, 32, 24, 16, 8, 0, 57, 49, 41, 33, 25, 17, 9, 1, 58, 50, 42, 34,
    26, 18, 10, 2, 59, 51, 43, 35, 62, 54, 46, 38, 30, 22, 14, 6, 61, 53, 45,
    37, 29, 21, 13, 5, 60, 52, 44, 36, 28, 20, 12, 4, 27, 19, 11, 3
  ];

  static const List<int> _leftRotations = [
    1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1
  ];

  static const List<int> _pc2 = [
    13, 16, 10, 23, 0, 4, 2, 27, 14, 5, 20, 9, 22, 18, 11, 3, 25, 7, 15, 6, 26,
    19, 12, 1, 40, 51, 30, 36, 46, 54, 29, 39, 50, 44, 32, 47, 43, 48, 38, 55,
    33, 52, 45, 41, 49, 35, 28, 31
  ];

  static const List<int> _ip = [
    57, 49, 41, 33, 25, 17, 9, 1, 59, 51, 43, 35, 27, 19, 11, 3, 61, 53, 45, 37,
    29, 21, 13, 5, 63, 55, 47, 39, 31, 23, 15, 7, 56, 48, 40, 32, 24, 16, 8, 0,
    58, 50, 42, 34, 26, 18, 10, 2, 60, 52, 44, 36, 28, 20, 12, 4, 62, 54, 46, 38,
    30, 22, 14, 6
  ];

  static const List<int> _expansionTable = [
    31, 0, 1, 2, 3, 4, 3, 4, 5, 6, 7, 8, 7, 8, 9, 10, 11, 12, 11, 12, 13, 14, 15,
    16, 15, 16, 17, 18, 19, 20, 19, 20, 21, 22, 23, 24, 23, 24, 25, 26, 27, 28,
    27, 28, 29, 30, 31, 0
  ];

  static const List<List<int>> _sBox = [
    [
      14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7, 0, 15, 7, 4, 14, 2,
      13, 1, 10, 6, 12, 11, 9, 5, 3, 8, 4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7,
      3, 10, 5, 0, 15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13
    ],
    [
      15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10, 3, 13, 4, 7, 15, 2, 8,
      14, 12, 0, 1, 10, 6, 9, 11, 5, 0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3,
      2, 15, 13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9
    ],
    [
      10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8, 13, 7, 0, 9, 3, 4, 6,
      10, 2, 8, 5, 14, 12, 11, 15, 1, 13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10,
      14, 7, 1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12
    ],
    [
      7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15, 13, 8, 11, 5, 6, 15, 0,
      3, 4, 7, 2, 12, 1, 10, 14, 9, 10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2,
      8, 4, 3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14
    ],
    [
      2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9, 14, 11, 2, 12, 4, 7, 13,
      1, 5, 0, 15, 10, 3, 9, 8, 6, 4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0,
      14, 11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3
    ],
    [
      12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11, 10, 15, 4, 2, 7, 12, 9,
      5, 6, 1, 13, 14, 0, 11, 3, 8, 9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11,
      6, 4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13
    ],
    [
      4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1, 13, 0, 11, 7, 4, 9, 1, 10,
      14, 3, 5, 12, 2, 15, 8, 6, 1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2,
      6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12
    ],
    [
      13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7, 1, 15, 13, 8, 10, 3, 7, 4,
      12, 5, 6, 11, 0, 14, 9, 2, 7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8,
      2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11
    ],
  ];

  static const List<int> _p = [
    15, 6, 19, 20, 28, 11, 27, 16, 0, 14, 22, 25, 4, 17, 30, 9, 1, 7, 23, 13, 31,
    26, 2, 8, 18, 12, 29, 5, 21, 10, 3, 24
  ];

  static const List<int> _fp = [
    39, 7, 47, 15, 55, 23, 63, 31, 38, 6, 46, 14, 54, 22, 62, 30, 37, 5, 45, 13,
    53, 21, 61, 29, 36, 4, 44, 12, 52, 20, 60, 28, 35, 3, 43, 11, 51, 19, 59, 27,
    34, 2, 42, 10, 50, 18, 58, 26, 33, 1, 41, 9, 49, 17, 57, 25, 32, 0, 40, 8,
    48, 16, 56, 24
  ];

  // end tables ----------------------------------------

  late _BaseDES _baseDES;
  // 16 48-bit keys (K1 - K16) as integers
  final List<int> _kN = List.generate(16, (_) => 0);

  set iv(List<int> value) => _baseDES.iv = value;
  final DESPaddingType paddingType;

  DES({
    required List<int> key,
    DESMode mode = DESMode.ECB,
    iv = IV_ZEROS,
    this.paddingType = DESPaddingType.OneAndZeroes,
  }) {
    if (key.length != 8) {
      throw Exception('Invalid DES key size. Key must be exactly 8 bytes long.');
    }
    _baseDES = _BaseDES(key, mode, iv);
    _createSubKeys();
  }

  // ---------------- utility: bytes <-> int64 ----------------
  static int _bytesToInt64(List<int> bytes, [int offset = 0]) {
    // bytes[offset .. offset+7] => big-endian int (MSB first)
    int v = 0;
    for (int i = 0; i < 8; i++) {
      v = (v << 8) | (bytes[offset + i] & 0xff);
    }
    return v;
  }

  static List<int> _int64ToBytes(int v) {
    final out = List<int>.filled(8, 0);
    for (int i = 7; i >= 0; i--) {
      out[i] = v & 0xff;
      v >>= 8;
    }
    return out;
  }

  // Permute integer using table: input treated as inLen bits, table contains indices 0..inLen-1
  // results as outLen bits (== table.length), MSB first.
  static int _permuteInt(int input, List<int> table, int inLen) {
    int out = 0;
    for (int i = 0; i < table.length; i++) {
      int pos = table[i];
      int bit = (input >> (inLen - 1 - pos)) & 1;
      out = (out << 1) | bit;
    }
    return out;
  }

  // Left rotate n-bit value (width bits) by shift
  static int _leftRotate(int value, int width, int shift) {
    shift %= width;
    return ((value << shift) & ((1 << width) - 1)) | ((value >> (width - shift)) & ((1 << shift) - 1));
  }

  // ---------------- key schedule ----------------
  void _createSubKeys() {
    // Start from 64-bit key (as bytes)
    int key64 = _bytesToInt64(_baseDES.key);
    // apply PC1 (64->56)
    int pc1 = _permuteInt(key64, _pc1, 64); // 56-bit result in lower bits? Actually _permuteInt returns MSB-first in bits-length == table.length
    // pc1 currently has 56 bits packed MSB-first in a 56-bit value.
    // split into 28-bit left (high) and right (low)
    int left = (pc1 >> 28) & ((1 << 28) - 1);
    int right = pc1 & ((1 << 28) - 1);

    for (int i = 0; i < 16; i++) {
      left = _leftRotate(left, 28, _leftRotations[i]);
      right = _leftRotate(right, 28, _leftRotations[i]);
      int combined = (left << 28) | right; // 56-bit
      // apply pc2 (56->48)
      int subkey48 = _permuteInt(combined, _pc2, 56); // 48-bit
      _kN[i] = subkey48;
    }
  }

  // ---------------- Feistel round utilities ----------------
  // expansion: 32 -> 48
  static int _expand32to48(int r32) {
    return _permuteInt(r32, _expansionTable, 32);
  }

  // s-box substitution: input 48-bit -> output 32-bit
  static int _sboxSubstitution(int in48) {
    int out32 = 0;
    // process 8 groups of 6 bits from MSB to LSB
    for (int i = 0; i < 8; i++) {
      int shift = (7 - i) * 6;
      int six = (in48 >> shift) & 0x3f; // 6 bits
      int row = ((six & 0x20) >> 4) | (six & 0x01); // b5 and b0 => row (0..3)
      int col = (six >> 1) & 0x0f; // middle 4 bits
      int sVal = _sBox[i][row * 16 + col] & 0x0f;
      out32 = (out32 << 4) | sVal;
    }
    return out32;
  }

  // permutation P (32->32)
  static int _permuteP(int in32) {
    return _permuteInt(in32, _p, 32);
  }

  // ---------------- core DES block function ----------------
  int _desBlockCryptInt(int block64, int cryptType) {
    // initial permutation (64->64)
    int ipVal = _permuteInt(block64, _ip, 64);

    int left = (ipVal >> 32) & 0xffffffff;
    int right = ipVal & 0xffffffff;

    int iter, iterAdjust;
    if (cryptType == _ENCRYPT) {
      iter = 0;
      iterAdjust = 1;
    } else {
      iter = 15;
      iterAdjust = -1;
    }

    for (int round = 0; round < 16; round++, iter += iterAdjust) {
      int tempRight = right;
      // expand right (32->48)
      int expanded = _expand32to48(right);
      // xor with subkey
      int xored = expanded ^ _kN[iter];
      // sbox -> 32
      int sboxed = _sboxSubstitution(xored);
      // p permutation
      int f = _permuteP(sboxed) & 0xffffffff;
      // xor with left
      right = left ^ f;
      left = tempRight;
    }

    // combine R16 and L16 (note order is right + left)
    int preout = ((right & 0xffffffff) << 32) | (left & 0xffffffff);
    // final permutation
    int out = _permuteInt(preout, _fp, 64);
    return out;
  }

  // ---------------- high-level crypt for List<int> ----------------
  List<int> crypt(List<int> data, int cryptType) {
    if (data.isEmpty) return [];

    if (cryptType == _DECRYPT && data.length % BLOCK_SIZE != 0) {
      throw Exception(
          'Invalid data length, data must be a multiple of $BLOCK_SIZE bytes.');
    }

    // prepare iv as int bits if CBC
    int? ivInt;
    if (_baseDES.mode == DESMode.CBC) {
      ivInt = _bytesToInt64(_baseDES.iv);
    }

    List<int> result = [];
    int i = 0;

    while (i < data.length) {
      // take 8 bytes (for encryption we ensure padded length is multiple of 8)
      final blockBytes = data.sublist(i, i + 8);
      int blockInt = _bytesToInt64(blockBytes);

      if (_baseDES.mode == DESMode.CBC) {
        if (cryptType == _ENCRYPT) {
          // XOR with IV before encrypt
          blockInt = blockInt ^ ivInt!;
          int processed = _desBlockCryptInt(blockInt, _ENCRYPT);
          // update iv to cipher block
          ivInt = processed;
          result.addAll(_int64ToBytes(processed));
        } else {
          // decrypt then xor with IV
          int processed = _desBlockCryptInt(blockInt, _DECRYPT);
          processed = processed ^ ivInt!;
          // update iv to current ciphertext block
          ivInt = blockInt;
          result.addAll(_int64ToBytes(processed));
        }
      } else {
        int processed = _desBlockCryptInt(blockInt, cryptType);
        result.addAll(_int64ToBytes(processed));
      }

      i += 8;
    }
    return result;
  }

  List<int> encrypt(List<int> data) =>
      crypt(DESPadding.pad(data, paddingType), _ENCRYPT);

  List<int> decrypt(List<int> data) =>
      DESPadding.unpad(crypt(data, _DECRYPT), paddingType);
}

//#################################
//#         Triple DES            #
//#################################
class DES3 {
  DESMode mode;
  DESPaddingType paddingType;

  DES? _desFirst;
  late DES _desSecond;
  DES? _desThird;
  List<int> iv;

  DES3(
      {required List<int> key,
        this.mode = DESMode.ECB,
        this.iv = DES.IV_ZEROS,
        this.paddingType = DESPaddingType.OneAndZeroes}) {
    int keySize = 24; // Use DES-EDE3 mode
    if (key.length != keySize) {
      if (key.length == 16) {
        // Use DES-EDE2 mode
        keySize = 16;
      } else {
        throw Exception(
            'Invalid triple DES key size. Key must be either 16 or 24 bytes long');
      }
    }
    if (mode == DESMode.CBC) {
      if (iv.length != DES.BLOCK_SIZE) {
        throw Exception('Invalid IV, must be 8 bytes in length');
      }
    }

    _desFirst = DES(
        key: key.sublist(0, 8),
        mode: mode,
        iv: iv,
        paddingType: DESPaddingType.None);
    _desSecond = DES(
        key: key.sublist(8, 16),
        mode: mode,
        iv: iv,
        paddingType: DESPaddingType.None);
    if (keySize == 16) {
      _desThird = _desFirst;
    } else {
      _desThird = DES(
          key: key.sublist(16),
          mode: mode,
          iv: iv,
          paddingType: DESPaddingType.None);
    }
    this.mode = mode;
  }

  // encryption: EDE (encrypt, decrypt, encrypt)
  List<int> encrypt(List<int> data) {
    data = DESPadding.pad(data, paddingType);
    if (mode == DESMode.CBC) {
      // make sure subdes ivs are set
      _desFirst!.iv = iv;
      _desSecond.iv = iv;
      _desThird!.iv = iv;

      int i = 0;
      List<int> result = [];
      while (i < data.length) {
        final block = data.sublist(i, i + 8);
        // each sub-des returns bytes
        List<int> b1 = _desFirst!.encrypt(block);
        List<int> b2 = _desSecond.decrypt(b1);
        List<int> b3 = _desThird!.encrypt(b2);
        // update IVs to last cipher block
        if (_desFirst != null) _desFirst!.iv = b3;
        _desSecond.iv = b3;
        if (_desThird != null) _desThird!.iv = b3;
        result.addAll(b3);
        i += 8;
      }
      return result;
    } else {
      List<int> r = _desFirst!.encrypt(data);
      r = _desSecond.decrypt(r);
      r = _desThird!.encrypt(r);
      return r;
    }
  }

  List<int> decrypt(List<int> data) {
    if (mode == DESMode.CBC) {
      _desFirst!.iv = iv;
      _desSecond.iv = iv;
      _desThird!.iv = iv;

      List<int> result = [];
      for (int i = 0; i < data.length; i += 8) {
        // current ciphertext block
        final cipherBlock = data.sublist(i, i + 8);
        // step: D3, E2, D1
        List<int> b = _desThird!.decrypt(cipherBlock);
        b = _desSecond.encrypt(b);
        b = _desFirst!.decrypt(b);
        // update IVs
        _desFirst!.iv = cipherBlock;
        _desSecond.iv = cipherBlock;
        _desThird!.iv = cipherBlock;
        result.addAll(b);
      }
      data = result;
    } else {
      List<int> r = _desThird!.decrypt(data);
      r = _desSecond.encrypt(r);
      r = _desFirst!.decrypt(r);
      data = r;
    }

    data = DESPadding.unpad(data, paddingType);
    return data;
  }
}
