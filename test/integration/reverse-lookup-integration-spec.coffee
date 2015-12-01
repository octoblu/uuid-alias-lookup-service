http    = require 'http'
request = require 'request'
shmock  = require 'shmock'
Server  = require '../../src/server'
mongojs = require 'mongojs'
Datastore = require 'meshblu-core-datastore'
iri = require 'iri'

describe 'GET /aliases/7bbf551d-e067-48e6-941d-d70f19e4e28b', ->
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
        alias =
          name: 'poor-trunk-ventilation'
          uuid: '7bbf551d-e067-48e6-941d-d70f19e4e28b'
          owner: '899801b3-e877-4c69-93db-89bd9787ceea'
          subaliases: [
            name: 'heat.death.of.the.universe'
            uuid: 'd52d2353-e85e-42f4-9652-2ca68b938098'
          ]
        @datastore.insert alias, (error, @alias) =>
          done error

      beforeEach (done) ->
        options =
          json: true

        request.get "http://localhost:#{@serverPort}/aliases/7bbf551d-e067-48e6-941d-d70f19e4e28b", options, (error, @response, @body) =>
          done error

      it 'should respond with 200', ->
        expect(@response.statusCode).to.equal 200

      it 'return an alias', ->
        expect(@body).to.deep.equal ['poor-trunk-ventilation.heat.death.of.the.universe','poor-trunk-ventilation']

  context 'when the alias does not exist', ->
    beforeEach (done) ->
      options =
        json: true

      request.get "http://localhost:#{@serverPort}/aliases/76ccfb20-79ce-49dd-97ca-6cb0236d4b9b", options, (error, @response, @body) =>
        done error

    it 'should respond with 404', ->
      expect(@response.statusCode).to.equal 404

    it 'should not return an alias', ->
      expect(@body).to.be.undefined
