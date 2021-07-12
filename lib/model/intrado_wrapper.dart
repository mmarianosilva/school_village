import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

@immutable
class IntradoWrapper {
  IntradoWrapper({
    this.eventAction,
    this.eventDescription,
    this.eventDetails,
    this.deviceDetails,
    this.caCivicAddress,
    this.geoLocation,
    this.serviceProvider,
    this.deviceOwner,
    this.eventTime,
  });

  final EventAction eventAction;
  final IntradoEventDescription eventDescription;
  final List<IntradoEventDetails> eventDetails;
  final IntradoDeviceDetails deviceDetails;
  final IntradoCaCivicAddress caCivicAddress;
  final IntradoGeoLocation geoLocation;
  final IntradoServiceProvider serviceProvider;
  final IntradoDeviceOwner deviceOwner;
  final DateTime eventTime;

  String toXml() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element("iotEvent", nest: () {
      builder.attribute("xmlns:ca", "urn:ietf:params:xml:ns:pidf:geopriv10:civicAddr");
      builder.attribute("xmlns:conf", "urn:ietf:params:xml:ns:geopriv:conf");
      builder.element("eventActions", nest: () {
        builder.element("action", nest: () {
          builder.text(describeEnum(eventAction));
        });
      });
      builder.element("eventDescription", nest: () {
        builder.attribute("xml:lang", eventDescription.lang);
        builder.text(eventDescription.text);
      });
      if (eventDetails.isNotEmpty) {
        builder.element("eventDetails", nest: () {
          eventDetails.forEach((element) {
            builder.element("detail", nest: () {
              builder.attribute("key", element.key);
              if (element.tel?.isNotEmpty ?? false) {
                builder.attribute("tel", element.tel);
              }
              builder.text(element.value);
            });
          });
        });
      }
      if (deviceDetails != null) {
        builder.element("deviceDetails", nest: () {
          if (deviceDetails.deviceClassification != null) {
            builder.element("deviceClassification", nest: () {
              builder.text(deviceDetails.deviceClassification);
            });
          }
          if (deviceDetails.deviceManager != null) {
            builder.element("deviceMfgr", nest: () {
              builder.text(deviceDetails.deviceManager);
            });
          }
          if (deviceDetails.deviceModeNumber != null) {
            builder.element("deviceModelNr", nest: () {
              builder.text(deviceDetails.deviceModeNumber);
            });
          }
          if (deviceDetails.uniqueDeviceId != null) {
            builder.element("uniqueDeviceID", nest: () {
              if (deviceDetails.typeOfDeviceId != null) {
                builder.attribute("typeOfDeviceID", deviceDetails.typeOfDeviceId);
              }
              builder.text(deviceDetails.uniqueDeviceId);
            });
          }
        });
      }
      if (caCivicAddress != null) {
        builder.element("ca:civicAddress", nest: () {
          if (caCivicAddress.country != null) {
            builder.element("ca:country", nest: () {
              builder.text(caCivicAddress.country);
            });
          }
          if (caCivicAddress.a1 != null) {
            builder.element("ca:A1", nest: () {
              builder.text(caCivicAddress.a1);
            });
          }
          if (caCivicAddress.a2 != null) {
            builder.element("ca:A2", nest: () {
              builder.text(caCivicAddress.a2);
            });
          }
          if (caCivicAddress.a3 != null) {
            builder.element("ca:A3", nest: () {
              builder.text(caCivicAddress.a3);
            });
          }
          if (caCivicAddress.rd != null) {
            builder.element("ca:RD", nest: () {
              builder.text(caCivicAddress.rd);
            });
          }
        });
      }
      if (geoLocation != null) {
        builder.element("geoLocation", nest: () {
          builder.element("latitude", nest: () {
            builder.text(geoLocation.latitude.toStringAsFixed(5));
          });
          builder.element("longitude", nest: () {
            builder.text(geoLocation.longitude.toStringAsFixed(5));
          });
          builder.element("altitude", nest: () {
            builder.text(geoLocation.altitude.toStringAsFixed(1));
          });
          if (geoLocation.uncertainty != null) {
            builder.element("uncertainty", nest: () {
              builder.text(geoLocation.uncertainty.toStringAsFixed(1));
            });
          }
          builder.element("conf:confidence", nest: () {
            builder.attribute("pdf", "normal");
            builder.text(geoLocation.confidence);
          });
        });
      }
      if (serviceProvider != null) {
        builder.element("serviceProvider", nest: () {
          if (serviceProvider.name != null) {
            builder.element("name", nest: () {
              builder.text(serviceProvider.name);
            });
          }
          if (serviceProvider.contactUri != null) {
            builder.element("contactURI", nest: () {
              builder.text(serviceProvider.contactUri);
            });
          }
          if (serviceProvider.textChatEnabled != null) {
            builder.element("textChatEnabled", nest: () {
              builder.text("${serviceProvider.textChatEnabled}");
            });
          }
        });
      }
      if (deviceOwner != null) {
        builder.element("deviceOwner", nest: () {
          if (deviceOwner.name != null) {
            builder.element("name", nest: () {
              builder.text(deviceOwner.name);
            });
          }
          if (deviceOwner.tel != null) {
            builder.element("tel", nest: () {
              builder.text(deviceOwner.tel);
            });
          }
          if (deviceOwner.environment != null) {
            builder.element("environment", nest: () {
              builder.text(deviceOwner.environment);
            });
          }
          if (deviceOwner.mobility != null) {
            builder.element("mobility", nest: () {
              builder.text(deviceOwner.mobility);
            });
          }
        });
      }
      builder.element("eventTime", nest: () {
        builder.text(eventTime.toIso8601String());
      });
    });
    return builder.build().toXmlString(pretty: true);
  }
}

