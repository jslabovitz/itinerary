class Itinerary

  class Record < HashStruct

    class Field

      attr_accessor :key
      attr_accessor :type
      attr_accessor :name

      def initialize(key, options={})
        @key = key
        @type = options[:type]
        @name = options[:name]
      end

    end

    # include Geocoder::Model::Record

    @@fields = {}

    def self.define_field(key, options={})
      @@fields[key] = Field.new(key, options)
    end

    def self.field(key)
      @@fields[key]
    end

    def self.fields
      @@fields
    end

    def self.field_keys
      @@fields.keys
    end

    attr_accessor :path

    define_field :person, type: String, name: 'Person'
    define_field :organization, type: String, name: 'Organization'
    define_field :address, type: String, name: 'Address'
    define_field :geocoding, type: Object, name: 'Geocoding'
    define_field :email, type: String, name: 'Email'
    define_field :phone, type: String, name: 'Phone'
    define_field :uri, type: URI, name: 'URL'
    define_field :description, type: String, name: 'Description'
    define_field :ref, type: String, name: 'Reference'
    define_field :group, type: String, name: 'Group'
    define_field :rank, type: Integer, name: 'Rank'
    define_field :visited, type: Date, name: 'Visited'
    define_field :contacted, type: Date, name: 'Contacted'
    define_field :declined, type: Date, name: 'Declined'
    define_field :notes, type: String, name: 'Notes'

    MaxFieldNameLength = @@fields.map { |k, f| f.name.length }.max

    def self.load(path, options={})
      io = path.open
      rec = new(:path => path)
      last_key = nil
      while !io.eof? && (line = io.readline) do
        case line.chomp
        when ''
          break
        when /^\s*(\w+):\s*(.*)\s*$/
          field_name, value = $1, $2.strip
          next if value.empty?
          field = @@fields[field_name.to_sym] || @@fields.values.find { |f| f.name == field_name } \
            or raise "#{path}: Unknown field: #{field_name.inspect}"
          if field.type == URI
            #FIXME: sometimes this field is a space-separated list
            # value = URI.parse(value)
          elsif field.type == Object
            value = eval(value)
          end
          rec[field.key] = value
          last_key = field.key
        when /^\s+(.+)\s*$/
          raise "#{path}: Can't continue line without initial key or name" unless last_key
          if rec[last_key]
            rec[last_key] += ' ' + $1
          else
            rec[last_key] = $1
          end
        else
          warn "#{path}: Bad line: #{line.inspect}"
          next
        end
      end
      notes = io.read
      unless notes.empty?
        if rec.notes
          rec.notes += "\n\n" + notes
        else
          rec.notes = notes
        end
      end
      io.close
      rec
    end

    ###

    def name
      organization || person
    end

    def city
      geocoding[:city] if geocoded?
    end

    def state
      geocoding[:state] if geocoded?
    end

    def country
      geocoding[:country] if geocoded?
    end

    def latitude
      geocoding[:latitude] if geocoded?
    end

    def longitude
      geocoding[:longitude] if geocoded?
    end

    def coordinates
      [latitude, longitude] if geocoded?
    end

    def geocoded?
      !geocoding.nil?
    end

    def geocode
      results = Geocoder.search(address)
      if (result = results.first)
        self.geocoding = {
          :city => result.city,
          :state => result.state_code,
          :country => result.country_code,
          :latitude => result.coordinates[0],
          :longitude => result.coordinates[1],
        }
        true
      else
        false
      end
    end

    def near(coords, radius)
      if geocoded? && (distance = Haversine.distance(*coords, latitude, longitude).to_miles) <= radius
        distance
      else
        nil
      end
    end

    def visited?
      !visited.nil? && visited < DateTime.now
    end

    def visit?
      rank > 3
    end

    def unvisited?
      visited.nil?
    end

    def contacted?
      !contacted.nil?
    end

    def declined?
      !declined.nil?
    end

    def match(query, itinerary)
      case query
      when Pathname
        query == path
      when String
        rpath = path.relative_path_from(itinerary.entries_path).to_s
        File.fnmatch(query, rpath)
      else
        raise "Don't know how to query on #{query.inspect}"
      end
    end

    def string_to_key(str)
      key = str.dup
      key.downcase!
      key.gsub!(/[^\w]+/, '-')
      key.sub!(/^-+/, '')
      key.sub!(/-+$/, '')
      key
    end

    def make_path(root)
      @path = Pathname.new(root.dup)
      raise "Not geocoded" unless geocoded?
      @path += string_to_key(country) if country
      @path += string_to_key(state) if state
      raise "Can't make key from empty name" unless name
      @path += string_to_key(name)
      @path = Pathname.new(@path.to_s + '.md')
      @path
    end

    def clean!
      @@fields.values.select { |f| f.type == String }.each do |field|
        if (value = self[field.key])
          value = value.gsub(/[[:space:]]+/, ' ').strip
        end
        if value.nil? || value.empty?
          delete(field.key)
        else
          self[field.key] = value
        end
      end
    end

    def convert
      false
    end

    def to_text(options={})
      t = StringIO.new
      keys = options[:field_keys] || @@fields.keys
      keys.each do |key|
        next if key == :notes
        value = self[key] or next
        if value =~ /\n/
          value = "\n" + value.gsub(/^/, "\t")
        end
        field = @@fields[key]
        t.puts "%-#{MaxFieldNameLength + 1}.#{MaxFieldNameLength + 1}s %s" % [(field ? field.name : key.to_s.capitalize) + ':', value]
      end
      t.puts
      t.puts notes if notes && keys.include?(:notes)
      t.rewind
      t.read
    end

    def to_tab(options={})
      field_keys = options[:field_keys] || self.field_keys
      field_keys.map { |k| @@fields[k] }.map do |field|
        value = self[field.key] || ''
        if value =~ /\n/
          value = value.gsub(/\n+/, ' | ')
        end
        value
      end.join("\t")
    end

    def to_html(options={})
      use_dl = options[:use_dl]
      fields_html = fields_to_html(options[:field_keys] || self.field_keys)
      html = Builder::XmlMarkup.new
      html.h2(name)
      if use_dl
        html.dl do
          fields_html.each do |display_name, h|
            html.dt(display_name)
            html.dd << h
          end
        end
      else
        fields_html.each do |display_name, h|
          html.p do
            html.b("#{display_name}: ")
            html << h
          end
        end
      end
      html.target!
    end

    def fields_to_html(field_keys)
      fields_html = {}
      field_keys.each do |key|
        field = @@fields[key] or raise "Unknown field: #{key.inspect}"
        display_name = field.name
        if (value = self[field.key])
          case field.key
          when :geocoding
            display_name = 'Location'
            value = [city, state].compact.join(', ')
          when :contacted, :declined, :visited
            value = value.strftime('%-d %b %Y')
          when :description
            html = Builder::XmlMarkup.new
            html.i(value)
            value = html
          when :uri
            display_name = 'Website'
            #FIXME: anything beyond first URI is ignored -- make into list of links
            value = URI.parse(value.split(/\s+/).first) if value.kind_of?(String)
          end
          html = Builder::XmlMarkup.new
          case value
          when URI
            html.a(value.to_s, :href => value.to_s)
          when Builder::XmlMarkup
            html << value
          else
            html.text!(value)
          end
          fields_html[display_name] = html.target!
        end
      end
      fields_html
    end

    def save!(force: force=false)
      raise "Record has no path" unless @path
      raise "Path #{@path} exists" if @path.exist? && !force
      @path.dirname.mkpath unless @path.dirname.exist?
      @path.open('w') { |io| io.write(to_text) }
    end

    def edit(options={})
      system(
        'subl',
        options[:wait] ? '--wait' : (),
        @path.to_s)
    end

    def open_in_editor_link
      URI.parse("subl://open/?url=file://#{URI.escape(full_path)}")
    end

    def print_diff(other)
      if self != other
        puts
        puts "< #{self.path}"
        puts "> #{other.path}"
        (self.keys + other.keys).sort.uniq.each do |key|
          if self[key] != other[key]
            puts "\t" + "#{key}:"
            if self[key] && !other[key]
              puts "\t\t" + "- #{self[key].inspect}"
            elsif !self[key] && other[key]
              puts "\t\t" + "+ #{other[key].inspect}"
            elsif self[key] != other[key]
              puts "\t\t" + "< #{self[key].inspect}"
              puts "\t\t" + "> #{other[key].inspect}"
            end
          end
        end
      end
    end

  end

end