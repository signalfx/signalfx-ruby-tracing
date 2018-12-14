

module SignalFx
  module Tracing
    module Compat
      module PhusionPassenger
        def self.apply
          puts "applying Passenger compatibility"

          # register a hook for newly spawned processes
          if defined? ::PhusionPassenger
            ::PhusionPassenger.on_event(:starting_worker_process) do |forked|
              if forked
                # revive the async reporter thread
                puts "reviving reporter"
                SignalFx::Tracing::Instrumenter.set_reporter
              end
            end
          end
        end
      end

      add_compat PhusionPassenger
    end
  end
end
