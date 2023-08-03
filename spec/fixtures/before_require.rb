# frozen_string_literal: true

# before require test function
module TebakoRuntime
  def self.ffi_alert
    puts "TebakoRuntime::ffi_alert was called"
  end
end
