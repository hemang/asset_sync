module AssetSync

  class << self

    def config=(data)
      @config = data
    end

    def config(env='development')
      @config ||= Config.new(env)
      @config
    end

    def configure(&proc)
      @config ||= Config.new
      yield @config
    end

    def storage
      @storage ||= Storage.new(self.config)
    end

    def sync(env='development')
      return unless AssetSync.enabled?

      if config.fail_silently?
        self.warn config.errors.full_messages.join(', ') unless config(env) && config.valid?
      else
        raise Config::Invalid.new(config.errors.full_messages.join(', ')) unless config(env) && config.valid?
      end
      self.storage.sync if config(env) && config.valid?
    end

    def warn(msg)
      stderr.puts msg
    end

    def log(msg)
      stdout.puts msg if !(self.config.log == false)
    end

    def enabled?
      config.enabled?
    end

    # easier to stub
    def stderr ; STDERR ; end
    def stdout ; STDOUT ; end

  end

end
