# MATLAB genpath2

A function to ignore specified subfolders when executing `genpath`

## Description

MATLAB's `genpath(folderName)` generates a character array containg the path to `folderName` and its subfolders. `genpath` will exclude folders starting with `@`, `+`, `private`, and `resource`, but it does not allow users to specify other patterns (e.g., `.git` and `.svn`) to exclude.

When `addpath(genpath())` is used, the MATLAB search path will include unecessary folders. Unlike other similar functions on File Exchange, `genpath2` is simply wrapper for `genpath` that executes it and then removes folders from its output matching a specified pattern.

## Installation

From GitBash, clone this project

```bash
git clone git@github.com:ssordopalacios/matlab-genpath2.git
```

From MATLAB, add it to your path

```matlab
addpath('matlab-genpath2');
```

## Usage

`genpath2(folderName)` returns an array identical to `genpath(folderName)`

`genpath2(folderName, '.git')` returns a array without folders starting with `.git`

`genpath2(folderName, {'.git', '.svn'})` returns a vector without folders starting with `.git` and `.svn`

## Contributing
* [MATLAB File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/72791-genpath2)
* [GitHub](https://github.com/ssordopalacios/matlab-genpath2)

## Authors
* Santiago I. Sordo-Palacios, 2019
