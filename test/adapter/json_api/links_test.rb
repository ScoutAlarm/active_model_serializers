require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        class LinksTest < Minitest::Test
          def setup
            @serializer_class = Class.new(ActiveModel::Serializer) do
              attributes :title, :id
              has_many :comments, serializer: CommentPreviewSerializer
            end
            @with_self_link = Proc.new do
              def self_link
                "http://fake.com/posts/#{object.id}"
              end
            end
            @with_assoc_self_link = Proc.new do
              def comments_self_link
                "http://fake.com/posts/#{object.id}/comments"
              end
            end
            @with_assoc_related_link = Proc.new do
              def comments_related_link
                "http://fake.com/posts/#{object.id}/rel/comments"
              end
            end
            @post = Post.new(id: 1, title: 'Hello!!', body: 'Hello, world!!')
            @post.comments = []
            @post.author = nil
            ActionController::Base.cache_store.clear
          end

          def test_self_link
            @serializer_class.class_eval &@with_self_link
            expected = {
              id: "1",
              self: "http://fake.com/posts/1",
              type: "posts",
              title: "Hello!!",
              links: {
                comments: { linkage: [] }
              }
            }
            assert_post_serialization(expected)
          end

          def test_association_self_link
            @serializer_class.class_eval &@with_assoc_self_link
            expected = {
              id: "1",
              type: "posts",
              title: "Hello!!",
              links: {
                comments: {
                  self: "http://fake.com/posts/1/comments",
                  linkage: []
                }
              }
            }
            assert_post_serialization(expected)
          end

          def test_association_related_link
            @serializer_class.class_eval &@with_assoc_related_link
            expected = {
              id: "1",
              type: "posts",
              title: "Hello!!",
              links: {
                comments: {
                  related: "http://fake.com/posts/1/rel/comments",
                  linkage: []
                }
              }
            }
            assert_post_serialization(expected)
          end

          def test_all_link_urls
            [@with_self_link, @with_assoc_self_link, @with_assoc_related_link].each do |proc|
              @serializer_class.class_eval &proc
            end
            @post.comments = [Comment.new(id: 5)]
            expected = {
              id: "1",
              self: "http://fake.com/posts/1",
              type: "posts",
              title: "Hello!!",
              links: {
                comments: {
                  self: "http://fake.com/posts/1/comments",
                  related: "http://fake.com/posts/1/rel/comments",
                  linkage: [{ id: "5", type: "comments" }]
                }
              }
            }
            assert_post_serialization(expected)
          end

          private
          def assert_post_serialization(expected)
            serializer = @serializer_class.new(@post)
            adapter = ActiveModel::Serializer::Adapter::JsonApi.new(serializer)
            assert_equal(expected, adapter.serializable_hash[:data])
          end
        end
      end
    end
  end
end
