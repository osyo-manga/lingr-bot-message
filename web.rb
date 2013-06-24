# -*- encoding: UTF-8 -*-
require 'sinatra'
require 'json'

load "last_post.rb"
load "mention.rb"


help = <<"EOS"
lingr の履歴とかを保存しておく bot です
アプリをリスタートするたびに履歴は消えてしまうのであしからず
"#lastpost [{nickname}]"   : 最後に {nickname} が発言したリンクを出力 引数がなければ自分を参照する
"#mention [{nickname}]"   : @{nickname} or {nickname}: されたポストの一覧を出力 この値は #mention した時にリセットされる
"#mention! [{nickname}]"   : #mention と同等　ただし、値はリセットされない
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
mention = Mention.new 10

get '/lingr_bot' do
	"lingr bot"
end

get '/lingr_bot/mention' do
	
end

post '/lingr_bot' do
	content_type :text
	json = JSON.parse(request.body.string)
	json["events"].select {|e| e['message'] }.map {|e|
		room = e["message"]["room"]
		text = e["message"]["text"]
		command = text.split(/[\s　]+/)
		
		case command[0]
		when "#message"
			case command.fetch(1, "")
			when "help"
				return help
			end
		when "#lastpost"
			name = command.fetch(1, e["message"]["nickname"])
			return last_post.get(room, name, "Not Found")
		when "#mention"
			name = command.fetch(1, e["message"]["nickname"])
			puts name
			return mention.pop(room, name, ["Not Found"]).join("\n")
		when "#mention!"
			name = command.fetch(1, e["message"]["nickname"])
			puts name
			return mention.get(room, name, ["Not Found"]).join("\n")
		end

		name = e["message"]["nickname"]
		last_post.add(room, name, to_lingr_link(e["message"]))

		if /^[\s　]*@(.*)[\s　]+[^\s　]+/ =~ text
			name = text[/^[\s　]*@(.*)[\s　]+[^\s　]+/, 1]
			mention.add(room, name, text + "\n" + to_lingr_link(e["message"]))
		end
		if /^[\s　]*([^\s　]+)[\s　]*[:：].+/ =~ text
			name = text[/^[\s　]*([^\s　]+)[\s　]*[:：].+/, 1]
			mention.add(room, name, text + "\n" + to_lingr_link(e["message"]))
		end

	}
	return ""
end

