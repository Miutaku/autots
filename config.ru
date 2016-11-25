$:.unshift File.expand_path('../lib', __FILE__)

require 'json'
require 'chrono'
require 'ayaneru'

run Ayaneru::Server

Thread.new do
  Chrono::Trigger.new('5 0 * * *') do
    registered_tags = Ayaneru.redis.lrange 'tags', 0, -1
    registered_tags.each do |tag|
      r = Ayaneru.niconico.search(tag, 1).to_s.split("\n")
      results = JSON.parse(r[2])
      if results['values']
        results['values'].each do |value|
          begin
            ret = Ayaneru.niconico.reserve(value["cmsid"])
          rescue => exception
            puts exception.message
            begin
              Ayaneru.twitter.create_direct_message(Ayaneru.twitter.user.screen_name, "これ以上タイムシフト予約できません．『#{value['title']}』（http://live.nicovideo.jp/watch/#{value['cmsid']}）")
            rescue => exception
              puts exception.message
            end
          end
          begin
            Ayaneru.twitter.create_direct_message(Ayaneru.twitter.user.screen_name, "『#{value['title']}』（http://live.nicovideo.jp/watch/#{value['cmsid']}）をタイムシフト予約しました．") if ret
          rescue => exception
            puts exception.message
          end
        end
      end
    end
  end.run
end
