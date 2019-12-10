# Easy w3wp performance monitoring
Performance counters require to specify instance name of a process to be monitored.
In case of IIS Application Pools all process names are the same - w3wp.
Also one application poll may change it's instance name every several minutes: w3wp#1, then w3wp#12, etc.

## Solution
Use Zabbix Low-level discovery feature and custom script which can find proper instance name for application pool.

## Installation
- Copy file for discovery logic into Zabbix Agent Script folder (e.g: C:\zabbix\scripts)
  -- easy.w3wp.discovery.ps1

- Append Zabbix Agent configuration file (zabbix_agentd.conf) with lines from file easy.w3wp.conf.
Note: verify and adjust if necessary the path of the script easy.w3wp.discovery.ps1 if your Zabbix Agent is installed into different location.

- In Zabbix web portal:
  -- Import Zabbix template (easy.w3wp.template.xml).
  -- Assign this template to Hosts where w3wp processes should be monitored.

## Following configuration
Open Template Details > Discovery > Item Prototypes.
Disable not interested items.
Add new item prototype and use macros:
- {#APP_POOL} for Application Pool Name
- {#INSTANCE_NAME} for Instance Name for given application pool


## Useful Links
https://www.zabbix.com/documentation/4.2/manual/discovery/low_level_discovery
