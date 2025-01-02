# frozen_string_literal: true

# TrackingHash is a subclass of Hash that tracks the keys that are accessed.
class TrackingHash < Hash
  # rubocop:disable Metrics/MethodLength
  def initialize(constructor = {})
    super()

    @keys_accessed = Set.new

    return unless constructor.is_a?(Hash)

    constructor&.each do |key, value|
      self[key] = if value.is_a?(Hash)
                    TrackingHash.new(value)
                  elsif value.is_a?(Array)
                    value.map { TrackingHash.new(it) }
                  else
                    value
                  end
    end
  end
  # rubocop:enable Metrics/MethodLength

  def [](key)
    @keys_accessed.add(key)

    unless key?(key)
      return super(key.to_s) if key.is_a?(Symbol)

      return super(key.to_sym) if key.is_a?(String)
    end

    super
  end

  def dig(*keys)
    current = self
    keys.each do |key|
      return nil unless current.is_a?(Hash) || current.is_a?(Array)

      current = current[key] # Reuse overwritten methods
    end

    current
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
