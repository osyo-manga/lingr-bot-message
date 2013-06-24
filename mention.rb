# -*- encoding: UTF-8 -*-
class Mention
	def initialize(size)
		@cache_size = size
		@cache = {}
	end

	def add(room, name, text)
		if !@cache.has_key? room
			@cache[room] = {}
		end
		if !@cache[room].has_key? name
			@cache[room][name] = []
		end
		@cache[room][name] << text
		if @cache[room][name].size > @cache_size
			@cache[room][name].slice!(0, @cache[room][name].size - @cache_size)
		end
	end

	def pop(room, name, default=[])
		if !@cache.has_key? room
			@cache[room] = {}
		end
		result = @cache.fetch(room, {}).fetch(name, default)
		@cache[room].delete name
		result
	end

	def get(room, name, default="")
		@cache.fetch(room, {}).fetch(name, default)
	end
end

