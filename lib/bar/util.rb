# Extend the kernel to allow warning suppression
module Kernel
  # Allow the suppression of warnings for a block of code
  def suppress_warnings
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    result = yield
    $VERBOSE = original_verbosity

    result
  end
end

# Add simple convenience methods
class Object
  # Convert all the keys of a hash to symbols
  def deep_symbolize_keys
    return each_with_object({}) do |(k, v), memo|
      memo[k.to_sym] = v.deep_symbolize_keys
      memo
    end if self.is_a? Hash

    return each_with_object([]) do |v, memo|
      memo << v.deep_symbolize_keys
      memo
    end if self.is_a? Array

    self
  end
end
