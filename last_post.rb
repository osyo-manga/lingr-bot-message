# -*- encoding: UTF-8 -*-
require "data_mapper"

DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_ONYX_URL'])


class LastPostData
	include DataMapper::Resource

	property :id, Serial
	property :room, String
	property :name, String
	property :text, String, :length => 512
end
LastPostData.auto_upgrade!


class LastPost
	def initialize
	end

	def add(room, name, text)
		item = LastPostData.first_or_create({:room => room, :name => name})
		item.text = text
		item.save
	end

	def get(room, name, default="")
		begin
			result = LastPostData.first(:room => room, :name => name).text
		rescue
			result = default
		end
		result
	end
end

