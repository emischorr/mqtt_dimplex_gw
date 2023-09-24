# Mqtt-Dimplex-Gw

A gateway service written in Elixir connecting the HTTP API of a Dimplex heatpump to MQTT and vice versa.
The project pulls data from the API every 60s and publishes it to the configured MQTT broker. The topics can be adjusted via environment.
In the other direction the gateway service subscribes to MQTT topics and listens for commands and forwards them to the API.

This requires access to the API interface over the local network. Depending on your heatpump this is maybe locked down by the firewall running on the device.
Tested with a Dimplex System M (version M1.4 of the heat pump manager and software version 5.0.6 of the gateway).

This project is not associated with Glen Dimplex.

## Docker Setup

The following command will pull the latest docker image and start the service in the background.
Ensure that you have replaced or set the environment variables accordingly.

```bash
docker run -d \
-e MQTT_HOST=$MQTT_HOST \
-e MQTT_USER=$MQTT_USER \
-e MQTT_PW=$MQTT_PW \
-e DIMPLEX_HOST=$DIMPLEX_HOST \
emischorr/mqtt_dimplex_gw:latest
```

You can also use the docker-compose file.

## Topics

These are examples of topics used to publish the values that are configured as default:
- 'home/get/dimplex_gw/heatpump/status'
- 'home/get/dimplex_gw/heatpump/outdoor_temp'
- 'home/get/dimplex_gw/heatpump/warmwater_current_temp'
- ...

If you would like to use different topics you can define another namespace with the environment variable `MQTT_EVENT_TOPIC_NS`.
This defaults to 'home/get/dimplex_gw'.

For controlling the heatpump one can use the following topics:
- 'home/set/dimplex_gw/heatpump/warmwater_target_temp'
- 'home/set/dimplex_gw/heatpump/heating_offset'

As payload use just raw/binary data.

Here you can change the namespace of these topics with the environment variable `MQTT_CMD_TOPIC_NS`.
This defaults to 'home/set/dimplex_gw'.