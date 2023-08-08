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
    TebakoRuntime::COMPILER_MEMFS = File.join(__dir__, "fixtures", "files")

    test_file = File.join(TebakoRuntime::COMPILER_MEMFS, "test1.file")
    expect(FileUtils).to receive(:cp_r).with([test_file], TebakoRuntime::COMPILER_MEMFS_LIB_CACHE)

    ref = TebakoRuntime.extract_memfs(File.join(TebakoRuntime::COMPILER_MEMFS, "test1.file"))
    expect(ref).to eq(File.join(TebakoRuntime::COMPILER_MEMFS_LIB_CACHE, "test1.file"))
  end

  it "processes memfs files with the same extension when wild option is given" do
    TebakoRuntime.send(:remove_const, :COMPILER_MEMFS)
    TebakoRuntime::COMPILER_MEMFS = File.join(__dir__, "fixtures", "files")

    test1_file = File.join(TebakoRuntime::COMPILER_MEMFS, "test1.file")
    test2_file = File.join(TebakoRuntime::COMPILER_MEMFS, "test2.file")
    expect(FileUtils).to receive(:cp_r).with(array_including(test1_file, test2_file),
                                             TebakoRuntime::COMPILER_MEMFS_LIB_CACHE)

    ref = TebakoRuntime.extract_memfs(File.join(TebakoRuntime::COMPILER_MEMFS, "test1.file"), wild: true)
    expect(ref).to eq(File.join(TebakoRuntime::COMPILER_MEMFS_LIB_CACHE, "test1.file"))
  end

  it "processes a memfs file with manually set cache folder" do
    cache = Pathname.new(Dir.mktmpdir("test-"))
    TebakoRuntime.send(:remove_const, :COMPILER_MEMFS)
    TebakoRuntime::COMPILER_MEMFS = File.join(__dir__, "fixtures", "files")

    test_file = File.join(TebakoRuntime::COMPILER_MEMFS, "test1.file")
    expect(FileUtils).to receive(:cp_r).with([test_file], cache)

    ref = TebakoRuntime.extract_memfs(File.join(TebakoRuntime::COMPILER_MEMFS, "test1.file"), cache_path: cache)
    expect(ref).to eq(File.join(cache, "test1.file"))
  end

  it "returns unchanged reference to non-memfs file with quoted name" do
    expect(TebakoRuntime.extract_memfs("\"/tmp/test.file\"")).to eq("\"/tmp/test.file\"")
  end

  it "processes a memfs file with quoted name" do
    TebakoRuntime.send(:remove_const, :COMPILER_MEMFS)
    TebakoRuntime::COMPILER_MEMFS = File.join(__dir__, "fixtures", "files")

    test_file = File.join(TebakoRuntime::COMPILER_MEMFS, "test1.file")
    expect(FileUtils).to receive(:cp_r).with([test_file], TebakoRuntime::COMPILER_MEMFS_LIB_CACHE)

    ref = TebakoRuntime.extract_memfs("\"#{File.join(TebakoRuntime::COMPILER_MEMFS, "test1.file")}\"")
    expect(ref).to eq("\"#{File.join(TebakoRuntime::COMPILER_MEMFS_LIB_CACHE, "test1.file")}\"")
  end

  it "provides an adapter for ffi gem" do
    expect(TebakoRuntime).to receive(:extract_memfs).with("test")
    require "ffi"
    FFI.map_library_name("test")
  end

  it "provides an adapter for jing gem" do
    TebakoRuntime.send(:remove_const, :COMPILER_MEMFS)
    TebakoRuntime::COMPILER_MEMFS = File.join(__dir__, "fixtures", "jing")
    test_schema = File.join(TebakoRuntime::COMPILER_MEMFS, "schema.rnc")
    test_xml = File.join(TebakoRuntime::COMPILER_MEMFS, "valid.xml")

    expect(TebakoRuntime).to receive(:extract_memfs)
      .with(File.join(TebakoRuntime.full_gem_path("ruby-jing"), "lib",
                      "jing-20091111.jar")).and_call_original
    require "jing"
    expect(TebakoRuntime).to receive(:extract_memfs).with(test_schema, { wild: true }).and_call_original
    j = Jing.new(test_schema)
    expect(TebakoRuntime).to receive(:extract_memfs).with(test_xml).and_call_original
    j.validate(test_xml)
  end

  it "provides an adapter for mn2pdf gem" do
    expect(TebakoRuntime).to receive(:extract_memfs).with(File.join(TebakoRuntime.full_gem_path("mn2pdf"), "bin",
                                                                    "mn2pdf.jar")).and_call_original
    require "mn2pdf"
  end

  it "provides an adapter for mnconvert gem" do
    expect(TebakoRuntime).to receive(:extract_memfs).with(File.join(TebakoRuntime.full_gem_path("mnconvert"), "bin",
                                                                    "mnconvert.jar")).and_call_original
    require "mnconvert"
  end

  it "provides an adapter for sassc gem" do
    TebakoRuntime.send(:remove_const, :COMPILER_MEMFS)
    TebakoRuntime::COMPILER_MEMFS = __dir__

    require "sassc"
    SassC.load_paths << File.join(TebakoRuntime::COMPILER_MEMFS, "fixtures")
    expect(FileUtils).to receive(:cp_r).with(File.join(TebakoRuntime::COMPILER_MEMFS, "fixtures", "."),
                                             File.join(TebakoRuntime::COMPILER_MEMFS_LIB_CACHE,
                                                       "fixtures")).and_call_original
    SassC::Engine.new("@import 'style/all.scss'", style: :compressed).render
  end

  it "provides a pre-processor for seven-zip gem" do
    sevenz_lib = RUBY_PLATFORM.downcase.match(/mswin|mingw/) ? "7z*.dll" : "7z.so"
    sevenz_path = File.join(TebakoRuntime.full_gem_path("seven-zip"), "lib", "seven_zip_ruby", sevenz_lib).to_s
    sevenz_new_folder = TebakoRuntime::COMPILER_MEMFS_LIB_CACHE / "seven_zip_ruby"

    expect(FileUtils).to receive(:cp).with(sevenz_path, sevenz_new_folder).and_call_original
    require "seven_zip_ruby"

    expect($LOAD_PATH).to include(TebakoRuntime::COMPILER_MEMFS_LIB_CACHE)
  end
end
# rubocop:enable Metrics/BlockLength
