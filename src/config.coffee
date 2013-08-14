require "js-yaml"

process.env.NODE_ENV = process.env.NODE_ENV || "development"
module.exports = require "./config/#{process.env.NODE_ENV}"