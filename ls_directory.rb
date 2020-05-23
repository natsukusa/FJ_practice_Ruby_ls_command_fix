# frozen_string_literal: true

module Ls

  class Directory

    def initialize(directory)
      @directory = directory
    end
    
    def generate_at_argv_files
      array = []
      file_names = sort_and_reverse(Argv.files)
      file_details = create_file_details(file_names).each(&:apend_info)
      array << finalize(file_details)
      array
    end

    def generate_at_argv_directories
      array = []
      Dir.chdir(@directory) do
        file_names = sort_and_reverse(look_up_dir)
        file_details = create_file_details(file_names).each(&:apend_info)
        array << "total #{file_details.sum(&:blocks)}"
        array << finalize(file_details)
      end
      array
    end

    def generate_at_non_argv
      array = []
      Dir.chdir(@directory) do
        file_names = sort_and_reverse(look_up_dir)
        file_details = create_file_details(file_names).each(&:apend_info)
        array << "total #{file_details.sum(&:blocks)}"
        array << finalize(file_details)
      end
      array
    end

    def finalize(file_details)
      max_size_digit = file_details.max_by(&:size).size.to_s.length
      max_nlink_digit = file_details.max_by { |file_data| file_data.nlink.length }.nlink.length
      file_details.map do |f|
        "#{f.ftype}#{f.mode}  #{f.nlink.to_s.rjust(max_nlink_digit)} #{f.owner}  #{f.group}  #{f.size.to_s.rjust(max_size_digit)} #{f.mtime} #{f.file}"
      end
    end

    private

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
