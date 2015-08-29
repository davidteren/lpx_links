# lpx_links

lpx_links is a utilty to get the direct download links for the additional sample/sound content for Logic Pro X.


  - It gets the most current links for version 10.2.0
  - Creates a text file with all the links in them.
  - Importing the links file into a download manager like the DownThemAll addon for FireFox should work well.

> Please note that if you do not have version 10.2.0
> installed the utility will most likely fail.


### Version
0.0.5 - final version
This is the fianl version of lpx_links as I am working on
LogicLinks and this will replace lpx_links.

LogicLinks will feature:
* Download Manager
* Content Installer (Install to User Defined Location)
* Content Re-locator (Move content to another drive - with auto linking)
* Content Re-linker (Attempts to fixes the links should they something go

### Usage

Simply open the terminal and paste the command below.

```sh
 cd ~/Downloads; mkdir -p lpx_links/app ; cd lpx_links/app ; curl -#L https://github.com/davidteren/lpx_links/tarball/master | tar -xzv --strip-components 1 ; ./lpx_links.rb

```

### Development

Want to contribute? Fork and let me know.

License
----

GNU General Public License, version 3 (GPL-3.0)
(http://opensource.org/licenses/GPL-3.0)
