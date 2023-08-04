# frozen_string_literal: true

# Copyright (c) 2023 [Ribose Inc](https://www.ribose.com).
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

require_relative "../memfs"

module SassC
  # Load style files for sassc
  class Engine
    # rubocop:disable Style/ClassVars
    @@loaded_pathes = []
    @@loaded_pathes_semaphore = Mutex.new
    # rubocop:enable Style/ClassVars

    def load_files(path, m_path)
      FileUtils.mkdir_p(m_path)
      FileUtils.cp_r(File.join(path, "."), m_path) if File.exist?(path)
      @@loaded_pathes << m_path
    end

    def load_path(path, new_paths)
      if path.start_with?(TebakoRuntime::COMPILER_MEMFS)
        m_path = path.sub(TebakoRuntime::COMPILER_MEMFS, TebakoRuntime::COMPILER_MEMFS_LIB_CACHE.to_s)
        @@loaded_pathes_semaphore.synchronize do
          load_files(path, m_path) unless @@loaded_pathes.include?(m_path)
        end
        new_paths << m_path
      else
        new_paths << path
      end
    end

    def load_paths
      paths = (@options[:load_paths] || []) + SassC.load_paths
      new_paths = []
      paths.each { |path| load_path path, new_paths }
      pp = new_paths.join(File::PATH_SEPARATOR) unless new_paths.empty?
      pp
    end
  end
end
