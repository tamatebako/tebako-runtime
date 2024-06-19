# frozen_string_literal: true

# Copyright (c) 2023-2024 [Ribose Inc](https://www.ribose.com).
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

require_relative "lib/tebako-runtime/version"

Gem::Specification.new do |spec|
  spec.name          = "tebako-runtime"
  spec.version       = TebakoRuntime::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]
  spec.license       = "BSD-2-Clause"

  spec.summary = "Run-time support of tebako executable packager"
  spec.description = <<~SUM
    Tebako (https://github.com/tamatebako/tebako) is an executable packager.
    tebako-runtime gem implements adapters for Ruby gems that shall be aware
    that they run in tebako environment.
  SUM
  spec.homepage = "https://github.com/tamatebako/tebako-runtime"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/tamatebako/tebako-runtime"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files --recurse-submodules -z`.split("\x0").reject do |f|
      (f == __FILE__) ||
        f.match(%r{\A(?:(?:spec|tmp|\.github)/|\.(?:git|rspec|rubocop|gitignore))})
    end
  end
  spec.files += Dir.glob("lib/cert/*")
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "rubocop", "~> 1.52"
  spec.add_development_dependency "rubocop-rspec", "~> 2.23"
  spec.add_development_dependency "rubocop-rubycw", "~> 0.1"

  spec.add_development_dependency "excavate", "~> 0.3"
  spec.add_development_dependency "ffi", "~> 1.15"
  spec.add_development_dependency "mn2pdf", "~> 1.79"
  spec.add_development_dependency "mnconvert", "~> 1.54"
  spec.add_development_dependency "ruby-jing", "~> 0.0.3"
  spec.add_development_dependency "sassc", "~> 2.4"
end
