require "safe_yaml/load" # https://github.com/dtao/safe_yaml#what-if-i-dont-want-to-patch-yaml

SafeYAML::OPTIONS[:default_mode] = :safe
