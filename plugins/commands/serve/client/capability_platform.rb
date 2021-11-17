require "google/protobuf/well_known_types"

module VagrantPlugins
  module CommandServe
    module Client
      module CapabilityPlatform

        def self.included(klass)
          return if klass.ancestors.include?(Util::HasMapper)
          klass.prepend(Util::HasMapper)
        end

        def seed(*args)
          raise NotImplementedError,
            "Seeding is not currently supported via Ruby client"
        end

        def seeds
          res = client.seeds(Empty.new)
          res.arguments
        end

        # @param [Symbol] cap_name Capability name
        # @return [Boolean]
        def has_capability?(cap_name)
          logger.debug("checking for capability #{cap_name}")
          val = SDK::Args::NamedCapability.new(capability: cap_name.to_s)
          req = SDK::FuncSpec::Args.new(
            args: [SDK::FuncSpec::Value.new(
                name: "",
                type: "hashicorp.vagrant.sdk.Args.NamedCapability",
                value: Google::Protobuf::Any.pack(val)
            )]
          )

          res = client.has_capability(req)
          logger.debug("got result #{res}")

          res.has_capability
        end

        # @param [Symbol] cap_name Name of the capability
        def capability(cap_name, *args)
          logger.debug("executing capability #{cap_name}")
          arg_protos = seeds.map do |any|
            SDK::FuncSpec::Value.new(
              name: "",
              type: any.type_name,
              value: any,
            )
          end
          d = Types::Direct.new(arguments: args)
          da = mapper.map(d, to: Google::Protobuf::Any)
          arg_protos << SDK::FuncSpec::Value.new(
            name: "",
            type: "hashicorp.vagrant.sdk.Args.Direct",
            value: Google::Protobuf::Any.pack(da),
          )

          req = SDK::Platform::Capability::NamedRequest.new(
            name: cap_name.to_s,
            func_args: SDK::FuncSpec::Args.new(
              args: arg_protos,
            )
          )
          client.capability(req)
        end
      end
    end
  end
end
