require 'nokogiri'
require 'open-uri'
require 'rubygems'
require 'thread'
require 'thread/pool'

pool = Thread.pool(10)
mutex = Mutex.new
done = 0

(1..1018).each { |page|
  pool.process {
    Nokogiri::HTML(open("http://bash.im/index/#{page}"), "Windows-1251").css('.quote').each { |quote|
      next if quote.css('.rating').empty?
      parts = []
      ['.rating', '.date', '.id', '.text'].each { |c|
        parts.push(quote.css(c))
      }
      mutex.synchronize do
        # TODO - is puts atomic?
        puts parts
      end
    }
    mutex.synchronize do
      done += 1
      STDERR.puts "Done #{done}"
    end
  }
}

pool.shutdown
