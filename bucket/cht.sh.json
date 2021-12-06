{
    "homepage": "https://cheat.sh/",
    "license": "MIT",
    "version": "0.0.4",
    "suggest": {
		"git": "git"
	},
    "url": "https://cht.sh/%3Acht.sh",
    "hash": "d3135e42b800ff2e7aac44d4dfe500f0f4e2c7eb00a1c2191b0dc8b28431f155",
    "installer": {
        "script": [
            "Rename-Item \"$dir\\%3Acht.sh\" \"cht.sh\"",
            "Set-Content \"$dir\\cht.bat\" \"@for /f %%i in ('scoop prefix git') do @%%i\\bin\\bash.exe %~dp0\\cht.sh %*\" -Encoding ASCII"
        ]
    },
    "bin": "cht.bat",
    "checkver": {
        "url": "https://cht.sh/%3Acht.sh",
        "regex": "__CHTSH_VERSION=([\\d.]+)"
    },
    "autoupdate": {
        "url": "https://cht.sh/%3Acht.sh"
    }
}
