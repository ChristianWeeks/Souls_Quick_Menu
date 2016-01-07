# Souls_Quick_Menu
Dark Souls inspired cyclical quick menu mod for Skyrim. Reduces trips to the quick menu by creating
queues of items for your left hand, right hand and shout slots, as well as an additional potion slot.  Cycle through them with a hotkey for quick, real time access.

This mod requires SkyUI and SKSE to work.

SETUP:
Copy and paste the scripts and interface folder into your Skyrim data folder.  The .psc files can be edited and compiled
in place without trouble.  Editing the .swf file requires a few more steps because it is dependent on SkyUI files, and I
will not upload SkyUI source code into this repository.

EDITING FLASH FILES:
The flash files are dependent upon the SkyUI library.  To edit and properly compile / publish them:

1. Download the SkyUI git repository.
2. The src file in this directory reflects the file hierarchy of the original SkyUI git repository.  ArrowCountWidget is
given as a basic example on how to create a widget, so it doesn't really matter in the SkyUI repository.  Copy and paste
the arrowcount flash file and arrowCountWidget actionscript file into their respective places in the skyUI repository.
3. You may now open these files and should be able to compile them without trouble.
4. Make sure the published file goes to the proper directory (where your active .swf file is in your Skyrim/Data/interface directory).

TODO:

Look at the issues tab of this repository to see what needs to be done. 

