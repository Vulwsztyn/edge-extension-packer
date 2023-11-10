# EdgeExtensionPacker

## Usage

### Requirements

`brew install elixir`

### How to use?

Download the `edge_extension_packer` from [releases](https://github.com/Vulwsztyn/edge-extension-packer/releases) 
e.g. with `wget` and put it into one of dirs in your `PATH` e.g. `/usr/local/bin`.

### "Normal"

```
edge_extension_packer 
    --name <your_extension_name> 
    --desc <your_extension_description> 
    --author <your_name> 
    --vendor <vendor_name> 
    --vendor_desc <vendor_description> 
    --version <version> 
    --files <comma_separated_files_you_want_zipped> 
    --files_to_load <comma_separated_subset_of_files_you_want_preloaded> 
    --path <path_to_dir_with files_to_be_zipped> # if other than cwd
```

### bump
In order not to repeat yourself you can use `bump` that will increment the patch in version and create a new zip.

Why? You might change one line of code, build your Web Component, and want to quickly create a new zip.


```
edge_extension_packer bump 
    --zip_filename <zip_filename> # optional - if not given the progrma will use the newset zip with name mathing `abc_x_y_z.zip`
    --path <path_to_dir_with files_to_be_zipped> # if other than cwd
```

All the info will be taken from `Manifest.json` and files will be the same as in the zip.

If you want to change anything while 

### Aliases

```
          n: :name,
          d: :desc,
          a: :author,
          V: :vendor,
          v: :version,
          D: :vendor_desc,
          f: :files,
          F: :files_to_load,
          z: :zip_filename,
          p: :path

```

## Local run

`mix deps.get`

create dir `dist` put some dummy files (e.g. `index.js` & `style.css`) there and run

` mix escript.build && ./edge_extension_packer -n my_pkg_name -d my_pkg_desc -a me -V my_vendor -D my_vendor_desc -f index.js,style.css -F index.js,style.css -p dist -v 1.0.1`

### Local debugging with pry



`iex -S mix run`

`EdgeExtensionPacker.CLI.main(String.split("-n test -d asd -a Artur -v Arturro -v 1.2.6 -f index.js -F index.js -V vendorro -D vendesc", " "))`
