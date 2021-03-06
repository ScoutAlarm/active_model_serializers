require 'test_helper'

module ActiveModel
  class Serializer
    class AttributesTest < Minitest::Test
      def setup
        @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1', nothing: nil })
        @profile_serializer = ProfileSerializer.new(@profile)
      end

      def test_attributes_definition
        assert_equal([:name, :description, :nothing],
                     @profile_serializer.class._attributes)
      end

      def test_attributes_with_fields_option
        assert_equal({name: 'Name 1'},
                     @profile_serializer.attributes(fields: [:name]))
      end

      def test_required_fields
        assert_equal({name: 'Name 1', description: 'Description 1'},
                     @profile_serializer.attributes(fields: [:name, :description], required_fields: [:name]))

      end

      def test_include_nil_false
        assert_equal({name: 'Name 1', description: 'Description 1'},
                     @profile_serializer.attributes(include_nil: false))

      end

      def test_include_nil_true
        assert_equal({name: 'Name 1', description: 'Description 1', nothing: nil},
                     @profile_serializer.attributes(include_nil: true))
      end

      def test_attributes_inheritance
        inherited_klass = Class.new(CommentSerializer)
        assert_equal([:id, :body], inherited_klass._attributes)
      end

      def test_attribute_inheritance_with_new_attribute
        inherited_klass = Class.new(CommentSerializer) do
          attribute :date
        end
        assert_equal([:id, :body, :date], inherited_klass._attributes)
        assert_equal([:id, :body], CommentSerializer._attributes)
      end
    end
  end
end
