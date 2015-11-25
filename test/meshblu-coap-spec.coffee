{EventEmitter2} = require 'eventemitter2'
coap = require 'coap'
MeshbluCoap = require '../index'

describe 'MeshbluCoap', ->
  beforeEach ->
    @req = new EventEmitter2
    @req.write = sinon.stub()
    @req.end = sinon.stub()
    @req.write.returns()
    @req.end.returns()
    @request = sinon.stub().returns @req

  context 'when unauthenticated', ->
    beforeEach ->
      @sut = new MeshbluCoap {}, {@request}

    describe '-> register', ->
      beforeEach (done) ->
        response =
          code: '2.01'
          payload: JSON.stringify uuid: 'new-uuid', type: 'coap-test'

        @req.end = =>
          @req.emit 'response', response

        @sut.register type: 'coap-test', (error, @device) =>
          done error

      it 'should call request', ->
        expect(@request).to.have.been.calledWith
          hostname: "coap.octoblu.com"
          method: "POST"
          options: { 98: new Buffer(''), 99: new Buffer(''), 'Content-Type': "application/json" }
          pathname: "/devices"
          port: 5683
        expect(@req.write).to.have.been.calledWith JSON.stringify type: 'coap-test'

      it 'should get a device', ->
        expect(@device).to.deep.equal uuid: 'new-uuid', type: 'coap-test'

    describe '-> status', ->
      beforeEach (done) ->
        response =
          code: '2.05'
          payload: JSON.stringify meshblu: 'online'

        @req.end = =>
          @req.emit 'response', response

        @sut.status (error, @status) =>
          done error

      it 'should get a status', ->
        expect(@status).to.deep.equal meshblu: 'online'

      it 'should call request', ->
        expect(@request).to.have.been.calledWith
          hostname: "coap.octoblu.com"
          method: "GET"
          options: { 98: new Buffer(''), 99: new Buffer(''), 'Content-Type': "application/json" }
          pathname: "/status"
          port: 5683

  context 'when authenticated', ->
    beforeEach ->
      @sut = new MeshbluCoap uuid: 'a-uuid', token: 'a-token', {@request}

    describe '-> whoami', ->
      beforeEach (done) ->
        response =
          code: '2.05'
          payload: JSON.stringify uuid: 'a-uuid'

        @req.end = =>
          @req.emit 'response', response

        @sut.whoami (error, @status) =>
          done error

      it 'should get a status', ->
        expect(@status).to.deep.equal uuid: 'a-uuid'

      it 'should call request', ->
        expect(@request).to.have.been.calledWith
          hostname: "coap.octoblu.com"
          method: "GET"
          options: { 98: new Buffer('a-uuid'), 99: new Buffer('a-token'), 'Content-Type': "application/json" }
          pathname: "/whoami"
          port: 5683

    describe '-> unregister', ->
      beforeEach (done) ->
        response =
          code: '2.05'
          payload: JSON.stringify uuid: 'a-uuid'

        @req.end = =>
          @req.emit 'response', response

        @sut.unregister 'a-uuid', (error, @status) =>
          done error

      it 'should get a status', ->
        expect(@status).to.deep.equal uuid: 'a-uuid'

      it 'should call request', ->
        expect(@request).to.have.been.calledWith
          hostname: "coap.octoblu.com"
          method: "DELETE"
          options: { 98: new Buffer('a-uuid'), 99: new Buffer('a-token'), 'Content-Type': "application/json" }
          pathname: "/devices/a-uuid"
          port: 5683
