Because almost everything was changed, improved, re-factored and bug-fixed since last release,
here are highlighted the most important ones for the end-user:

Start-up HotKeys
================

 'Function'        || 'Shortcut'           || 'Notes'
===================||======================||=========
 Disable Ozmosis   ||  Escape              ||  Press at start-up, screen will flash red to indicate Ozmosis is disabled.
 Reset NVRAM       ||  Option+Command+P+R  || From F12 menu, Ozmosis GUI, Shell or BIOS Setup.
 Start Ozmosis GUI ||  Option/Home         || It can be controlled with mouse only for now.
 Safe Boot Mode    ||  Shift               ||
 Verbose Mode      ||  Command+V           ||
 Single-User Mode  ||  Command+S           ||
 32 Bit Boot Mode  ||  3+2                 || Start Up In 32 Bit Mode
 64 Bit Boot Mode  ||  6+4                 || Start Up In 64 Bit Mode


Mac/PC Keyboard Legend
======================

'Mac' Key  || 'PC' Key
 Option    || Alt
 Command   || WinLogo


Added the ability to control graphics and audio injection using NVRAM variables, complete list of variables:

Default Settings 1F8E0C02-58A9-4E34-AE22-2B63745FA101
======================================================

 'Key'                        || 'Value' || 'Note/Example'
==============================||=========||==================================
 AcpiLoaderMode               || INTEGER || Control ACPI Loader
 UserInterface                || BOOLEAN || Display User Interface/GUI
 TimeOut                      || INTEGER || Time-out In Seconds
 DisableAtiInjection          || BOOLEAN || De/activate ATI GFX device property injection
 AtiFramebuffer               || STRING  || Name of the specific ATI framebuffer
 DisableNvidaInjection        || BOOLEAN || De/activate Nvidia GFX device property injection
 DisableIntelInjection        || BOOLEAN || De/activate Intel GFX device property injection
 DisableVoodooHda             || BOOLEAN || Disables loading VoodooHDA from firmware
 EnableVoodooHdaInternalSpdif || BOOLEAN || Enable/Disable onboard S/PDIF header when using VoodooHDA from firmware
 DisableBootEntriesFilter     || BOOLEAN || Disables filtering of firmware generated boot entries
 AAPL,snb_platform_id         || INTEGER ||
 AAPL,ig-platform-id          || INTEGER ||
 BootEntryTemplate            || STRING  || $label $guid
 DarwinDiskTemplate           || STRING  || $label $platform $major $minor $build
 DarwinRecoveryDiskTemplate   || STRING  || $label $platform $major $minor $build

Examples:
=========

  !! Note on VoodooHDA, it covers ONLY the onboard codec and is enabled for the moment only for ALC892/ALC1150 !!
  !! For discrete graphics HDMI/DP audio AppleHDA is used instead. Those who use internal GPU (IGPU) only will !!
  !! have to disable VoodooHda and use AppleHda for HDMI/DP audio                                              !!

  To Disable loading VoodooHda.kext from Firmware

    sudo nvram 1F8E0C02-58A9-4E34-AE22-2B63745FA101:DisableVoodooHda=%01

  To Enable loading VoodooHda.kext from Firmware

    sudo nvram 1F8E0C02-58A9-4E34-AE22-2B63745FA101:DisableVoodooHda=%00


 Changing ATI Framebuffers
=========================

  sudo nvram 1F8E0C02-58A9-4E34-AE22-2B63745FA101:AtiFramebuffer=Futomaki

 Or based on VendorSubsystemId

  sudo nvram 1F8E0C02-58A9-4E34-AE22-2B63745FA101:AtiFramebuffer10029440=Futomaki

 Or based on pci addressing

  sudo nvram 1F8E0C02-58A9-4E34-AE22-2B63745FA101:AtiFramebuffer00.01.00=Futomaki

