class Cache

  def initialize(dir)
    @dir = dir
    @dir.mkpath unless @dir.exist?
  end

  def path_for_key(key)
    @dir + URI.encode(key).gsub(%r{/}, '_')
  end

  def read(key)
    path = path_for_key(key)
    if path.exist?
      Marshal.load(path.read)
    else
      warn "[MISS #{key}]"
    end
  end

  def write(key, data)
    path = path_for_key(key)
    path.open('w') { |io| io.write(Marshal.dump(data)) }
  end

  def fetch(key)
    read(key) || yield.tap { |data| write(key, data) }
  end

end
