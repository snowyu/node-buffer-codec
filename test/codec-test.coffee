chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
Codec           = require '../src/codec'
Errors          = require 'abstract-object/Error'
util            = require 'abstract-object/util'
inherits        = util.inherits
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
      str = codec.encode data
      str.should.be.equal String(data)
    it "should encode buffer as buffer", ->
      data = new Buffer('234')
      result = codec.encode data
      result.should.be.equal data
  describe ".decodeString", ->
    it "should decode a string", ->
      expected = 'hi,world'
      str = String expected
      codec.decode(str).should.be.deep.equal expected
    it "should decode a buffer as buffer", ->
      expected = new Buffer('ho wool')
      result = codec.decode(expected) 
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
        str = json.encode data
        str.should.be.equal JSON.stringify(data)
    describe ".decodeString", ->
      it "should decode a string", ->
        expected = {a: 1, b:2, cKey:"hi world C", arr:[1,2,"as"]}
        str = JSON.stringify expected
        json.decode(str).should.be.deep.equal expected
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
      str = codec.encode data
      str.should.be.equal data
    it "should encode array to a string", ->
      data = [1,2,3]
      str = codec.encode data
      str.should.be.equal "\x01\x02\x03"
  describe ".decodeString", ->
    it "should decode a string", ->
      expected = 'hi,world'
      str = 'hi,world'
      codec.decode(str).toString().should.be.equal expected
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
  describe ".decodeBuffer", ->
    it "should decode a buffer", ->
      expected = 'ok,hi!'
      buf = toBuffer expected
      codec.decodeBuffer(buf).toString().should.be.equal expected
