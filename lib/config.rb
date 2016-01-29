LPX     = '/Applications/Logic Pro X.app'
VERSION = `mdls -name kMDItemVersion '/Applications/Logic Pro X.app/'`
              .gsub('kMDItemVersion = "', '')
              .delete('"')
              .delete('.').chomp
RSC     = "/Contents/Resources/logicpro#{VERSION}.plist"
URL     = 'http://audiocontentdownload.apple.com/lp10_ms3_content_2016/'
ROOT		= File.dirname(__FILE__)
TMPDIR 	= File.join(ROOT, '/tmp')
PARENT	= File.expand_path('..', Dir.pwd)
PLIST   = File.join(LPX, RSC)
JSN     = File.join(TMPDIR, 'content.json')
DWN_LNK = File.join(PARENT, 'download_links')
DWN_LST = File.join(DWN_LNK, 'links.txt')
JSN_DIR	= File.join(DWN_LNK, 'json')
JSN_FLE	= File.join(JSN_DIR, "logicpro#{VERSION}_content.json")
INSTALL = File.join(PARENT, 'installers')
REPORT	= File.join(DWN_LNK, 'report.txt')
CAT			= %w(AppleLoops JamPacks GarageBand Instruments Alchemy IRs DrumKits)
PKG 		= 'Packages'
PKG_ID	= 'PackageID'
DLN			= 'DownloadName'
C_ALCH	=	'ContainsAlchemyFiles'
