# frozen_string_literal: true

# Cloud Foundry Java Buildpack
# Copyright 2013-2020 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fileutils'
require 'java_buildpack/framework'
require 'java_buildpack/component/versioned_dependency_component'

module JavaBuildpack
  module Framework

    # Encapsulates the functionality for enabling zero-touch Splunk OpenTelemetry Java Instrumetation support.
    class SplunkOtelJavaAgent < JavaBuildpack::Component::VersionedDependencyComponent
      include JavaBuildpack::Util

      def initialize(context, &version_validator)
        super(context, &version_validator)
        @component_name = 'Splunk OpenTelemetry Java Instrumentation'
      end

      # (see JavaBuildpack::Component::BaseComponent#compile)
      def compile
        download_jar
      end

      # (see JavaBuildpack::Component::BaseComponent#release)
      def release
        java_opts = @droplet.java_opts
        java_opts.add_javaagent(@droplet.sandbox + jar_name)

        @configuration.select { |key| key.start_with? 'otel' }
                      .each do |key, value|
          prop_name = key.gsub(/_/, '.')
          java_opts.add_system_property(prop_name, value)
        end
      end

      protected

      # (see JavaBuildpack::Component::VersionedDependencyComponent#supports?)
      def supports?
        @configuration['enabled']
      end

      # (see JavaBuildpack::Component::VersionedDependencyComponent#jar_name)
      def jar_name
        "splunk-otel-javaagent-#{@version}.jar"
      end
    end
  end
end
