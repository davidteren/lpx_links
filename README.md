
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
  
To download I recomend using *aria2*   
- Simply download & install - [aria2 ver1.33.0 installer](https://github.com/aria2/aria2/releases/download/release-1.33.0/aria2-1.33.0-osx-darwin.dmg)  


- Then in the Terminal  
   
```sh  
# To only download the mandatory files (32)
aria2c -c -i ~/Desktop/lpx_download_links/mandatory_download_links.txt -d ~/Downloads/logic_content

# To download all the packages
aria2c -c -i ~/Desktop/lpx_download_links/all_download_links.txt -d ~/Downloads/logic_content 
```

     
  
- -c tells arai2 to continue/resume downloads.  
 - -i is the path to the file with list of downloads.  
 - -d is the path to where you want the downloaded files.   
     
  ![aria2 download example](https://github.com/davidteren/lpx_links/blob/master/images/aria2_example.png?raw=true)
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
