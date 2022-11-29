haxe -hl hxd.fmt.pak.Build.hl -lib heaps -main hxd.fmt.pak.Build
hl hxd.fmt.pak.Build.hl -res "assets" -out "assets" -check-ogg -exclude-path "images"
copy assets.pak C:\Users\Nick\Documents\Projects\Haxe\ThreeStarJam\export\js