## Import a genepop file as a `PopObj`

```julia
genepop(infile; kwargs...)

# Example
julia> b = genepop("/data/wasp_hive.gen", digits = 3, popsep = "POP")
```

??? warning "Windows users"
    make sure to change your backslashes "\" to forward slashes "/" 

### arguments

- `#!julila infile::String` : path to genepop file, in quotes

### keyword Arguments

- `digits::Integer`: number of digits denoting each allele (default: `3`)
- `popsep::String` : word that separates populations in `infile` (default: "POP")
- `diploid::Bool`  : whether samples are diploid for parsing optimizations (default: `true`)
- `silent::Bool`   : whether to print file information during import (default: `true`)

!!! info ""
    By default, the file reader will assign numbers as population ID's (as Strings) in order of appearance in the genepop file. Use the `populations!` function to rename these with your own population ID's.

## Format

Files must follow standard Genepop formatting:

- First line is a comment (and skipped)
- Loci are listed after first line as one-per-line without commas or in single comma-separated row
- A line with a particular and consistent keyword must delimit populations
- **Must** be the same word each time and not a unique population name
- File is **tab** delimited or **space** delimited, but not both

### formatting examples

```tab="loci stacked vertically"
Wasp populations in New York
Locus1
Locus2
Locus3
POP
Oneida_01,	250230	564568	110100
Oneida_02,	252238	568558	100120
Oneida_03,	254230	564558	090100
POP
Newcomb_01,	254230	564558	080100
Newcomb_02,	000230	564558	090080
Newcomb_03,	254230	000000	090100
Newcomb_04,	254230	564000	090120
```

```tab="loci stacked horizontally"
Wasp populations in New York
Locus1,Locus2,Locus3
POP
Oneida_01,	250230	564568	110100
Oneida_02,	252238	568558	100120
Oneida_03,	254230	564558	090100
POP
Newcomb_01,	254230	564558	080100
Newcomb_02,	000230	564558	090080
Newcomb_03,	254230	000000	090100
Newcomb_04,	254230	564000	090120
```

-----------------

## Acknowledgements

The original implementations of this parser were written using only Base Julia, and while the speed was fantastic, the memory footprint involved seemed unusually high (~650mb RAM to parse `gulfsharks`, which is only 3.2mb in size). However, thanks to the efforts of the [CSV.jl](https://github.com/JuliaData/CSV.jl) team, we leverage that package to do much of the heavy lifting, in a multicore way, and all the while preserving the speed and reducing the memory footprint quite a bit!
