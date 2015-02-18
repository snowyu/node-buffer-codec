chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
Codec           = require '../src/codec'
setImmediate    = setImmediate || process.nextTick

chai.use(sinonChai)

describe "String", ->
  #before (done)->
  #after (done)->

  describe ".fromCharCode/.charCodeAt", ->
    it "should convert from 0x0000 to 0xFFFF.", ->
      for i in [0..0xFFFF]
        c = String.fromCharCode(i)
        c.charCodeAt(0).should.be.equal i

