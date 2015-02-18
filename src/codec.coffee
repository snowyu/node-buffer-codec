# Copyright (c) 2014-2015 Riceball LEE, MIT License
Errors      = require('abstract-error')
Codec       = module.exports = require './abstract-codec'
isString    = require("util-ex/lib/is/type/string")
register    = Codec.register
aliases     = Codec.aliases
isBuffer    = Buffer.isBuffer

InvalidFormatError    = Errors.InvalidFormatError

class TextCodec
  register TextCodec, Codec
  aliases  TextCodec, 'utf8', 'utf-8'

  _encodeString: (data)->
    if not data? or isBuffer data
      data
    else
      String(data)
  _decodeString: (data)->data
  byteLength: (data)->
    if data? then data.length || String(data).length else 0

class JsonCodec
  register JsonCodec, TextCodec

  _encodeString: JSON.stringify
  _decodeString: JSON.parse
  byteLength: (data)->@_encodeString(data).length

class HexCodec
  register HexCodec, TextCodec

  bufferEncoding: 'hex'
  byteToHex: (byte)->
    if byte < 16 then '0'+byte.toString(16) else byte.toString(16)
  _encodeString: (data)->
    length = data.length
    throw new InvalidFormatError('invalid hex string.') if length % 2 isnt 0
    length = length >> 1
    result = ""
    i = 0
    while i < length
      byte = parseInt(data.substr(i*2, 2), 16)
      result += String.fromCharCode(byte)
      i++
    result
  _decodeString: (data)->
    result = ""
    i = 0
    while i < data.length
      result += @byteToHex(data.charCodeAt(i))
      i++
    result
  _encodeBuffer: (data, destBuffer, offset, encoding)->
    offset = Number(offset) || 0
    length = data.length
    throw new InvalidFormatError('invalid hex string.') if length % 2 isnt 0
    length = length >> 1
    if isBuffer destBuffer
      length = destBuffer.write data, offset, length, 'hex'
    length
  _encodeBuffer2: (data, destBuffer, offset, encoding)->
    offset = Number(offset) || 0
    length = data.length
    throw new InvalidFormatError('invalid hex string.') if length % 2 isnt 0
    length = length >> 1
    if isBuffer destBuffer
      i = destBuffer.length - offset
      length = i if length > i
      i = 0
      while i < length
        byte = parseInt(data.substr(i*2, 2), 16)
        throw new InvalidFormatError('invalid hex string.') if isNaN(byte)
        destBuffer[offset+i]=byte
        i++
    length
  _decodeBuffer: (buf, start, end)->
    buf.toString 'hex', start, end
  _decodeBuffer2: (buf, start, end)->
    len = buf.length
    start = 0 if !start or start < 0
    end = len if !end or end < 0 or end > len
    result = ""
    while start < end
      result += @byteToHex(buf[start])
      start++
    result
  byteLength: (data)-> data.length >> 1

# Encode String or Array to Binary(Byte)
class BinaryCodec
  register BinaryCodec, Codec

  arraySlice = Array.prototype.slice

  toArray: (data)->arraySlice.call(data)
  byteLength: (data)->
    if isBuffer data 
      data.length
    else if isString data
      Codec.getByteLen data
    else
      arr = arraySlice.call(data)
      arr.length
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
          destBuffer.write(data, offset, encoding)
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
    if data? and start? and end and data.slice
      data.slice(start, end)
    else
      data

