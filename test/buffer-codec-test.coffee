chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
Codec           = require '../src/buffer-codec'
Errors          = require 'abstract-object/Error'
util            = require 'abstract-object/util'
inherits        = util.inherits
setImmediate    = setImmediate || process.nextTick

chai.use(sinonChai)

describe "Codec", ->
    #before (done)->
    #after (done)->
    register = Codec.register

    class MyNewCodec
      register(MyNewCodec).should.be.ok

      constructor: -> return super
    class MyBufferCodec
      register(MyBufferCodec).should.be.ok

      constructor: -> return super
      _encodeBuffer: ->
    getClass = (aName, expectedClass)->
      MyCodec = Codec[aName]
      should.exist MyCodec
      MyCodec.should.be.equal expectedClass
      myCodec = MyCodec()
      should.exist myCodec
      myCodec.should.be.instanceOf expectedClass
      myCodec.should.be.instanceOf Codec
      myCodec.should.be.equal Codec(aName)
      MyCodec
    it "should have a default bufferSize property", ->
      Codec.should.have.ownProperty "bufferSize"
      Codec.bufferSize.should.be.a "number"
    describe "Class(Static) Methods", ->
      describe ".register", ->
        it "should register a new Codec Class with default.", ->
          myCodec = Codec('myNew')
          should.exist myCodec
          myCodec.should.be.instanceOf MyNewCodec
          myCodec.should.be.instanceOf Codec
        it "should register a new Codec Class with parent Codec Class.", ->
          class MyNewSubCodec
            register(MyNewSubCodec, MyNewCodec).should.be.ok

            constructor: -> return super

          myCodec = Codec('myNewSub')
          should.exist myCodec
          myCodec.should.be.instanceOf MyNewSubCodec
          myCodec.should.be.instanceOf MyNewCodec
          myCodec.should.be.instanceOf Codec
        it "should register a new Codec Class with parent Codec Class and specified buffSize.", ->
          class MyBufferSubCodec
            register(MyBufferSubCodec, MyBufferCodec, 4120).should.be.ok

            constructor: -> return super

          myCodec = Codec('MyBufferSub')
          should.exist myCodec
          myCodec.should.be.instanceOf MyBufferSubCodec
          myCodec.should.be.instanceOf MyBufferCodec
          myCodec.should.be.instanceOf Codec
          myCodec.bufferSize.should.be.equal 4120
      describe ".constructor", ->
        it "should get a global codec object instance", ->
          MyCodec = getClass('MyNew', MyNewCodec)
        it "should create a new codec object instance", ->
          MyCodec = getClass('MyNew', MyNewCodec)
          should.exist MyCodec
          myCodec = new MyCodec()
          should.exist myCodec
          myCodec.should.be.instanceOf MyNewCodec
          myCodec.should.be.instanceOf Codec
          myCodec.should.be.not.equal Codec("myNew")
        it "should create a new codec object instance with specified bufferSize", ->
          MyCodec = getClass('MyBuffer', MyBufferCodec)
          myCodec = new MyCodec(1234)
          should.exist myCodec
          myCodec.should.be.instanceOf MyBufferCodec
          myCodec.should.be.instanceOf Codec
          myCodec.should.be.not.equal Codec("myBuffer")
          myCodec.bufferSize.should.be.equal 1234
          Buffer.isBuffer(myCodec.buffer).should.be.ok "isBuffer"

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
      buf.toString(null, 0, len).should.be.equal JSON.stringify(data)
  describe ".decodeBuffer", ->
    it "should decode a buffer", ->
      expected = {a: 1, b:2, cKey:"hi world C", arr:[1,2,"as"]}
      buf = jsonToBuffer expected
      json.decodeBuffer(buf).should.be.deep.equal expected
