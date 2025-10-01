# lpx_links

[![Ruby CI](https://github.com/davidteren/lpx_links/actions/workflows/ruby-ci.yml/badge.svg)](https://github.com/davidteren/lpx_links/actions/workflows/ruby-ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Ruby utility to get direct download links for additional sample/sound content for Logic Pro X and MainStage.

## Features

- 🔗 **Direct Download Links** - Extracts current download URLs from Apple's content servers
- 📝 **Text File Generation** - Creates organized text files with all download links
- 🎯 **Mandatory vs. All** - Separate lists for essential packages vs. complete library
- 🎹 **Multi-App Support** - Works with both Logic Pro X and MainStage
- 📦 **Download Manager Ready** - Compatible with aria2, DownThemAll, and other download managers
- 🧪 **Well Tested** - Comprehensive test suite with RSpec
- 🔍 **Linted Code** - RuboCop-compliant codebase

> **Note**: Mandatory package list feature thanks to _Matteo Ceruti_ aka [Matatata](https://github.com/matatata) for the idea.

## Version

**Current Version**: 0.0.10

See [CHANGELOG.md](CHANGELOG.md) for detailed version history and release notes.

## Usage

Simply open the terminal and paste one of the commands from below. 

For Logic Pro X use the following command:
```sh  
 cd ~/Downloads; mkdir -p lpx_links/app ; cd lpx_links/app ; curl -#L https://goo.gl/nUrpPi | tar -xzv --strip-components 1 ; ./lpx_links.rb -n Logic
  
```

For Mainstage use the following command:
```sh  
 cd ~/Downloads; mkdir -p lpx_links/app ; cd lpx_links/app ; curl -#L https://goo.gl/nUrpPi | tar -xzv --strip-components 1 ; ./lpx_links.rb -n Mainstage
  
```  
  
To download I recommend using *aria2*
- Download & install - [aria2 ver1.33.0 installer](https://github.com/aria2/aria2/releases/download/release-1.33.0/aria2-1.33.0-osx-darwin.dmg)  

- Then in the Terminal  

To only download the mandatory files (32)
```shell  

aria2c -c --auto-file-renaming=false -i ~/Desktop/lpx_download_links/mandatory_download_links.txt -d ~/Downloads/logic_content
```
To download all the packages
```shell
aria2c -c --auto-file-renaming=false -i ~/Desktop/lpx_download_links/all_download_links.txt -d ~/Downloads/logic_content
```

 - -c tells aria2 to continue/resume downloads
 - --auto-file-renaming=false ensures that files will never be redownloaded if they already exist in the target directory
 - -i is the path to the file with list of downloads
 - -d is the path to where you want the downloaded files
     
  ![aria2 download example](https://github.com/davidteren/lpx_links/blob/master/images/aria2_example.png?raw=true)
### Install All  
  
To install all the downloaded packages use the following command:  

```sh
 sudo ~/Downloads/lpx_links/install.sh ~/Downloads/logic_content 
```  

> Note: The install script expects a directory containing `.pkg` files as its argument, not a text file with download links.

## Development

### Contributing

Want to contribute? Great! Here's how:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run the local test script to validate your changes:
   ```bash
   ./test_local_workflow.sh
   ```
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to your branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Testing

This project includes a comprehensive local testing script that validates:
- RuboCop linting (0 offenses required)
- RSpec test suite (all tests must pass)
- End-to-end workflow simulation

See [TEST_WORKFLOW.md](TEST_WORKFLOW.md) for detailed testing documentation.

### Code Quality

- **Linting**: RuboCop with custom configuration (`.rubocop.yml`)
- **Testing**: RSpec with SimpleCov for coverage tracking
- **CI/CD**: GitHub Actions runs linting and tests on all PRs
  
## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

For copyright holder information and license history, see the [COPYRIGHT](COPYRIGHT) file.

### Why MIT?

This utility is licensed under MIT (changed from GPL-3.0 in October 2025) because:
- **Simple utility tool** - Straightforward download link generator
- **Maximum compatibility** - Can be used in any context without licensing concerns
- **Community standard** - Aligns with most Ruby gems
- **User-friendly** - No restrictions on commercial or private use
