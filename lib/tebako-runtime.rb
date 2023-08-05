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
require "pathname"

require_relative "tebako-runtime/version"
require_relative "tebako-runtime/memfs"
require_relative "tebako-runtime/config"

# Module TenakoRuntime
# Adds two additional steps for original require
# - an option to run some pre-processing 'BEFORE'
# - an option to implement adapter 'AFTER'
module TebakoRuntime
  PRE_REQUIRE_MAP = {
    "seven_zip_ruby" => "tebako-runtime/pre/seven-zip"
  }.freeze

  POST_REQUIRE_MAP = {
    "ffi" => "tebako-runtime/adapters/ffi",
    "sassc" => "tebako-runtime/adapters/sassc"
  }.freeze

  def self.full_gem_path(gem)
    Gem::Specification.find_by_name(gem).full_gem_path
  end

  def self.process(name, map, title)
    return !log_enabled unless map.key?(name)

    puts "Tebako runtime: #{title} #{name} => #{map[name]}" if log_enabled
    res_inner = require_relative map[name]
    puts "Tebako runtime: skipped #{name}" if log_enabled && !res_inner
    log_enabled
  end
end

# Some would call it 'monkey patching' but in reality we are adding
# adapters to gems that shall be aware that they are running in tebako environment
module Kernel
  alias original_require require
  def require(name)
    f1 = TebakoRuntime.process(name, TebakoRuntime::PRE_REQUIRE_MAP, "pre-processing")
    res = original_require name
    f2 = TebakoRuntime.process(name, TebakoRuntime::POST_REQUIRE_MAP, "attaching an adapter for")

    puts "Tebako runtime: no pre-processing or adapter definitions for #{name}" unless f1 || f2
    res
  end
end
