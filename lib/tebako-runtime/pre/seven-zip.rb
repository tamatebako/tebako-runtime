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

require_relative "../memfs"
require_relative "../../tebako-runtime"

# Fix path for 7zip load
module TebakoRuntime
  sevenz_lib = RUBY_PLATFORM.downcase.match(/mswin|mingw/) ? "7z*.dll" : "7z.so"
  sevenz_path = File.join(full_gem_path("seven-zip"), "lib", "seven_zip_ruby", sevenz_lib)
  sevenz_paths = Dir.glob(sevenz_path)
  sevenz_new_folder = COMPILER_MEMFS_LIB_CACHE / "seven_zip_ruby"
  FileUtils.mkdir_p(sevenz_new_folder)
  sevenz_paths.each do |file|
    puts "#{file} ==> #{sevenz_new_folder}"
    FileUtils.cp(file, sevenz_new_folder)
  end
  $LOAD_PATH.unshift(COMPILER_MEMFS_LIB_CACHE)
end
