# frozen_string_literal: true

require 'io/console/size'

module Ls

  class NameListFormatter
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

    def generate_with_argv_files
      file_names = Argv.files
      show_name(sort_and_reverse(file_names))
    end

    def generate_with_argv_directories
      views = []
      directories = sort_and_reverse(Argv.directories)
      directories.each do |directory|
        views.push("\n") unless (views.empty? && Argv.files.empty?)
        views << "#{directory}:"
        file_names = Dir.chdir(directory) { sort_and_reverse(look_up_dir) }
        views << show_name(file_names)
      end
      views
    end

    def generate_with_non_argv
      file_names = sort_and_reverse(look_up_dir)
      show_name(file_names)
    end


    def sort_and_reverse(array)
      Argv.option[:reverse] ? array.sort.reverse : array.sort
    end

    def look_up_dir
      Argv.option[:all] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    end


    def show_name(array)
      columns_width(array)
      number_of_rows(array)
      make_name_view(array)
    end

    # private

    def console_width
      IO.console_size[1]
    end


    # @columns_width = 8, 16, 24, 32, 40, 48 ...
    def columns_width(array)
      max_file_length = array.max_by(&:length).length
      ((max_file_length + 1) / 8.0).ceil * 8
    end

    def number_of_rows(array)
      number_of_columns = console_width / columns_width(array)
      (array.size / number_of_columns.to_f).ceil
    end

    def make_name_view(array)
      sliced_list = []
      formatted_list = array.map { |name| name.ljust(columns_width(array)) }
      formatted_list.each_slice(number_of_rows(array)) { |file| sliced_list << file } # map使える？
      sliced_list.last << '' while sliced_list.last.size < number_of_rows(array)
      sliced_list.transpose.map(&:join)
    end


  end
end
