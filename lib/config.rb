TMPDIR  = '/tmp'
LPX     = '/Applications/Logic Pro X.app'
RSC     = '/Contents/Resources/logicpro1020.plist'
URL     = 'http://audiocontentdownload.apple.com/lp10_ms3_content_2015/'
ROOT  	= File.dirname(__FILE__)
p ROOT
PARENT	= File.join(ROOT, '..', '..')
PLIST   = File.join(LPX, RSC)
JSN     = File.join(TMPDIR, 'content.json')
DWN_LNK = File.join(PARENT, 'download_links')
DWN_LST = File.join(DWN_LNK, 'links.txt')
INSTALS = File.join(PARENT, 'installers')
PKG     = 'Packages'
DLN     = 'DownloadName'
@line   = []