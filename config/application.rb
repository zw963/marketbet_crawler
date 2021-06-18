require_relative 'db'

Sequel::Model.plugin :timestamps
Sequel.extension :symbol_aref
require 'sequel/extensions/blank'
