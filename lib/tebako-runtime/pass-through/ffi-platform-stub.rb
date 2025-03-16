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

module FFI
  module Platform
    ARCH = case RbConfig::CONFIG["host_cpu"].downcase
           when /amd64|x86_64|x64/
             "x86_64"
           when /i\d86|x86|i86pc/
             "i386"
           when /ppc64|powerpc64/
             "powerpc64"
           when /ppc|powerpc/
             "powerpc"
           when /sparcv9|sparc64/
             "sparcv9"
           when /arm64|aarch64/ # MacOS calls it "arm64", other operating systems "aarch64"
             "aarch64"
           when /^arm/
             if OS == "darwin" # Ruby before 3.0 reports "arm" instead of "arm64" as host_cpu on darwin
               "aarch64"
             else
               "arm"
             end
           else
             RbConfig::CONFIG["host_cpu"].downcase
           end

    OS =
      case RbConfig::CONFIG["host_os"].downcase
      when /linux/
        "linux"
      when /darwin/
        "darwin"
      when /freebsd/
        "freebsd"
      when /netbsd/
        "netbsd"
      when /openbsd/
        "openbsd"
      when /dragonfly/
        "dragonflybsd"
      when /sunos|solaris/
        "solaris"
      when /mingw|mswin/
        "windows"
      else
        RbConfig::CONFIG["host_os"].downcase
      end

    LIBPREFIX = case OS
                when /windows|msys/
                  ""
                when /cygwin/
                  "cyg"
                else
                  "lib"
                end

    LIBSUFFIX = case OS
                when /darwin/
                  "dylib"
                when /windows|cygwin|msys/
                  "dll"
                else
                  # Punt and just assume a sane unix (i.e. anything but AIX)
                  # when /linux|bsd|solaris/
                  # "so"
                  "so"
                end

    PASS_THROUGH = true

    def self.mac?
      RUBY_PLATFORM =~ /darwin/
    end
  end
end
