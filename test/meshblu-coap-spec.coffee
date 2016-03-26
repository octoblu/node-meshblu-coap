{EventEmitter2} = require 'eventemitter2'
coap = require 'coap'
MeshbluCoap = require '../index'

describe 'MeshbluCoap', ->
  beforeEach ->
    @req = new EventEmitter2
    @req.end = sinon.stub()
    @req.end.returns()
    @request = sinon.stub().returns @req
    @streamResponse = new EventEmitter2

  context 'when unauthenticated', ->
    beforeEach ->
      @sut = new MeshbluCoap {}, {@request}

    describe '-> register', ->
      beforeEach (done) ->
        response =
          code: '2.01'
          payload: JSON.stringify uuid: 'new-uuid', type: 'coap-test'

        @req.end = sinon.spy =>
          @req.emit 'response', response

        @sut.register type: 'coap-test', (error, @device) =>
          done error

      it 'should call request', ->
        expect(@request).to.have.been.calledWith
          hostname: "meshblu-coap.octoblu.com"
          method: "POST"
          options: { 98: new Buffer(''), 99: new Buffer(''), 'Content-Type': "application/json" }
          pathname: "/devices"
          port: 5683
        expect(@req.end).to.have.been.calledWith JSON.stringify type: 'coap-test'

      it 'should get a device', ->
        expect(@device).to.deep.equal uuid: 'new-uuid', type: 'coap-test'

    describe '-> status', ->
      beforeEach (done) ->
        response =
          code: '2.05'
          payload: JSON.stringify meshblu: 'online'

        @req.end = =>
          @req.emit 'response', response

        @sut.status (error, @response) =>
          done error

      it 'should get a response', ->
        expect(@response).to.deep.equal meshblu: 'online'

      it 'should call request', ->
        expect(@request).to.have.been.calledWith
          hostname: "meshblu-coap.octoblu.com"
          method: "GET"
          options: { 98: new Buffer(''), 99: new Buffer(''), 'Content-Type': "application/json" }
          pathname: "/status"
          port: 5683

  context 'when authenticated', ->
    beforeEach ->
      @sut = new MeshbluCoap uuid: 'a-uuid', token: 'a-token', {@request}

    describe '-> device', ->
      beforeEach (done) ->
        response =
          code: '2.05'
          payload: JSON.stringify uuid: 'a-uuid'

        @req.end = =>
          @req.emit 'response', response

        @sut.device 'a-uuid', (error, @response) =>
          done error

      it 'should get a response', ->
        expect(@response).to.deep.equal uuid: 'a-uuid'

      it 'should call request', ->
        expect(@request).to.have.been.calledWith
          hostname: "meshblu-coap.octoblu.com"
          method: "GET"
          options: { 98: new Buffer('a-uuid'), 99: new Buffer('a-token'), 'Content-Type': "application/json" }
          pathname: "/devices/a-uuid"
          port: 5683

    describe '-> devicePublicKey', ->
      beforeEach (done) ->
        response =
          code: '2.05'
          payload: JSON.stringify publicKey: 'a-uuid'

        @req.end = =>
          @req.emit 'response', response

        @sut.devicePublicKey 'a-uuid', (error, @response) =>
          done error

      it 'should get a response', ->
        expect(@response).to.deep.equal publicKey: 'a-uuid'

      it 'should call request', ->
        expect(@request).to.have.been.calledWith
          hostname: "meshblu-coap.octoblu.com"
          method: "GET"
          options: { 98: new Buffer('a-uuid'), 99: new Buffer('a-token'), 'Content-Type': "application/json" }
          pathname: "/devices/a-uuid/publickey"
          port: 5683

    describe '-> devices', ->
      beforeEach (done) ->
        response =
          code: '2.05'
          payload: JSON.stringify [uuid: 'a-uuid']

        @req.end = =>
          @req.emit 'response', response

        @sut.devices foo: 'bar', (error, @response) =>
          done error

      it 'should get a response', ->
        expect(@response).to.deep.equal [uuid: 'a-uuid']

      it 'should call request', ->
        expect(@request).to.have.been.calledWith
          hostname: "meshblu-coap.octoblu.com"
          method: "GET"
          options: { 98: new Buffer('a-uuid'), 99: new Buffer('a-token'), 'Content-Type': "application/json" }
          pathname: "/devices?foo=bar"
          port: 5683

    describe '-> message', ->
      beforeEach (done) ->
        response =
          code: '2.01'
          payload: JSON.stringify [uuid: 'a-uuid']

        @req.end = sinon.spy =>
          @req.emit 'response', response

        @sut.message devices: ['*'], foo: 'bar', (error, @response) =>
          done error

      it 'should get a response', ->
        expect(@response).to.deep.equal [uuid: 'a-uuid']

      it 'should call request', ->
        expect(@request).to.have.been.calledWith
          hostname: "meshblu-coap.octoblu.com"
          method: "POST"
          options: { 98: new Buffer('a-uuid'), 99: new Buffer('a-token'), 'Content-Type': "application/json" }
          pathname: "/messages"
          port: 5683
        expect(@req.end).to.have.been.calledWith JSON.stringify devices: ['*'], foo: 'bar'

    describe '-> mydevices', ->
      beforeEach (done) ->
        response =
          code: '2.05'
          payload: JSON.stringify [uuid: 'a-uuid']

        @req.end = =>
          @req.emit 'response', response

        @sut.mydevices (error, @response) =>
          done error

      it 'should get a response', ->
        expect(@response).to.deep.equal [uuid: 'a-uuid']

      it 'should call request', ->
        expect(@request).to.have.been.calledWith
          hostname: "meshblu-coap.octoblu.com"
          method: "GET"
          options: { 98: new Buffer('a-uuid'), 99: new Buffer('a-token'), 'Content-Type': "application/json" }
          pathname: "/mydevices"
          port: 5683

    describe '-> update', ->
      beforeEach (done) ->
        response =
          code: '2.04'
          payload: JSON.stringify uuid: 'a-uuid'

        @req.end = sinon.spy =>
          @req.emit 'response', response

        @sut.update 'a-uuid', foo: 'bar', (error, @response) =>
          done error

      it 'should get a response', ->
        expect(@response).to.deep.equal uuid: 'a-uuid'

      it 'should call request', ->
        expect(@request).to.have.been.calledWith
          hostname: "meshblu-coap.octoblu.com"
          method: "PUT"
          options: { 98: new Buffer('a-uuid'), 99: new Buffer('a-token'), 'Content-Type': "application/json" }
          pathname: "/devices/a-uuid"
          port: 5683
        expect(@req.end).to.have.been.calledWith JSON.stringify foo: 'bar'

    describe '-> whoami', ->
      beforeEach (done) ->
        response =
          code: '2.05'
          payload: JSON.stringify uuid: 'a-uuid'

        @req.end = =>
          @req.emit 'response', response

        @sut.whoami (error, @response) =>
          done error

      it 'should get a response', ->
        expect(@response).to.deep.equal uuid: 'a-uuid'

      it 'should call request', ->
        expect(@request).to.have.been.calledWith
          hostname: "meshblu-coap.octoblu.com"
          method: "GET"
          options: { 98: new Buffer('a-uuid'), 99: new Buffer('a-token'), 'Content-Type': "application/json" }
          pathname: "/whoami"
          port: 5683

    describe '-> unregister', ->
      beforeEach (done) ->
        response =
          code: '2.02'
          payload: JSON.stringify uuid: 'a-uuid'

        @req.end = =>
          @req.emit 'response', response

        @sut.unregister 'a-uuid', (error, @response) =>
          done error

      it 'should get a response', ->
        expect(@response).to.deep.equal uuid: 'a-uuid'

      it 'should call request', ->
        expect(@request).to.have.been.calledWith
          hostname: "meshblu-coap.octoblu.com"
          method: "DELETE"
          options: { 98: new Buffer('a-uuid'), 99: new Buffer('a-token'), 'Content-Type': "application/json" }
          pathname: "/devices/a-uuid"
          port: 5683

    describe '-> subscribe', ->
      beforeEach (done) ->
        response =
          code: '2.05'
          payload: JSON.stringify uuid: 'a-uuid'

        setTimeout =>
          @req.emit 'response', @streamResponse
          setTimeout =>
            @streamResponse.emit 'data', devices: ['*']
          , 50
        , 50

        @sut.subscribe uuid: 'a-uuid', (error, @response) =>
          return done error if error?
          @response.on 'data', (@message) =>
            done()

      it 'should get a message', ->
        expect(@message).to.deep.equal devices: ['*']

      it 'should call request', ->
        expect(@request).to.have.been.calledWith
          hostname: 'meshblu-coap.octoblu.com'
          method: 'GET'
          observe: true
          options: { 98: new Buffer('a-uuid'), 99: new Buffer('a-token'), 'Content-Type': 'application/json' }
          pathname: '/subscribe?uuid=a-uuid'
          port: 5683
