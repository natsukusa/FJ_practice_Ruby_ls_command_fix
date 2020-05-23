# frozen_string_literal: true

require './ls_directory.rb'
require './ls_file_data.rb'

module Ls

  class DetailListFormatter
    def generate
      puts finalized_view
    end

    def finalized_view
      views = []
      views << generate_with_argv_files if Argv.files?
      views << generate_with_argv_directories if Argv.directories?
      views << generate_with_non_argv if Argv.both_empty?
      views
    end

    private

    def generate_with_argv_files
      Directory.new(Argv.files).generate_at_argv_files
    end

    def generate_with_argv_directories
      views = []
      directories ||= sort_and_reverse(Argv.directories)
      directories.each do |directory|
        views.push("\n") unless (views.empty? && Argv.files.empty?)
        views << Directory.new(directory).generate_at_argv_directories
      end
      views
    end

    def generate_with_non_argv
      Directory.new(Dir.pwd).generate_at_non_argv
    end

    def sort_and_reverse(array)
      Argv.option[:reverse] ? array.sort.reverse : array.sort
    end
  end
end
