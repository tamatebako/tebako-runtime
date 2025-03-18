# frozen_string_literal: true

# Copyright (c) 2025 [Ribose Inc](https://www.ribose.com).
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

require "tebako-runtime"

RSpec.describe TebakoRuntime do # rubocop:disable  Metrics/BlockLength
  around do |example|
    # Save environment variables
    saved_env = {}
    %w[BUNDLE_GEMFILE TEBAKO_PASS_THROUGH].each do |key|
      saved_env[key] = ENV[key] if ENV.key?(key)
    end

    # Save COMPILER_MEMFS constant
    saved_compiler_memfs = TebakoRuntime.const_defined?(:COMPILER_MEMFS) ? TebakoRuntime::COMPILER_MEMFS : nil

    begin
      TebakoRuntime.send(:remove_const, :COMPILER_MEMFS) if defined?(TebakoRuntime::COMPILER_MEMFS)
      TebakoRuntime::COMPILER_MEMFS = File.join(__dir__, "fixtures")
      ENV.delete("BUNDLE_GEMFILE")
      ENV.delete("TEBAKO_PASS_THROUGH")

      example.run
    ensure
      # Restore environment variables
      ENV.delete("BUNDLE_GEMFILE")
      ENV.delete("TEBAKO_PASS_THROUGH")
      saved_env.each { |key, value| ENV[key] = value }

      # Restore COMPILER_MEMFS constant
      TebakoRuntime.send(:remove_const, :COMPILER_MEMFS) if defined?(TebakoRuntime::COMPILER_MEMFS)
      TebakoRuntime::COMPILER_MEMFS = saved_compiler_memfs if saved_compiler_memfs
    end
  end

  it "does nothing when TEBAKO_PASS_THROUGH is set" do
    ENV["TEBAKO_PASS_THROUGH"] = "1"
    expect(File).not_to receive(:exist?)
    TebakoRuntime.set_bundle_gemfile
    expect(ENV.fetch("BUNDLE_GEMFILE", nil)).to be_nil
  end

  it "sets BUNDLE_GEMFILE when .bundle/Gemfile exists" do
    bundle_gemfile = File.join(TebakoRuntime::COMPILER_MEMFS, ".bundle", "Gemfile")
    expect(File).to receive(:exist?).with(bundle_gemfile).and_return(true)
    TebakoRuntime.set_bundle_gemfile
    expect(ENV.fetch("BUNDLE_GEMFILE", nil)).to eq(bundle_gemfile)
  end

  it "does not set BUNDLE_GEMFILE when .bundle/Gemfile does not exist" do
    bundle_gemfile = File.join(TebakoRuntime::COMPILER_MEMFS, ".bundle", "Gemfile")
    expect(File).to receive(:exist?).with(bundle_gemfile).and_return(false)
    TebakoRuntime.set_bundle_gemfile
    expect(ENV.fetch("BUNDLE_GEMFILE", nil)).to be_nil
  end
end
