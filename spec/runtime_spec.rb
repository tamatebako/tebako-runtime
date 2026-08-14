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

require "pathname"
require "tebako-runtime"

# rubocop:disable Metrics/BlockLength
RSpec.describe TebakoRuntime do
  let(:tmpd) { tmpdir_name }

  it "has a version number" do
    expect(TebakoRuntime::VERSION).not_to be nil
  end

  # Temporary directory
  def tmpdir_name
    tdm = RUBY_PLATFORM =~ /msys|mingw|cygwin|mswin/ ? ENV.fetch("TEMP", nil) : "/tmp"
    File.join(tdm, "tebako-test-#{$PROCESS_ID}-#{rand 2**32}").tr("\\", "/")
  end

  it "extracts single file from memfs" do
    test_file = File.join(__dir__, "fixtures", "files", "test1.file")
    expect(FileUtils).to receive(:cp_r).with([test_file], tmpd)

    TebakoRuntime.extract(test_file, false, tmpd)
  end

  it "extracts files from memfs by wildcard" do
    test1_file = File.join(__dir__, "fixtures", "files", "test1.file")
    test2_file = File.join(__dir__, "fixtures", "files", "test2.file")
    test_files = File.join(__dir__, "fixtures", "files", "*.file")

    expect(FileUtils).to receive(:cp_r).with(array_including(test1_file, test2_file), tmpd)

    TebakoRuntime.extract(test_files, true, tmpd)
  end

  it "returns unchanged reference to non-memfs file" do
    expect(TebakoRuntime.extract_memfs("#{tmpd}/test.file")).to eq("#{tmpd}/test.file")
  end

  it "processes a memfs file with default settings" do
    TebakoRuntime.send(:remove_const, :COMPILER_MEMFS) if defined?(TebakoRuntime::COMPILER_MEMFS)
    TebakoRuntime::COMPILER_MEMFS = File.join(__dir__, "fixtures", "files")

    test_file = File.join(TebakoRuntime::COMPILER_MEMFS, "test1.file")
    expect(FileUtils).to receive(:cp_r).with([test_file], TebakoRuntime::COMPILER_MEMFS_LIB_CACHE)

    ref = TebakoRuntime.extract_memfs(File.join(TebakoRuntime::COMPILER_MEMFS, "test1.file"))
    expect(ref).to eq(File.join(TebakoRuntime::COMPILER_MEMFS_LIB_CACHE, "test1.file"))
  end

  it "processes memfs files with the same extension when wild option is given" do
    TebakoRuntime.send(:remove_const, :COMPILER_MEMFS) if defined?(TebakoRuntime::COMPILER_MEMFS)
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
    TebakoRuntime.send(:remove_const, :COMPILER_MEMFS) if defined?(TebakoRuntime::COMPILER_MEMFS)
    TebakoRuntime::COMPILER_MEMFS = File.join(__dir__, "fixtures", "files")

    test_file = File.join(TebakoRuntime::COMPILER_MEMFS, "test1.file")
    expect(FileUtils).to receive(:cp_r).with([test_file], cache)

    ref = TebakoRuntime.extract_memfs(File.join(TebakoRuntime::COMPILER_MEMFS, "test1.file"), cache_path: cache)
    expect(ref).to eq(File.join(cache, "test1.file"))

    FileUtils.remove_dir(cache, true)
  end

  it "returns unchanged reference to non-memfs file with quoted name" do
    expect(TebakoRuntime.extract_memfs("\"#{tmpd}/test.file\"")).to eq("\"#{tmpd}/test.file\"")
  end

  it "processes a memfs file with quoted name" do
    TebakoRuntime.send(:remove_const, :COMPILER_MEMFS) if defined?(TebakoRuntime::COMPILER_MEMFS)
    TebakoRuntime::COMPILER_MEMFS = File.join(__dir__, "fixtures", "files")

    test_file = File.join(TebakoRuntime::COMPILER_MEMFS, "test1.file")
    expect(FileUtils).to receive(:cp_r).with([test_file], TebakoRuntime::COMPILER_MEMFS_LIB_CACHE)

    ref = TebakoRuntime.extract_memfs("\"#{File.join(TebakoRuntime::COMPILER_MEMFS, "test1.file")}\"")
    expect(ref).to eq("\"#{File.join(TebakoRuntime::COMPILER_MEMFS_LIB_CACHE, "test1.file")}\"")
  end

  it "provides an adapter for net/http gem" do
    TebakoRuntime.send(:remove_const, :COMPILER_MEMFS) if defined?(TebakoRuntime::COMPILER_MEMFS)
    TebakoRuntime::COMPILER_MEMFS = File.join(TebakoRuntime.full_gem_path("tebako-runtime"), "lib")

    tfile = File.join(TebakoRuntime.full_gem_path("tebako-runtime"), "lib", "cert", "cacert.pem.mozilla")
    if RUBY_PLATFORM =~ /mswin|mingw/
      allow(TebakoRuntime).to receive(:extract_memfs).with("kernel32.dll").and_call_original
      allow(TebakoRuntime).to receive(:extract_memfs).with("advapi32.dll").and_call_original
    end
    expect(TebakoRuntime).to receive(:extract_memfs).with(tfile).and_call_original
    require "net/http"

    uri = URI("https://github.com/tamatebako/tebako-runtime/archive/refs/tags/v0.2.0.tar.gz")
    http = Net::HTTP.new(uri.host, uri.port)

    expect(http).to receive(:use_ssl=).with(true).and_call_original

    http.use_ssl = true

    expect(http.ca_file).to eq(File.join(TebakoRuntime::COMPILER_MEMFS_LIB_CACHE, "cacert.pem.mozilla"))
    expect(http.verify_mode).to eq(OpenSSL::SSL::VERIFY_PEER)
  end
end
# rubocop:enable Metrics/BlockLength