Changing AAPL,ig-platform-id
============================

  sudo nvram 1F8E0C02-58A9-4E34-AE22-2B63745FA101:AAPL,ig-platform-id=0x01620005

Changing AcpiLoader Mode
============================

  Add The Following Values Together For Default Acpi Loader Mode

  ACPI_LOADER_MODE_DISABLE        0x00000000
  ACPI_LOADER_MODE_ENABLE         0x00000001
  ACPI_LOADER_MODE_DUMP           0x00000002
  ACPI_LOADER_MODE_WINDOWS        0x00000008
  ACPI_LOADER_MODE_UPDATE_LEGACY  0x00000040

  Default Value : ACPI_LOADER_MODE_ENABLE | ACPI_LOADER_MODE_DARWIN | ACPI_LOADER_MODE_UPDATE_LEGACY = 0x45

  To Change

  sudo nvram 1F8E0C02-58A9-4E34-AE22-2B63745FA101:AcpiLoaderMode=0x45

Note: They can also be controlled by using Defaults.plist placed on boot hard-drive efi system partition and path is /EFI/OZ/Defaults.plist, see bellow for example.

WARNING! Defaults.plist will override the one found in firmware and values are used only if variables are not already added.
For example if you want to set BiosVersion using Defaults.plist and was already set by Defaults from Firmware, you will need
to do a 4 finger NVRAM reset or delete the BiosVersion variable from shell, for the new one to be used.

Default Settings Example of Modifications on Defaults.plist
===========================================================

// If AcpiLoaderMode NEEDS to be changed, change second line, put desired value, then add both line in Defaults.plist
<key>AcpiLoaderMode</key>
<integer>0x45</integer>

// If UserInterface NEEDS to be enabled on every boot, change second line and set to true, then add both line in Defaults.plist
<key>UserInterface</key>
<false/>

// If TimeOut NEEDS to be changed, change second line and put desired value in seconds, then add both line in Defaults.plist
<key>TimeOut</key>
<integer>5</integer>

// If DisableAtiInjection NEEDS to be enabled, change second line bellow and set to true, then add both line in Defaults.plist
<key>DisableAtiInjection</key>
<false/>

// If AtiFramebuffer NEEDS to be changed, modify second line bellow and set to correct one, then add both line in Defaults.plist
<key>AtiFramebuffer</key>
<string>ReplaceMe</string>
!! WARNING DisableAtiInjection needs to be set to false to function !!

// If DisableNvidaInjection NEEDS to be enabled, change second line bellow and set to true, then add both line in Defaults.plist
<key>DisableNvidaInjection</key>
<false/>

// If DisableIntelInjection NEEDS to be enabled, change second line bellow and set to true, then add both line in Defaults.plist
<key>DisableIntelInjection</key>
<false/>

// If AAPL,snb_platform_id NEEDS to be changed, change second line bellow and set to correct one, then add both line in Defaults.plist
<key>AAPL,snb_platform_id</key>
<integer>0x00030010</integer>
!! WARNING DisableIntelInjection needs to be set to false to function !!

// If AAPL,ig-platform-id NEEDS to be changed, modify second line bellow and set to correct one, then add both line in Defaults.plist
<key>AAPL,ig-platform-id</key>
<integer>0x0166000A</integer>
!! WARNING DisableIntelInjection needs to be set to false to function !!

// If DisableVoodooHda NEEDS to be enabled, change second line bellow and set to true, then add both line in Defaults.plist
<key>DisableVoodooHda</key>
<false/>

// If EnableVoodooHdaInternalSpdif NEEDS to be enabled, change second line bellow and set to true, then add both line in Defaults.plist
<key>EnableVoodooHdaInternalSpdif</key>
<false/>
!! WARNING DisableVoodooHda needs to be set to false to function !!

// If DisableBootEntriesFilter NEEDS to be enabled, change second line bellow and set to true, then add both line in Defaults.plist
<key>DisableBootEntriesFilter</key>
<false/>