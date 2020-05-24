# frozen_string_literal: true

require 'optparse'
require './ls_argv.rb'
require './ls_detail_list_formatter.rb'
require './ls_name_list_formatter.rb'

module Ls
  class Main
    def generate(option, argv)
      apply_argv_to_module(argv)
      Argv.option = option
      if option[:list]
        DetailListFormatter.new.generate
      else
        NameListFormatter.new.generate
      end
    end

    private

    def apply_argv_to_module(argv)
      argv.each do |value|
        if File.file?(value)
          Argv.files << value
        elsif File.directory?(value)
          Argv.directories << value
        else
          raise "ls: #{value}: No such file or directory"
        end
      end
    end
  end

  if $PROGRAM_NAME == __FILE__
    opt = OptionParser.new

    option = {}

    opt.on('-a') { |v| option[:all] = v }
    opt.on('-l') { |v| option[:list] = v }
    opt.on('-r') { |v| option[:reverse] = v }

    opt.parse!(ARGV)

    Main.new.generate(option, ARGV)
  end
end
