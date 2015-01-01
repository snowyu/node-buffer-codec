# Copyright (c) 2014 Riceball LEE, MIT License
util        = require("abstract-object/lib/util")
isString    = util.isString
Codec       = module.exports = require './abstract-codec'
register    = Codec.register
aliases     = Codec.aliases
isBuffer    = Buffer.isBuffer

class TextCodec
  register TextCodec, Codec
  aliases  TextCodec, 'utf8', 'utf-8'

  _encodeString: (data)->
    if not data? or isBuffer data
      data
    else
      String(data)
  _decodeString: (data)->data

class JsonCodec
  register JsonCodec, TextCodec

  _encodeString: JSON.stringify
  _decodeString: JSON.parse

# Encode String or Array to Binary(Byte)
class BinaryCodec
  register BinaryCodec, Codec

  arraySlice = Array.prototype.slice

  toArray: (data)->arraySlice.call(data)
  _encodeBuffer: (data, destBuffer, offset, encoding)->
    if not data?
      0
    else
      dataIsBuffer = isBuffer data
      if isBuffer destBuffer
        if dataIsBuffer
          len = Math.min data.length, destBuffer.length - offset
          data.copy destBuffer, offset, 0, len
          len
        else if isString data
          destBuffer.write(data, offset, undefined, encoding)
        else
          offset = 0 unless offset > 0
          arr = arraySlice.call(data)
          if arr.length > 0
            for v,i in arr
              destBuffer.writeUInt8 v, i+offset, true
          arr.length
      else
        if dataIsBuffer
          data.length
        else if isString data
          Codec.getByteLen data
        else
          arr = arraySlice.call(data)
          arr.length

  _decodeBuffer: (data, start, end)->
    if not data? or not (start? and end) or not data.slice
      data
    else
      data.slice(start, end)

