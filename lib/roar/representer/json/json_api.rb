require 'roar/representer/json'

module Roar::Representer::JSON
  module JsonApi
    def self.included(base)
      base.class_eval do
        include Roar::Representer::JSON
        include Roar::Representer::Feature::Hypermedia
        extend ClassMethods
      end

      # def to_hash(options)
      #   super.tap do |hash|
      #      hash[:_links] = v[:links]
      #      v[:links] = v[:private_links] # FIXME: this is too much work we're doing (rendering links for every element).
      #   end
      # end
    end


    module LinkRepresenter
      include Roar::Representer::JSON

      property :href
      property :type
    end

    require 'representable/json/hash'
    module LinkCollectionRepresenter
      include Representable::JSON::Hash

      values :extend => LinkRepresenter#,
        # :instance => lambda { |fragment, *| fragment.is_a?(LinkArray) ? fragment : Roar::Representer::Feature::Hypermedia::Hyperlink.new }

      # def to_hash(options)
      #   super.tap do |hsh|  # TODO: cool: super(:exclude => [:rel]).
      #     hsh.each { |k,v| v.delete(:rel) }
      #   end
      # end


      def from_hash(hash, options={})
        hash.each { |k,v| hash[k] = LinkArray.new(v, k) if is_array?(k) }

        hsh = super(hash) # this is where :class and :extend do the work.

        hsh.each { |k, v| v.rel = k }
      end
    end


    module ClassMethods
      def links_definition_options
        {
          :extend   => LinkCollectionRepresenter,
          #:instance => lambda { |*| LinkCollection.new(link_array_rels) }, # defined in InstanceMethods as this is executed in represented context.
          :decorator_scope => true
        }
      end
    end
  end
end
