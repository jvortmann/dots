# -*- encoding:  utf-8 -*-
$KCODE = 'u' unless defined?(Encoding)
require 'rubygems'
require 'pp'
require 'irb/ext/save-history'

#History configuration
IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"

alias q exit
IRB.conf.merge! :PROMPT_MODE  => :SIMPLE, :AUTO_INDENT  => true

begin
  require('awesome_print')
  AwesomePrint.irb!
rescue LoadError
end
