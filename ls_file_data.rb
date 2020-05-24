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

    attr_accessor :file, :ftype, :mode, :nlink,
                  :owner, :group, :size, :mtime, :blocks

    def initialize(file)
      @file = file
    end

    def apend_info
      fill_ftype
      fill_mode
      fill_nlink
      fill_owner
      fill_group
      fill_size
      fill_mtime
      fill_blocks
    end

    def format_max_nlink_digit(file_details, file_data)
      max_nlink_digit = file_details.max_by { |f| f.nlink.length }.nlink.length
      file_data.nlink.to_s.rjust(max_nlink_digit)
    end

    def format_max_size_digit(file_details, file_data)
      max_size_digit = file_details.max_by(&:size).size.to_s.length
      file_data.size.to_s.rjust(max_size_digit)
    end

    def fill_ftype
      self.ftype = FILE_TYPE[File.ftype(@file)]
    end

    def fill_mode
      permission = File.lstat(@file).mode.to_s(8)[-3..-1]
      self.mode = change_mode_style(permission).join
    end

    def change_mode_style(permission)
      permission.each_char.map do |number|
        PERMISSION.fetch(number)
      end
    end

    def fill_nlink
      self.nlink = File.lstat(@file).nlink.to_s
    end

    def fill_owner
      self.owner = Etc.getpwuid(File.lstat(@file).uid).name
    end

    def fill_group
      self.group = Etc.getgrgid(File.lstat(@file).gid).name
    end

    def fill_size
      self.size = File.lstat(@file).size
    end

    def fill_mtime
      self.mtime = File.lstat(@file).mtime.strftime('%_m %_d %H:%M')
    end

    def fill_blocks
      self.blocks = File.lstat(@file).blocks.to_i
    end
  end
end
