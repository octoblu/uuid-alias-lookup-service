_ = require 'lodash'
mongojs = require 'mongojs'
Datastore = require 'meshblu-core-datastore'
http = require 'http'

class ReverseLookupService
  constructor: ({mongoDbUri}) ->
    @datastore = new Datastore
      database: mongojs mongoDbUri
      collection: 'aliases'

  find: ({uuid}, callback) =>
    query =
      '$or': [
        {uuid: uuid}
        {'subaliases.uuid': uuid}
      ]

    @datastore.find query, (error, matches) =>
      return callback @userError 404, http.STATUS_CODES[404] if _.isEmpty matches
      return callback error if error?
      aliases = []

      _.each matches, (match) =>
        aliases.push match.name if match.uuid == uuid
        _.each match.subaliases, (subalias) =>
          aliases.push "#{match.name}.#{subalias.name}" if subalias.uuid == uuid

      callback null, aliases

  userError: (status, message) =>
    error = new Error message
    error.status = status
    error

module.exports = ReverseLookupService
