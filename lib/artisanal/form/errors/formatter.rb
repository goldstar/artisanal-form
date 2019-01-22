module Artisanal::Form
  class Errors::Formatter
    include Singleton

    def call(hash)
      humanize(sources(hash))
    end

    private

    def sources(hash)
      hash.each.with_object({}) do |(k, v), h|
        handler = "handle_#{v.class.name.downcase}"
        if respond_to?(handler, true)
          send(handler, h, k, v)
        else
          handle_generic(h, k, v)
        end
      end
    end

    def humanize(sources)
      sources.each.with_object({}) do |(path, errors), memo|
        attr_name = path.to_s.split('/').last
        memo["#/#{path}"] = {
          human_name: attr_name.humanize,
            messages: Array.wrap(errors)
        }
      end
    end

    def handle_generic(h,k,v)
      h[k] = v
    end

    def handle_hash(h,k,v)
      sources(v).each do |h_k, h_v|
        h["#{k}/#{h_k}".intern] = h_v
      end
    end

    def handle_array(h,k,v)
      handle_generic(h,k,v) and return unless v.all? {|a_v| a_v.is_a?(Hash) }

      if v.count == 1
        handle_hash(h, k, v[0])
      else
        sources(index(v)).each do |h_k, h_v|
          h["#{k}/#{h_k}".to_sym] = h_v
        end
      end
    end

    def index(v)
      Array(v).each.with_index.with_object({}) {|(a_v, a_i), a_h|
        a_h[a_i] = a_v
      }
    end
  end
end
