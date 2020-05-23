# frozen_string_literal: true

require 'etc'

module Ls

  class FileData
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

    # def instans_to_h
    #   { ftype: @ftype, mode: @mode, nlink: @nlink, owner: @owner,
    #     group: @group, size: @size, mtime: @mtime, file: @file }
    # end

    private

    def fill_ftype
      hash = { 'blockSpecial' => 'b', 'characterSpecial' => 'c',
               'directory' => 'd', 'link' => 'l', 'socket' => 's',
               'fifo' => 'p', 'file' => '-' }
      self.ftype = File.ftype(@file).gsub(/[a-z]+/, hash)
    end

    def fill_mode
      permission = File.lstat(@file).mode.to_s(8)[-3..-1]
      self.mode = change_mode_style(permission).join
    end

    def change_mode_style(permission)
      permission.split(//).map do |number|
        format('%<char>03d', char: number.to_i.to_s(2))
          .gsub(/^1/, 'r').gsub(/1$/, 'x').tr('1', 'w').tr('0', '-')
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