enum EventAction { TextMsg, PSAPLink }

@immutable
class IntradoEventDescription {
  IntradoEventDescription({
    this.lang = "EN",
    this.text,
  });

  final String lang;
  final String text;
}

@immutable
class IntradoEventDetails {
  IntradoEventDetails({
    this.key,
    this.value,
    this.tel,
  });

  final String key;
  final String value;
  final String tel;
}

@immutable
class IntradoDeviceDetails {
  IntradoDeviceDetails({
    this.deviceClassification,
    this.deviceManager,
    this.deviceModeNumber,
    this.typeOfDeviceId,
    this.uniqueDeviceId,
    this.deviceSpecificData,
    this.deviceSpecificType,
  });

  final String deviceClassification;
  final String deviceManager;
  final String deviceModeNumber;
  final String typeOfDeviceId;
  final String uniqueDeviceId;
  final String deviceSpecificData;
  final String deviceSpecificType;
}

@immutable
class IntradoCaCivicAddress {
  IntradoCaCivicAddress({
    this.country,
    this.a1,
    this.a2,
    this.a3,
    this.hno,
    this.hns,
    this.prd,
    this.rd,
    this.pod,
    this.sts,
    this.lmk,
    this.loc,
    this.nam,
    this.pc,
  });

  final String country;
  final String a1;
  final String a2;
  final String a3;
  final String hno;
  final String hns;
  final String prd;
  final String rd;
  final String pod;
  final String sts;
  final String lmk;
  final String loc;
  final String nam;
  final String pc;
}

@immutable
class IntradoGeoLocation {
  IntradoGeoLocation({
    this.latitude,
    this.longitude,
    this.altitude,
    this.uncertainty,
    this.confidence,
  });

  final double latitude;
  final double longitude;
  final double altitude;
  final double uncertainty;
  final int confidence;
}

@immutable
class IntradoServiceProvider {
  IntradoServiceProvider({
    this.name,
    this.contactUri,
    this.textChatEnabled,
  });

  final String name;
  final String contactUri;
  final bool textChatEnabled;
}

@immutable
class IntradoDeviceOwner {
  IntradoDeviceOwner({
    this.name,
    this.tel,
    this.environment,
    this.mobility,
  });

  final String name;
  final String tel;
  final String environment;
  final String mobility;
}
