require 'redis'

module CsvExport
  class RedisAccountStorage
    def initialize(redis = Redis.current)
      @redis = redis
    end

    def store(account)
      dump = Marshal.dump(account)
      @redis.set(key(account.id), dump)
    end

    def get(account_id)
      dump = @redis.get(key(account_id))
      dump.nil? ? nil : Marshal.load(dump)
    end

    private

    def key(account_id)
      "dnsimple:csvexport:#{account_id}"
    end

  end
end
