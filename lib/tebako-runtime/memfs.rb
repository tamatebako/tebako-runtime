# frozen_string_literal: true

# Copyright (c) 2023-2024 [Ribose Inc](https://www.ribose.com).
# All rights reserved.
# This file is a part of the Tebako project.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require "fileutils"
require "pathname"
require "rubygems"
require "tempfile"
require "fiddle"

require_relative "string"

# Module TebakoRuntime
# Methods to extract files from memfs to temporary folder
module TebakoRuntime
  # The v2 multi-mount world: an extractable path is one HELD by the TFS
  # mounts (the env image at COMPILER_MEMFS, payloads at their declared
  # points) — the compiled-in prefix can no longer express it. The
  # runtime executable's own tebako_fs_stat is the discriminator: it
  # answers only mounted content (0); host paths (and jail-denied ones)
  # answer otherwise. Fiddle::Handle::DEFAULT addresses the process
  # image WITHOUT this gem's own fiddle adapter (dlopen(nil) routes
  # through it and chokes on the nil).
  MEMFS_STAT_FN = begin
    Fiddle::Function.new(Fiddle::Handle::DEFAULT["tebako_fs_stat"],
                         [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
  rescue StandardError
    nil
  end

  # struct stat is at most 512 bytes on every supported platform
  # (darwin-arm64 and linux x86_64 use 144).
  MEMFS_STAT_BUF = "\0".b * 512

  def self.embedded_path?(path)
    return path.start_with?(COMPILER_MEMFS) if MEMFS_STAT_FN.nil?

    MEMFS_STAT_FN.call(path, MEMFS_STAT_BUF).zero? || path.start_with?(COMPILER_MEMFS)
  end

  def self.initialize_compiler_memfs_lib_cache
    Pathname.new(Dir.mktmpdir("tebako-runtime-"))
  rescue StandardError
    return nil unless defined?($tebako_original_pwd) && !$tebako_original_pwd.nil? # rubocop:disable Style/GlobalVars

    begin
      Pathname.new(Dir.mktmpdir("tebako-runtime-", $tebako_original_pwd)) # rubocop:disable Style/GlobalVars
    rescue StandardError
      nil
    end
  end

  COMPILER_MEMFS = RUBY_PLATFORM =~ /mswin|mingw/ ? "A:/__tebako_memfs__" : "/__tebako_memfs__"
  COMPILER_MEMFS_LIB_CACHE = initialize_compiler_memfs_lib_cache
  exit if COMPILER_MEMFS_LIB_CACHE.nil?

  def self.extract(file, wild, extract_path)
    files = if wild
              Dir.glob("#{File.dirname(file)}/*#{File.extname(file)}")
            else
              [file]
            end
    FileUtils.cp_r files, extract_path
  end

  # wild == true means "also extract other files with the same extension"
  def self.extract_memfs(file, wild: false, cache_path: COMPILER_MEMFS_LIB_CACHE)
    is_quoted = file.quoted?
    file = file.unquote if is_quoted
    return is_quoted ? file.quote : file unless File.exist?(file) && embedded_path?(file)

    memfs_extracted_file = cache_path + File.basename(file)
    extract(file, wild, cache_path) unless memfs_extracted_file.exist?

    is_quoted ? memfs_extracted_file.to_path.quote : memfs_extracted_file.to_path
  end
end

at_exit do
  return if TebakoRuntime::COMPILER_MEMFS_LIB_CACHE.nil?

  FileUtils.remove_dir(TebakoRuntime::COMPILER_MEMFS_LIB_CACHE.to_path, true)
end
