# dropbox-ignore

## A macOS zsh shell script (actually two) to ignore (or un-ignore) a file/folder in Dropbox

Quoting the relevant (macOS) portion of [How to set a Dropbox file to be ignored](https://help.dropbox.com/files-folders/restore-delete/ignored-files) from Dropbox Help:

> 1. Open the Terminal application on your computer
>
> 2. Type
>
> 		`xattr -w com.dropbox.ignored 1`
>
> 3.	Type the location of the file next to that.
>
> 	- You can also drag and drop the file or folder that you want to ignore from your file browser into the Terminal and it will populate with the location of the file.
>
> 	- It should look something like this:
>
> 		`xattr -w com.dropbox.ignored 1 /Users/yourname/Dropbox/YourFileName.pdf`
>
> 4. Press return on your keyboard.
>
> The icon beside your file will change to a _gray minus sign_ which indicates that the file is ignored.

Note that as of 2020-02-26, that same page also says:

> This feature is currently in beta and not available to all Dropbox users. It will be rolled out to more users in the future.

So this script _may_ not work for you, but I’m one of the lucky ones who have access to this feature, and I wanted an easy way to use it.
