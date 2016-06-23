#!/usr/bin/ruby
#Вас предупреждали
require 'json'
require 'telegram/bot'

config = JSON.parse File.read "./config.json"
phrases = config["phrases"]
reactions = config["reactions"]
chance = config["chance"]
token = ARGV[0] || config["token"]

def get_reaction(reactions,text)
  reactions.each{
    |k,v|
    if text.match(/#{k}/i)
      if v.kind_of? Array
        return v[Random.rand(v.size)].to_s
      else
        return v.to_s
      end
    end
  }
  nil
end

Telegram::Bot::Client.run(token) do |bot|
  me = bot.api.get_me
  puts me.inspect
  puts "Fuck! I am started!"
  bot.listen do |msg|
    begin
      puts "<#{msg.from.username}> : #{msg.text}"
      puts "#{msg.reply_to_message.from.username} ? #{me['result']['username']}" if msg.reply_to_message

      if msg.text == "ping"
        bot.api.send_message(chat_id: msg.chat.id, text: "понг", reply_to_message_id: msg.message_id)
      elsif msg.reply_to_message and msg.reply_to_message.from.username == me['result']['username']
        puts "Phrase!"
        bot.api.send_message(chat_id: msg.chat.id, text: phrases[Random.rand(phrases.size)], reply_to_message_id: msg.message_id)
      elsif r = get_reaction(reactions,msg.text)
        puts "Reaction"
        bot.api.send_message(chat_id: msg.chat.id, text: r, reply_to_message_id: msg.message_id, parse_mode:"Markdown")
      end

      bot.api.send_message(chat_id: msg.chat.id,text: "иди хуйца сосни шлюха", reply_to_message_id:msg.message_id) if msg.from.username == "minibobrik"
    rescue => e
      puts e
      puts e.backtrace.join("\n\t")
    end
  end
end
