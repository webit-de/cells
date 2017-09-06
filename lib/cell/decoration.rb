module Cell::ViewModel::Decoration

  def self.included(base)
    base.class_eval do
      inheritable_attr :decorator_class
      self.decorator_class = EscapeDecorator
    end
  end

  class EscapeDecorator < SimpleDelegator

    def method_missing(method, *args, &block)
      decorate_or_escape!(super)
    end

  private

    def decorate_or_escape!(value)
      if value.is_a?(String)
        escape!(value)
      elsif value.is_a?(Numeric)
        # numbers can not contain dangerous scripts
        value
      else
        # every other object should get wrapped again with this decorator
        EscapeDecorator.new(value)
      end
    end

    require "erb"
    def escape!(string)
      ::ERB::Util.html_escape(string)
    end

  end

private

  # hook into setup! to decorate the cell model
  def setup!(model, options)
    super
    @model = self.class.decorator_class.new(@model)
  end


end
