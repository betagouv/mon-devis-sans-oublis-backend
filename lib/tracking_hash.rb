# frozen_string_literal: true

# TrackingHash is a subclass of Hash that tracks the keys that are accessed.
class TrackingHash < Hash
  def initialize(constructor = {})
    super()
    @keys_accessed = Set.new
    constructor&.each do |key, value|
      self[key] = value.is_a?(Hash) ? TrackingHash.new(value) : value
    end
  end

  def [](key)
    @keys_accessed.add(key)
    super || super(key.to_s)
  end

  def keys_accessed
    @keys_accessed.to_a.map do |key|
      if self[key].is_a?(TrackingHash)
        { key => self[key].keys_accessed }
      else
        key
      end
    end
  end
end
