module SignalFx
  module Tracing
    module Compat
      module PhusionPassenger
        def self.apply
          # register a hook for newly spawned processes
          if defined? ::PhusionPassenger
            ::PhusionPassenger.on_event(:starting_worker_process) do |forked|
              if forked
                SignalFx::Tracing::Instrumenter.revive
              end
            end
          end
        end
      end

      add_compat PhusionPassenger
    end
  end
end
