module CachedResource
  # NilIO emulates a null device (like /dev/null). This sort of
  # doesn't belong here, but it's a dependency of cached resource.
  class NilIO < StringIO

    # Write to the null device. Disregards
    # string parameter and returns the length
    # of the string in bytes.
    def write(string)
      string.bytesize
    end

    # Read form the null device.  Always returns nil.
    def read(length=nil, buffer=nil)
      nil
    end

  end
end