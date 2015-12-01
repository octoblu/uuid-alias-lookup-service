_ = require 'lodash'
mongojs = require 'mongojs'
Datastore = require 'meshblu-core-datastore'
http = require 'http'

class AliasService
  constructor: ({mongoDbUri}) ->
    @datastore = new Datastore
      database: mongojs mongoDbUri
      collection: 'aliases'

  find: ({name}, callback) =>
    @datastore.findOne {name}, (error, alias) =>
      return callback @userError 404, http.STATUS_CODES[404] if _.isEmpty alias
      return callback error if error?
      callback null, alias

  findByUuid: ({uuid}, callback) =>
    @datastore.findOne {uuid}, (error, alias) =>
      return callback @userError 404, http.STATUS_CODES[404] if _.isEmpty alias
      return callback error if error?
      callback null, alias

  userError: (status, message) =>
    error = new Error message
    error.status = status
    error

module.exports = AliasService
