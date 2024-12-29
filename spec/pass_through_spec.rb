# frozen_string_literal: true

# Copyright (c) 2024 [Ribose Inc](https://www.ribose.com).
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

require "rspec"
require "tebako-runtime"

# rubocop:disable Metrics/BlockLength
RSpec.describe TebakoRuntime do
  it "provides a stub for ffi gem in pass through mode on Windows" do
    if RUBY_PLATFORM =~ /msys|mingw|cygwin/
      if defined?(FFI)
        FFI::Platform.send(:remove_const, :OS)
        FFI::Platform.send(:remove_const, :ARCH)
        FFI::Platform.send(:remove_const, :LIBPREFIX)
        FFI::Platform.send(:remove_const, :LIBSUFFIX)
        FFI::Platform.send(:remove_const, :PASS_THROUGH)
      end
      ENV["TEBAKO_PASS_THROUGH"] = "1"
      require "ffi"

      expect(defined?(FFI::Platform::OS)).to_not be_nil
      expect(defined?(FFI::Platform::ARCH)).to_not be_nil
      expect(defined?(FFI::Platform::LIBPREFIX)).to_not be_nil
      expect(defined?(FFI::Platform::LIBSUFFIX)).to_not be_nil
      expect(FFI::Platform::PASS_THROUGH).to eq(true)
    end
  end

  after do
    if RUBY_PLATFORM =~ /msys|mingw|cygwin/
      ENV.delete("TEBAKO_PASS_THROUGH")
      FFI::Platform.send(:remove_const, :OS) if Object.const_defined?(:OS)
      FFI::Platform.send(:remove_const, :ARCH) if Object.const_defined?(:ARCH)
      FFI::Platform.send(:remove_const, :LIBPREFIX) if Object.const_defined?(:LIBPREFIX)
      FFI::Platform.send(:remove_const, :LIBSUFFIX) if Object.const_defined?(:LIBSUFFIX)
      FFI::Platform.send(:remove_const, :PASS_THROUGH) if Object.const_defined?(:PASS_THROUGH)
    end
  end

  it "is transparent for other gems in PASS_THROUGH mode" do
    if RUBY_PLATFORM =~ /msys|mingw|cygwin/
      if defined?(FFI)
        FFI::Platform.send(:remove_const, :OS)
        FFI::Platform.send(:remove_const, :ARCH)
        FFI::Platform.send(:remove_const, :LIBPREFIX)
        FFI::Platform.send(:remove_const, :LIBSUFFIX)
        FFI::Platform.send(:remove_const, :PASS_THROUGH)
      end
      ENV["TEBAKO_PASS_THROUGH"] = "1"
      require "fiddle"

      expect(defined?(Fiddle)).to_not be_nil

    end
  end

  after do
    if RUBY_PLATFORM =~ /msys|mingw|cygwin/
      ENV.delete("TEBAKO_PASS_THROUGH")
      FFI::Platform.send(:remove_const, :OS) if Object.const_defined?(:OS)
      FFI::Platform.send(:remove_const, :ARCH) if Object.const_defined?(:ARCH)
      FFI::Platform.send(:remove_const, :LIBPREFIX) if Object.const_defined?(:LIBPREFIX)
      FFI::Platform.send(:remove_const, :LIBSUFFIX) if Object.const_defined?(:LIBSUFFIX)
      FFI::Platform.send(:remove_const, :PASS_THROUGH) if Object.const_defined?(:PASS_THROUGH)
    end
  end
end
# rubocop:enable Metrics/BlockLength
