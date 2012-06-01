module AssetSync

  class << self

    def config=(data)
      @config = data
    end

    def config(force_reload=false)
      @config = Config.new if force_reload
      @config ||= Config.new
      @config
    end

    def configure(&proc)
      @config ||= Config.new
      yield @config
    end

    def storage
      @storage ||= Storage.new(self.config)
    end

    def sync(force_config_reload=false)
      return unless AssetSync.enabled?

      #Force reload only once
      if config.fail_silently?
        self.warn config.errors.full_messages.join(', ') unless config(force_config_reload) && config.valid?
      else
        raise Config::Invalid.new(config.errors.full_messages.join(', ')) unless config(force_config_reload) && config.valid?
      end
      
      #This is really a valid? check only. No reload necessary.
      self.storage.sync if config && config.valid?
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
