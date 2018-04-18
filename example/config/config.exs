use Mix.Config

# Customize non-Elixir parts of the firmware.  See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.
config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Use shoehorn to start the main application. See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.
config :shoehorn,
  init: [:nerves_runtime, :nerves_network],
  app: Mix.Project.config()[:app]

config :nerves_network, regulatory_domain: "US"

config :nerves_network, :default,
  eth0: [
    ipv4_address_method: :dhcp
  ]

config :nerves_firmware_ssh,
  authorized_keys: [
    File.read!(Path.join(System.user_home!(), ".ssh/id_rsa.pub"))
  ]

# Add the LoggerCircularBuffer backend. This removes the
# default :console backend.
config :logger, backends: [RingLogger]

# Set the number of messages to hold in the circular buffer
config :logger, RingLogger, buffer_size: 100

# import_config "#{Mix.Project.config[:target]}.exs"
