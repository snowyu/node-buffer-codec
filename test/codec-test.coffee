chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
Codec           = require '../src/codec'
setImmediate    = setImmediate || process.nextTick

chai.use(sinonChai)

describe "TextCodec", ->
  codec = Codec('text')
  
  toBuffer= (value)->
    len = codec.encodeBuffer value
    buf = new Buffer(len)
    codec.encodeBuffer(value, buf).should.be.equal len
    buf.toString().should.be.equal String(value)
    buf
  describe ".encodeString", ->
    it "should encode value to a string", ->
      data = [1,2,3]
      str = codec.encodeString data
      str.should.be.equal String(data)
    it "should encode buffer as buffer", ->
      data = new Buffer('234')
      result = codec.encodeString data
      result.should.be.equal data
  describe ".decodeString", ->
    it "should decode a string", ->
      expected = 'hi,world'
      str = String expected
      codec.decodeString(str).should.be.deep.equal expected
    it "should decode a buffer as buffer", ->
      expected = new Buffer('ho wool')
      result = codec.decodeString(expected) 
      result.should.be.equal expected
  describe ".encodeBuffer", ->
    it "should encode value to buffer", ->
      data = [1,2,3]
      buf = new Buffer(4096)
      len = codec.encodeBuffer data, buf
      buf.toString(undefined, 0, len).should.be.equal String(data)
    it "should encode buffer as buffer", ->
      data = new Buffer [1,2,3]
      buf = new Buffer(4096)
      len = codec.encodeBuffer data, buf
      buf.toString(undefined, 0, len).should.be.equal data.toString()
  describe ".decodeBuffer", ->
    it "should decode a buffer", ->
      expected = 'ok,hi!'
      buf = toBuffer expected
      codec.decodeBuffer(buf).should.be.equal expected
  describe ".encode", ->
    it "should encode value to a string", ->
      data = [1,2,3]
      str = codec.encode data
      str.should.be.equal String(data)
    it "should encode value to a specified buffer", ->
      data = "some thing need encode"
      # get the byte length of encoded data
      len = codec.encode data, {buffer: -1}
      len.should.be.a "number"
      len.should.be.greaterThan 0
      result = new Buffer(len)
      codec.encode data, {buffer: result}
      result.toString().should.be.equal data
    it "should encode value to the buffer", ->
      data = "some thing need encode"
      result = codec.encode data, {buffer: true}
      result.toString().should.be.equal data
  describe ".decode", ->
    it "should decode a buffer", ->
      expected = 'ok,hi!'
      buf = toBuffer expected
      codec.decode(buf).should.be.equal expected
    it "should decode a atring", ->
      expected = 'ok,hi!'
      codec.decode(expected).should.be.equal expected
  
  

describe "JsonCodec", ->
  json = Codec('json')
  
  jsonToBuffer= (value)->
    len = json.encodeBuffer value
    buf = new Buffer(len)
    json.encodeBuffer(value, buf).should.be.equal len
    buf.toString().should.be.equal JSON.stringify(value)
    buf
  describe ".encodeString", ->
    it "should encode value to a string", ->
      data = {a: 1, b:2, cKey:"hi world C", arr:[1,2,"as"]}
      str = json.encodeString data
      str.should.be.equal JSON.stringify(data)
  describe ".decodeString", ->
    it "should decode a string", ->
      expected = {a: 1, b:2, cKey:"hi world C", arr:[1,2,"as"]}
      str = JSON.stringify expected
      json.decodeString(str).should.be.deep.equal expected
  describe ".encodeBuffer", ->
    it "should encode value to buffer", ->
      data = {a: 1, b:2, cKey:"hi world C", arr:[1,2,"as"]}
      buf = new Buffer(4096)
      len = json.encodeBuffer data, buf
      buf.toString(undefined, 0, len).should.be.equal JSON.stringify(data)
  describe ".decodeBuffer", ->
    it "should decode a buffer", ->
      expected = {a: 1, b:2, cKey:"hi world C", arr:[1,2,"as"]}
      buf = jsonToBuffer expected
      json.decodeBuffer(buf).should.be.deep.equal expected
  describe ".encode", ->
    it "should encode value to a string", ->
      data = [1,2,3]
      str = json.encode data
      str.should.be.equal JSON.stringify(data)
    it "should encode value to a specified buffer", ->
      data = {data:"some thing need encode", int:23}
      # get the byte length of encoded data
      len = json.encode data, {buffer: -1}
      len.should.be.a "number"
      len.should.be.greaterThan 0
      result = new Buffer(len)
      json.encode data, {buffer: result}
      result.toString().should.be.equal JSON.stringify(data)
    it "should encode value to the buffer", ->
      expected = {a: 1, b:2, cKey:"hi world C", arr:[1,2,"as"]}
      result = json.encode expected, {buffer: true}
      result.toString().should.be.equal JSON.stringify(expected)
  describe ".decode", ->
    it "should decode a buffer", ->
      expected = {a: 1, b:2, cKey:"hi world C", arr:[1,2,"as"]}
      buf = jsonToBuffer expected
      json.decode(buf).should.be.deep.equal expected
    it "should decode a atring", ->
      expected = "ok,hi!"
      json.decode(JSON.stringify(expected)).should.be.deep.equal expected

