require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        class LinksTest < Minitest::Test
          def setup
            serializer_class = Class.new(ActiveModel::Serializer) do
              def self_link
                "http://fake.com/posts/#{object.id}"
              end
              attributes :title, :id
              has_many :comments, serializer: CommentPreviewSerializer
            end
            @post = Post.new(id: 1, title: 'Hello!!', body: 'Hello, world!!')
            @post.comments = []
            @post.author = nil
            @serializer = serializer_class.new(@post)
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer)
            ActionController::Base.cache_store.clear
          end

          def test_self_link
            expected = {
              id: "1",
              self: "http://fake.com/posts/1",
              type: "posts",
              title: "Hello!!",
              links: {
                comments: { linkage: [] }
              }
            }

            assert_equal(expected, @adapter.serializable_hash[:data])
          end
        end
      end
    end
  end
end
