class ServiceBase
  def initialize(*_args)
    @errors = []
  end

  class << self
    def call(*args)
      args = standardize_params(args)
      service_obj = new(*args)

      if service_obj.callable?
        service_obj.send(:before_call)
        call_result = service_obj.call
        service_obj.send(:after_call)
        call_result
      end
    end

    private

    def standardize_params(args)
      if args.length == 1 && args[0].is_a?(Hash)
        args[0] = args[0].with_indifferent_access
      end

      args
    end
  end

  attr_reader :errors

  def callable?
    true
  end

  def success?
    errors.blank?
  end

  def error?
    !success?
  end

  def error_messages
    return [] if errors.blank?

    errors&.each_with_object([]) do |error, error_messages|
      if error.is_a?(Exception)
        error_messages << error.message
      elsif error.is_a?(ActiveModel::Errors)
        error_messages.concat(error.full_messages)
      else
        error_messages << error.to_s
      end
    end
  end

  def has_error_class?(input_error_class)
    errors.detect do |error|
      error.class.name == input_error_class.try(:name)
    end.present?
  end

  private

  def add_errors(errors)
    @errors ||= []
    # WARN: Call #to_a on ActiveModel::Errors, missing error details
    @errors += Array(errors)
  end

  def add_error(error)
    @errors ||= []

    if error.is_a?(StandardError)
      @errors << error
    elsif error.is_a?(ActiveModel::Errors)
      @errors << error
    elsif error.is_a?(Array)
      error.each { |err| add_error(err) }
    else
      @errors << StandardError.new(error)
    end
  end

  def before_call; end

  def after_call; end
end
