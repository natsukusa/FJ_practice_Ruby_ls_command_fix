# frozen_string_literal: true

module Ls
  class Directory
    def initialize(directory)
      @directory = directory
    end

    def generate_at_argv_files
      array = []
      file_names = sort_and_reverse(Argv.files)
      file_details = create_file_details(file_names).each(&:append_info)
      array << finalize(file_details)
      array
    end

    def generate_with_directories
      array = []
      Dir.chdir(@directory) do
        file_names = sort_and_reverse(look_up_dir)
        file_details = create_file_details(file_names).each(&:append_info)
        array << "total #{calc_block_sum(file_details)}"
        array << finalize(file_details)
      end
      array
    end

    private

    def calc_block_sum(file_details)
      file_details.map { |file_data| file_data.file_info[:blocks] }.sum
    end

    # some long methods are to deal with rubocop abc size check.
    def finalize(file_details)
      file_details.map do |f|
        "#{f.file_info[:ftype]}#{f.file_info[:mode]}  "\
        "#{f.format_max_nlink_digit(file_details, f)} "\
        "#{f.file_info[:owner].rjust(5)}  #{f.file_info[:group]}  "\
        "#{f.format_max_size_digit(file_details, f)} "\
        "#{f.file_info[:mtime]} #{f.file}"\
      end
    end

    def create_file_details(file_names)
      file_names.map { |file| FileData.new(file) }
    end

    def look_up_dir
      Argv.option[:all] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    end

    def sort_and_reverse(array)
      Argv.option[:reverse] ? array.sort.reverse : array.sort
    end
  end
end
