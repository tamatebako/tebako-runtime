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

require "pathname"

# rubocop:disable Metrics/BlockLength
RSpec.describe TebakoRuntime do
  it "has a version number" do
    expect(TebakoRuntime::VERSION).not_to be nil
  end

  it "extracts single file from memfs" do
    test_file = File.join(__dir__, "fixtures", "files", "test1.file")
    expect(FileUtils).to receive(:cp_r).with([test_file], "/tmp")

    TebakoRuntime.extract(test_file, false, "/tmp")
  end

  it "extracts files from memfs by wildcard" do
    test1_file = File.join(__dir__, "fixtures", "files", "test1.file")
    test2_file = File.join(__dir__, "fixtures", "files", "test2.file")
    test_files = File.join(__dir__, "fixtures", "files", "*.file")

    expect(FileUtils).to receive(:cp_r).with(array_including(test1_file, test2_file), "/tmp")

    TebakoRuntime.extract(test_files, true, "/tmp")
  end

  it "returns unchanged reference to non-memfs file" do
    expect(TebakoRuntime.extract_memfs("/tmp/test.file")).to eq("/tmp/test.file")
  end

  it "processes a memfs file with default settings" do
    TebakoRuntime.send(:remove_const, :COMPILER_MEMFS)
    TebakoRuntime::COMPILER_MEMFS  = File.join(__dir__, "fixtures", "files")

    test_file = File.join(__dir__, "fixtures", "files", "test1.file")
    expect(FileUtils).to receive(:cp_r).with([test_file], TebakoRuntime::COMPILER_MEMFS_LIB_CACHE)

    ref = TebakoRuntime.extract_memfs(File.join(TebakoRuntime::COMPILER_MEMFS, "test1.file"))
    expect(ref).to eq(File.join(TebakoRuntime::COMPILER_MEMFS_LIB_CACHE, "test1.file"))
  end

  it "processes a memfs file with manually set cache folder" do
    cache = Pathname.new(Dir.mktmpdir("test-"))
    TebakoRuntime.send(:remove_const, :COMPILER_MEMFS)
    TebakoRuntime::COMPILER_MEMFS  = File.join(__dir__, "fixtures", "files")

    test_file = File.join(__dir__, "fixtures", "files", "test1.file")
    expect(FileUtils).to receive(:cp_r).with([test_file], cache)

    ref = TebakoRuntime.extract_memfs(File.join(TebakoRuntime::COMPILER_MEMFS, "test1.file"), cache_path: cache)
    expect(ref).to eq(File.join(cache, "test1.file"))
  end

  it "returns unchanged reference to non-memfs file with quoted name" do
    expect(TebakoRuntime.extract_memfs("\"/tmp/test.file\"")).to eq("\"/tmp/test.file\"")
  end

  it "processes a memfs file with quoted name" do
    TebakoRuntime.send(:remove_const, :COMPILER_MEMFS)
    TebakoRuntime::COMPILER_MEMFS  = File.join(__dir__, "fixtures", "files")

    test_file = File.join(__dir__, "fixtures", "files", "test1.file")
    expect(FileUtils).to receive(:cp_r).with([test_file], TebakoRuntime::COMPILER_MEMFS_LIB_CACHE)

    ref = TebakoRuntime.extract_memfs("\"#{File.join(TebakoRuntime::COMPILER_MEMFS, "test1.file")}\"")
    expect(ref).to eq("\"#{File.join(TebakoRuntime::COMPILER_MEMFS_LIB_CACHE, "test1.file")}\"")
  end

  it "provides an option to call a method before 'require'" do
    require_relative "fixtures/before_require"

    TebakoRuntime.send(:remove_const, :PRE_REQUIRE_MAP)
    TebakoRuntime.send(:remove_const, :POST_REQUIRE_MAP)

    TebakoRuntime::PRE_REQUIRE_MAP = {
      "ffi" => "ffi_alert"
    }.freeze

    TebakoRuntime::POST_REQUIRE_MAP = {}.freeze

    expect(TebakoRuntime).to receive(:ffi_alert)
    require "ffi"
  end

  it "provides an option to add an adaptor after 'require'" do
    require_relative "../lib/tebako-runtime/adaptors/ffi"

    TebakoRuntime.send(:remove_const, :PRE_REQUIRE_MAP)
    TebakoRuntime.send(:remove_const, :POST_REQUIRE_MAP)

    TebakoRuntime::PRE_REQUIRE_MAP = {}.freeze

    TebakoRuntime::POST_REQUIRE_MAP = {
      "ffi" => "tebako-runtime/adaptors/ffi"
    }.freeze

    expect(TebakoRuntime).to receive(:extract_memfs).with("test")

    require "ffi"
    FFI.map_library_name("test")
  end
end
# rubocop:enable Metrics/BlockLength
