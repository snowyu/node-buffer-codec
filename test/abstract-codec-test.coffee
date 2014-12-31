chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
Codec           = require '../src/abstract-codec'
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
    testCodecInstance = (myCodec, expectedClass, bufSize)->
      should.exist myCodec
      myCodec.should.be.instanceOf expectedClass
      myCodec.should.be.instanceOf Codec
      if bufSize > 0
        myCodec.bufferSize.should.be.equal bufSize
        Buffer.isBuffer(myCodec.buffer).should.be.ok "should has Buffer"
        myCodec.buffer.should.has.length.at.least bufSize
    getClass = (aName, expectedClass, bufSize)->
      MyCodec = Codec[aName.toLowerCase()]
      should.exist MyCodec
      MyCodec.should.be.equal expectedClass
      myCodec = MyCodec(bufSize)
      testCodecInstance myCodec, expectedClass, bufSize
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
          MyCodec = getClass 'MyNew', MyNewCodec
          MyCodec.should.have.property 'mynewsub', MyNewSubCodec
        it "should register a new Codec Class with parent Codec Class and specified buffSize.", ->
          class MyBufferSubCodec
            register(MyBufferSubCodec, MyBufferCodec, 32).should.be.ok

            constructor: -> return super

          myCodec = Codec('MyBufferSub')
          should.exist myCodec
          myCodec.should.be.instanceOf MyBufferSubCodec
          myCodec.should.be.instanceOf MyBufferCodec
          myCodec.should.be.instanceOf Codec
          myCodec.bufferSize.should.be.equal 32
      describe ".constructor", ->
        it "should get a global codec object instance", ->
          MyCodec = getClass('MyNew', MyNewCodec)
        it "should get a global codec object instance with specified bufferSize", ->
          myCodec = Codec('MyNew', 123)
          testCodecInstance(myCodec, MyNewCodec, 123)
          myCodec.should.be.equal MyNewCodec()
        it "should get a global codec object instance with specified bufferSize(encodeBuffer)", ->
          myCodec = Codec('MyBuffer', 33)
          testCodecInstance(myCodec, MyBufferCodec, 33)
          myCodec.should.be.equal MyBufferCodec()
        it "should get a global codec object instance with specified bufferSize From the CodecClass", ->
          MyCodec = getClass('MyBuffer', MyBufferCodec, 16)
        it "should create a new codec object instance", ->
          MyCodec = getClass('MyNew', MyNewCodec)
          should.exist MyCodec
          myCodec = new MyCodec()
          testCodecInstance myCodec, MyNewCodec
          myCodec.should.be.not.equal Codec("myNew")
        it "should create a new codec object instance with specified bufferSize", ->
          MyCodec = getClass('MyBuffer', MyBufferCodec, 12)
          myCodec = new MyCodec(13)
          testCodecInstance myCodec, MyBufferCodec, 13
          myCodec.should.be.not.equal Codec("MyBuffer")


