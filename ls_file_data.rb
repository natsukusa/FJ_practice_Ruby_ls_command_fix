# frozen_string_literal: true

require 'etc'

module Ls
  class FileData
    FILE_TYPE = {
      'blockSpecial' => 'b',
      'characterSpecial' => 'c',
      'directory' => 'd',
      'link' => 'l',
      'socket' => 's',
      'fifo' => 'p',
      'file' => '-'
    }.freeze

    PERMISSION = {
      '7' => 'rwx',
      '6' => 'rw-',
      '5' => 'r-x',
      '4' => 'r--',
      '3' => '-wx',
      '2' => '-w-',
      '1' => '--x',
      '0' => '---'
    }.freeze

    attr_accessor :file, :file_info

    def initialize(file)
      @file = file
      @file_info = {}
    end

    def append_info
      @file_info[:ftype] = fill_ftype
      @file_info[:mode] = fill_mode
      @file_info[:nlink] = fill_nlink
      @file_info[:owner] = fill_owner
      @file_info[:group] = fill_group
      @file_info[:size] = fill_size
      @file_info[:mtime] = fill_mtime
      @file_info[:blocks] = fill_blocks
    end

    def format_max_nlink_digit(file_details, file_data)
      max_nlink_digit = file_details.map { |f| f.file_info[:nlink] }.max.to_s.length
      file_data.file_info[:nlink].to_s.rjust(max_nlink_digit)
    end

    def format_max_size_digit(file_details, file_data)
      max_size_digit = file_details.map { |f| f.file_info[:size] }.max.to_s.length
      file_data.file_info[:size].to_s.rjust(max_size_digit)
    end

    def fill_ftype
      FILE_TYPE[File.ftype(@file)]
    end

    def fill_mode
      permission = File.lstat(@file).mode.to_s(8)[-3..-1]
      change_mode_style(permission).join
    end

    def change_mode_style(permission)
      permission.each_char.map do |number|
        PERMISSION.fetch(number)
      end
    end

    def fill_nlink
      File.lstat(@file).nlink
    end

    def fill_owner
      Etc.getpwuid(File.lstat(@file).uid).name
    end

    def fill_group
      Etc.getgrgid(File.lstat(@file).gid).name
    end

    def fill_size
      File.lstat(@file).size
    end

    def fill_mtime
      File.lstat(@file).mtime.strftime('%_m %_d %H:%M')
    end

    def fill_blocks
      File.lstat(@file).blocks.to_i
    end
  end
end
