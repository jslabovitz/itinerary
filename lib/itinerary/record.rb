module Itinerary

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

    def self.field(key, options={})
      @@fields[key] = Field.new(key, options)
    end

    attr_accessor :path

    field :person, type: String, name: 'Person'
    field :organization, type: String, name: 'Organization'
    field :address, type: String, name: 'Address'
    field :geocoding, type: Object, name: 'Geocoding'
    field :email, type: String, name: 'Email'
    field :phone, type: String, name: 'Phone'
    field :uri, type: URI, name: 'URL'
    field :description, type: String, name: 'Description'
    field :notes, type: String, name: 'Notes'
    field :visited, type: Date, name: 'Visited'
    field :contacted, type: Date, name: 'Contacted'
    field :declined, type: Date, name: 'Declined'
    field :ref, type: String, name: 'Reference'
    field :group, type: String, name: 'Group'

    TabFields = {
      'Name' => :name,
      'Organization' => :organization,
      'Person' => :person,
      'Address' => :address,
      'Latitude' => :latitude,
      'Longitude' => :longitude,
      'Email' => :email,
      'Phone' => :phone,
      'URL' => :uri,
      'Description' => :description,
      'Group' => :group,
    }

    MaxFieldNameLength = @@fields.map { |k, f| f.name.length }.max

    def self.export(output, mode=:text)
      case output
      when String
        output = Pathname.new(output).open('w')
      when Pathname
        output = output.open('w')
      when IO
        # nothing
      else
        raise "Can't write output #{output.inspect}"
      end
      lines = case mode
      when :text
        each.map { |r| r.to_text }
      when :tab
        tab_header + each.map { |r| r.to_tab }
      end.join("\n")
      output.write(lines)
    end

    def self.load(path)
      io = path.open
      rec = new(:path => path.expand_path.realpath)
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

    def self.tab_header
      TabFields.keys.join("\t")
    end

    def self.all
      each.to_a
    end

    def self.each(&block)
      if block_given?
        Itinerary.root.find do |path|
          if path.file? && path.basename.to_s[0] != '.'
            yield(load(path))
          end
        end
      else
        Enumerator.new(self, :each)
      end
    end

    def self.near(coords, radius)
      matches = {}
      each do |rec|
        if rec.geocoded?
          dist = Haversine.distance(*coords, rec.latitude, rec.longitude).to_miles
          if dist <= radius
            matches[dist] ||= []
            matches[dist] << rec
          end
        end
      end
      matches
    end

    # def self.[](path)
    #   each { |r| return r if r.path == path }
    #   nil
    # end

    ###

    def name
      organization || person
    end

    def id
      path.basename
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

    def kml_coordinates
      [longitude, latitude, 0].join(',')
    end

    def string_to_key(str)
      key = str.dup
      key.downcase!
      key.gsub!(/[^\w]+/, '-')
      key.sub!(/^-+/, '')
      key.sub!(/-+$/, '')
      key
    end

    def make_path
      path = Itinerary.root.dup
      if geocoded?
        path += string_to_key(country) if country
        path += string_to_key(state) if state
      else
        path += 'unknown'
      end
      raise "Can't make key from empty name" unless name
      key = string_to_key(name)
      i = 1
      p = nil
      loop do
        p = key.dup
        p += i.to_s if i > 1
        break unless (path + p).exist?
        i += 1
      end
      path += p
      path
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

    def to_text
      t = StringIO.new
      @@fields.values.map do |f|
        next if f.key == :notes
        value = self[f.key] or next
        if value =~ /\n/
          value = "\n" + value.gsub(/^/, "\t")
        end
        t.puts "%-#{MaxFieldNameLength + 1}.#{MaxFieldNameLength + 1}s %s" % [f.name + ':', value]
      end
      t.puts
      t.puts notes if notes
      t.rewind
      t.read
    end

    def to_tab
      TabFields.values.map { |v| self[v] || '' }.join("\t")
    end

    def to_html(options={})
      show_fields = options[:show] || @@fields.keys
      hide_fields = options[:hide] || []
      html = Builder::XmlMarkup.new
      html.h2(self.name)
      html.dl do
        (show_fields - hide_fields).each do |key|
          field = @@fields[key] or raise "Unknown field: #{key.inspect}"
          name = field.name
          value = self[field.key]
          if value
            case field.key
            when :geocoding
              name = 'Location'
              value = [city, state].compact.join(', ')
            when :contacted, :declined, :visited
              value = self[key].strftime('%-d %b %Y')
            when :uri
              name = 'Website'
              value = URI.parse(uri.split(/\s+/).first) if value.kind_of?(String)
            end
            html.dt(name)
            html.dd do
              if value.kind_of?(URI)
                html.a(value.to_s, :href => value.to_s)
              else
                html.text!(value)
              end
            end
          end
        end
      end
      html.target!
    end

    def save!
      @path ||= make_path
      @path.dirname.mkpath unless @path.dirname.exist?
      @path.open('w') { |io| io.write(to_text) }
      ;;puts "Saved to #{@path}"
    end

    def edit(options={})
      system(
        'subl',
        options[:wait] ? '--wait' : (),
        @path.to_s)
    end

    def open_in_editor_link
      URI.parse("subl://open/?url=file://#{URI.escape(@path)}")
    end

  end

end