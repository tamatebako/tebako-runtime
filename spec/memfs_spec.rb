# frozen_string_literal: true

# Copyright (c) 2024 [Ribose Inc](https://www.ribose.com).
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

require "rspec"
require "pathname"
require "tempfile"

# rubocop:disable Style/GlobalVars
# Mock the global variable

$tebako_original_pwd = nil
RSpec.describe "COMPILER_MEMFS_LIB_CACHE initialization" do # rubocop:disable Metrics/BlockLength
  before do
    # Reset the global variable before each test
    $tebako_original_pwd = nil
  end

  it "creates a temporary directory successfully" do
    allow(Dir).to receive(:mktmpdir).and_return("/tmp/tebako-runtime-1234")
    memfs_cache = TebakoRuntime.send(:initialize_compiler_memfs_lib_cache)
    expect(memfs_cache.to_s).to eq("/tmp/tebako-runtime-1234")
  end

  it "handles failure to create temporary directory and uses $tebako_original_pwd" do
    allow(Dir).to receive(:mktmpdir).and_raise(StandardError)
    $tebako_original_pwd = "/tmp"
    allow(Dir).to receive(:mktmpdir).with("tebako-runtime-",
                                          $tebako_original_pwd).and_return("/tmp/tebako-runtime-5678")

    memfs_cache = TebakoRuntime.send(:initialize_compiler_memfs_lib_cache)
    expect(memfs_cache.to_s).to eq("/tmp/tebako-runtime-5678")
  end

  it "handles failure to create temporary directory and $tebako_original_pwd is nil" do
    allow(Dir).to receive(:mktmpdir).and_raise(StandardError)
    $tebako_original_pwd = nil

    memfs_cache = TebakoRuntime.send(:initialize_compiler_memfs_lib_cache)
    expect(memfs_cache).to be_nil
  end

  it "handles failure to create temporary directory botha at standard locations and with $tebako_original_pwd is nil" do
    call_count = 0
    allow(Dir).to receive(:mktmpdir) do
      call_count += 1
      raise StandardError if call_count <= 2

      "/tmp/tebako-runtime-1234"
    end

    $tebako_original_pwd = "/tmp"

    memfs_cache = TebakoRuntime.send(:initialize_compiler_memfs_lib_cache)
    expect(memfs_cache).to be_nil
  end
end
# rubocop:enable Style/GlobalVars
