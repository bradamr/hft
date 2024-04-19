require 'yaml'

class Properties
  attr_reader :files, :properties

  def initialize(files)
    @files      = files
    @properties = {}
    @keys       = {}
  end

  def self.load(files)
    new(files).load
  end

  def load
    return if files.nil? || files.empty?

    yaml_load(files) unless files.is_a?(Array)
    files.each { |f| yaml_load(f) } if files.is_a?(Array)

    properties
  end

  private

  def yaml_load(file)
    env_file = File.join(Dir.pwd, 'config', file)
    return unless File.exists?(env_file)

    file = File.open(env_file)
    file = decrypt_file(env_file) unless env_file.index('.gpg').nil?

    YAML.safe_load(file).each do |key, value|
      @properties[key.to_sym] = value
    end
  end

  def decrypt_file(file)
    puts "File: #{file}"
    `gpg -d #{file}`
  end

end
