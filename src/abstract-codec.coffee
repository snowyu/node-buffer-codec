# Copyright (c) 2014 Riceball LEE, MIT License
util                  = require("abstract-object/lib/util")
inherits              = util.inherits
isInheritedFrom       = util.isInheritedFrom
isNumber              = util.isNumber
isString              = util.isString
createObject          = util.createObject
Errors                = require('abstract-object/Error')
createError           = Errors.createError
AbstractError         = Errors.AbstractError
NotImplementedError   = Errors.NotImplementedError
InvalidArgumentError  = Errors.InvalidArgumentError
InvalidFormatError    = Errors.InvalidFormatError
InvalidUtf8Error      = createError("InvalidUtf8", 0x81, InvalidFormatError)
isBuffer              = Buffer.isBuffer

Errors.InvalidUtf8Error = InvalidUtf8Error

module.exports = class Codec
  UNSAFE_CHARS = '%'

  @bufferSize: 1024
  @getBuffer: (aBufferSize) ->
    if not Codec.buffer or Codec.buffer.length < aBufferSize
      aBufferSize ||= Codec.bufferSize
      Codec.buffer = new Buffer(aBufferSize)
      Codec.bufferSize = aBufferSize
      
    Codec.buffer
  @_codecs: {}
  @_aliases: {}
  codecs = Codec._codecs
  aliases = Codec._aliases
  constructor: (aCodecName, aBufferSize)->
    if isNumber aCodecName
      aBufferSize = aCodecName
      aCodecName = null
    else if aCodecName instanceof Codec
      aCodecName.init(aBufferSize) if aBufferSize > 0
      return aCodecName
    if not (this instanceof Codec)
      # arguments.callee is forbidden if strict mode enabled.
      if not aCodecName
        try aCodecName = Codec.getNameFromClass(arguments.callee.caller)
      aCodecName = aCodecName.toLowerCase()
      result = codecs[aCodecName]
      if not result?
        alias = aCodecName
        aCodecName = Codec.getRealNameFromAlias alias
        if aCodecName
          result = codecs[aCodecName]
      if result instanceof Codec
        result.init(aBufferSize) if aBufferSize > 0
      else if result
        result = Math.max result, aBufferSize if aBufferSize > 0
        result = undefined if result < 0 or result is NaN
        result = codecs[aCodecName] = createObject Codec[aCodecName], result
      return result
    else
      @init(aBufferSize)
  init: (aBufferSize)->
    if @_encodeBuffer or aBufferSize > 0
      aBufferSize ||= Codec.bufferSize
      if not @buffer or aBufferSize > @buffer.length
        @buffer = new Buffer(aBufferSize)
      @bufferSize = aBufferSize
    @buffer
  isBuffer: ()->
    @buffer?
  byteLength: (value)->
    if @_encodeBuffer
      @encodeBuffer value
    else if @_encodeString
      @_encodeString(value).length
    else
      throw new NotImplementedError()
  encodeString: (value)->
    if @_encodeString
      @_encodeString value
    else if @_encodeBuffer
      len = @_encodeBuffer(value, @buffer)
      @buffer.toString(@bufferEncoding, 0, len)
    else
      throw new NotImplementedError()
  decodeString: (str)->
    if @_decodeString
      @_decodeString str
    else if @_decodeBuffer
      len = @buffer.write str
      @decodeBuffer(@buffer, 0, len)
    else
      throw new NotImplementedError()
  encodeBuffer: (value, destBuffer, offset=0, encoding='utf8')->
    if @_encodeBuffer
      @_encodeBuffer value, destBuffer, offset, encoding
    else if @_encodeString
      result = @_encodeString(value)
      resultIsBuffer = isBuffer result
      if isBuffer destBuffer
        if resultIsBuffer
          len = Math.min result.length, destBuffer.length - offset
          result.copy destBuffer, offset, 0, len
          len
        else
          destBuffer.write(result, offset, undefined, encoding)
      else if resultIsBuffer
        result.length
      else
        Codec.getByteLen result
    else
      throw new NotImplementedError()
  decodeBuffer: (buffer, start=0, end, encoding='utf8')->
    if @_decodeBuffer
      @_decodeBuffer buffer, start, end, encoding
    else if @_decodeString
      @_decodeString buffer.toString(encoding, start, end)
    else
      throw new NotImplementedError()
  ensureEncodeBuffer: (buffer, encoding='utf8') ->
    len = @encodeBuffer buffer, null, 0, encoding
    destBuffer = @init(len)
    len = @encodeBuffer buffer, destBuffer, 0, encoding
    destBuffer.slice(0, len)
  encode: (value, options)->
    options ||= {}
    @options = options
    if options.buffer
      if options.buffer is true
        result = @ensureEncodeBuffer value, options.bufferEncoding
      else
        result = @encodeBuffer value, options.buffer, options.bufferOffset, options.bufferEncoding
    else
      result = @encodeString value
    delete @options
    result
  decode: (value, options)->
    options ||= {}
    @options = options
    if isBuffer value
      result = @decodeBuffer value, options.bufferStart, options.bufferEnd, options.bufferEncoding
    else
      result = @decodeString value
    delete @options
    result
  @encode: (value, options)->
    return value unless options and options.encoding
    encoding = options.encoding
    if encoding not instanceof Codec
      encoding = Codec(encoding)
      return value unless encoding
    encoding.encode(value, options)
  @decode: (value, options)->
    return value unless options and options.encoding
    encoding = options.encoding
    if encoding not instanceof Codec
      encoding = Codec(encoding)
      return value unless encoding
    encoding.decode value, options
  @getNameFromClass: (aCodecClass)->
    codecName = aCodecClass.name
    len = codecName.length
    throw new InvalidArgumentError('the codec(construcor) has no name error.') unless len
    codecName = codecName.substring(0, len-5) if len > 5 and codecName.substring(len-5).toLowerCase() is 'codec'
    codecName
  @getRealNameFromAlias: (alias)->
    aliases[alias]
  @alias: (aCodecClass, aAliases...)->
    codecName = Codec.getNameFromClass(aCodecClass)
    lowerName = codecName.toLowerCase()
    if codecs.hasOwnProperty(lowerName)
      for alias in aAliases
        aliases[alias] = lowerName
  @aliases: @alias
  @register: (aCodecClass, aParentCodecClass = Codec, aBufferSize)->
    inherits aCodecClass, aParentCodecClass
    codecName = Codec.getNameFromClass(aCodecClass)
    aCodecClass::name = codecName
    lowerName = codecName.toLowerCase()
    if isInheritedFrom(aCodecClass, Codec) and not codecs.hasOwnProperty(lowerName)
      aParentCodecClass[lowerName] = aCodecClass
      if aParentCodecClass isnt Codec
        Codec[lowerName] = aCodecClass
      if aBufferSize > 0
        codecs[lowerName] = aBufferSize
      else
        codecs[lowerName] = -1 #createObject aCodecClass, aBufferSize
    else
      false
  @unregister: (aCodecName)->
    delete codecs[aCodecName.toLowerCase()]
  @escapeString = escapeString = (aString, aUnSafeChars) ->
    return aString if !isString(aString) or aString.length == 0
    aUnSafeChars = UNSAFE_CHARS unless aUnSafeChars?
    result = ""
    for c in aString
      result += if aUnSafeChars.indexOf(c) >= 0
        "%" + aString.charCodeAt(_i).toString(16)
      else
        c
    result
  @unescapeString = unescapeString = decodeURIComponent
  ###
   * Count bytes in a string's UTF-8 representation.
   *
   * @param   string
   * @return  int
   *
  ###
  @getByteLen: (str) ->
    # Force string type
    str = String(str)

    result = 0
    for _,i in str
        c = str.charCodeAt(i)
        result += if c < (1 <<  7) then 1
        else if c < (1 << 11) then 2
        else if c < (1 << 16) then 3
        else if c < (1 << 21) then 4
        else if c < (1 << 26) then 5
        else if c < (1 << 31) then 6 
        else Number.NaN
    return result
  # Refer: https://github.com/feross/buffer
  #convert bytes to utf8 string
  @utf8Slice: (buf, start, end) ->
    result = ''
    tmp = ''
    end = Math.min(buf.length, end)

    for i in [start...end] # start<= i < end
      if buf[i] <= 0x7F
        result += decodeURIComponent(tmp) + String.fromCharCode(buf[i])
        tmp = ''
      else
        tmp += '%' + buf[i].toString(16)
    return result + decodeURIComponent(tmp)
  @utf8ToBytes: (string, units)->
    length = string.length
    leadSurrogate = null
    units = units || Infinity
    bytes = []

    for _, i in string
      codePoint = string.charCodeAt(i)

      # is surrogate component
      if codePoint > 0xD7FF && codePoint < 0xE000

        # last char was a lead
        if (leadSurrogate)

          # 2 leads in a row
          if (codePoint < 0xDC00)
            if ((units -= 3) > -1) then bytes.push(0xEF, 0xBF, 0xBD)
            leadSurrogate = codePoint
            continue

          # valid surrogate pair
          else
            codePoint = leadSurrogate - 0xD800 << 10 | codePoint - 0xDC00 | 0x10000
            leadSurrogate = null

        # no lead yet
        else
          # unexpected trail
          if (codePoint > 0xDBFF)
            if ((units -= 3) > -1) then bytes.push(0xEF, 0xBF, 0xBD)
            continue
          # unpaired lead
          else if (i + 1 == length)
            if ((units -= 3) > -1) then bytes.push(0xEF, 0xBF, 0xBD)
            continue

          # valid lead
          else
            leadSurrogate = codePoint
            continue

      # valid bmp char, but last char was a lead
      else if (leadSurrogate)
        if ((units -= 3) > -1) then bytes.push(0xEF, 0xBF, 0xBD)
        leadSurrogate = null

      # encode utf8
      if (codePoint < 0x80)
        if ((units -= 1) < 0) then break
        bytes.push(codePoint)
      else if (codePoint < 0x800)
        if ((units -= 2) < 0) then break
        bytes.push(
          codePoint >> 0x6 | 0xC0,
          codePoint & 0x3F | 0x80
        )
      else if (codePoint < 0x10000)
        if ((units -= 3) < 0) then break
        bytes.push(
          codePoint >> 0xC | 0xE0,
          codePoint >> 0x6 & 0x3F | 0x80,
          codePoint & 0x3F | 0x80
        )
      else if (codePoint < 0x200000)
        if ((units -= 4) < 0) then break
        bytes.push(
          codePoint >> 0x12 | 0xF0,
          codePoint >> 0xC & 0x3F | 0x80,
          codePoint >> 0x6 & 0x3F | 0x80,
          codePoint & 0x3F | 0x80
        )
      else
        throw new InvalidUtf8Error('utf8:Invalid code point')
    return bytes


