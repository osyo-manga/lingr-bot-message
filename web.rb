# -*- encoding: UTF-8 -*-
require 'sinatra'
require 'json'

load "last_post.rb"


help = <<"EOS"
"#lastpost"   : 最後に自分が発言したリンクを出力
"#message help" : 使い方を出力
EOS


def to_lingr_link(message)
	time = message["timestamp"].match(/(.*)T/).to_a[1].gsub(/-/, '/')
	return "http://lingr.com/room/#{message["room"]}/archives/#{time}/#message-#{message["id"]}"
	10
end


get '/' do
	"Hello, world"
end

last_post = LastPost.new


get '/lingr_bot' do
	"lingr bot"
end

post '/lingr_bot' do
	content_type :text
	json = JSON.parse(request.body.string)
	json["events"].select {|e| e['message'] }.map {|e|
		name = e["message"]["nickname"]
		room = e["message"]["room"]
		text = e["message"]["text"]

		if /^#lastpost$/ =~ text
			return last_post.get(room, name, "Not Found")
		end

		last_post.add(room, name, to_lingr_link(e["message"]))
	}
	return ""
end

