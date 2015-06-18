# lpx_links

lpx_links is a utilty to get the direct download links for the additional sample/sound content for Logic Pro X.


  - It gets the most current links for version 10.1.1
  - Creates a text file with all the links in them.
  - Importing the links file into a download manager like the DownThemAll addon for FireFox should work well.
  
> Please note that if you do not have version 10.1.1 
> installed the utility will most likely fail.


### Version
0.0.1


### Usage

Simply open the terminal and paste the command below. Leave out the dollar sign ($).

```sh
$ cd ~/Downloads; mkdir lpx_links ; cd lpx_links ; curl -#L https://github.com/DavidTeren/lpx_links/tarball/master | tar -xzv --strip-components 1 ; ./lpx_links.rb

```

### Development

Want to contribute? Fork and let me know.

License
----

GNU General Public License, version 3 (GPL-3.0)
(http://opensource.org/licenses/GPL-3.0)
