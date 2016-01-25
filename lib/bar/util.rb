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

# Extend Hash to allow merging values containing arrays
class Hash
  # Like #merge but when encountering an array, add new values
  def merge_with_arrays(other)
    merge(other) do |_k, v1, v2|
      case v1
      when Array
        # Combine the two arrays in the result
        v1.clone.concat(v2).uniq
      when Hash
        # Recursively merge the corresponding hashes
        v1.merge_with_arrays(v2)
      else
        # Override the value if something new was specified
        v2
      end
    end
  end
end