describe "HexCodec", ->
  codec = Codec('hex')
  
  toHex = (str)->
    i = 0
    result = ""
    while i < str.length >> 1
      byte = parseInt(str.substr(i*2, 2), 16)
      result += String.fromCharCode(byte)
      i++
    result

  toBuffer= (value)->
    len = codec.byteLength value
    buf = new Buffer(len)
    codec.encodeBuffer(value, buf).should.be.equal len
    buf.toString('hex').should.be.equal value
    buf
  describe ".encodeString", ->
    it "should encode value to a string", ->
      data = "0102ff0305"
      str = codec.encodeString data
      str.should.be.equal "\x01\x02\xff\x03\x05"
  describe ".decodeString", ->
    it "should decode a string", ->
      expected = "0102ff0305"
      str = "\x01\x02\xff\x03\x05"
      codec.decodeString(str).should.be.equal expected
  describe ".encodeBuffer", ->
    it "should encode value to buffer", ->
      data = "0102ff0305"
      buf = new Buffer(4096)
      len = codec.encodeBuffer data, buf
      buf.toString('hex', 0, len).should.be.equal data
  describe ".decodeBuffer", ->
    it "should decode a buffer", ->
      expected = "0102ff0305"
      buf = toBuffer expected
      codec.decodeBuffer(buf).should.be.equal expected
  describe ".encode", ->
    it "should encode value to a string", ->
      data = "0102ff0305"
      str = codec.encode data
      str.should.be.equal "\x01\x02\xff\x03\x05"
    it "should encode value to a specified buffer", ->
      data = "0102ff0305"
      # get the byte length of encoded data
      len = codec.encode data, {buffer: -1}
      len.should.be.a "number"
      len.should.be.greaterThan 0
      result = new Buffer(len)
      codec.encode data, {buffer: result}
      result.toString('hex').should.be.equal data
    it "should encode value to the buffer", ->
      expected = "0102ff0305"
      result = codec.encode expected, {buffer: true}
      result.toString('hex').should.be.equal expected
  describe ".decode", ->
    it "should decode a buffer", ->
      expected = "0102ff0305"
      buf = toBuffer expected
      codec.decode(buf).should.be.equal expected
    it "should decode a atring", ->
      expected = "0102ff0305"
      codec.decode(toHex(expected)).should.be.equal expected

describe "BinaryCodec", ->
  codec = Codec('binary', 4096)
  it "default bufferSize should be >= 4096", ->
    Codec('binary').bufferSize.should.be.gte 4096
  
  toBuffer= (value)->
    len = codec.encodeBuffer value
    buf = new Buffer(len)
    codec.encodeBuffer(value, buf).should.be.equal len
    buf.toString().should.be.equal value
    buf
  describe ".encodeString", ->
    it "should encode string to a string", ->
      data = "string A"
      str = codec.encodeString data
      str.should.be.equal data
    it "should encode string with hex encoding", ->
      data = "string A"
      str = codec.encodeString data, 'hex'
      str.should.be.equal '737472696e672041'
    it "should encode array to a string", ->
      data = [1,2,3]
      str = codec.encodeString data
      str.should.be.equal "\x01\x02\x03"
    it "should encode buffer to a string", ->
      data = new Buffer [1,2,3]
      str = codec.encodeString data
      str.should.be.equal "\x01\x02\x03"
  describe ".decodeString", ->
    it "should decode a string", ->
      expected = 'hi,world'
      str = 'hi,world'
      codec.decodeString(str).toString().should.be.equal expected
  describe ".encodeBuffer", ->
    it "should encode array to buffer", ->
      data = [1,2,3]
      buf = new Buffer(4096)
      len = codec.encodeBuffer data, buf
      buf.slice(0, len).toString().should.be.equal "\x01\x02\x03"
    it "should encode string to buffer", ->
      data = "string a world"
      buf = new Buffer(4096)
      len = codec.encodeBuffer data, buf
      buf.slice(0, len).toString().should.be.equal data
    it "should encode hex string to buffer", ->
      data = "01020304"
      buf = new Buffer(4096)
      len = codec.encodeBuffer data, buf, 'hex'
      buf.slice(0, len).toString().should.be.equal '\x01\x02\x03\x04'
  describe ".decodeBuffer", ->
    it "should decode a buffer", ->
      expected = 'ok,hi!'
      buf = toBuffer expected
      codec.decodeBuffer(buf).toString().should.be.equal expected
  describe ".encode", ->
    it "should encode array to a string", ->
      data = [1,2,3]
      str = codec.encode data
      str.should.be.equal "\x01\x02\x03"
    it "should encode buffer to a string", ->
      data = new Buffer [1,2,3]
      str = codec.encode data
      str.should.be.equal "\x01\x02\x03"
    it "should encode string with hex encoding", ->
      data = "string A"
      str = codec.encode data, bufferEncoding:'hex'
      str.should.be.equal '737472696e672041'
    it "should encode value to a specified buffer", ->
      data = "some thing need encode"
      # get the byte length of encoded data
      len = codec.encode data, {buffer: -1}
      len.should.be.a "number"
      len.should.be.greaterThan 0
      result = new Buffer(len)
      codec.encode data, {buffer: result}
      result.toString().should.be.equal data
    it "should encode value to the buffer", ->
      data = "some thing need encode"
      result = codec.encode data, {buffer: true}
      result.toString().should.be.equal data
  describe ".decode", ->
    it "should decode a buffer", ->
      expected = 'ok,hi!'
      buf = toBuffer expected
      codec.decode(buf).toString().should.be.equal expected
    it "should decode a atring", ->
      expected = 'ok,hi!'
      codec.decode(expected).toString().should.be.equal expected
  
