# lpx_links

lpx_links is a utilty to get the direct download links for the additional sample/sound content for Logic Pro X.


  - It gets the most current links
  - Creates a text file with all the links in them.
  - Importing the links file into a download manager like the DownThemAll addon for FireFox should work well.

### Version
0.0.6 - added version detection. Any version of Logic Pro X should work now.
This is the final version of lpx_links and will hopefully be replaced by LogicLinks.

LogicLinks will feature:
* Download Manager
* Content Installer (Install to User Defined Location)
* Content Re-locator (Move content to another drive - with auto linking)
* Content Re-linker (Attempts to fix broken)

### Usage

Simply open the terminal and paste the command below.

```sh
 cd ~/Downloads; mkdir -p lpx_links/app ; cd lpx_links/app ; curl -#L https://github.com/davidteren/lpx_links/tarball/master | tar -xzv --strip-components 1 ; ./lpx_links.rb

```

### Install All

To install all the downloaded packages use the following command:

```sh
 sudo ./download_install.sh ../download_links/links.txt ../LogicX
```

### Development

Want to contribute? Fork and let me know.

License
----

GNU General Public License, version 3 (GPL-3.0)
(http://opensource.org/licenses/GPL-3.0)
