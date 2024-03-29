# frozen_string_literal: true

# Copyright (c) 2023-2024 [Ribose Inc](https://www.ribose.com).
# All rights reserved.
# This file is a part of tebako
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

require_relative "string"

# Module TebakoRuntime
# Methods to extract files from memfs to temporary folder
module TebakoRuntime
  COMPILER_MEMFS = RUBY_PLATFORM =~ /msys|mingw|cygwin/ ? "A:/__tebako_memfs__" : "/__tebako_memfs__"
  COMPILER_MEMFS_LIB_CACHE = Pathname.new(Dir.mktmpdir("tebako-runtime-"))

  class << self
    def extract(file, wild, extract_path)
      files = if wild
                Dir.glob("#{File.dirname(file)}/*#{File.extname(file)}")
              else
                [file]
              end
      FileUtils.cp_r files, extract_path
    end

    # wild == true means "also extract other files with the same extension"
    def extract_memfs(file, wild: false, cache_path: COMPILER_MEMFS_LIB_CACHE)
      is_quoted = file.quoted?
      file = file.unquote if is_quoted
      return is_quoted ? file.quote : file unless File.exist?(file) && file.start_with?(COMPILER_MEMFS)

      memfs_extracted_file = cache_path + File.basename(file)
      extract(file, wild, cache_path) unless memfs_extracted_file.exist?

      is_quoted ? memfs_extracted_file.to_path.quote : memfs_extracted_file.to_path
    end
  end
end

at_exit do
  FileUtils.remove_dir(TebakoRuntime::COMPILER_MEMFS_LIB_CACHE.to_path, true)
end
