# -*- encoding: UTF-8 -*-
class LastPost
	def initialize
		@cache = {}
	end

	def add(room, name, text)
		if !@cache.has_key? room
			@cache[room] = {}
		end
		@cache[room][name] = text
	end

	def get(room, name, default="")
		@cache.fetch(room, {}).fetch(name, default)
	end
end

