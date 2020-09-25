# Splunk OpenTelemetry Java Instrumentation Framework
The Splunk OpenTelemetry Java Instrumentation Framework contributes Splunk distribution of OpenTelemetry Java
instrumentation agent configuration to the application at runtime.

<table>
  <tr>
    <td><strong>Detection Criterion</strong></td>
    <td><code>enabled</code> set in the <code>config/splunk_otel_java_agent.yml</code> file</td>
  </tr>
  <tr>
    <td><strong>Tags</strong></td>
    <td><code>splunk-otel-java-agent=&lt;version&gt;</code></td>
  </tr>
</table>
Tags are printed to standard output by the buildpack detect script.

## Configuration
For general information on configuring the buildpack, including how to specify configuration values through environment variables, refer to [Configuration and Extension][].

The framework can be configured by modifying the [`config/splunk_otel_java_agent.yml`][] file in the buildpack fork.
The framework uses the [`Repository` utility support][repositories] and so it supports the [version syntax][] defined there.

| Name                       | Description
| ----                       | -----------
| `repository_root`          | The URL of the Splunk OpenTelemetry Java Instrumentation repository index ([details][repositories]).
| `version`                  | The version of Splunk distribution of OpenTelemetry Java instrumentation agent to use. Available versions can be found [here][github releases].
| `enabled`                  | A boolean describing whether OpenTelemetry Java instrumentation should be enabled.
| `otel_zipkin_service_name` | The name of the service being instrumented. Defaults to the result of <code>$(jq -r -n "$VCAP_APPLICATION &#124; .application_name")</code>.

The framework supports all OpenTelemetry Java Instrumentation [configuration parameters][]: all you need to do to use them is replace dots with underscores, e.g.
instead of `otel.endpoint.peer.service.mapping` use `otel_endpoint_peer_service_mapping`.
All configuration parameters defined this way are passed to the agent using Java system properties.

[Configuration and Extension]: ../README.md#configuration-and-extension
[`config/splunk_otel_java_agent.yml`]: ../config/splunk_otel_java_agent.yml
[repositories]: extending-repositories.md
[version syntax]: extending-repositories.md#version-syntax-and-ordering
[github releases]: https://github.com/signalfx/splunk-otel-java/releases
[configuration parameters]: https://github.com/open-telemetry/opentelemetry-java-instrumentation#configuration-parameters-subject-to-change