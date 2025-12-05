{
  lib,
  pkgs,
  ...
}: let
  wasteTypes = [
  ];
  defaultTemplate = ''
    {% if value.daysTo == 0 %}Today{% elif value.daysTo == 1 %}Tommorow{% else %} {{value.daysTo}} days{% endif %}
  '';

  # Function to create a sensor
  mkSensor = {
    name,
    types,
    leadtime ? "3",
    value_template ? defaultTemplate,
  }: {
    platform = "waste_collection_schedule";
    inherit name leadtime value_template types;
    details_format = "appointment_types";
  };
in {
  services.home-assistant = {
    config = {
      waste_collection_schedule = {
        sources = [
          {
            name = "!secret waste-source";
            args = {
              town = "!secret waste-town";
              street = "!secret waste-street";
              house_number = "!secret waste-house_number";
            };
          }
        ];
      };

      sensor =
        [
          {
            platform = "waste_collection_schedule";
            name = "Next waste";
            details_format = "appointment_types";
          }
        ]
        ++ map (type:
          mkSensor {
            name = "${lib.strings.toLower type}";
            types = [type];
          })
        wasteTypes;
    };

    customComponents = with pkgs.home-assistant-custom-components; [
      waste_collection_schedule
    ];
  };
}
