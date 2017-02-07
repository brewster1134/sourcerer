module Sourcerer
  module Packages
    class Git < Sourcerer::Package
      # @see Sourcerer::Package#search
      #
      def search package_name:, version:
      end

      # @see Sourcerer::Package#download
      #
      def download
      end

      # @see Sourcerer::Package#versions
      #
      def versions package_name:
      end
    end
  end
end
