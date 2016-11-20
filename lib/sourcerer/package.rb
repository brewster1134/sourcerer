module Sourcerer
  class Package
    @@subclasses = {}

    def self.inherited subclass
      key = caller.first.match(/.+\/packages\/(.+)\.rb/)[1].to_sym
      add_subclass key, subclass
    end

    def self.add_subclass key, subclass
      @@subclasses[key] = subclass
    end

    def self.subclasses key = nil
      key ? @@subclasses[key] : @@subclasses
    end

    def self.search package, version:, type:
    end

    def initialize package, version:
      @version = Semantic::Version.new version
    end

    def search
    end

    def type
    end

    def install
    end
  end

  module Packages
    Dir[File.join(__dir__, 'packages', '*.rb')].each { |file| require file }
  end
end
