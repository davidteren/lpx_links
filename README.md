# lpx_links

lpx_links is a utilty to get the direct download links for the additional sample/sound content for Logic Pro X.

  - It gets the most current links
  - Creates a text file with all the links in them.
  - Importing the links file into a download manager like the DownThemAll addon for FireFox should work well.
  
  Includes Mandatory only list. Thanks to _Matteo Ceruti_ aka [Matatata](https://github.com/matatata) for the idea.
 
### Version

0.0.7 - added mandatory file list & refactor of code.

0.0.6 - added version detection. Any version of Logic Pro X should work now.

### Usage

Simply open the terminal and paste the command below.

```sh
 cd ~/Downloads; mkdir -p lpx_links/app ; cd lpx_links/app ; curl -#L https://goo.gl/nUrpPi | tar -xzv --strip-components 1 ; ./lpx_links.rb

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
