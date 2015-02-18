chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
Codec           = require '../src/abstract-codec'
setImmediate    = setImmediate || process.nextTick

chai.use(sinonChai)

describe "Codec", ->
    #before (done)->
    #after (done)->
    register  = Codec.register
    aliases   = Codec.aliases

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
        Buffer.isBuffer(myCodec.buffer).should.be.equal true, "should has Buffer"
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
        it "should get an instance via the child Codec class directly.", ->
          MyNewSubCodec = Codec['mynewsub']
          class MyNewSub1Codec
            register(MyNewSub1Codec, MyNewSubCodec).should.be.ok

            constructor: -> return super

          myCodec = Codec('myNewSub1')
          should.exist myCodec
          myCodec.should.be.instanceOf MyNewSub1Codec
          myCodec.should.be.instanceOf MyNewSubCodec
          myCodec.should.be.instanceOf MyNewCodec
          myCodec.should.be.instanceOf Codec
          my = MyNewSub1Codec 123456
          testCodecInstance my, MyNewSub1Codec, 123456
          my.should.be.equal myCodec
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
        it "should bypass the codec object instance", ->
          myCodec = Codec('MyBuffer', 33)
          my = Codec(myCodec)
          my.should.be.equal myCodec
        it "should bypass the codec object instance and expand the bufferSize", ->
          myCodec = Codec('MyBuffer', 33)
          my = Codec(myCodec, 900)
          my.should.be.equal myCodec
          my.bufferSize.should.at.least 900
        it "should return undefined for unkown codec name", ->
          myCodec = Codec('Notfound')
          should.not.exist myCodec
        it "should return undefined for illegal codec name argument", ->
          myCodec = Codec()
          should.not.exist myCodec


      describe ".aliases", ->
        class MyAliasCodec
          register MyAliasCodec, Codec
          aliases  MyAliasCodec, 'alia1', 'other'

          constructor: -> return super

        it "should get a global codec object instance via alias", ->
          myCodec = Codec('alia1')
          testCodecInstance myCodec, MyAliasCodec
          other = Codec('other')
          testCodecInstance myCodec, MyAliasCodec
          other.should.equal myCodec

      class MyCodec
        register MyCodec
        encode: sinon.spy((v)->v+'encode')
        decode: sinon.spy((v)->v+'decode')
        constructor: -> return super
      describe ".encode", ->

        it "should return value directly when no options", ->
          value = [1,25,21,1]
          result = Codec.encode value
          result.should.be.equal value
          
        it "should return value directly when no options.encoding", ->
          value = [1,25,21,1]
          result = Codec.encode value, {}
          result.should.be.equal value
          
        it "should return value directly when options.encoding is illegal.", ->
          value = [1,25,21,1]
          result = Codec.encode value, {encoding: "No Such CodeC"}
          result.should.be.equal value
        it "should get the correct codec to encode.", ->
          value = [1,25,21,1]
          options = {encoding: "my"}
          result = Codec.encode value, options
          my = MyCodec()
          my.encode.should.have.been.calledOnce
          my.encode.should.have.been.calledWith value, options
          my.encode.should.have.returned value+'encode'
          
        
      describe ".decode", ->
        it "should return value directly when no options", ->
          value = [1,25,21,1]
          result = Codec.decode value
          result.should.be.equal value
          
        it "should return value directly when no options.encoding", ->
          value = [1,25,21,1]
          result = Codec.decode value, {}
          result.should.be.equal value
          
        it "should return value directly when options.encoding is illegal.", ->
          value = [1,25,21,1]
          result = Codec.decode value, {encoding: "No Such CodeC"}
          result.should.be.equal value

        it "should get the correct codec to decode.", ->
          value = [1,25,21,1]
          options = {encoding: "my"}
          result = Codec.decode value, options
          my = MyCodec()
          my.decode.should.have.been.calledOnce
          my.decode.should.have.been.calledWith value, options
          my.decode.should.have.returned value+'decode'

      describe ".escapeString", ->
        escapeString = Codec.escapeString
        it 'should escape string with default unSafeChars', ->
            escapeString("你好/世界.属性%动作").should.equal "你好/世界.属性%25动作"
        it 'should escape string with custom unSafeChars', ->
            escapeString("你/好0世界 属性@动作", "0 ").should.equal "你/好%30世界%20属性@动作"
      describe ".unescapeString", ->
        unescapeString = Codec.unescapeString
        it 'should unescape string', ->
            unescapeString("你好%2f世界%2e属性%40动作").should.equal "你好/世界.属性@动作"

