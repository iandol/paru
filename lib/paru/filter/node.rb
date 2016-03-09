module Paru
    module PandocFilter
        class Node

            include Enumerable

            # require all pandoc types
            Dir[File.dirname(__FILE__) + '/*.rb'].each do |file|
                require_relative file
            end

            def initialize contents, inline_children = false
                @children = []

                if contents.is_a? Array
                    contents.each do |elt|
                        if PandocFilter.const_defined? elt["t"]
                            @children.push PandocFilter.const_get(elt["t"]).new elt["c"]
                        else
                            if inline_children
                                @children.push PandocFilter::Inline.new elt["c"]
                            else
                                @children.push PandocFilter::Block.new elt["c"]
                            end
                        end
                    end
                end
            end

            def each
                @children.each do |child|
                    yield child
                end
            end

            def has_children?
                defined? @children and @children.size > 0
            end

            def is_block?
                false
            end

            def is_inline?
                false
            end

            def to_s
                self.class.name
            end

            def ast_type
                self.class.name.split("::").last
            end

            def ast_contents
                if has_children?
                    @children.map {|child| child.to_ast}
                else
                    []
                end
            end

            def to_ast
                {
                    "t": ast_type,
                    "c": ast_contents
                }
            end
        end
    end
end