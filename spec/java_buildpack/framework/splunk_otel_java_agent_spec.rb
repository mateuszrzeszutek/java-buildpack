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

require 'spec_helper'
require 'component_helper'
require 'java_buildpack/framework/splunk_otel_java_agent'

describe JavaBuildpack::Framework::SplunkOtelJavaAgent do
  include_context 'with component help'

  let(:configuration) do
    { 'otel_zipkin_service_name' => '$(jq -r -n "$VCAP_APPLICATION | .application_name")' }
  end

  it 'does not detect if not enabled' do
    expect(component.detect).to be_nil
  end

  context do
    let(:configuration) { super().merge 'enabled' => true }

    it 'detects when enabled' do
      expect(component.detect).to eq("splunk-otel-java-agent=#{version}")
    end

    it 'downloads Splunk OTel agent distribution',
       cache_fixture: 'stub-splunk-otel-javaagent.jar' do

      component.compile

      expect(sandbox + "splunk-otel-javaagent-#{version}.jar").to exist
    end

    it 'configures the Java agent with defaults' do
      component.release

      expect(java_opts).to include('-javaagent:$PWD/.java-buildpack/splunk_otel_java_agent/'\
                                   "splunk-otel-javaagent-#{version}.jar")
      expect(java_opts).to include('-Dotel.zipkin.service.name=$(jq -r -n "$VCAP_APPLICATION | .application_name")')
    end

    context do
      let(:configuration) do
        super().merge({ 'otel_zipkin_service_name' => 'some-service',
                        'otel_zipkin_endpoint' => 'http://custom-endpoint:8080/v1/trace' })
      end

      it 'configures the Java agent using provided OTel configuration' do
        component.release

        expect(java_opts).to include('-javaagent:$PWD/.java-buildpack/splunk_otel_java_agent/'\
                                   "splunk-otel-javaagent-#{version}.jar")
        expect(java_opts).to include('-Dotel.zipkin.service.name=some-service')
        expect(java_opts).to include('-Dotel.zipkin.endpoint=http://custom-endpoint:8080/v1/trace')
      end
    end
  end
end
