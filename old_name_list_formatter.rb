# frozen_string_literal: true
require 'io/console/size'

module Ls

  class NameListFormatter
    def initialize
      @final_view = []
    end

    def setup
      generate_with_argv_files if Argv.files?
      generate_with_argv_directories if Argv.directories?
      generate_with_non_argv if Argv.both_empty?
      puts @final_view
    end

    private

    def generate_with_argv_files
      file_names = Argv.files
      @final_view << show_name(sort_and_reverse(file_names))
    end

    def generate_with_argv_directories
      directories = sort_and_reverse(Argv.directories)
      directories.each do |directory|
        @final_view.push("\n") unless @final_view.empty?
        @final_view << "#{directory}:"
        file_names = Dir.chdir(directory) { sort_and_reverse(look_up_dir) }
        @final_view << show_name(file_names)
      end
    end

    def generate_with_non_argv
      # directory = Dir.pwd
      # file_names = Dir.chdir(directory) { sort_and_reverse(look_up_dir) }
      file_names = sort_and_reverse(look_up_dir)
      @final_view << show_name(file_names)
    end

    def sort_and_reverse(array)
      Argv.option[:reverse] ? array.sort.reverse : array.sort
    end

    def look_up_dir
      Argv.option[:all] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    end
  # end

  # class Viewer
    def show_name(array)
      make_variables(array)
      make_formatted_list(array, @columns_width)
      make_name_view(@formatted_list, @number_of_rows)
    end

    # private

    def console_width
      IO.console_size[1]
    end

    # @columns_width = 8, 16, 24, 32, 40, 48 ...
    def make_variables(array)
      max_file_length = array.max_by(&:length).length
      @columns_width = ((max_file_length + 1) / 8.0).ceil * 8
      @number_of_columns = console_width / @columns_width
      @number_of_rows = (array.size / @number_of_columns.to_f).ceil
    end

    def make_formatted_list(array, columns_width)
      @formatted_list = array.map { |name| name.ljust(columns_width) }
    end

    def make_name_view(formatted_list, number_of_rows)
      sliced_list = []
      formatted_list.each_slice(number_of_rows) { |file| sliced_list << file }
      sliced_list.last << '' while sliced_list.last.size < number_of_rows
      # sliced_list.transpose.each(&:join).map(&:join)
      sliced_list.transpose.map(&:join)
    end
  end


end
