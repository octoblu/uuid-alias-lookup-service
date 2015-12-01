http    = require 'http'
request = require 'request'
shmock  = require 'shmock'
Server  = require '../../src/server'
mongojs = require 'mongojs'
Datastore = require 'meshblu-core-datastore'
iri = require 'iri'

describe 'GET /?name=poor-trunk-ventilation', ->
  beforeEach (done) ->
    meshbluConfig =
      server: 'localhost'
      port: 0xd00d

    serverOptions =
      port: undefined,
      disableLogging: true
      meshbluConfig: meshbluConfig
      mongoDbUri: 'mongodb://127.0.0.1/test-uuid-alias-lookup-service'

    @server = new Server serverOptions

    @server.run =>
      @serverPort = @server.address().port
      done()

  beforeEach (done) ->
    @datastore = new Datastore
      database: mongojs 'mongodb://127.0.0.1/test-uuid-alias-lookup-service'
      collection: 'aliases'
    @datastore.remove {}, (error) => done() # delete everything

  afterEach (done) ->
    @server.stop => done()

  context 'when the alias exists', ->
    context 'an ascii name', ->
      beforeEach (done) ->
        @datastore.insert name: 'poor-trunk-ventilation', uuid: '21560426-7338-450d-ab10-e477ef1908a6', owner: '899801b3-e877-4c69-93db-89bd9787ceea', (error, @alias) =>
          done error

      beforeEach (done) ->
        options =
          json: true

        request.get "http://localhost:#{@serverPort}/?name=poor-trunk-ventilation", options, (error, @response, @body) =>
          done error

      it 'should respond with 200', ->
        expect(@response.statusCode).to.equal 200

      it 'return an alias', ->
        expect(@body).to.contain name: 'poor-trunk-ventilation', uuid: '21560426-7338-450d-ab10-e477ef1908a6', owner: '899801b3-e877-4c69-93db-89bd9787ceea'

    context 'a unicode name', ->
      beforeEach (done) ->
        @datastore.insert name: '💩', uuid: '4fac613f-fea4-49b6-8c0a-715d15d21120', owner: '899801b3-e877-4c69-93db-89bd9787ceea', (error, @alias) =>
          done error

      beforeEach (done) ->
        options =
          json: true

        path = new iri.IRI "http://localhost:#{@serverPort}/?name=💩"

        request.get path.toURIString(), options, (error, @response, @body) =>
          done error

      it 'should respond with 200', ->
        expect(@response.statusCode).to.equal 200

      it 'return an alias', ->
        expect(@body).to.contain name: '💩', uuid: '4fac613f-fea4-49b6-8c0a-715d15d21120', owner: '899801b3-e877-4c69-93db-89bd9787ceea'

  context 'when the alias does not exist', ->
    beforeEach (done) ->
      options =
        json: true

      request.get "http://localhost:#{@serverPort}/?name=car-over-cliff", options, (error, @response, @body) =>
        done error

    it 'should respond with 404', ->
      expect(@response.statusCode).to.equal 404

    it 'should not return an alias', ->
      expect(@body).to.be.undefined
