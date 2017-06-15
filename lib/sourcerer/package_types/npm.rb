module Sourcerer
  module Packages
    class Npm < Sourcerer::Package
      # @see Sourcerer::Package#search
      #
      def search name:, version:
      end

      # @see Sourcerer::Package#download
      #
      def download
      end

      # @see Sourcerer::Package#versions
      #
      def versions name:
      end
    end
  end
end
