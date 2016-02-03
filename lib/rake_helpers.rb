class RakeHelpers
  def self.notify_exception(*args, &block)
    _data = *args[0] || {}
    yield
  rescue => e
    if defined?(ExceptionNotifier)
       ExceptionNotifier.notify_exception(e, data: _data.try(:to_h))
    else
      raise e
    end
  end
end
